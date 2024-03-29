@echo off
rg NOCOMMIT --type-add "haxe:*.{hx,hxml}" --type haxe src/
if %ERRORLEVEL% EQU 0 (
rg COMMITAREA --line-number --type-add "haxe:*.{hx,hxml}" --glob "!*/CommitArea.hx" --glob "!*/import.hx" --type haxe src/
rg ncp --line-number --type-add "haxe:*.{hx,hxml}" --type haxe src/
exit /b 1)
rg COMMITAREA --line-number --type-add "haxe:*.{hx,hxml}" --glob "!*/CommitArea.hx" --glob "!*/import.hx" --type haxe src/
if %ERRORLEVEL% EQU 0 (
rg \*ncp --line-number --type-add "haxe:*.{hx,hxml}" --type haxe src/
exit /b 1)
rg \*ncp --line-number --type-add "haxe:*.{hx,hxml}" --type haxe src/
if %ERRORLEVEL% EQU 0 (exit /b 1) else (exit /b 0)
