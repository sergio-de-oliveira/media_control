Dim oShell
Set WshShell = WScript.CreateObject("WScript.Shell")
Set oShell = WScript.CreateObject ("WScript.Shell")
oShell.run "C:\ahk\MediaControl\keyboard_lua_script.lua"
WScript.Sleep 500
WshShell.SendKeys "^{Enter}"
oShell.run "C:\ahk\MediaControl\MusicLAB.ahk"
Set oShell = Nothing