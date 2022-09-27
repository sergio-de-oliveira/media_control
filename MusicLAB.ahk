/*
 *************************************************************************************
 *                                MUSIC LAB SCRIPT                                   *
 *************************************************************************************
 */

; ------------------------------ Includes --------------------------------------------

#Include VMR.ahk
#Include AHKHID.ahk

; ------------------------------ Definitions -----------------------------------------

;#Warn	; Enable warnings to assist with detecting common errors.
#NoEnv	; Recommended for performance and compatibility with future AutoHotkey releases.
#InstallKeybdHook
#UseHook On
;Menu, Tray, Icon, shell32.dll, 283 ; this changes the tray icon to a little keyboard!
Menu, Tray, Icon, DDORes.dll, 28 ; this changes the tray icon to a little keyboard!
#SingleInstance force	;only one instance of this script may run at a time!
#MaxHotkeysPerInterval 200	; Allow more hotkeys in rapid succession... helps with the scroll wheel
#WinActivateForce	; https://autohotkey.com/docs/commands/_WinActivateForce.htm
#Persistent
SendMode Input	; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%	; Ensures a consistent starting directory.
DetectHiddenWindows, On	; Allow detecting Windows that are minimized to Tray (such as Voicemeeterpro.exe)

; ------------------------------ Variables -------------------------------------------

; ---------- VoiceMeeter
global media_mode	:= 0 
global modeMusic	:= 0
global modeLema		:= 1
global modeAltium	:= 2

global BUS_1 := 0
global BUS_2 := 1
global BUS_3 := 2
global BUS_4 := 3
global BUS_5 := 4

global IN_1 := 0
global IN_2 := 1
global IN_3 := 2
global IN_4 := 3
global IN_5 := 4
global IN_6 := 5
global IN_7 := 6

global A1_equalizer_state := "ON"
global A2_equalizer_state := "ON"
global A3_equalizer_state := "ON"
global A4_equalizer_state := "ON"
global A5_equalizer_state := "ON"

global discord_mute_file := "\sounds\discord_mute.mp3"
global discord_unmute_file := "\sounds\discord_unmute.mp3"
global volume_up_file := "\sounds\volume_up.wav"
global volume_down_file := "\sounds\volume_down.wav"
global mute := 1.0
global vol_strip := 0.0
global voicemeeterVisible := 0
global voicemeeter_open := 0    ; Try to track the status of the VoiceMeeter Window

;global DEVICE_PA := "FONE (HECATE G1 GAMING HEADSET)" 	;id=2
;global DEVICE_HECATE := ""								;id=9
;global DEVICE_AIRDOTS := "" 							;id=4
;global DEVICE_T7 := "" 								;id=3

; ---------- Mouse
LastMouseState := ""
LButtonState := "LButtonState_solto"
RButtonState := "RButtonState_solto"
WheelMidState := "WheelMid_solto"
KeyBoarID_bright := "\\?\HID#VID_04D9&PID_A01C&MI_01&Col01#8&15884e3e&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
Mouse2_ID := ""


; ------------------------------ Initialization --------------------------------------

AHKHID_UseConstants() ; Set up the constants

voicemeeterInit()

mouseInit()	

DefaultMusicSettings()	; Set default voicemeeter settings

KeyboardInit() ; 2nd keyboard with Luamacros: https://www.youtube.com/watch?v=Arn8ExQ2Gjg

; ------------------------------ Implementation --------------------------------------

;====================================================================================================================================================
; VOICEMEETER
;====================================================================================================================================================

voicemeeterInit()
{
	global voicemeeter := new VMR()
	voicemeeter.login()
	voicemeeter.recorder["mode.PlayOnLoad"] := true
	DllLoad := DllCall("LoadLibrary", "Str", "C:\Program Files (x86)\VB\Voicemeeter\VoicemeeterRemote64.dll")   ; Set this to your VoiceMeeter install directory

	VMLogin()               ; Connect to VoiceMeeter

	OnExit("VMLogout")      ; When script exists, disconnect from VoiceMeeter
}

DefaultMusicSettings()
{
	SetNumLockState, Off

	; Out BUS Assignation -----------------------------------------
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].A1", "Float", 1.0)

	; Gain slider -------------------------------------------------
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[0].Gain", "Float", 12.0)   ; Set the Microphone
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].Gain", "Float", 0.0)   ; Set the HDL Line In volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Gain", "Float", -60.0)  ; Set the Imput3 volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Gain", "Float", -60.0)  ; Set the Imput4 volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Gain", "Float", -60.0)  ; Set the Imput5 volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[5].Gain", "Float", 0.0)    ; Set the voicemeeter VAIO volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[6].Gain", "Float", -60.0)  ; Set the voicemeeter AUX volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[7].Gain", "Float", -60.0)  ; Set the voicemeeter VAIO 3 volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].Gain", "Float", 0.0)      ; Set the PA output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].Gain", "Float", 0.0)      ; Set the PHONE output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].Gain", "Float", 0.0)      ; Set the EAR output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].Gain", "Float", 0.0)      ; Set the T7 output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].Gain", "Float", 0.0)      ; Set the HDL output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[5].Gain", "Float", 0.0)      ; Set the HDL output volume

	; Mute Button -------------------------------------------------
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Mute", "Float", 1.0)    ; Set Imput3 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Mute", "Float", 1.0)    ; Set Imput4 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Mute", "Float", 1.0)    ; Set Imput5 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[6].Mute", "Float", 1.0)    ; Set voicemeeter AUX to On
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[7].Mute", "Float", 1.0)    ; Set voicemeeter VAIO 3 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[6].Mute", "Float", 1.0)      ; Set B2 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[7].Mute", "Float", 1.0)      ; Set B3 Mute

	; EQ Button ---------------------------------------------------
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].EQ.on", "Float", 1.0)     ; Sets PA equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].EQ.on", "Float", 1.0)     ; Sets PHONE equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].EQ.on", "Float", 1.0)     ; Sets EAR equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].EQ.on", "Float", 1.0)     ; Sets T7 equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].EQ.on", "Float", 1.0)     ; Sets HDL equalizer ON
	show_message = "MUSIC MODE"
	tippy(show_message)
}

