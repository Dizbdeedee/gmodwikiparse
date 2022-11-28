package publishers;

interface DescriptionPublisher {
	function publish(descNodes:Array<DescItem>):Promise<Id<DescriptionStorage>>;
}

@:await
class DescriptionPublisherDef implements DescriptionPublisher {
	
	public function new(conn:WikiDB) {
		dbConnection = conn;
	}

    final dbConnection:WikiDB;

    public function publish(descNodes:Array<DescItem>):Promise<Id<DescriptionStorage>> {
		if (descNodes.length < 1) return Promise.reject(new Error("Need at least one descNode to publish..."));
		return publishDescToDB(descNodes)
		.next(descID -> validateInsertion(descNodes,descID)
			.next(_ -> descID)
		);
	}

	function validateInsertion(arr:Array<DescItem>,id:Id<DescriptionStorage>):Promise<Bool> {
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
					trace('textValue : ${sql.textValue} ${presql.textValue} ${sql.textValue == presql.textValue}');
					trace('type : ${sql.type} ${presql.type} ${sql.type == presql.type}');
					throw "DUMB";
				}
			}
			return verify;
		});
	}

	function giveDescItemsIDs(arr:Array<DescItem>,maxIndex:Int):Promise<Array<Id<DescItem>>> {
		var nextID = maxIndex + 1;
		var insertionDescriptions = arr.map((desc) -> {
			// untyped desc.id = nextID++;
			return dbConnection.DescItem.insertOne({
				id : nextID++,
				type : desc.type,
				textValue : desc.textValue
			});
		});
		return Promise.inSequence(insertionDescriptions);
	}

	@:async function getMaxID() {
		var result = @:await dbConnection.DescItem.select({
			id : tink.sql.expr.Functions.max(DescItem.id)
		}).first();
		return result.id;
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

	@:async function publishDescToDB(arr:Array<DescItem>) {
		var maxID = @:await getMaxID();
		var descItemIDS:Array<Id<DescItem>> = @:await giveDescItemsIDs(arr,maxID);
		var idDescriptionStorage = @:await createDescriptionStorages(descItemIDS);
		return idDescriptionStorage;
	}
}