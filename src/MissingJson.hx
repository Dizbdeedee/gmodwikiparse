import haxe.Json;
import js.node.Fs;
import js.node.Readline;

var linesParsed:Map<String,Bool> = [];

var allLines:Map<String,Bool> = [];

function produceMissingJson() {
    if (!Fs.existsSync("seeds.txt")) throw "No pages.json";
    var parse = Readline.createInterface({input: Fs.createReadStream("parsed.json")});
    parse.on("line",(parseLine) -> {
        var json = Json.parse(parseLine);
        var seedIn = Readline.createInterface({input: Fs.createReadStream("seeds.txt")});
        for (fieldID in Reflect.fields(json)) {
            var arr:Array<String> = Reflect.field(json,fieldID);
            for (arrItem in arr) {
                linesParsed.set(arrItem,true);
            }
        }
        seedIn.on("line",(seedLine) -> {
            allLines.set(seedLine,true);
        });
        seedIn.on("close",() -> {
            var buf = new StringBuf();
            for (str => _ in allLines) {
                if (linesParsed.exists(str)) {
                    // trace('Parsed $str');
                } else {
                    buf.add(str + "\n");
                }
            }
            Fs.writeFileSync("unparsedseeds.txt",buf.toString());
        });
    });       
}