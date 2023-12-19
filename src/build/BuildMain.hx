package;

function main() {
    #if npm
    Sys.command("npm install");
    #elseif missingJson
    Sys.setCwd("staging");
    Sys.command("lix buildstaging.hxml -D missingJson && node gmodwiki.js");
    #elseif keepPrev
    Sys.setCwd("staging");
    Sys.command("lix buildstaging.hxml -D keepPrev && node gmodwiki.js");
    #elseif build
    Sys.setCwd("staging");
    Sys.command("lix buildstaging.hxml && node gmodwiki.js");
    #elseif test
    Sys.setCwd("staging");
    Sys.command("lix buildstaging.hxml -D test && node gmodwiki.js");
    #elseif nodb
    Sys.setCwd("staging");
    Sys.command("lix buildstaging.hxml -D nodb && node gmodwiki.js");
    #elseif linkage
    Sys.setCwd("staging");
    Sys.command("lix buildstaging.hxml -D linkage && node gmodwiki.js");
    #else
    trace("Run with -D (command) Commands: npm, build, nodb");
    #end
}