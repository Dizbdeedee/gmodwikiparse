package generators.desc;

import data.WikiDB;
import tink.sql.Types;
using tink.CoreApi;

interface DescriptionPublisher {
    function publish(conn:WikiDB,descNodes:UnresolvedDescription):Promise<Id<DescriptionStorage>>;
}

class DescriptionPublisherDef implements DescriptionPublisher {

    public function new() {}

    var dbConnection:WikiDB;

    static var lastPublishID:Int = Std.int(Math.NEGATIVE_INFINITY);

    public function publish(conn:data.WikiDB,descNodes:UnresolvedDescription):Promise<Id<DescriptionStorage>> {
        dbConnection = conn;
        if (descNodes.length < 1) return Promise.reject(new Error("Need at least one descNode to publish..."));
        return publishDescToDB(descNodes)
            .next(descID -> {return validateInsertion(descNodes,descID).swap(descID);}
        );
    }

    function validateInsertion(unresolvedDescArr:UnresolvedDescription,id:Id<DescriptionStorage>):Promise<Bool> {
        return dbConnection.DescItem
        .leftJoin(dbConnection.DescriptionStorage)
        .on(DescriptionStorage.descItem == DescItem.id)
        .select({
            id : DescItem.id,
            textValue : DescItem.textValue,
            type : DescItem.type
        })
        .where(DescriptionStorage.id == id)
        .orderBy((fields) -> [{field : fields.DescItem.id, order : Asc}])
        .all()
        .next((descItemsArr) -> {
            var verify = descItemsArr.length == unresolvedDescArr.length;
            if (!verify) {
                trace(descItemsArr);
                trace(unresolvedDescArr);
                throw "Wrong length";
            }
            for (i in 0...descItemsArr.length) {
                var sql = descItemsArr[i];
                var presql = unresolvedDescArr[i];
                verify = sql.textValue == presql.textValue
                && sql.type == presql.type
                && verify;
                if (!verify) {
                    // trace('id : ${descItems[i].id == arr[i].id}');
                    // trace('textValue : ${descITems}')
                    trace(lastPublishID);
                    trace('Unverified id $id');
                    trace('textValue : ${sql.textValue} ${presql.textValue} ${sql.textValue == presql.textValue}');
                    trace('type : ${sql.type} ${presql.type} ${sql.type == presql.type}');
                    trace(presql);
                    trace(descItemsArr);
                    throw "Failed to validate insertion of description.";
                }
            }
            return verify;
        });
    }

    function giveDescItemsIDs(descItemsArr:Array<DescItem>,maxIndex:Int):Promise<Array<Id<DescItem>>> {
        lastPublishID = Std.int(Math.max(maxIndex + 1,lastPublishID + 1)); //TODO, why does the maxIndex we get collide sometimes? trace futures how to resolve cleanly?
        var promises:Array<Promise<Id<DescItem>>> = [];
        for (desc in descItemsArr) {
            promises.push(Promise.lazy(() -> {
                var what = lastPublishID;
                return dbConnection.DescItem.insertOne({
                    id : lastPublishID++,
                    type : desc.type,
                    textValue : desc.textValue
                }).next(x -> {return Promise.resolve(x);});
            }));
        }
        return Promise.inSequence(promises);
    }

    function getMaxID() {
        return dbConnection.DescItem.select({
            id : tink.sql.expr.Functions.max(DescItem.id)
        }).first().next((ob) -> ob.id);
    }

    function assignFirstDescriptionStorage(initial:Id<DescItem>):Promise<Id<DescriptionStorage>> {
        return
        dbConnection.DescriptionStorage.insertOne({
            id : -1,
            descItem : initial
        })
        .next((autoDescStoreID) ->
        dbConnection.DescriptionStorage.update(
            (ds) -> [ds.id.set(autoDescStoreID)],{
            where : (ds) -> ds.descItem == initial
        })
        .swap(autoDescStoreID));
    }

    function createDescriptionStorages(descItemIDSS:Array<Id<DescItem>>) {
        return
        assignFirstDescriptionStorage(descItemIDSS[0])
        .next((autoDescStoreID) -> {
        return if (descItemIDSS.length > 1) {
            var process = descItemIDSS.slice(1).map((descItemID) -> {
                id : autoDescStoreID,
                descItem : descItemID
            });
            dbConnection.DescriptionStorage.insertMany(process).swap(autoDescStoreID);
        } else {
            Promise.resolve(autoDescStoreID);
        }
        });
    }

    function publishDescToDB(descItemsArr:Array<DescItem>):Promise<Id<DescriptionStorage>> {
        return getMaxID()
        .next((maxID) -> giveDescItemsIDs(descItemsArr,maxID)
        .next((descItemIDS) -> createDescriptionStorages(descItemIDS)));
        // .next((idDescStorage) -> idDescStorage)));
    }
}