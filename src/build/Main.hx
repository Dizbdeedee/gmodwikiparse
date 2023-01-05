package;

function main() {
    #if npm
    Sys.command("npm install");
    #elseif build
    Sys.setCwd("staging");
    Sys.command("haxe buildstaging.hxml && node gmodwiki.js");
    #else
    trace("Run with -D (command) Commands: npm, build");
    #end
}