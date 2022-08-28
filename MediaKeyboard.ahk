#NoEnv
SendMode Input
#InstallKeybdHook
#UseHook On
Menu, Tray, Icon, shell32.dll, 283 ; this changes the tray icon to a little keyboard!
#SingleInstance force ;only one instance of this script may run at a time!
#MaxHotkeysPerInterval 2000
#WinActivateForce ;https://autohotkey.com/docs/commands/_WinActivateForce.htm

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; HELLO, poeple who want info about making a second keyboard, using luamacros!

; Here's my LTT video about how I use the 2nd keyboard with Luamacros: https://www.youtube.com/watch?v=Arn8ExQ2Gjg

; And Tom's video, which unfortunately does not have info on how to actually DO it: https://youtu.be/lIFE7h3m40U?t=16m9s

; If you have never used AutoHotKey, you must take this tutorial before proceeding!
; https://autohotkey.com/docs/Tutorial.htm

; So you will need luamacros, of course.
; Luamacros: http://www.hidmacros.eu/forum/viewtopic.php?f=10&t=241#p794
; AutohotKey: https://autohotkey.com/

; However, I no longer use luamacros, because I believe interecept.exe is even better! My current code is available in "ALL_MULTIPLE_KEYBOARD_ASSIGNMENTS.ahk"

; Lots of other explanatory videos other AHK scripts can be found on my youtube channel! https://www.youtube.com/user/TaranVH/videos 
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;=========================================================================================
; Env Setup
;=========================================================================================
#Persistent
#Include VMR.ahk
;#NoEnv                        ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn                         ; Enable warnings to assist with detecting common errors.
SendMode Input                ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%   ; Ensures a consistent starting directory.
;#SingleInstance Force         ; Determines whether a script is allowed to run again when it is already running. "Force" skips the dialog box and replaces the old instance automatically
#MaxHotkeysPerInterval 200    ; Allow more hotkeys in rapid succession... helps with the scroll wheel
DetectHiddenWindows, On       ; Allow detecting Windows that are minimized to Tray (such as Voicemeeterpro.exe)

;=========================================================================================
; VoiceMeeter DEFINES
;=========================================================================================
global A1 := 5
global A2 := 6
global A3 := 7
global A4 := 8
global A5 := 9

global IN_1 := 0
global IN_2 := 1
global IN_3 := 2
global IN_4 := 3
global IN_5 := 4

;=========================================================================================
; VoiceMeeter Remote API Connection & Variable Initialization
;=========================================================================================
CircleProgress := new CircleProgressClass()
voicemeeter := new VMR()
voicemeeter.login()
voicemeeter.recorder["mode.PlayOnLoad"]:=true	
 
global mute := 1.0
global vol_strip := 0.0

global voicemeeter_open := 0    ; Try to track the status of the VoiceMeeter Window
                                ; Might get out of sync if you manually Minimize or Show the VoiceMeeter window, so just hit Show/Hide hotkey toggle twice to fix
 
OpenKeyboard()	 

;OpenMediaMouse()

;WinWait, ahk_exe LuaMacros.exe   ; Wait for voicemeeter
                                      ; Should be opening one way or another because of OpenVoicemeeter()
OpenVoicemeeter()       ; Call OpenVoicemeeter function to ensure Voicemeeter is running before the rest of the script executes
                        ; Will launch if closed, or bring to foreground if already running
                        ; Either way, the DllLoad should always work because Voicemeeter will be running

WinWait, ahk_exe voicemeeterpro.exe   ; Wait for voicemeeter
                                      ; Should be opening one way or another because of OpenVoicemeeter()

DllLoad := DllCall("LoadLibrary", "Str", "C:\Program Files (x86)\VB\Voicemeeter\VoicemeeterRemote64.dll")   ; Set this to your VoiceMeeter install directory


VMLogin()               ; Connect to VoiceMeeter

OnExit("VMLogout")      ; When script exists, disconnect from VoiceMeeter


