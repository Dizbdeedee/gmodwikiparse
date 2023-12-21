package generators.library;

import generators.desc.UnresolvedDescription;
import generators.desc.DescriptionPublisher;
import generators.desc.DescriptionParser;
import ParseUtil;

using tink.CoreApi;

interface LibraryResolver {
	function parse(url:String, jq:CheerioAPI):UnresolvedLibrary;
	function publish(conn:data.WikiDB, page:UnresolvedLibrary):Promise<Noise>;
}

typedef UnresolvedLibrary = {
	url:String,
	urls:Array<UnresolvedLibraryURL>,
	name:String,
	isDeprecated:Bool,
	fields:Array<UnresolvedLibraryField>,
	description:UnresolvedDescription
}

typedef UnresolvedLibraryField = {
	fieldNo:Int,
	type:String,
	typeURL:String,
	description:UnresolvedDescription,
	name:String
}

typedef UnresolvedLibraryURL = {
	urlNo:Int,
	url:String
}

class LibraryResolverDef implements LibraryResolver {
	final descParser:DescriptionParser;

	final descPublisher:DescriptionPublisher;

	public function new(_descParser, _descPublisher) {
		descParser = _descParser;
		descPublisher = _descPublisher;
	}

	public function parse(url:String, jq:CheerioAPI):UnresolvedLibrary {
		var name = getPageName(url);
		var pageContent = getCheer(jq, "div.type > div.section");
		var desc = descParser.parseDescNode(pageContent, jq);
		var urlsNode = getCheer(jq, "div.members > h1:contains('Methods') + div.section");
		var fieldsNodeOpt = getOptCheer(jq, "div.members > h1:contains('Fields') + div.section");
		var id = 0;
		var urls:Array<UnresolvedLibraryURL> = mapChildren(urlsNode, jq, (el) -> parseURL(el, jq, id++));
		id = 0;
		var fields:Array<UnresolvedLibraryField> = switch (fieldsNodeOpt) {
			case Some(fieldsNode):
				mapChildren(fieldsNode, jq, (el) -> parseField(el, jq, id++));
			case None:
				[];
		}
		var isDeprecated = isPageDeprecated(jq);
		return {
			description: desc,
			name: name,
			urls: urls,
			url: trimFullURL(url),
			isDeprecated: isDeprecated,
			fields: fields
		}
	}

	function parseURL(node:CheerioD, jq:CheerioAPI, no:Int):UnresolvedLibraryURL {
		var url = getChildCheer(node, "a.subject").attr("href");
		return {
			urlNo: no,
			url: url
		}
	}

	function parseField(node:CheerioD, jq:CheerioAPI, no:Int):UnresolvedLibraryField {
		var type = getChildCheer(node, "a.link-page").text();
		var typeURL = getChildCheer(node, "a.link-page").attr("href");
		var descNode = getChildCheer(node, "div.summary");
		var desc = descParser.parseDescNode(descNode, jq);
		var name = getChildCheer(node, "a.subject").text();
		return {
			typeURL: typeURL,
			type: type,
			description: desc,
			name: name,
			fieldNo: no
		}
	}

	public function publish(conn:data.WikiDB, page:UnresolvedLibrary) {
		return descPublisher.publish(conn, page.description)
			.next((descID) -> conn.Library.insertOne({
				id: null,
				description: descID,
				url: page.url,
				name: page.name,
				isDeprecated: page.isDeprecated
			})
				.next((libraryID) -> {
					var urls = page.urls.map((url) -> libraryURLPublish(conn, libraryID, url).noise());
					var fields = page.fields.map((field) -> libraryFieldPublish(conn, libraryID
						, field).noise());
					return Promise.inSequence(urls.concat(fields))
						.noise();
				}));
	}

	function libraryURLPublish(conn:data.WikiDB, libraryID:Int, url:UnresolvedLibraryURL) {
		return Promise.lazy(() -> conn.LibraryURL.insertOne({
			urlNo: url.urlNo,
			url: url.url,
			libraryID: libraryID,
		}));
	}

	function libraryFieldPublish(conn:data.WikiDB, libraryID:Int, field:UnresolvedLibraryField) {
		return Promise.lazy(() -> descPublisher.publish(conn, field.description)
			.next((descID) -> conn.LibraryField.insertOne({
				fieldNo: field.fieldNo,
				description: descID,
				typeURL: field.typeURL,
				type: field.type,
				libraryID: libraryID,
				name: field.name
			})));
	}
}