DefaultLemaSettings()
{
	; Out BUS Assignation -----------------------------------------
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].A1", "Float", 0.0)

	; Gain slider -------------------------------------------------
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[0].Gain", "Float", 12.0)   ; Set the Microphone
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].Gain", "Float", 0.0)   ; Set the HDL Line In volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Gain", "Float", -60.0)  ; Set the Imput3 volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Gain", "Float", -60.0)  ; Set the Imput4 volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Gain", "Float", -60.0)  ; Set the Imput5 volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[5].Gain", "Float", 0.0)    ; Set the voicemeeter VAIO volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[6].Gain", "Float", -60.0)  ; Set the voicemeeter AUX volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[7].Gain", "Float", -60.0)  ; Set the voicemeeter VAIO 3 volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].Gain", "Float", 0.0)      ; Set the PA output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].Gain", "Float", 0.0)      ; Set the PHONE output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].Gain", "Float", 0.0)      ; Set the EAR output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].Gain", "Float", 0.0)      ; Set the T7 output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].Gain", "Float", 0.0)      ; Set the HDL output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[5].Gain", "Float", 0.0)      ; Set the HDL output volume

	; Mute Button -------------------------------------------------
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Mute", "Float", 1.0)    ; Set Imput3 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Mute", "Float", 1.0)    ; Set Imput4 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Mute", "Float", 1.0)    ; Set Imput5 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[6].Mute", "Float", 1.0)    ; Set voicemeeter AUX to On
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[7].Mute", "Float", 1.0)    ; Set voicemeeter VAIO 3 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[6].Mute", "Float", 1.0)      ; Set B2 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[7].Mute", "Float", 1.0)      ; Set B3 Mute

	; EQ Button ---------------------------------------------------
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].EQ.on", "Float", 1.0)     ; Sets PA equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].EQ.on", "Float", 1.0)     ; Sets PHONE equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].EQ.on", "Float", 1.0)     ; Sets EAR equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].EQ.on", "Float", 1.0)     ; Sets T7 equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].EQ.on", "Float", 1.0)     ; Sets HDL equalizer ON
	show_message = "LEMA MODE"
	tippy(show_message)
}

DefaultAltiumSettings()
{
	; Out BUS Assignation -----------------------------------------
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].A1", "Float", 1.0)

	; Gain slider -------------------------------------------------
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[0].Gain", "Float", 12.0)   ; Set the Microphone
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].Gain", "Float", 0.0)   ; Set the HDL Line In volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Gain", "Float", -60.0)  ; Set the Imput3 volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Gain", "Float", -60.0)  ; Set the Imput4 volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Gain", "Float", -60.0)  ; Set the Imput5 volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[5].Gain", "Float", 0.0)    ; Set the voicemeeter VAIO volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[6].Gain", "Float", -60.0)  ; Set the voicemeeter AUX volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[7].Gain", "Float", -60.0)  ; Set the voicemeeter VAIO 3 volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].Gain", "Float", 0.0)      ; Set the PA output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].Gain", "Float", 0.0)      ; Set the PHONE output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].Gain", "Float", 0.0)      ; Set the EAR output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].Gain", "Float", 0.0)      ; Set the T7 output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].Gain", "Float", 0.0)      ; Set the HDL output volume
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[5].Gain", "Float", 0.0)      ; Set the HDL output volume

	; Mute Button -------------------------------------------------
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Mute", "Float", 1.0)    ; Set Imput3 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Mute", "Float", 1.0)    ; Set Imput4 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Mute", "Float", 1.0)    ; Set Imput5 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[6].Mute", "Float", 1.0)    ; Set voicemeeter AUX to On
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[7].Mute", "Float", 1.0)    ; Set voicemeeter VAIO 3 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[6].Mute", "Float", 1.0)      ; Set B2 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[7].Mute", "Float", 1.0)      ; Set B3 Mute

	; EQ Button ---------------------------------------------------
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].EQ.on", "Float", 1.0)     ; Sets PA equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].EQ.on", "Float", 1.0)     ; Sets PHONE equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].EQ.on", "Float", 1.0)     ; Sets EAR equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].EQ.on", "Float", 1.0)     ; Sets T7 equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].EQ.on", "Float", 1.0)     ; Sets HDL equalizer ON
	show_message = "ALTIUM MODE"
	tippy(show_message)
}

VMLogin()
{
    Login := DllCall("VoicemeeterRemote64\VBVMR_Login")
}

VMLogout()
{
    Logout := DllCall("VoicemeeterRemote64\VBVMR_Logout")
}

OpenVoicemeeter()
{
    IfWinExist ahk_exe voicemeeter8x64.exe   ; If VoiceMeeter is already running, bring it up from the Tray and bring it to Foreground
    {
        ;WinShow ahk_exe voicemeeter8x64.exe
        ;WinActivate ahk_exe voicemeeter8x64.exe   ; Sometimes WinShow does not bring it in front of say, Spotify. So running WinActivate right after gives it focus and brings it all the way to the foreground
    }
    else   ; If VoiceMeeter is NOT running, run the .exe, wait for it to launch, then show and bring foreground
    {
        Run C:\Program Files (x86)\VB\Voicemeeter\voicemeeter8x64.exe   ; Set this to your VoiceMeeter install directory
        WinWait ahk_exe voicemeeter8x64.exe
        ;WinShow ahk_exe voicemeeter8x64.exe
        ;WinActivate ahk_exe voicemeeter8x64.exe   ; Sometimes WinShow does not bring it in front of say, Spotify. So running WinActivate right after gives it focus and brings it all the way to the foreground
    }
}

ShowVoicemeeter()
{
    IfWinExist ahk_exe voicemeeter8x64.exe   ; If VoiceMeeter is already running, bring it up from the Tray and bring it to Foreground
    {
        WinShow, ahk_exe voicemeeter8x64.exe
        WinActivate, ahk_exe voicemeeter8x64.exe   ; Sometimes WinShow does not bring it in front of say, Spotify. So running WinActivate right after gives it focus and brings it all the way to the foreground
    }
}

HideVoicemeeter()
{
    IfWinExist ahk_exe voicemeeter8x64.exe   ; If VoiceMeeter is already running, bring it up from the Tray and bring it to Foreground
    {		
    	WinHide, ahk_exe voicemeeter8x64.exe   ; Hide VoiceMeeter back into the Tray.  This assumes you configured VoiceMeeter to "minimize to tray" rather than taskbar in it's settings
	}
}

WaitForNotDirty()
{
    Loop
    {
        Dirty := DllCall("VoicemeeterRemote64\VBVMR_IsParametersDirty")   ; Check to see if VoiceMeeter says that parameters have changed elsewhere
        if (Dirty != 0)                                                   ; This would happen if you changed something in the app directly          
            sleep, 20                                                     ; It can stay dirty for a decent amount of time, in computer terms. Like a few hundred milliseconds
        else                                                              ; If it is still Dirty, wait a moment and check again
            return 1                                                      ; If it is NOT Dirty, Return 1 (True) 
    }
}