; Set Initial State
ApplyVolume(0.0)        ; Output volume to 0.0   (VoiceMeeter's default, does NOT mean Mute)

UnMuteVolume()          ; Make sure it's not Muted

SetSpeakersOutput()     ; Select the Speakers as output, NOT Headphones, assuming you configured VoiceMeeter to have Speakers on A1 and Headphones on A2.  Change to however you like

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OpenKeyboard() {
    Process, Exist, keyboard_lua_script.lua
        If Not ErrorLevel
        {
	        Run, LuaMacros.exe -r "C:\AHK\MediaControl\keyboard_lua_script.lua" ;"C:\AHK\MediaControl\2nd_keyboard.bat"
        }
        Else
        {
            WinActivate, ahk_exe keyboard_lua_script.lua
        }
        Return
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OpenMediaMouse() {
    Process, Exist, Media_Mouse.exe
        If Not ErrorLevel
        {
	        Run, "MediaMouse.exe"
        }
        Else
        {
            WinActivate, Media_Mouse.exe
        }
        Return
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VMLogin() {
    Login := DllCall("VoicemeeterRemote64\VBVMR_Login")
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VMLogout() {
    Logout := DllCall("VoicemeeterRemote64\VBVMR_Logout")
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OpenVoicemeeter() {
    IfWinExist ahk_exe voicemeeter8x64.exe   ; If VoiceMeeter is already running, bring it up from the Tray and bring it to Foreground
    {
        WinShow ahk_exe voicemeeter8x64.exe
        WinActivate ahk_exe voicemeeter8x64.exe   ; Sometimes WinShow does not bring it in front of say, Spotify. So running WinActivate right after gives it focus and brings it all the way to the foreground
    }
    else   ; If VoiceMeeter is NOT running, run the .exe, wait for it to launch, then show and bring foreground
    {
        Run C:\Program Files (x86)\VB\Voicemeeter\voicemeeter8x64.exe   ; Set this to your VoiceMeeter install directory
        WinWait ahk_exe voicemeeter8x64.exe
        WinShow ahk_exe voicemeeter8x64.exe
        WinActivate ahk_exe voicemeeter8x64.exe   ; Sometimes WinShow does not bring it in front of say, Spotify. So running WinActivate right after gives it focus and brings it all the way to the foreground
    }
    voicemeeter_open := 1   ; Set state of VoiceMeeter for toggling between Open and Closed
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
HideVoicemeeter() {
    WinHide ahk_exe voicemeeter8x64.exe   ; Hide VoiceMeeter back into the Tray.  This assumes you configured VoiceMeeter to "minimize to tray" rather than taskbar in it's settings
    voicemeeter_open := 0                ; Set state of VoiceMeeter for toggling between Open and Closed
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WaitForNotDirty() {
    Loop
    {
        Dirty := DllCall("VoicemeeterRemote64\VBVMR_IsParametersDirty")   ; Check to see if VoiceMeeter says that parameters have changed elsewhere
        if (Dirty != 0)                                                   ; This would happen if you changed something in the app directly          
            sleep, 20                                                     ; It can stay dirty for a decent amount of time, in computer terms. Like a few hundred milliseconds
        else                                                              ; If it is still Dirty, wait a moment and check again
            return 1                                                      ; If it is NOT Dirty, Return 1 (True) 
    }
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GetVolume(channel) {
    WaitForNotDirty()   
                                                                                                  ; Make sure the VoiceMeeter parameters are not dirty before querying anything
	if(channel < 5) {
		channel_id = Strip[%channel%].Gain
	}
	else {
		bus_id := channel - 5
		channel_id = Bus[%bus_id%].Gain	
		;tippy(bus_id)
	}

    vm_volume := 1.0                                                                                                      ; Initialize variable
    NumPut(0.0, vm_volume, 0, "Float")                                                                                    ; Force it to be a float
                                                                                                                          ; The POINTER to the variable vm_volume is being sent to the Dll                                           
    Result := DllCall("VoicemeeterRemote64\VBVMR_GetParameterFloat", "AStr", channel_id, "Ptr", &vm_volume, "Int")     ; The "Result" is just a Success or Error Code                                                             
                                                                                                                          ; The actual "volume" of Speaker Channel (A1) is shoved into the memory address associated with the POINTER
    vm_volume := NumGet(vm_volume, 0, "Float")   ; Make sure the value of that variable is a Float after the Dll          ; Pointers are passed using the ' & ' before a variable                                                    
    vm_volume := Round(vm_volume)                ; Round the float so it's nicer to use later                             
    return vm_volume
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ApplyVolume(vol_lvl) {
    if (vol_lvl > 12.0) {                ; If the volume is trying to go above 12.0, set it back to 12.0 as a Max
        vol_lvl := 12.0
    } else if (vol_lvl < -60.0) {        ; If the volume is trying to go below -60.0, set it back to -60.0 as the Min
        vol_lvl := -60.0
    }
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].Gain", "Float", vol_lvl)   ; Set the Speakers to vol_lvl
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].Gain", "Float", vol_lvl)   ; Set the Headphones to vol_lvl
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SetVolume(channel, vol) {
	if(channel < 5) {
		channel_id = Strip[%channel%].Gain
	}
	else {
		bus_id := channel - 5
		channel_id = Bus[%bus_id%].Gain	
		;tippy(bus_id)
	}
	
	vol_strip := GetVolume(channel)
	
	if (vol = "up") {
		vol_strip += 4.0
		load_sound_vol_up(channel)
		CircleProgress.Update(A_Index, "Downloading`nAutoHotkey.exe`n`n" A_Index "% done")
	}
	else if(vol = "down") {
		vol_strip -= 4.0
		load_sound_vol_down(channel)
	}
	else if(vol = "0") {
		vol_strip = 0.0
		load_sound_vol_down(channel)
	}
    if (vol_strip > 12.0) {                ; If the volume is trying to go above 12.0, set it back to 12.0 as a Max
        vol_strip := 12.0
    } else if (vol_strip < -60.0) {        ; If the volume is trying to go below -60.0, set it back to -60.0 as the Min
        vol_strip := -60.0
    }
	show_message = VOL = %vol_strip%
	tippy(show_message)
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", channel_id, "Float", vol_strip)   ; Set the Speakers to vol_lvl
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sTooltip(sTooltipTxt,seconds=5,bg=0xFFFFE7,fg=0x0,x=-1,y=-1, tt=1) { 
   ; (w) derRaphael / zLib Style released 
   if (Seconds+0=0) 
      Seconds = 5 
   StartTime := EndTime := A_Now 
   EnvAdd,EndTime,Seconds,Seconds 
    
   fg := ((fg&255)<<16)+(((fg>>8)&255)<<8)+(fg>>16) ; rgb -> bgr 
   bg := ((bg&255)<<16)+(((bg>>8)&255)<<8)+(bg>>16) ; rgb -> bgr 
    
   tooltip,% (ttID:="TooltipColor " A_TickCount) 
   ;tThWnd1:=WinExist(ttID ahk_class tooltips_class32) 
   Process, Exist
   WinGet, tThWnd1, List, ahk_pid %ErrorLevel%
   Loop, %tThWnd1%
   {
	   WinGetClass	tThWnd1, % "ahk_id " tThWnd1%A_Index%
	   If tThWnd1 = tooltips_class32
	   {
		   tThWnd1 := tThWnd1%A_Index%
		   break
	   }
   }
   ; remove border 
   ;WinSet,Style,-0x800000,ahk_id %tThWnd1% 
   SendMessage, 0x400+19, bg,fg,, ahk_id %tThWnd1% 
   ToolTip, %sTooltipTxt%
   MouseGetPos, lastx, lasty
   Loop,
    if (EndTime=A_Now) 
      Break 
    else {
      MouseGetPos, x, y
      if (lastx != x) || (lasty != y) {
       ToolTip, %sTooltipTxt%
       lastx := x, lasty := y
     }
     sleep, 50
   }
   ToolTip 
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GetIsMuted(channel) {
    WaitForNotDirty()                                                                                                     ; Make sure the VoiceMeeter parameters are not dirty before querying anything

    is_muted := 0.0                                                                                                       ; Initialize variable
    NumPut(0.0, is_muted, 0, "Float")                                                                                     ; Force it to be a float
                                                                                                                          ; The POINTER to the variable is_muted is being sent to the Dll                                                 
    if(channel < 5) {
		channel_id = Strip[%channel%].Mute
	}
	else {
		bus_id := channel - 5
		channel_id = Bus[%bus_id%].Mute
	}
	Result := DllCall("VoicemeeterRemote64\VBVMR_GetParameterFloat", "AStr", channel_id, "Ptr", &is_muted, "Int")      ; The "Result" is just a Success or Error Code                                                                  
                                                                                                                          ; The actual "muted state" of Speaker Channel (A1) is shoved into the memory address associated with the POINTER
    is_muted := NumGet(is_muted, 0, "Float")   ; Make sure the value of that variable is a Float after the Dll            ; Pointers are passed using the ' & ' before a variable                                                         
    return is_muted                            ; For some reason, not doing this makes the variable unusable              
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MuteVolume() {
	;tippy("MIC OFF")
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[0].Mute", "Float", 1.0)   ; Sets Speaker Mute button to On
    ;Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].Mute", "Float", 1.0)   ; Sets Headphone Mute button to On
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
UnMuteVolume() {
	;tippy("MIN ON")
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[0].Mute", "Float", 0.0)   ; Sets Speaker Mute button to Off
    ;Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].Mute", "Float", 0.0)   ; Sets Headphone Mute button to Off
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SetMuteVolume(channel, osd) {
	if(GetIsMuted(channel)) {
		mute := 0.0
		NumPut(0.0, mute, 0, "Float")                                                                                     ; Force it to be a float
		;show_message = IN %channel% ON
		show_message = %osd% UNMUTE
		tippy(show_message)
		load_sound_discord_unmute()
		;Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Command.Button[1].State", "Int", 1)
		;Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Recorder.Play", "Float", 1.0)   ; Sets Speaker Mute button to On
	}
	else {
		mute := 1.0
		NumPut(1.0, mute, 1, "Float")                                                                                     ; Force it to be a float
		;show_message = IN %channel% OFF
		show_message = %osd% MUTE
		tippy(show_message)
		load_sound_discord_mute()
		;Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Recorder.Play", "Float", 1.0)   ; Sets Speaker Mute button to On
	}
	
	if(channel < 5) {
		channel_id = Strip[%channel%].Mute
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", channel_id, "Float", mute)   ; Sets Speaker Mute button to On
	}
	else {
		bus_id := channel - 5
		channel_id = Bus[%bus_id%].Mute	
		;tippy(bus_id)
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", channel_id, "Float", mute)   ; Sets Speaker Mute button to On
	}
	if(channel = "all") {
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[0].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].Mute", "Float", mute)   ; Sets Speaker Mute button to On
	}
	;voicemeeter_show()
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;https://www.myinstants.com
load_sound_discord_mute() {
	global
	voicemeeter.recorder.gain:= 0.0
	voicemeeter.recorder.load:= "C:\AHK\2nd-keyboard\LUAMACROS\discord_mute.mp3"
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
load_sound_discord_unmute() {
	global
	voicemeeter.recorder.gain:= 0.0
	voicemeeter.recorder.load:= "C:\AHK\2nd-keyboard\LUAMACROS\discord_unmute.mp3"
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
load_sound_vol_up(channel) {
	global
	gain := GetVolume(channel)
	if(gain < -12.0)
	gain := -12.0
	voicemeeter.recorder.gain:= gain
	voicemeeter.recorder.load:= "C:\AHK\2nd-keyboard\LUAMACROS\volume_up.wav"
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
load_sound_vol_down(channel) {
	global
	gain := GetVolume(channel)
	if(gain < -12.0)
	gain := -12.0
	voicemeeter.recorder.gain:= gain
	voicemeeter.recorder.load:= "C:\AHK\2nd-keyboard\LUAMACROS\volume_down.wav"
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
voicemeeter_show() {
	OpenVoicemeeter()
	sleep, 1000
	HideVoicemeeter()
}
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GetCurrentOutput() {
    WaitForNotDirty()                                                                                                     ; Make sure the VoiceMeeter parameters are not dirty before querying anything

    a1_active := 0.0                                                                                                      ; Initialize variable
    NumPut(0.0, a1_active, 0, "Float")                                                                                    ; Force it to be a float
                                                                                                                          ; The POINTER to the variable is_muted is being sent to the Dll                                                 
    Result := DllCall("VoicemeeterRemote64\VBVMR_GetParameterFloat", "AStr", "Strip[3].A1", "Ptr", &a1_active, "Int")     ; The "Result" is just a Success or Error Code                                                                  
                                                                                                                          ; The actual "muted state" of Speaker Channel (A1) is shoved into the memory address associated with the POINTER
    a1_active := NumGet(a1_active, 0, "Float")   ; Make sure the value of that variable is a Float after the Dll          ; Pointers are passed using the ' & ' before a variable                                                         
    return a1_active                             ; For some reason, not doing this makes the variable unusable              
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SetSpeakersOutput() {
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].A1", "Float", 1.0)   ; Sets Output Channel A1 to On (Speakers On)
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].A2", "Float", 0.0)   ; Sets Output Channel A2 to Off (Headphones Off)
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SetHeadphonesOutput() {
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].A1", "Float", 0.0)   ; Sets Output Channel A1 to Off (Speakers Off)
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].A2", "Float", 1.0)   ; Sets Output Channel A2 to On (Headphones On)
}

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
restart_audio_engine() {
	global
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Command.Restart", "Int", 1)   ; Sets Speaker Mute button to Off
	voicemeeter.recorder.load := "C:\AHK\2nd-keyboard\LUAMACROS\discord_unmute.mp3"
}

;=========================================================================================
; 2ND KEYBOARD USING LUAMACROS
;=========================================================================================
;#IfWinActive ahk_exe voicemeeterpro.exe ;---EVERYTHING BELOW THIS LINE WILL ONLY WORK INSIDE PREMIERE PRO. But you can change this to anything you like. You can use Window Spy to determine the ahk_exe of any program, so that your macros will only work when and where you want them to.

;There is no code here. T'was just an example.

;#IfWinActive ;---- This will allow for everything below this line to work in ANY application.

~F24::
FileRead, key, C:\AHK\2nd-keyboard\LUAMACROS\keypressed.txt
;tippy(key) ;<--- this function will just launch a quick tooltip that shows you what key you pressed. OPTIONAL.
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ RESTART AUDIO ENGINE CONTROL
if(key = "escape")
restart_audio_engine()

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPEN/CLOSE CONTROL
;.......... OPEN VOICEMEETER
else if(key = "F1")
OpenVoicemeeter()
;.......... CLOSE VOICEMEETER
else if(key = "F2")
HideVoicemeeter()

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MUTE CONTROL
;.......... MUTE/UNMUTE SPLIT 0
else if(key = "space")
SetMuteVolume(0, "MIC")

;.......... MUTE/UNMUTE SPLIT 1
else if(key = "7")
SetMuteVolume(1, "LEGRAND OUT")

;.......... MUTE/UNMUTE SPLIT 2
else if(key = "8")
SetMuteVolume(2, "N.A.")

;.......... MUTE/UNMUTE SPLIT 3
else if(key = "4")
SetMuteVolume(IN_2, "PA IN")

;.......... MUTE/UNMUTE SPLIT 4
else if(key = "5")
SetMuteVolume(A5, "DISCORD/MEET IN")

;.......... MUTE/UNMUTE BUS 0
else if(key = "1") 
SetMuteVolume(A1, "PA OUT")

;.......... MUTE/UNMUTE BUS 1
else if(key = "2") ;or (key = "num8"))
SetMuteVolume(A2, "FONE OUT")

;.......... MUTE/UNMUTE BUS 3
else if(key = "3") ;or (key = "num7"))
SetMuteVolume(A3, "AUX IN")

;.......... MUTE/UNMUTE BUS 2

else if((key = "9") or (key = "num9"))
SetMuteVolume(8, "N.A.")

;.......... MUTE/UNMUTE BUS 4
;else if(key = "6")
;OpenKeyboard()
;Run, C:\AHK\2nd-keyboard\LUAMACROS\2nd_keyboard\Media_Mouse.exe ;OpenKeyboard() Run, TheJukeBoxer.exe, C:\Program Files\JukeBoxer
;SetMuteVolume(9, "DISCORD/MEET OUT")

;.......... MUTE/UNMUTE ALL
else if(key = "minus")
SetMuteVolume("all", "ALL")


; VOLUME CONTROL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
;
;  IN0 IN1 IN2 IN3 IN4 VT1 VT2 VT3 A0  A1  A2  A3  A4  A5  A1  B1  B2  B3
; |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
; |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
; |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
;
; CHANNEL 1 (MIC IN) -> (BUS 0)
else if(key = "q")
SetVolume(A1, "up")
else if(key = "a")
SetVolume(A1, "down")
else if(key = "z")
SetVolume(A1, "0")

; CHANNEL 1 (LEGRAND IN) -> (BUS 1)
else if(key = "w")
SetVolume(A2, "up")
else if(key = "s")
SetVolume(A2, "down")
else if(key = "x")
SetVolume(A2, "0")

; CHANNEL 1 (BLUETOOTH OUT) -> (BUS 2)
else if(key = "e")
{
	SetVolume(A3, "up")
	SetVolume(A4, "up")
}
else if(key = "d")
{
	SetVolume(A3, "down")
	SetVolume(A4, "down")
}	
else if(key = "c")
{
	SetVolume(A3, "0")
	SetVolume(A4, "0")
}	

; CHANNEL 1 (LEGRAND IN) -> (STRIP 1)
else if(key = "r")
SetVolume(IN_2, "up")
else if(key = "f")
SetVolume(IN_2, "down")
else if(key = "v")
SetVolume(IN_2, "0")

;.......... SPLIT 4
;else if(key = "t")
;SetVolume(4, "up")
;else if(key = "g")
;SetVolume(4, "down")

;.......... BUS 0
;else if(key = "y")
;SetVolume(5, "up")
;else if(key = "h")
;SetVolume(5, "down")

;.......... BUS 1
;else if(key = "u") ;or (key = "num4"))
;SetVolume(1, "up")
;else if(key = "j") ;or (key = "num1"))
;SetVolume(1, "down")

;.......... BUS 2
;else if((key = "i") or (key = "num5"))
;SetVolume(2, "up")
;else if((key = "k") or (key = "num2"))
;SetVolume(2, "down")

;.......... BUS 3
;else if((key = "o") or (key = "num6"))
;SetVolume(3, "up")
;else if((key = "l") or (key = "num3"))
;SetVolume(3, "down")

;.......... BUS 4
;else if((key = "p") or (key = "numMinus"))
;SetVolume(9, "up")
;else if((key = "semicolon") or (key = "numPlus"))
;SetVolume(9, "down")


;else if(key = "leftbracket")
;else if(key = "rightbracket")
;else if(key = "comma")
;else if(key = "period")
;else if(key = "slash")
;else if(key = "singlequote")
;else if(key = "b")
;else if(key = "v")
;else if(key = "F7")
;else if(key = "F8")
;else if(key = "F9")
;else if(key = "F10")
;else if(key = "F11")
;else if(key = "F12")
;else if(key = "F5")
;else if(key = "insert")
;else if(key = "home") 
;else if(key = "pageup")
;else if(key = "delete")
;else if(key = "end")
;else if(key = "pagedown")
;else if(key = "equals")
;else if(key = "up")
;else if(key = "left")
;else if(key = "down")
;else if(key = "right")
;else if(key = "enter")
;else if(key = "num0")
;else if(key = "num1")
;else if(key = "num2")
;else if(key = "num3")

;else if(key = "num5")
;else if(key = "num6")
;else if(key = "num7")
;else if(key = "num8")
;else if(key = "num9")
;else if(key = "numDiv")
;else if(key = "numMult")
;else if(key = "F6")

Return ;from luamacros F24
;THE BLOCK OF CODE ABOVE is the original, simple Luamacros-dependant script.


;;;ALL THE CODE BELOW CAN BE THE ACTUAL FUNCTIONS THAT YOU WANT TO CALL;;;


;;;;;;temporary tooltip maker;;;;;;
Tippy(tipsHere, wait:=2000) {
;ToolTip, %tipsHere% TP,,,8
ToolTip, %tipsHere%, 0, 0, 8
SetTimer, noTip, %wait% ;--in 1/3 seconds by default, remove the tooltip
}
noTip:
	ToolTip,,,,8
	;removes the tooltip
return
;;;;;;/temporary tooltip maker;;;;;;

#!g::

 Return

insertSFX(parameter){
msgbox, you launched insertSFX with the parameter %parameter%
msgbox, obviously you can now put any function you like in here.

}


audiomonomaker(parameter){
msgbox, you launched audiomonomaker with the parameter %parameter%
msgbox, you can grab the real function from Almost_All_Premiere_Functions.ahk

}


preset(parameter){
msgbox, you launched PRESET with the parameter %parameter%

}


recallTransition(parameter){
msgbox, you launched recallTransition with the parameter %parameter%
}


copy(bar){
msgbox, you launched COPY with the parameter %bar%

}

paste(foo){
msgbox, you launched PASTE with the parameter %foo%

}