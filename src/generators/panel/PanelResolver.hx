package generators.panel;

import generators.desc.UnresolvedDescription;
import generators.desc.DescriptionParser;
import generators.desc.DescriptionPublisher;
import ParseUtil;

using tink.CoreApi;

interface PanelResolver {
	function resolve(url:String, jq:CheerioAPI):UnresolvedPanelPage;
	function publish(conn:data.WikiDB, page:UnresolvedPanelPage):Promise<Noise>;
}

typedef UnresolvedPanelPage = {
	name:String,
	description:UnresolvedDescription,
	?urls:Array<UnresolvedPanelUrl>,
	url:String,
	parenturl:String,
	isDeprecated:Bool,
	isInternal:Bool
}

typedef UnresolvedPanelUrl = {
	urlNo:Int,
	url:String
}

class PanelResolverDef implements PanelResolver {
	final descParser:DescriptionParser;

	final descPublisher:DescriptionPublisher;

	public function new(_descParser:DescriptionParser, _descPublisher:DescriptionPublisher) {
		descParser = _descParser;
		descPublisher = _descPublisher;
	}

	public function resolve(url:String, jq:CheerioAPI):UnresolvedPanelPage {
		var name = getPageName(url);
		var pageContent = getCheer(jq, "div.description_section");
		var desc = descParser.parseDescNode(pageContent, jq);
		var parentUrlOpt = getOptCheer(jq, 'div.panel > h1:contains("Parent") ~ p > a');
		var urlsNodeOpt = getOptCheer(jq, "div.members > h1:contains('Methods') + div.section");
		var urls = switch (urlsNodeOpt) {
			case Some(urlsNode):
				parseUrlNode(jq, urlsNode);
			case None:
				null;
		}
		var parentUrl = switch (parentUrlOpt) {
			case Some(parentUrl):
				parentUrl.attr("href");
			case None:
				null;
		}
		var isInternal = isPageInternal(jq);
		var isDeprecated = isPageDeprecated(jq);
		return {
			name: name,
			description: desc,
			url: trimFullURL(url),
			urls: urls,
			parenturl: parentUrl,
			isInternal: isInternal,
			isDeprecated: isDeprecated
		};
	}

	function parseUrlNode(jq:CheerioAPI, urlsNode:CheerioD):Array<UnresolvedPanelUrl> {
		var id:Int = 0;
		final urls:Array<UnresolvedPanelUrl> = [];
		urlsNode.children()
			.each((_, el) -> {
				var cheerEl = jq.call(el);
				urls.push(parseURL(cheerEl, jq, id++));
				return true;
			});
		return urls;
	}

	function parseURL(node:CheerioD, jq:CheerioAPI, no:Int):UnresolvedPanelUrl {
		var url = getChildCheer(node, "a.subject").attr("href");
		return {
			urlNo: no,
			url: url
		};
	}

	public function publish(conn:data.WikiDB, page:UnresolvedPanelPage):Promise<Noise> {
		return descPublisher.publish(conn, page.description)
			.next(pageDescID -> {
				conn.Panel.insertOne({
					id: null,
					description: pageDescID,
					parentLink: page.parenturl,
					url: page.url,
					name: page.name,
					isDeprecated: page.isDeprecated,
					isInternal: page.isInternal
				})
					.next(panelID -> {
						if (page.urls == null)
							return Promise.NOISE;
						var urls:Array<data.WikiDB.PanelURL> = page.urls.map((url) -> {
							urlNo: url.urlNo,
							url: url.url,
							panelID: panelID
						});
						return conn.PanelURL.insertMany(urls);
					});
			});
	}
}