GetVolume(channel_type, channel)
{
    WaitForNotDirty()   
                                                                                                  ; Make sure the VoiceMeeter parameters are not dirty before querying anything
	if(channel_type = "STRIP")
	{
		channel_id = Strip[%channel%].Gain
	}
	else
	if(channel_type = "BUS")
	{
		channel_id = Bus[%channel%].Gain	
	}

    volume := 1.0                                                                                                      ; Initialize variable
    NumPut(0.0, volume, 0, "Float")                                                                                    ; Force it to be a float
                                                                                                                          ; The POINTER to the variable vm_volume is being sent to the Dll                                           
    Result := DllCall("VoicemeeterRemote64\VBVMR_GetParameterFloat", "AStr", channel_id, "Ptr", &volume, "Int")     ; The "Result" is just a Success or Error Code                                                             
                                                                                                                          ; The actual "volume" of Speaker Channel (A1) is shoved into the memory address associated with the POINTER
    volume := NumGet(volume, 0, "Float")   ; Make sure the value of that variable is a Float after the Dll          ; Pointers are passed using the ' & ' before a variable                                                    
    volume := Round(volume)                ; Round the float so it's nicer to use later                             
    return volume
}

SetVolume(channel_type, channel, vol)
{
	if(channel_type = "STRIP")
	{
		channel_id = Strip[%channel%].Gain
	}
	else
	if(channel_type = "BUS")
	{
		channel_id = Bus[%channel%].Gain	
	}

	volume := GetVolume(channel_type, channel)
	
	if (vol = "up")
	{
		volume += 4.0
		load_sound_vol_up(channel_type, channel)
		CircleProgress.Update(A_Index, "Downloading`nAutoHotkey.exe`n`n" A_Index "% done")
	}
	else if(vol = "down")
	{
		volume -= 4.0
		load_sound_vol_down(channel_type, channel)
	}
	else if(vol = "0")
	{
		volume = 0.0
		load_sound_vol_down(channel_type, channel)
	}
    if (volume > 12.0)
	{                ; If the volume is trying to go above 12.0, set it back to 12.0 as a Max
        volume := 12.0
    }
	else if (volume < -60.0)
	{        ; If the volume is trying to go below -60.0, set it back to -60.0 as the Min
        volume := -60.0
    }
	show_message = vol = %volume%
	tippy(show_message)
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", channel_id, "Float", volume)   ; Set the Speakers to vol_lvl
}

GetIsMuted(channel_type, channel)
{
    WaitForNotDirty()                                                                                                     ; Make sure the VoiceMeeter parameters are not dirty before querying anything

    is_muted := 0.0                                                                                                       ; Initialize variable
    NumPut(0.0, is_muted, 0, "Float")                                                                                     ; Force it to be a float
                                                                                                                          ; The POINTER to the variable is_muted is being sent to the Dll                                                 
    if(channel_type = "STRIP")
	{
		channel_id = Strip[%channel%].Mute
	}
	else if(channel_type = "BUS")
	{
		bus_id := channel
		channel_id = Bus[%bus_id%].Mute
	}
	else if(channel_type = "ALL")
	{
		bus_id := channel
		channel_id = Bus[%bus_id%].Mute
	}
	Result := DllCall("VoicemeeterRemote64\VBVMR_GetParameterFloat", "AStr", channel_id, "Ptr", &is_muted, "Int")      ; The "Result" is just a Success or Error Code                                                                  
                                                                                                                          ; The actual "muted state" of Speaker Channel (A1) is shoved into the memory address associated with the POINTER
    is_muted := NumGet(is_muted, 0, "Float")   ; Make sure the value of that variable is a Float after the Dll            ; Pointers are passed using the ' & ' before a variable                                                         
    return is_muted                            ; For some reason, not doing this makes the variable unusable              
}

MuteVolume()
{
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[0].Mute", "Float", 1.0)   ; Sets Speaker Mute button to On
}

UnMuteVolume()
{
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[0].Mute", "Float", 0.0)   ; Sets Speaker Mute button to Off
}

SetMuteVolume(channel_type, channel ,osd)
{
	if(GetIsMuted(channel_type, channel))
	{
		mute := 0.0
		NumPut(0.0, mute, 0, "Float")                                                                                     ; Force it to be a float
		;show_message = IN %channel% ON
		show_message = %osd% UNMUTE
		tippy(show_message)
		load_sound_discord_unmute()
	}
	else
	{
		mute := 1.0
		NumPut(1.0, mute, 1, "Float")                                                                                     ; Force it to be a float
		;show_message = IN %channel% OFF
		show_message = %osd% MUTE
		tippy(show_message)
		load_sound_discord_mute()
		Sleep, 300
	}
	if(channel_type = "STRIP")
	{
		channel_id = Strip[%channel%].Mute
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", channel_id, "Float", mute)   ; Sets Speaker Mute button to On
	}
	else if(channel_type = "BUS")
	{
		bus_id := channel
		channel_id = Bus[%bus_id%].Mute	
		;tippy(bus_id)
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", channel_id, "Float", mute)   ; Sets Speaker Mute button to On
	}
	else if(channel_type = "ALL")
	{
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[0].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[5].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].Mute", "Float", mute)   ; Sets Speaker Mute button to On
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].Mute", "Float", mute)   ; Sets Speaker Mute button to On
	}
	;voicemeeter_show()
}

GetIsEqON(channel_type, channel)
{
	is_eq_on := 0.0
	if(channel_type = "BUS")
	{
		WaitForNotDirty()                                                                                                     ; Make sure the VoiceMeeter parameters are not dirty before querying anything
						                                                                                                       ; Initialize variable
		NumPut(0.0, is_eq_on, 0, "Float")                                                                                     ; Force it to be a float
																															; The POINTER to the variable is_muted is being sent to the Dll                                                 
		bus_id := channel
		channel_id = Bus[%bus_id%].EQ.on
		
		Result := DllCall("VoicemeeterRemote64\VBVMR_GetParameterFloat", "AStr", channel_id, "Ptr", &is_eq_on, "Int")		  ; The "Result" is just a Success or Error Code                                                                  
																															; The actual "muted state" of Speaker Channel (A1) is shoved into the memory address associated with the POINTER
		is_eq_on := NumGet(is_eq_on, 0, "Float")   ; Make sure the value of that variable is a Float after the Dll            ; Pointers are passed using the ' & ' before a variable                                                         
	}
	return is_eq_on                            ; For some reason, not doing this makes the variable unusable              
}

