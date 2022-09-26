OpenKeyboard()

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OpenKeyboard() {
    Process, Exist, LuaMacros.exe
        If Not ErrorLevel
        {
	        Run "C:\AHK\MediaControl\keyboard_lua_script.lua"
            ;Sleep, 1000
            ;Send ^{Enter}
        }
        Else
        {
            WinActivate, ahk_exe LuaMacros.exe
        }
        Return
}