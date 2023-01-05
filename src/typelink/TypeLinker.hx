package typelink;

import js.node.Path;
import data.WikiDB;
import js.node.Fs;
using tink.CoreApi;

class TypeLinker {
    public function new() {

    }

    public static function addLuaTypes(db:WikiDB) {
        return new Promise(function (success,failure) {
            var str = Fs.readdirSync("luatypes");
            var it = str.iterator();
            var cancel = false;
            function iterate(prevOutcome) {
                if (cancel) return;
                switch(prevOutcome) {
                    case null:
                    case Failure(fail):
                        failure(fail);
                    case Success(_):
                }
                if (!it.hasNext()) {
                    success(Noise);
                } else {
                    var sqlFilename = it.next();
                    var sql = Fs.readFileSync(Path.join("luatypes",sqlFilename)).toString();
                    db.__pool.executeSql(sql).handle(iterate);
                }
            }
            iterate(null);
            return () -> cancel = true;
        });
       
    }
}