SetEqualizerState(channel_type, channel, osd)
{
	if(channel_type = "BUS")
	{
		if(GetIsEqON(channel_type, channel))
		{
			eq_state := 0.0
			NumPut(0.0, eq_state, 0, "Float")                                                                                     ; Force it to be a float
			;show_message = IN %channel% ON
			show_message = %osd% ON
			tippy(show_message)
			load_sound_discord_unmute()
		}
		else
		{
			eq_state := 1.0
			NumPut(1.0, mute, 1, "Float")                                                                                     ; Force it to be a float
			;show_message = IN %channel% OFF
			show_message = %osd% OFF
			tippy(show_message)
			load_sound_discord_mute()
		}
		
		bus_id := channel
		channel_id = Bus[%bus_id%].EQ.on	
		;tippy(bus_id)
		Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", channel_id, "Float", eq_state)   ; Sets Speaker Mute button to On
		if(channel = "all")
		{
			Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[0].Mute", "Float", eq_state)   ; Sets Speaker Mute button to On
			Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].Mute", "Float", eq_state)   ; Sets Speaker Mute button to On
			Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Mute", "Float", eq_state)   ; Sets Speaker Mute button to On
			Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Mute", "Float", eq_state)   ; Sets Speaker Mute button to On
			Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Mute", "Float", eq_state)   ; Sets Speaker Mute button to On
			Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].Mute", "Float", eq_state)   ; Sets Speaker Mute button to On
			Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].Mute", "Float", eq_state)   ; Sets Speaker Mute button to On
			Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].Mute", "Float", eq_state)   ; Sets Speaker Mute button to On
			Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].Mute", "Float", eq_state)   ; Sets Speaker Mute button to On
			Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].Mute", "Float", eq_state)   ; Sets Speaker Mute button to On
		}
	}
}

EQ_OFF(channel)
{
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr",  Bus[%channel%].EQ.on, "Float", 0.0)   ; Sets equalizer OFF
}

GetFullPathName(path)
{
    cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
    VarSetCapacity(buf, cc*(A_IsUnicode?2:1))
    DllCall("GetFullPathName", "str", path, "uint", cc, "str", buf, "ptr", 0, "uint")
    return buf
}

load_sound_discord_mute() ;https://www.myinstants.com
{
	global
	voicemeeter.recorder.gain := 0.0
	voicemeeter.recorder.load := A_ScriptDir . discord_mute_file
}

load_sound_discord_unmute()
{
	global
	voicemeeter.recorder.gain := 0.0
	voicemeeter.recorder.load := A_ScriptDir . discord_unmute_file
}

load_sound_vol_up(channel_type, channel)
{
	global
	gain := GetVolume(channel_type, channel)
	if(gain < -12.0)
	gain := -12.0
	voicemeeter.recorder.gain:= gain
	voicemeeter.recorder.load:= A_ScriptDir . volume_up_file
}

load_sound_vol_down(channel_type, channel)
{
	global
	gain := GetVolume(channel_type, channel)
	if(gain < -12.0)
	gain := -12.0
	voicemeeter.recorder.gain:= gain
	voicemeeter.recorder.load:= A_ScriptDir . volume_down_file
}

voicemeeter_show()
{
	if(voicemeeterVisible = 0)
	{
		voicemeeterVisible := 1
		ShowVoicemeeter()
	}
	else if(voicemeeterVisible = 1)
	{
		voicemeeterVisible := 0
		HideVoicemeeter()
	}
}

GetCurrentOutput()
{
    WaitForNotDirty()                                                                                                     ; Make sure the VoiceMeeter parameters are not dirty before querying anything

    a1_active := 0.0                                                                                                      ; Initialize variable
    NumPut(0.0, a1_active, 0, "Float")                                                                                    ; Force it to be a float
                                                                                                                          ; The POINTER to the variable is_muted is being sent to the Dll                                                 
    Result := DllCall("VoicemeeterRemote64\VBVMR_GetParameterFloat", "AStr", "Strip[3].A1", "Ptr", &a1_active, "Int")     ; The "Result" is just a Success or Error Code                                                                  
                                                                                                                          ; The actual "muted state" of Speaker Channel (A1) is shoved into the memory address associated with the POINTER
    a1_active := NumGet(a1_active, 0, "Float")   ; Make sure the value of that variable is a Float after the Dll          ; Pointers are passed using the ' & ' before a variable                                                         
    return a1_active                             ; For some reason, not doing this makes the variable unusable              
}

SetSpeakersOutput()
{
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].A1", "Float", 1.0)   ; Sets Output Channel A1 to On (Speakers On)
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].A2", "Float", 0.0)   ; Sets Output Channel A2 to Off (Headphones Off)
}

SetHeadphonesOutput()
{
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].A1", "Float", 0.0)   ; Sets Output Channel A1 to Off (Speakers Off)
    Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].A2", "Float", 1.0)   ; Sets Output Channel A2 to On (Headphones On)
}

restart_audio_engine()
{
	global
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Command.Restart", "Int", 1)   ; Sets Speaker Mute button to Off
	voicemeeter.recorder.load := "C:\AHK\MediaControl\sounds\discord_unmute.mp3"
}

;====================================================================================================================================================
; KEYBOARD
;====================================================================================================================================================

KeyboardInit()
{
    Process, Exist, LuaMacros.exe
	If Not ErrorLevel
	{
		Run "C:\AHK\MediaControl\keyboard_lua_script.lua"
		Sleep, 500
		Send ^{Enter}
	}
	Else
	{
		WinActivate, ahk_exe LuaMacros.exe
	}
	Return
}

KeyboardName(h)
{
	DllCall("GetRawInputDeviceInfo",Int,h,UInt,0x20000007,Int,0,"UInt*",l)
	VarSetCapacity(Name,l*2+2)
	DllCall("GetRawInputDeviceInfo",Int,h,UInt,0x20000007,Str,Name,"UInt*",l)
	return Name
}

~F24::
FileRead, key, C:\AHK\MediaControl\keypressed.txt

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ RESTART AUDIO ENGINE CONTROL
if(key = "space")
restart_audio_engine()

if(key = "tab")
voicemeeter_show()

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ EQUALIZER CONTROL
;.......... PA EQUALIZER
else if(key = "F6")
SetEqualizerState("BUS", BUS_1, "PA EQ")

;.......... FONE EQUALIZER
else if(key = "F7")
SetEqualizerState("BUS", BUS_2, "FONE EQ")

;.......... BLUETOOTH EAR EQUALIZER
else if(key = "F8")
SetEqualizerState("BUS", BUS_3, "EAR EQ")

