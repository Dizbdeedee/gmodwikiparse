package generators.desc;

import data.WikiDB;
import tink.sql.Types;
using tink.CoreApi;

interface DescriptionPublisher {
	function publish(conn:WikiDB,descNodes:UnresolvedDescription):Promise<Id<DescriptionStorage>>;
}

@:await
class DescriptionPublisherDef implements DescriptionPublisher {
	
	public function new() {}

    var dbConnection:WikiDB;

	static var lastPublishID:Int = Std.int(Math.NEGATIVE_INFINITY);

    public function publish(conn:data.WikiDB,descNodes:UnresolvedDescription):Promise<Id<DescriptionStorage>> {
		dbConnection = conn;
		if (descNodes.length < 1) return Promise.reject(new Error("Need at least one descNode to publish..."));
		return publishDescToDB(descNodes)
		.next(descID -> validateInsertion(descNodes,descID)
		.swap(descID));
	}

	function validateInsertion(arr:UnresolvedDescription,id:Id<DescriptionStorage>):Promise<Bool> {
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
		.next((descItemss) -> {
			var verify = descItemss.length == arr.length;
			for (i in 0...descItemss.length) {
				var sql = descItemss[i];
				var presql = arr[i];
				verify = sql.textValue == presql.textValue
				&& sql.type == presql.type
				&& verify;
				if (!verify) {
					// trace('id : ${descItems[i].id == arr[i].id}');
					// trace('textValue : ${descITems}')
					trace('Unverified id $id');
					trace('textValue : ${sql.textValue} ${presql.textValue} ${sql.textValue == presql.textValue}');
					trace('type : ${sql.type} ${presql.type} ${sql.type == presql.type}');
					throw "Failed to validate insertion of description.";
				}
			}
			return verify;
		});
	}

	

	function giveDescItemsIDs(arr:Array<DescItem>,maxIndex:Int):Promise<Array<Id<DescItem>>> {
		lastPublishID = Std.int(Math.max(maxIndex + 1,lastPublishID + 1)); //TODO, why does the maxIndex we get collide sometimes? trace futures how to resolve cleanly?
		var promises:Array<Promise<Id<DescItem>>> = [];
		for (desc in arr) {
			promises.push(Promise.lazy(() -> dbConnection.DescItem.insertOne({
				id : lastPublishID++,
				type : desc.type,
				textValue : desc.textValue
			})));	
		}
		return Promise.inSequence(promises);
	}

	function getMaxID() {
		return dbConnection.DescItem.select({
			id : tink.sql.expr.Functions.max(DescItem.id)
		}).first().next((ob) -> ob.id);
	}

	@:async function assignFirstDescriptionStorage(initial:Id<DescItem>) {
		var autoDescStoreID = @:await dbConnection.DescriptionStorage.insertOne({
			id : -1,
			descItem : initial
		});
		@:await dbConnection.DescriptionStorage.update(
			(ds) -> [ds.id.set(autoDescStoreID)],{
				where : (ds) -> ds.id == -1
			}).eager();
		return autoDescStoreID;
	}

	@:async function createDescriptionStorages(descItemIDSS:Array<Id<DescItem>>) {
		var autoID:Id<DescriptionStorage> = @:await assignFirstDescriptionStorage(descItemIDSS[0]);
		if (descItemIDSS.length > 1) {
			var process = descItemIDSS.slice(1).map((descItemID) -> {
				id : autoID,
				descItem : descItemID
			});
			@:await dbConnection.DescriptionStorage.insertMany(process).eager();
		}
		return autoID;
	}

	function publishDescToDB(arr:Array<DescItem>):Promise<Id<DescriptionStorage>> {
		return getMaxID()
		.next((maxID) -> giveDescItemsIDs(arr,maxID)
		.next((descItemIDS) -> createDescriptionStorages(descItemIDS)));
		// .next((idDescStorage) -> idDescStorage)));
	}
}