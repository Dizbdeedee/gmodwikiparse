package;

function main() {
    #if npm
    Sys.command("npm install");
    #elseif missingJson
    Sys.setCwd("staging");
    Sys.command("haxe -D missingJson buildstaging.hxml && node gmodwiki.js");
    #elseif build
    Sys.setCwd("staging");
    Sys.command("haxe buildstaging.hxml && node gmodwiki.js");
    #elseif test
    Sys.setCwd("staging");
    Sys.command("haxe -D test buildstaging.hxml && node gmodwiki.js");
    #elseif nodb
    Sys.setCwd("staging");
    Sys.command("haxe -D nodb buildstaging.hxml && node gmodwiki.js");
    #elseif linkage
    Sys.setCwd("staging");
    Sys.command("haxe -D linkage buildstaging.hxml && node gmodwiki.js");
    #else
    trace("Run with -D (command) Commands: npm, build, nodb");
    #end
}