;.......... BLUETOOTH T7 EQUALIZER
else if(key = "F9")
SetEqualizerState("BUS", BUS_4, "T7 EQ")

;.......... HDL EQUALIZER
else if(key = "F10")
SetEqualizerState("BUS", BUS_5, "HDL EQ")

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MUTE CONTROL
;.......... MUTE/UNMUTE SPLIT 0
else if(key = "1")
SetMuteVolume("STRIP", IN_1, "MIC")

;.......... MUTE/UNMUTE SPLIT 1
else if(key = "2")
SetMuteVolume("STRIP", IN_2, "LEGRAND IN")

;.......... MUTE/UNMUTE SPLIT 2
else if(key = "3")
SetMuteVolume("STRIP", IN_3, "INTPUT3")

;.......... MUTE/UNMUTE SPLIT 3
else if(key = "4")
SetMuteVolume("STRIP", IN_4, "INTPUT4")

;.......... MUTE/UNMUTE SPLIT 3
else if(key = "5")
SetMuteVolume("STRIP", IN_5, "INTPUT5")

;.......... MUTE/UNMUTE BUS 0
else if(key = "6") 
SetMuteVolume("BUS", BUS_1, "PA OUT")

;.......... MUTE/UNMUTE BUS 1
else if(key = "7")
SetMuteVolume("BUS", BUS_2, "FONE OUT")

;.......... MUTE/UNMUTE BUS 2
else if(key = "8")
SetMuteVolume("BUS", BUS_3, "EAR OUT")

;.......... MUTE/UNMUTE BUS 3
else if(key = "9")
SetMuteVolume("BUS", BUS_4, "T7 OUT")

;.......... MUTE/UNMUTE BUS 4
else if(key = "0")
SetMuteVolume("BUS", BUS_5, "HDL OUT")

;.......... MUTE/UNMUTE ALL
else if(key = "minus")
SetMuteVolume("ALL", "all", "ALL")

;.......... MUTE/UNMUTE ALL
else if(key = "backspace")
SetMuteVolume("STRIP", IN_6, "PC")

; VOLUME CONTROL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
;
;  IN0 IN1 IN2 IN3 IN4 VT1 VT2 VT3 A0  A1  A2  A3  A4  A5  A1  B1  B2  B3
; |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
; |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
; |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
;
; CHANNEL 1 (MIC IN) -> (Strip 0)
else if(key = "q")
SetVolume("STRIP", IN_1, "up")
else if(key = "a")
SetVolume("STRIP", IN_1, "down")
else if(key = "z")
SetVolume("STRIP", IN_1, "0")

; CHANNEL 2 (LEGRAND IN) -> (Strip 1)
else if(key = "w")
SetVolume("STRIP", IN_2, "up")
else if(key = "s")
SetVolume("STRIP", IN_2, "down")
else if(key = "x")
SetVolume("STRIP", IN_2, "0")

; CHANNEL 3 (N.A. IN) -> (Strip 2)
else if(key = "e")
SetVolume("STRIP", IN_3, "up")
else if(key = "d")
SetVolume("STRIP", IN_3, "down")
else if(key = "c")
SetVolume("STRIP", IN_3, "0")

; CHANNEL 4 (N.A. IN) -> (Strip 3)
else if(key = "r")
SetVolume("STRIP", IN_4, "up")
else if(key = "f")
SetVolume("STRIP", IN_4, "down")
else if(key = "v")
SetVolume("STRIP", IN_4, "0")

; CHANNEL 5 (N.A. IN) -> (Strip 4)
else if(key = "t")
SetVolume("STRIP", IN_5, "up")
else if(key = "g")
SetVolume("STRIP", IN_5, "down")
else if(key = "b")
SetVolume("STRIP", IN_5, "0")

; CHANNEL 1 (PA OUT) -> (Bus 0)
else if(key = "y")
SetVolume("BUS", BUS_1, "up")
else if(key = "h")
SetVolume("BUS", BUS_1, "down")
else if(key = "n")
SetVolume("BUS", BUS_1, "0")

; CHANNEL 2 (PHONE OUT) -> (Bus 1)
else if(key = "u")
SetVolume("BUS", BUS_2, "up")
else if(key = "j")
SetVolume("BUS", BUS_2, "down")
else if(key = "m")
SetVolume("BUS", BUS_2, "0")

; CHANNEL 3 (BLUETOOTH EAR OUT) -> (Bus 2)
else if(key = "i")
SetVolume("BUS", BUS_3, "up")
else if(key = "k")
SetVolume("BUS", BUS_3, "down")
else if(key = "comma")
SetVolume("BUS", BUS_3, "0")

; CHANNEL 4 (BLUETOOTH T7 OUT) -> (Bus 3)
else if(key = "o")
SetVolume("BUS", BUS_4, "up")
else if(key = "l")
SetVolume("BUS", BUS_4, "down")
else if(key = "period")
SetVolume("BUS", BUS_4, "0")

; CHANNEL 4 (BLUETOOTH HDL OUT) -> (Bus 4)
else if(key = "p")
SetVolume("BUS", BUS_5, "up")
else if(key = "semicolon")
SetVolume("BUS", BUS_5, "down")
else if(key = "slash")
SetVolume("BUS", BUS_5, "0")

else if(key = "left")
{
	if (Media_mode < 2)
	{
		Media_mode += 1
	}
	if(media_mode == modeMusic)
	{
		DefaultMusicSettings()
	}
	Else if(media_mode == modeLema)
	{
		DefaultLemaSettings()
	}
	Else if(media_mode == modeAltium)
	{
		DefaultAltiumSettings()
	}
}

else if(key = "right")
{
	if (Media_mode > 0)
	{
		Media_mode -= 1
	}
	if(media_mode == modeMusic)
	{
		DefaultMusicSettings()
	}
	Else if(media_mode == modeLema)
	{
		DefaultLemaSettings()
	}
	Else if(media_mode == modeAltium)
	{
		DefaultAltiumSettings()
	}
}
Return ;from luamacros F24

;====================================================================================================================================================
; TOOLS
;====================================================================================================================================================

sTooltip(sTooltipTxt,seconds=5,bg=0xFFFFE7,fg=0x0,x=-1,y=-1, tt=1)
{ 
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

Tippy(tipsHere, wait:=2000)	; temporary tooltip maker https://www.autohotkey.com/boards/viewtopic.php?t=48976
{
	sFaceName := "Segoe UI"
	nHeight := 9
	length := GetTextWidth(tipsHere, sFaceName, nHeight = 9, bBold = True, bItalic = True, bUnderline = False, bStrikeOut = False, nCharSet = 0) ;GetTextWidth(tipsHere, sFaceName, nHeight)
	toolX := (A_ScreenWidth/2) - (length/2)
	toolY := A_ScreenHeight
	;ToolTip, [ Text, X, Y, WhichToolTip]
	ToolTip, %tipsHere%, toolX, toolY, 8
	SetTimer, noTip, %wait% ;--in 1/3 seconds by default, remove the tooltip
}

noTip:
	ToolTip,,,,8
return

;#!g::
; Return

GetTextWidth(YourText, sFaceName, nHeight = 9, bBold = False, bItalic = False, bUnderline = False, bStrikeOut = False, nCharSet = 0)
{
	hDC := DllCall("GetDC", "Uint", 0)
	nHeight := -DllCall("MulDiv", "int", nHeight, "int", DllCall("GetDeviceCaps", "Uint", hDC, "int", 90), "int", 72)

	hFont := DllCall("CreateFont", "int", nHeight, "int", 0, "int", 0, "int", 0, "int", 400 + 300 * bBold, "Uint", bItalic, "Uint", bUnderline, "Uint", bStrikeOut, "Uint", nCharSet, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", sFaceName)
	hFold := DllCall("SelectObject", "Uint", hDC, "Uint", hFont)

	DllCall("GetTextExtentPoint32", "Uint", hDC, "str", YourText, "int", StrLen(YourText), "int64P", nSize)

	DllCall("SelectObject", "Uint", hDC, "Uint", hFold)
	DllCall("DeleteObject", "Uint", hFont)
	DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)

	nWidth  := nSize & 0xFFFFFFFF
	nHeight := nSize >> 32 & 0xFFFFFFFF

	Return nWidth
}

;====================================================================================================================================================
; MOUSE
;====================================================================================================================================================

mouseInit()
{
	md := new mouseDelta(func("f"))
	md.start()
}

f(id,dx,dy,flags,data)
{
	static RI_MOUSE_WHEEL := 0x0400
	static mice := []
	static axis := ["y","x"]
	if !(flags & RI_MOUSE_WHEEL)
		return
	if id {
		if !mice.hasKey(id) {	; Setup
			mice[id]:=axis.pop()
			return 
		}
		myMouseMove(mice[id],data)
	}
}

myMouseMove(axis,dir)
{
	static step_size := 10	; Step size in pixels
	static sign := -1		; Change to 1 to change the direction of the movements
	local x:=0, y:=0
	%axis% := round(sign*dir * step_size / 120)
	mousemove, x, y, 0, R
}

Class MouseDelta
{
	State := 0
	__New(callback)
	{
		this.MouseMovedFn := this.MouseMoved.Bind(this)
		this.Callback := callback
	}

	;------------------------------------------------------------
	Start()
	{
		static DevSize := 8 + A_PtrSize, RIDEV_INPUTSINK := 0x00000100
		; Register mouse for WM_INPUT messages.
		VarSetCapacity(RAWINPUTDEVICE, DevSize)
		NumPut(1, RAWINPUTDEVICE, 0, "UShort")
		NumPut(2, RAWINPUTDEVICE, 2, "UShort")
		NumPut(RIDEV_INPUTSINK, RAWINPUTDEVICE, 4, "Uint")
		; WM_INPUT needs a hwnd to route to, so get the hwnd of the AHK Gui.
		; It doesn't matter if the GUI is showing, it still exists
		Gui +hwndhwnd
		NumPut(hwnd, RAWINPUTDEVICE, 8, "Uint")
 
		this.RAWINPUTDEVICE := RAWINPUTDEVICE
		DllCall("RegisterRawInputDevices", "Ptr", &RAWINPUTDEVICE, "UInt", 1, "UInt", DevSize )
		OnMessage(0x00FF, this.MouseMovedFn)
		this.State := 1
		return this	; allow chaining
	}
	
	;------------------------------------------------------------
	Stop()
	{
		static RIDEV_REMOVE := 0x00000001
		static DevSize := 8 + A_PtrSize
		OnMessage(0x00FF, this.MouseMovedFn, 0)
		RAWINPUTDEVICE := this.RAWINPUTDEVICE
		NumPut(RIDEV_REMOVE, RAWINPUTDEVICE, 4, "Uint")
		DllCall("RegisterRawInputDevices", "Ptr", &RAWINPUTDEVICE, "UInt", 1, "UInt", DevSize )
		this.State := 0
		return this	; allow chaining
	}
	
	;------------------------------------------------------------
	toggle()
	{
		return this.setState(!this.state)
	}
	
	;------------------------------------------------------------
	getState()
	{
		return this.state
	}
	
	;------------------------------------------------------------
	SetState(state)
	{
		if (state && !this.State)
			this.Start()
		else if (!state && this.State)
			this.Stop()
		return this	; allow chaining
	}
	
	;------------------------------------------------------------
	Delete()
	{
		this.Stop()
		this.MouseMovedFn := ""
	}
	
	;------------------------------------------------------------
	; Called when the mouse moved.
	; Messages tend to contain small (+/- 1) movements, and happen frequently (~20ms)
	MouseMoved(wParam, lParam)
	{
		Critical
		; RawInput statics
		static DeviceSize := 2 * A_PtrSize, iSize := 0, sz := 0, pcbSize:=8+2*A_PtrSize, offsets := {usButtonFlags:12+A_PtrSize*2, usButtonData:14+A_PtrSize*2, x: (20+A_PtrSize*2), y: (24+A_PtrSize*2)}, uRawInput

		; Get hDevice from RAWINPUTHEADER to identify which mouse this data came from
		VarSetCapacity(header, pcbSize, 0)
		if (!DllCall("GetRawInputData", "UPtr", lParam, "uint", 0x10000005, "UPtr", &header, "Uint*", pcbSize, "Uint", pcbSize) or ErrorLevel) {
			Return 0
		}
		
		if !(ThisMouse := NumGet(header, 8, "UPtr")) {
			return
		}
		
		; Find size of rawinput data - only needs to be run the first time.
		if (!iSize){
			r := DllCall("GetRawInputData", "UInt", lParam, "UInt", 0x10000003, "Ptr", 0, "UInt*", iSize, "UInt", 8 + (A_PtrSize * 2))
			VarSetCapacity(uRawInput, iSize)
		}
		sz := iSize	; param gets overwritten with # of bytes output, so preserve iSize
		; Get RawInput data
		r := DllCall("GetRawInputData", "UInt", lParam, "UInt", 0x10000003, "Ptr", &uRawInput, "UInt*", sz, "UInt", 8 + (A_PtrSize * 2))
 
		; Ensure we always report a number for an axis. Needed? - No it is overwritten by the numget. 
		dx := NumGet(&uRawInput, offsets.x, "Int")
		dy := NumGet(&uRawInput, offsets.y, "Int")
		
		usButtonFlags:=NumGet(&uRawInput, offsets.usButtonFlags, "UShort")	; Transition state of the mouse buttons.
		usButtonData:=NumGet(&uRawInput, offsets.usButtonData, "Short")		; Contains mouse wheel delta, if usButtonFlags=RI_MOUSE_WHEEL=0x0400
		
		;this.Callback.(ThisMouse, dx, dy, usButtonFlags, usButtonData)
		
		; \\?\HID#VID_1BCF&PID_0005#7&35a657bd&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd} (3D Mouse Happens)
		; \\?\HID#VID_046D&PID_C53F&MI_01&Col01#8&390bcb53&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd} (G305)
		; \\?\HID#VID_04D9&PID_A01C&MI_01&Col01#8&35678ec0&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd} (Mouse Bright)
		; \\?\HID#DRIVERENUM&Col01#6&15d781bd&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}
		; \\?\ACPI#SYN1222#3#{378de44c-56ef-11d1-bc8c-00a0c91405dd}

		MouseID_g305 := "\\?\HID#VID_046D&PID_C53F&MI_01&Col01#8&390bcb53&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
		MouseID_3d := "\\?\HID#VID_1BCF&PID_0005#7&35a657bd&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
		MouseID_bright := "\\?\HID#VID_04D9&PID_A01C&MI_01&Col01#8&15884e3e&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"

		;KeyBoarID_bright := "\\?\HID#VID_04D9&PID_A01C&MI_00#8&2583200&0&0000#{884b96c3-56ef-11d1-bc8c-00a0c91405dd}"

		Mouse := KeyboardName(ThisMouse)
		;MouseID := between(Mouse, "\\?\HID#", "0005#")
		MouseID := MouseID_3d
		
		;Handle := NumGet(&uRawInput, 2 * 4, "UInt")
		;MsgBox, %Handle%

		;HID0 = 1
		;HID%HID0%_Name   := AHKHID_GetDevName(HID0)
		;MsgBox, HID%HID0%_Name
		
		;MsgBox, %MouseID%
		;MsgBox, %Mouse%
		;MsgBox, %usButtonFlags%

		if(Mouse = MouseID_3d)
		{
			if (usButtonData = 120) ;whell up
			{
				;Send {Volume_Up}
				;1=??; 2=PA 3=??; 4=AIRDOTS; 5=voicemmeter_AUX; 6=??; 7=voicemmeter_VAIO3, 8=voicemmeter; 9=HECATE
				SoundSet, +2 , MASTER, VOLUME, 2 ;PA
				SoundSet, +2 , MASTER, VOLUME, 9 ;HECATE
				SoundSet, +2 , MASTER, VOLUME, 4 ;AIRDOTS
				SoundSet, +1 , MASTER, VOLUME, 3 ;T7
			} 
			else if (usButtonData = -120) ;whell down
			{
				;Send {Volume_Down}
				SoundSet, -2 , MASTER, VOLUME, 2 ;PA
				SoundSet, -2 , MASTER, VOLUME, 9 ;HECATE
				SoundSet, -2 , MASTER, VOLUME, 4 ;AIRDOTS
				SoundSet, -1 , MASTER, VOLUME, 3 ;T7
			}
			else if (usButtonFlags = 256) ;botao forwad
			{
				if (Media_mode < 2)
				{
					Media_mode += 1
				}
				if(media_mode == modeMusic)
				{
					DefaultMusicSettings()
				}
				Else if(media_mode == modeLema)
				{
					DefaultLemaSettings()
				}
				Else if(media_mode == modeAltium)
				{
					DefaultAltiumSettings()
				}
				;Send {Media_Next}
			}
			else if (usButtonFlags = 64) ;botao backward
			{
				if (Media_mode > 0)
				{
					Media_mode -= 1
				}
				if(media_mode == modeMusic)
				{
					DefaultMusicSettings()
				}
				Else if(media_mode == modeLema)
				{
					DefaultLemaSettings()
				}
				Else if(media_mode == modeAltium)
				{
					DefaultAltiumSettings()
				}
				;Send {Media_Prev}
			}
			else if (usButtonFlags = 32) ;whell click down
			{
				;Send {Media_Play_Pause}
			}
		}
		if(Mouse = MouseID_bright)
		{
			if (usButtonData = 120) ;whell up
			{
				;Send {Volume_Up}
				SoundSet, +2 , MASTER, VOLUME, 2 ;PA
				SoundSet, +2 , MASTER, VOLUME, 9 ;HECATE
				SoundSet, +2 , MASTER, VOLUME, 4 ;AIRDOTS
				SoundSet, +1 , MASTER, VOLUME, 3 ;T7
			} 
			else if (usButtonData = -120) ;whell down
			{
				;Send {Volume_Down}
				SoundSet, -2 , MASTER, VOLUME, 2 ;PA
				SoundSet, -2 , MASTER, VOLUME, 9 ;HECATE
				SoundSet, -2 , MASTER, VOLUME, 4 ;AIRDOTS
				SoundSet, -1 , MASTER, VOLUME, 3 ;T7
			}
			;else if (usButtonFlags = 256) ;botao forwad
			;{
				;Send {Media_Next}
			;}
			;else if (usButtonFlags = 64) ;botao backward
			;{
				;Send {Media_Prev}
			;}
			else if (usButtonFlags = 32) ;whell click down
			{
				;Send {Media_Play_Pause}
			}
		}
		else if(Mouse = MouseID_g305)
		{
		 	if (usButtonData = 120) ;whell up
			{
		 		MouseClick, WheelUp
		 	}
		 	else if (usButtonData = -120) ;whell down
			{
		 		MouseClick, WheelDown
		 	}
			else if (usButtonFlags = 256) ;botao forwad
			{
				Send {XButton2}
			}
			else if (usButtonFlags = 64) ;botao backward
			{
				Send {XButton1}
			}
			else if (usButtonFlags = 32) ;whell click up
			{
				if (WheelMidState != "WheelMid_solto")
				{
					if(GetKeyState("LShift", "P"))
					{
						Send {LShift Up}
					}
					if(GetKeyState("Ctrl", "P"))
					{
						Send {LCtrl Up}
					}
				}
				;Send {RButton Up}
  				WheelMidState := "WheelMid_solto"
			}
			else if (usButtonFlags = 16) ;whell click up
			{
				if (WheelMidState != "WheelMid_clicado")
				{
					MouseClick, middle
					if(GetKeyState("LShift", "P"))
					{
						Send {LShift Up}
					}
					if(GetKeyState("Ctrl", "P"))
					{
						Send {LCtrl Up}
					}
				}
				;Send {RButton Up}
  				WheelMidState := "WheelMid_clicado"
			}
			else if (usButtonFlags = 8) ;botao direito solto------------------------------------------------------------
			{
				if (RButtonState != "RButtonState_solto")
				{
					if(GetKeyState("LShift", "P"))
					{
						Send {LShift Up}
					}
					if(GetKeyState("Ctrl", "P"))
					{
						Send {LCtrl Up}
					}
				}
				;Send {RButton Up}
  				RButtonState := "RButtonState_solto"	
			}
			else if (usButtonFlags = 4) ;botao direito clicado------------------------------------------------------------
			{
				if (RButtonState != "RButtonState_clicado")
				{
					if(GetKeyState("LShift", "P"))
					{
						Send {LShift Down}
					}
					if(GetKeyState("LCtrl", "P"))
					{
						Send {LCtrl Down}
					}
				}
				;Send {RButton Down}
				RButtonState := "RButtonState_clicado"
			}
			else if (usButtonFlags = 2) ;botao esquerdo solto------------------------------------------------------------
			{
				if (LButtonState != "LButtonState_solto")
				{
					if(GetKeyState("Shift", "P"))
					{
						Send {LShift Up}
					}
					if(GetKeyState("Ctrl", "P"))
					{
						Send {LCtrl Up}
					}
				}
				;Send {LButton Up}
  				LButtonState := "LButtonState_solto"			
			}
			else if (usButtonFlags = 1) ;botao esquerdo clicado------------------------------------------------------------
			{
				if (LButtonState != "LButtonState_clicado")
				{
					if(GetKeyState("Shift", "P"))
					{
						Send {LShift Down}
					}
					if(GetKeyState("Ctrl", "P"))
					{
						Send {LCtrl Down}
					}
				}
				;Send {LButton Down}
				LButtonState := "LButtonState_clicado"
			}
		}
		; else if(HID1_Name == KeyBoarID_bright)
		; {
		; 	;MsgBox, "OK!!!"
		; 	if(GetKeyState("X", "P"))
		; 	{
		; 		MsgBox, "OK!!!"
		; 	}
		; }
	}
}

between(string, left, right) {
    if (strLen(left) > 1)    ;# if its a word or sentence
        {
        string := strReplace(string, left, "¢")    ; replace with symbol
        left := "¢"                                ; set new deliminator
        }
    if (strLen(right) > 1)
        {
        string := strReplace(string, right, "¢")
        right := "¢"
        }
    stringSplit, split, string, % left    ;# if its a single character
    stringSplit, split, split2, % right
    return split1
}

MouseName(h) {
	DllCall("GetRawInputDeviceInfo",Int,h,UInt,0x20000007,Int,0,"UInt*",l)
	VarSetCapacity(Name,l*2+2)
	DllCall("GetRawInputDeviceInfo",Int,h,UInt,0x20000007,Str,Name,"UInt*",l)
	return Name
}

get_hid()	; Retrieve info for each device
{ 
	iCount := AHKHID_GetDevCount()
	Loop 5 {
		
		HID0 += 1
		;Get device handle, type and name
		HID%HID0%_Handle := AHKHID_GetDevHandle(HID0)
		HID%HID0%_Type   := AHKHID_GetDevType(HID0)
		HID%HID0%_Name   := AHKHID_GetDevName(HID0)
		
		;Get device info
		If (HID%HID0%_Type = RIM_TYPEMOUSE) {
			HID%HID0%_ID            := AHKHID_GetDevInfo(HID0, DI_MSE_ID)
			HID%HID0%_Buttons       := AHKHID_GetDevInfo(HID0, DI_MSE_NUMBEROFBUTTONS)
			HID%HID0%_SampleRate    := AHKHID_GetDevInfo(HID0, DI_MSE_SAMPLERATE)
			;If(HID%HID0%_Name = "\\?\HID#VID_1BCF&PID_0005#8&110be8c&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}") {
			;	Mouse2_ID := "\\?\HID#VID_1BCF&PID_0005#8&110be8c&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
			;	MsgBox, %Mouse2_ID%
			;}
			;If bVista ;Only supported in Windows Vista and higher {
			;	HID%HID0%_HWheel    := AHKHID_GetDevInfo(HID0, DI_MSE_HASHORIZONTALWHEEL)
			;}
			
			;MsgBox, FOI
		} Else If (HID%HID0%_Type = RIM_TYPEKEYBOARD) {
			HID%HID0%_KBType        := AHKHID_GetDevInfo(HID0, DI_KBD_TYPE)
			HID%HID0%_KBSubType     := AHKHID_GetDevInfo(HID0, DI_KBD_SUBTYPE)
			HID%HID0%_KeyboardMode  := AHKHID_GetDevInfo(HID0, DI_KBD_KEYBOARDMODE)
			HID%HID0%_FunctionKeys  := AHKHID_GetDevInfo(HID0, DI_KBD_NUMBEROFFUNCTIONKEYS)
			HID%HID0%_Indicators    := AHKHID_GetDevInfo(HID0, DI_KBD_NUMBEROFINDICATORS)
			HID%HID0%_KeysTotal     := AHKHID_GetDevInfo(HID0, DI_KBD_NUMBEROFKEYSTOTAL)*/
		} Else If (HID%HID0%_Type = RIM_TYPEHID) {
			HID%HID0%_VendorID      := AHKHID_GetDevInfo(HID0, DI_HID_VENDORID)
			HID%HID0%_ProductID     := AHKHID_GetDevInfo(HID0, DI_HID_PRODUCTID)
			HID%HID0%_VersionNumber := AHKHID_GetDevInfo(HID0, DI_HID_VERSIONNUMBER)
			HID%HID0%_UsagePage     := AHKHID_GetDevInfo(HID0, DI_HID_USAGEPAGE)
			HID%HID0%_Usage         := AHKHID_GetDevInfo(HID0, DI_HID_USAGE)
		}
	}
}

; second mouse keys
WheelUp::
WheelDown::
XButton1::
XButton2::
MButton::

; ------------------------------ Includes --------------------------------------------
; ------------------------------ Definitions -----------------------------------------
; ------------------------------ Structures ------------------------------------------
; ------------------------------ Local Functions -------------------------------------
; ------------------------------ Variables -------------------------------------------
; ------------------------------ Implementation --------------------------------------