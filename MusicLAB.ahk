/*
 *************************************************************************************
 *                                MUSIC LAB SCRIPT                                   *
 *************************************************************************************

 ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
| PA  | G1  | EAR | T7  |     |     |     |     |     |     |     |     |     |     |     |     |
| EQ  | EQ  | EQ  |     |     |     |     |     |     |     |     |     |     |     |     |     |
 ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
 ------- ------- ------- ------- ------- ------- ------- ------- ------- ------- ------- -------
|  PA   |  G1   |  EAR  |  T7   | CSGO  |       |       |       |       |       |       |       |
|  MUT  |  MUT  |  MUT  |  MUT  |  MUT  |       |       |       |       |       |       |       |
 ------- ------- ------- ------- ------- ------- ------- ------- ------- ------- ------- -------
 --- ------- ------- ------- ------- ------- ------- ------- ------- ------- ------- ----- -----
|   |  PA+  |  G1+  | EAR+  |  T7+  | CSGO+ |       |       |       |       |       |     |     |
|   |   +   |   +   |   +   |   +   |   +   |       |       |       |       |       |     |     |
 --- ------- ------- ------- ------- ------- ------- ------- ------- ------- ------- ----- -----
 ----- ------- ------- ------- ------- ------- ------- ------- ------- ------- ------- ---------
|     |  PA-  |  G1-  | EAR-  |  T7-  | CSGO- |       |       |       |       |       |         |
|     |   -   |   -   |   -   |   -   |   -   |       |       |       |       |       |         |
 ----- ------- ------- ------- ------- ------- ------- ------- ------- ------- ------- ---------
 --------- ------- ------- ------- ------- ------- ------- ------- ----- ----- ----- ----- -----
|         |  PA   |  G1   | EAR   |  T7   | CSGO  |       |       |     |     |     |     |     |
|         |  0.0  |  0.0  |  0.0  |  0.0  |  0.0  |       |       |     |     |     |     |     |
 --------- ------- ------- ------- ------- ------- ------- ------- ----- ----- ----- ----- -----
 ----- ----- ----- ----- ----- ----------------------------- ----- ----- ----- ----- ----- -----
|     |     |     |     |     |		RESTART AUDIO ENGINE    |     |     |     |     |     |     |
 ----- ----- ----- ----- ----- ----------------------------- ----- ----- ----- ----- ----- -----

 */

; ------------------------------ Includes --------------------------------------------
#Requires AutoHotkey v1.1
#Include, VMR.ahk
#Include, AHKHID.ahk
#Include, va.ahk
; #Include sound_card_init.ahk

; Gui, Add, ListView, w800 h400 vMyListView, Component Type|Control Type|Setting|Mixer|Name
; LV_ModifyCol(4, "Integer")
; scGui := Gui(, "Sound Components")
; scLV := scGui.Add('ListView', "w600 h400", ["Component", "#", "Device", "Volume", "Mute"])
; devMap := Map()



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
;SetTimer, soundCardCheck, 5000

; ------------------------------ Variables -------------------------------------------

; Most of the pure numbers below probably don't exist in any mixer, but they're queried for completeness.
; The numbers correspond to the following items (in order): CUSTOM, BOOLEANMETER, SIGNEDMETER, PEAKMETER,
; UNSIGNEDMETER, BOOLEAN, BUTTON, DECIBELS, SIGNED, UNSIGNED, PERCENT, SLIDER, FADER, SINGLESELECT, MUX,
; MULTIPLESELECT, MIXER, MICROTIME, MILLITIME
global ControlTypes := "VOLUME,ONOFF,MUTE,MONO,LOUDNESS,STEREOENH,BASSBOOST,PAN,QSOUNDPAN,BASS,TREBLE,EQUALIZER,0x00000000, 0x10010000,0x10020000,0x10020001,0x10030000,0x20010000,0x21010000,0x30040000,0x30020000,0x30030000,0x30050000,0x40020000,0x50030000,0x70010000,0x70010001,0x71010000,0x71010001,0x60030000,0x61030000"
global ComponentTypes := "MASTER,HEADPHONES,DIGITAL,LINE,MICROPHONE,SYNTH,CD,TELEPHONE,PCSPEAKER,WAVE,AUX,ANALOG,NA"
global DeviceName := ""

global DEVICE_PA_ID				:= 0
global DEVICE_HECATE_ID			:= 0
global DEVICE_REDMI_ID			:= 0
global DEVICE_MI_ID				:= 0
global DEVICE_T7_ID				:= 0
global DEVICE_LINE_OUT_ID		:= 0

global DEVICE_PA_ID_OK 			:= 0 ;PA
global DEVICE_HECATE_ID_OK		:= 0 ;HECATE
global DEVICE_REDMI_ID_OK 		:= 0 ;REDMI
global DEVICE_MI_ID_OK 			:= 0 ;MI
global DEVICE_T7_ID_OK 			:= 0 ;T7
global DEVICE_LINE_OUT_ID_OK	:= 0 ;LINE OUT

; ---------- VoiceMeeter
global sss
global nType
global szName
global szHardwareId
global voicemeeter_path := "C:\Program Files (x86)\VB\Voicemeeter\"
global voicemeeter_app 	:= "voicemeeter8x64.exe"
global soundcard_analisys_path := "C:\AHK\MediaControl\"
global soundcard_analisys_app := "soundcard_analisys.exe"

;global media_mode	:= 0 
;global modeMusic	:= 0
;global modeLema	:= 1
;global modeAltium	:= 2

global MediaMode	:= 0 
global mode_Music	:= 0
global mode_Drum	:= 1
global mode_Lema	:= 2
global mode_Altium	:= 3

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
global audioSourceMute := 0

; ---------- Mouse
global LastMouseState := ""
global LButtonState := "LButtonState_solto"
global RButtonState := "RButtonState_solto"
global WheelMidState := "WheelMid_solto"
; global MouseID_g305 := "\\?\HID#VID_046D&PID_C53F&MI_01&Col01#8&390bcb53&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
; global MouseID_3d := "\\?\HID#VID_1BCF&PID_0005#7&35a657bd&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
; global MouseID_bright := "\\?\HID#VID_04D9&PID_A01C&MI_01&Col01#8&15884e3e&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
; global MouseID_sculpt := "\\?\HID#VID_045E&PID_07A5&MI_01&Col01#8&181bbcc8&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
; global KeyBoarID_bright := "\\?\HID#VID_04D9&PID_A01C&MI_01&Col01#8&15884e3e&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
global MouseID_g305 := "HID#VID_046D&PID_C53F&MI_01&Col01#"
global MouseID_g203 := "HID#VID_046D&PID_C092&MI_00#7&1ff824c5&0&0000#"
global MouseID_3d := "HID#VID_1BCF&PID_0005#"
global MouseID_bright := "HID#VID_04D9&PID_A01C&MI_01&Col01#"
global MouseID_sculpt := "HID#VID_045E&PID_07A5&MI_01&Col01#"
global KeyBoarID_bright := "HID#VID_04D9&PID_A01C&MI_01&Col01#"
global Mouse2_ID := ""
global key
global DeviceID := 0

; ------------------------------ Initialization --------------------------------------

AHKHID_UseConstants() ; Set up the constants

voicemeeterInit()

soundCardInit()

OpenSoundcardAnalisys()

mouseInit()

DefaultMusicSettings()	; Set default voicemeeter settingsx

; KeyboardInit() ; 2nd keyboard with Luamacros: https://www.youtube.com/watch?v=Arn8ExQ2Gjg

; ------------------------------ Implementation --------------------------------------

; Loop
; {
; 	SetTimer, soundCardCheck, 5000
; }

soundCardCheck:
{
	;soundCardInit()
	;MsgBox, "OK!!!"
}

;====================================================================================================================================================
; SOUND CARD SETUP
;====================================================================================================================================================
soundCardInit()
{
	; Create a ListView and prepare for the main loop:
	DEVICE_PA_ID	       	:= 0
	DEVICE_HECATE_ID		:= 0
	DEVICE_REDMI_ID			:= 0
	DEVICE_MI_ID			:= 0
	DEVICE_T7_ID			:= 0
	DEVICE_LINE_OUT_ID		:= 0
	
	DEVICE_PA_ID_OK 		:= 0 ;PA
	DEVICE_HECATE_ID_OK		:= 0 ;HECATE
	DEVICE_REDMI_ID_OK 		:= 0 ;REDMI
	DEVICE_MI_ID_OK 		:= 0 ;MI
	DEVICE_T7_ID_OK 		:= 0 ;T7
	DEVICE_LINE_OUT_ID_OK	:= 0 ;LINE OUT

	Loop
	{
		FileReadLine, Line, C:\AHK\MediaControl\SoundDeviceFile.txt, %A_Index%
		if ErrorLevel
			break
		; MsgBox, 4, , Line #%A_Index% is "%Line%".  Continue?
		IfMsgBox, No
			return

		StringLeft, DeviceID, Line, 2
		StringRight, DeviceName, Line, StrLen(Line)-3

		; MsgBox, %DeviceID%
		; MsgBox, %DeviceName%

		if( DeviceName = "FONE (HECATE G1 GAMING HEADSET)" )
		{
			if(DEVICE_HECATE_ID_OK = 0)
			{
				DEVICE_HECATE_ID_OK := 1
				DEVICE_HECATE_ID := DeviceID
				; MsgBox %DeviceName% %CurrMixerNum%
				; LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
			}
		}
		if( (DeviceName = "PA (Realtek High Definition Audio)" || DeviceName = "PA (High Definition Audio Device)") )
		{
			if(DEVICE_PA_ID_OK = 0)
			{
				DEVICE_PA_ID_OK := 1
				DEVICE_PA_ID := DeviceID
				; MsgBox %DeviceName% %CurrMixer%
				; LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
			}
		}
		if( DeviceName = "MI (Mi True Wireless EBs Basic 2 Stereo)" )
		{
			if(DEVICE_MI_ID_OK = 0)
			{
				DEVICE_MI_ID_OK := 1
				DEVICE_MI_ID := DeviceID
				;MsgBox %DeviceName% %CurrMixer%
				; LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
			}
		}
		if( DeviceName = "Fones de ouvido (Redmi AirDots_R Stereo)" )
		{
			if(DEVICE_REDMI_ID_OK = 0)
			{
				DEVICE_REDMI_ID_OK := 1
				DEVICE_REDMI_ID := DeviceID
				;MsgBox %DeviceName% %CurrMixer%
				; LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
			}
		}
		if( DeviceName = "T7 (T7 Stereo)" )
		{
			if(DEVICE_T7_ID_OK = 0)
			{
				DEVICE_T7_ID_OK := 1
				DEVICE_T7_ID := DeviceID
				;MsgBox %DeviceName% %CurrMixer%
				; LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
			}
		}
		if( (DeviceName = "LINE_OUT (Generic USB Audio Device)" || DeviceName = "LINE_OUT (USB PnP Sound Device)") )
		{
			if(DEVICE_LINE_OUT_ID_OK = 0)
			{
				DEVICE_LINE_OUT_ID_OK := 1
				DEVICE_LINE_OUT_ID := DeviceID
				;MsgBox %DeviceName% %CurrMixer%
				; LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
			}
		}
	}
}


;====================================================================================================================================================
; SOUND CARD
;====================================================================================================================================================
; soundCardInit()
; {
; 	; Create a ListView and prepare for the main loop:
; 	DEVICE_PA_ID	       	:= 0
; 	DEVICE_HECATE_ID		:= 0
; 	DEVICE_REDMI_ID			:= 0
; 	DEVICE_MI_ID			:= 0
; 	DEVICE_T7_ID			:= 0
; 	DEVICE_LINE_OUT_ID		:= 0
	
; 	DEVICE_PA_ID_OK 		:= 0 ;PA
; 	DEVICE_HECATE_ID_OK		:= 0 ;HECATE
; 	DEVICE_REDMI_ID_OK 		:= 0 ;REDMI
; 	DEVICE_MI_ID_OK 		:= 0 ;MI
; 	DEVICE_T7_ID_OK 		:= 0 ;T7
; 	DEVICE_LINE_OUT_ID_OK	:= 0 ;LINE OUT
; 	Loop  ; For each mixer number that exists in the system, query its capabilities.
; 	{
; 		CurrMixer := A_Index
; 		SoundGet, Setting,,, %CurrMixer%

; 		if (ErrorLevel = "Can't Open Specified Mixer")  ; Any error other than this indicates that the mixer exists.
; 			break

; 		; For each component type that exists in this mixer, query its instances and control types:
; 		Loop, parse, ComponentTypes, `,
; 		{
; 			CurrComponent := A_LoopField
; 			; First check if this component type even exists in the mixer:
; 			SoundGet, Setting, %CurrComponent%,, %CurrMixer%
; 			if (ErrorLevel = "Mixer Doesn't Support This Component Type")
; 				continue  ; Start a new iteration to move on to the next component type.
; 			Loop  ; For each instance of this component type, query its control types.
; 			{
; 				CurrInstance := A_Index        
; 				; First check if this instance of this instance even exists in the mixer:
; 				SoundGet, Setting, %CurrComponent%:%CurrInstance%,, %CurrMixer%
; 				; Checking for both of the following errors allows this script to run on older versions:
; 				if ErrorLevel in Mixer Doesn't Have That Many of That Component Type,Invalid Control Type or Component Type
; 					break  ; No more instances of this component type.
; 				; Get the current setting of each control type that exists in this instance of this component:
; 				Loop, parse, ControlTypes, `,
; 				{
; 					CurrControl := A_LoopField
; 					SoundGet, Setting, %CurrComponent%:%CurrInstance%, %CurrControl%, %CurrMixer%

; 					; Checking for both of the following errors allows this script to run on older versions:
; 					if ErrorLevel in Component Doesn't Support This Control Type,Invalid Control Type or Component Type
; 						continue
; 					if ErrorLevel  ; Some other error, which is unexpected so show it in the results.
; 						Setting := ErrorLevel
; 					ComponentString := CurrComponent
; 					if (CurrInstance > 1)
; 						ComponentString := ComponentString ":" CurrInstance
; 					;CurrMixerNum := StrGet(&CurrMixer,"UTF-16") ;string2 := NumGet(string1) ;convert string to number ;string3 := StrGet(&string2,,"UTF-16") ;convert number back to string
; 					; CurrMixerNum := StrGet(&CurrMixer,"UTF-8")
; 					; MsgBox %CurrMixer%
; 					CurrMixerNum := CurrMixer
;                 	VA_dev := VA_GetDevice(CurrMixerNum)
; 					; MsgBox VA_dev: %VA_dev%, CurrMixer: %CurrMixerNum%

; 					if(VA_dev = 0)
; 					{
; 						DeviceName := "OFFLINE"
; 						LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
; 					}
; 					else ;if(ComponentString = "MASTER" && CurrControl = "VOLUME")						
; 					{
; 						; MsgBox VA_dev: %VA_dev%, CurrMixer: %CurrMixerNum%
; 						; if(ComponentString = "MASTER" && CurrControl = "VOLUME")
; 						; {
; 							DeviceName := VA_GetDeviceName(VA_dev)
; 							;LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
; 							; MsgBox %DeviceName% %CurrMixer%
; 							if(DeviceName = "FONE (HECATE G1 GAMING HEADSET)" && ComponentString = "MASTER" && CurrControl = "VOLUME")
; 							{
; 								if(DEVICE_HECATE_ID_OK = 0)
; 								{
; 									DEVICE_HECATE_ID_OK := 1
; 									DEVICE_HECATE_ID := CurrMixerNum
; 									; MsgBox %DeviceName% %CurrMixerNum%
; 									LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
; 								}
; 							}
; 							if((DeviceName = "PA (Realtek High Definition Audio)" || DeviceName = "PA (High Definition Audio Device)") && ComponentString = "MASTER" && CurrControl = "VOLUME")
; 							{
; 								if(DEVICE_PA_ID_OK = 0)
; 								{
; 									DEVICE_PA_ID_OK := 1
; 									DEVICE_PA_ID := CurrMixerNum
; 									; MsgBox %DeviceName% %CurrMixer%
; 									LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
; 								}
; 							}
; 							if(DeviceName = "MI (Mi True Wireless EBs Basic 2 Stereo)" && ComponentString = "MASTER" && CurrControl = "VOLUME")
; 							{
; 								if(DEVICE_MI_ID_OK = 0)
; 								{
; 									DEVICE_MI_ID_OK := 1
; 									DEVICE_MI_ID := CurrMixerNum
; 									;MsgBox %DeviceName% %CurrMixer%
; 									LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
; 								}
; 							}
; 							if(DeviceName = "REDMI (Redmi AirDots_R Stereo)" && ComponentString = "MASTER" && CurrControl = "VOLUME")
; 							{
; 								if(DEVICE_REDMI_ID_OK = 0)
; 								{
; 									DEVICE_REDMI_ID_OK := 1
; 									DEVICE_REDMI_ID := CurrMixerNum
; 									;MsgBox %DeviceName% %CurrMixer%
; 									LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
; 								}
; 							}
; 							if(DeviceName = "T7 (T7 Stereo)" && ComponentString = "MASTER" && CurrControl = "VOLUME")
; 							{
; 								if(DEVICE_T7_ID_OK = 0)
; 								{
; 									DEVICE_T7_ID_OK := 1
; 									DEVICE_T7_ID := CurrMixerNum
; 									;MsgBox %DeviceName% %CurrMixer%
; 									LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
; 								}
; 							}
; 							if( (DeviceName = "LINE_OUT (Generic USB Audio Device)" || DeviceName = "LINE_OUT (USB PnP Sound Device)") && ComponentString = "MASTER" && CurrControl = "VOLUME" )
; 							{
; 								if(DEVICE_LINE_OUT_ID_OK = 0)
; 								{
; 									DEVICE_LINE_OUT_ID_OK := 1
; 									DEVICE_LINE_OUT_ID := CurrMixerNum
; 									;MsgBox %DeviceName% %CurrMixer%
; 									LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
; 								}
; 							}
; 						; }
; 						; MsgBox %ComponentString% %CurrControl% %Setting% %CurrMixer% %DeviceName%
; 						;LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
; 					}
; 					;LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
; 				}  ; For each control type.
; 			}  ; For each component instance.
; 		}  ; For each component type.
; 	}  ; For each mixer.

; 	;Loop % LV_GetCount("Col")  ; Auto-size each column to fit its contents.
; 	;	LV_ModifyCol(A_Index, "AutoHdr")

; 	; Loop % LV_GetCount("Col")  ; Auto-size each column to fit its contents.
; 	; 	LV_ModifyCol(A_Index, "AutoHdr")

; 	Gui, Show

; 	delay_time := 100
; 	message := "..............."
; 	tippy(message)
; 	Sleep, delay_time
; 	message := ".......<>......"
; 	tippy(message)
; 	Sleep, delay_time
; 	message := "......<<>>......"
; 	tippy(message)
; 	Sleep, delay_time
; 	message := ".....<<<>>>....."
; 	tippy(message)
; 	Sleep, delay_time
; 	message := "....<<<IC>>>...."
; 	tippy(message)
; 	Sleep, delay_time
; 	message := "...<<<SICL>>>..."
; 	tippy(message)
; 	Sleep, delay_time
; 	message := "..<<<USICLA>>>.."
; 	tippy(message)
; 	Sleep, delay_time
; 	message := ".<<<MUSICLAB>>>."
; 	tippy(message)
; 	Sleep, delay_time

; 	;MsgBox %DEVICE_PA_ID% %DEVICE_HECATE_ID% %DEVICE_AIRDOTS_ID% %DEVICE_T7_ID%
; 	; rep := voicemeeter.VBVMR_Output_GetDeviceDescA(1, &nType, szName, szHardwareId)
; 	; if (rep == 0)
; 	; {
; 	; 	switch nType
; 	; 	{
; 	; 		case VBVMR_DEVTYPE_MME:
; 	; 			;sprintf(sss,"MME: %s",szName)
; 	; 			;tippy(sss)
; 	; 			;tippy(sprintf("%p%n","Int",65, "Int",&szName))
; 	; 			return
; 	; 		case VBVMR_DEVTYPE_WDM:
; 	; 			;sprintf(sss,"WDM: %s",szName)
; 	; 			;tippy(sss)
; 	; 			;tippy(sprintf("%p%n","Int",65, "Int",&szName))
; 	; 			return
; 	; 		case VBVMR_DEVTYPE_KS:
; 	; 			;sprintf(sss,"KS: %s",szName)
; 	; 			;tippy(sss)
; 	; 			;tippy(sprintf("%p%n","Int",65, "Int",&szName))
; 	; 			return
; 	; 		case VBVMR_DEVTYPE_ASIO:
; 	; 			;sprintf(sss,"ASIO: %s",szName)
; 	; 			;tippy(sss)
; 	; 			;tippy(sprintf("%p%n","Int",65, "Int",&szName))
; 	; 			return
; 	; 	}
; 	; 	;tippy(message)
; 	; }
; 	; tippy("OK!!!!!!!!!!!!!!!!!!")
; 	; MsgBox %DEVICE_HECATE_ID% %DEVICE_PA_ID%
; }

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

	IfWinExist ahk_exe %voicemeeter_app%
	{
		voicemeeterVisible = 1
	}
	else
	{
		voicemeeterVisible = 0
	}
}

DefaultMusicSettings()
{
	SetNumLockState, Off

	; Out BUS Assignation
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].A1", "Float", 1.0)

	; Gain slider
    ; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[0].Gain", "Float", 12.0)   ; Set the Microphone
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].Gain", "Float", 0.0)   ; Set the HDL Line In volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Gain", "Float", -60.0)  ; Set the Imput3 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Gain", "Float", -60.0)  ; Set the Imput4 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Gain", "Float", -60.0)  ; Set the Imput5 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[5].Gain", "Float", 0.0)    ; Set the voicemeeter VAIO volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[6].Gain", "Float", 0.0)  ; Set the voicemeeter AUX volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[7].Gain", "Float", 0.0)  ; Set the voicemeeter VAIO 3 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].Gain", "Float", 0.0)      ; Set the PA output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].Gain", "Float", 0.0)      ; Set the PHONE output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].Gain", "Float", 0.0)      ; Set the EAR output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].Gain", "Float", 0.0)      ; Set the T7 output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].Gain", "Float", 0.0)      ; Set the HDL output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[5].Gain", "Float", 0.0)      ; Set the HDL output volume

	; Mute Button
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Mute", "Float", 1.0)    ; Set Imput3 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Mute", "Float", 1.0)    ; Set Imput4 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Mute", "Float", 1.0)    ; Set Imput5 Mute
	;Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[6].Mute", "Float", 1.0)    ; Set voicemeeter AUX to On
	;Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[7].Mute", "Float", 1.0)    ; Set voicemeeter VAIO 3 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[6].Mute", "Float", 1.0)      ; Set B2 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[7].Mute", "Float", 1.0)      ; Set B3 Mute

	; EQ Button
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].EQ.on", "Float", 1.0)     ; Sets PA equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].EQ.on", "Float", 1.0)     ; Sets PHONE equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].EQ.on", "Float", 1.0)     ; Sets EAR equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].EQ.on", "Float", 1.0)     ; Sets T7 equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].EQ.on", "Float", 1.0)     ; Sets HDL equalizer ON
	; show_message = "MUSIC MODE"
	; tippy(show_message)
}

DefaultLemaSettings()
{
	; Out BUS Assignation
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].A1", "Float", 0.0)

	; Gain slider
    ; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[0].Gain", "Float", 12.0)   ; Set the Microphone
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].Gain", "Float", 0.0)   ; Set the HDL Line In volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Gain", "Float", -60.0)  ; Set the Imput3 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Gain", "Float", -60.0)  ; Set the Imput4 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Gain", "Float", -60.0)  ; Set the Imput5 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[5].Gain", "Float", 0.0)    ; Set the voicemeeter VAIO volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[6].Gain", "Float", 0.0)  ; Set the voicemeeter AUX volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[7].Gain", "Float", 0.0)  ; Set the voicemeeter VAIO 3 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].Gain", "Float", 0.0)      ; Set the PA output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].Gain", "Float", 0.0)      ; Set the PHONE output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].Gain", "Float", 0.0)      ; Set the EAR output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].Gain", "Float", 0.0)      ; Set the T7 output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].Gain", "Float", 0.0)      ; Set the HDL output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[5].Gain", "Float", 0.0)      ; Set the HDL output volume

	; Mute Button
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Mute", "Float", 1.0)    ; Set Imput3 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Mute", "Float", 1.0)    ; Set Imput4 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Mute", "Float", 1.0)    ; Set Imput5 Mute
	;Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[6].Mute", "Float", 1.0)    ; Set voicemeeter AUX to On
	;Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[7].Mute", "Float", 1.0)    ; Set voicemeeter VAIO 3 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[6].Mute", "Float", 1.0)      ; Set B2 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[7].Mute", "Float", 1.0)      ; Set B3 Mute

	; EQ Button
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].EQ.on", "Float", 1.0)     ; Sets PA equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].EQ.on", "Float", 1.0)     ; Sets PHONE equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].EQ.on", "Float", 1.0)     ; Sets EAR equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].EQ.on", "Float", 1.0)     ; Sets T7 equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].EQ.on", "Float", 1.0)     ; Sets HDL equalizer ON
	; show_message = "LEMA MODE"
	; tippy(show_message)
}

DefaultAltiumSettings()
{
	; Out BUS Assignation
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].A1", "Float", 1.0)

	; Gain slider
    ; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[0].Gain", "Float", 12.0)   ; Set the Microphone
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].Gain", "Float", 0.0)   ; Set the HDL Line In volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Gain", "Float", -60.0)  ; Set the Imput3 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Gain", "Float", -60.0)  ; Set the Imput4 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Gain", "Float", -60.0)  ; Set the Imput5 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[5].Gain", "Float", 0.0)    ; Set the voicemeeter VAIO volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[6].Gain", "Float", 0.0)  ; Set the voicemeeter AUX volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[7].Gain", "Float", 0.0)  ; Set the voicemeeter VAIO 3 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].Gain", "Float", 0.0)      ; Set the PA output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].Gain", "Float", 0.0)      ; Set the PHONE output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].Gain", "Float", 0.0)      ; Set the EAR output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].Gain", "Float", 0.0)      ; Set the T7 output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].Gain", "Float", 0.0)      ; Set the HDL output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[5].Gain", "Float", 0.0)      ; Set the HDL output volume

	; Mute Button
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Mute", "Float", 1.0)    ; Set Imput3 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Mute", "Float", 1.0)    ; Set Imput4 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Mute", "Float", 1.0)    ; Set Imput5 Mute
	;Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[6].Mute", "Float", 1.0)    ; Set voicemeeter AUX to On
	;Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[7].Mute", "Float", 1.0)    ; Set voicemeeter VAIO 3 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[6].Mute", "Float", 1.0)      ; Set B2 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[7].Mute", "Float", 1.0)      ; Set B3 Mute

	; EQ Button
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].EQ.on", "Float", 1.0)     ; Sets PA equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].EQ.on", "Float", 1.0)     ; Sets PHONE equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].EQ.on", "Float", 1.0)     ; Sets EAR equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].EQ.on", "Float", 1.0)     ; Sets T7 equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].EQ.on", "Float", 1.0)     ; Sets HDL equalizer ON
	; show_message = "ALTIUM MODE"
	; tippy(show_message)
}

DefaultDrumSettings()
{
	; Out BUS Assignation
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].A1", "Float", 1.0)

	; Gain slider
    ; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[0].Gain", "Float", 12.0)   ; Set the Microphone
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[1].Gain", "Float", 0.0)   ; Set the HDL Line In volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Gain", "Float", -60.0)  ; Set the Imput3 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Gain", "Float", -60.0)  ; Set the Imput4 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Gain", "Float", -60.0)  ; Set the Imput5 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[5].Gain", "Float", 0.0)    ; Set the voicemeeter VAIO volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[6].Gain", "Float", -60.0)  ; Set the voicemeeter AUX volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[7].Gain", "Float", -60.0)  ; Set the voicemeeter VAIO 3 volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].Gain", "Float", 0.0)      ; Set the PA output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].Gain", "Float", 0.0)      ; Set the PHONE output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].Gain", "Float", 0.0)      ; Set the EAR output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].Gain", "Float", 0.0)      ; Set the T7 output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].Gain", "Float", 0.0)      ; Set the HDL output volume
	; Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[5].Gain", "Float", 0.0)      ; Set the HDL output volume

	; Mute Button
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[2].Mute", "Float", 1.0)    ; Set Imput3 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[3].Mute", "Float", 1.0)    ; Set Imput4 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[4].Mute", "Float", 1.0)    ; Set Imput5 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[6].Mute", "Float", 1.0)    ; Set voicemeeter AUX to On
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Strip[7].Mute", "Float", 1.0)    ; Set voicemeeter VAIO 3 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[6].Mute", "Float", 1.0)      ; Set B2 Mute
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[7].Mute", "Float", 1.0)      ; Set B3 Mute

	; EQ Button
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[0].EQ.on", "Float", 1.0)     ; Sets PA equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[1].EQ.on", "Float", 1.0)     ; Sets PHONE equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[2].EQ.on", "Float", 1.0)     ; Sets EAR equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[3].EQ.on", "Float", 1.0)     ; Sets T7 equalizer ON
	Result := DllCall("VoicemeeterRemote64\VBVMR_SetParameterFloat", "AStr", "Bus[4].EQ.on", "Float", 1.0)     ; Sets HDL equalizer ON
	; show_message = "DRUM MODE"
	; tippy(show_message)
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
    IfWinNotExist ahk_exe %voicemeeter_app%   ; If VoiceMeeter is already running, bring it up from the Tray and bring it to Foreground
    ; {
    ;     WinShow ahk_exe %voicemeeter_app%
    ;     WinActivate ahk_exe %voicemeeter_app%   ; Sometimes WinShow does not bring it in front of say, Spotify. So running WinActivate right after gives it focus and brings it all the way to the foreground
    ; }
    ; else   ; If VoiceMeeter is NOT running, run the .exe, wait for it to launch, then show and bring foreground
    {
		Run %voicemeeter_path%%voicemeeter_app%   ; Set this to your VoiceMeeter install directory
        WinWait ahk_exe %voicemeeter_app%
        WinActivate ahk_exe %voicemeeter_app%   ; Sometimes WinShow does not bring it in front of say, Spotify. So running WinActivate right after gives it focus and brings it all the way to the foreground
		WinShow
		Return
    }
}

ShowVoicemeeter()
{
	IfWinNotExist ahk_exe %voicemeeter_app%
	{
		Run %voicemeeter_path%%voicemeeter_app%   ; Set this to your VoiceMeeter install directory
        WinWait ahk_exe %voicemeeter_app%
        WinActivate ahk_exe %voicemeeter_app%   ; Sometimes WinShow does not bring it in front of say, Spotify. So running WinActivate right after gives it focus and brings it all the way to the foreground
		WinShow
		Return
	}
	else
    IfWinNotActive ahk_exe %voicemeeter_app%   ; If VoiceMeeter is already running, bring it up from the Tray and bring it to Foreground
    {
        WinActivate ; ahk_exe %voicemeeter_app%   ; Sometimes WinShow does not bring it in front of say, Spotify. So running WinActivate right after gives it focus and brings it all the way to the foreground
		WinShow ;, ahk_exe %voicemeeter_app%
		Return
    }
}

HideVoicemeeter()
{
    IfWinActive ahk_exe %voicemeeter_app%   ; If VoiceMeeter is already running, bring it up from the Tray and bring it to Foreground
    {		
    	WinClose ;, ahk_exe %voicemeeter_app%   ; Hide VoiceMeeter back into the Tray.  This assumes you configured VoiceMeeter to "minimize to tray" rather than taskbar in it's settings
		Return
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

playMuteState(channel_type, channel, osd)
{
	if(GetIsMuted(channel_type, channel))
	{
		load_sound_discord_mute()
		show_message = %osd% MUTE
		tippy(show_message)
	}
	else
	{
		load_sound_discord_unmute()
		show_message = %osd% UNMUTE
		tippy(show_message)
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
		;load_sound_vol_up(channel_type, channel)
		CircleProgress.Update(A_Index, "Downloading`nAutoHotkey.exe`n`n" A_Index "% done")
	}
	else if(vol = "down")
	{
		volume -= 4.0
		;load_sound_vol_down(channel_type, channel)
	}
	else if(vol = "0")
	{
		volume = 0.0
		;load_sound_vol_down(channel_type, channel)
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

SetMuteVolume(channel_type, channel, osd)
{
	if(GetIsMuted(channel_type, channel))
	{
		mute := 0.0
		NumPut(0.0, mute, 0, "Float")                                                                                     ; Force it to be a float
		;show_message = IN %channel% ON
		show_message = %osd% UNMUTE
		;tippy(show_message)
		;if(!(channel_type = "BUS" && channel = BUS_3 && channel = BUS_4))
			;load_sound_discord_unmute()
	}
	else
	{
		mute := 1.0
		NumPut(1.0, mute, 1, "Float")                                                                                     ; Force it to be a float
		;show_message = IN %channel% OFF
		show_message = %osd% MUTE
		;tippy(show_message)
		;if(!(channel_type = "BUS" && channel = BUS_3 && channel = BUS_4))
			;load_sound_discord_mute()
		if(channel_type = "BUS" && channel = BUS_1)
		{
			Sleep, 300
		}
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
; GET AUDIO DEVICES IDS
;====================================================================================================================================================
OpenSoundcardAnalisys()
{
    IfWinNotExist ahk_exe %soundcard_analisys_app%   ; If VoiceMeeter is already running, bring it up from the Tray and bring it to Foreground
    ; {
    ;     WinShow ahk_exe %voicemeeter_app%
    ;     WinActivate ahk_exe %voicemeeter_app%   ; Sometimes WinShow does not bring it in front of say, Spotify. So running WinActivate right after gives it focus and brings it all the way to the foreground
    ; }
    ; else   ; If VoiceMeeter is NOT running, run the .exe, wait for it to launch, then show and bring foreground
    {
		Run %soundcard_analisys_app%
        WinWait ahk_exe %soundcard_analisys_app%
        ;WinActivate ahk_exe %soundcard_analisys_app%
		;WinShow
		Return
    }
}
;====================================================================================================================================================
; KEYBOARD
;====================================================================================================================================================
KeyboardInit()
{
    Process, Exist, LuaMacros.exe
	If Not ErrorLevel
	{
		Run "C:\AHK\MediaControl\keyboard.lua"
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

MusicModeKeyboard()
{
	; EQUALIZER CONTROL
	if(key = "ESCAPE")
		SetEqualizerState("BUS", BUS_1, "PA EQ")
	else if(key = "F1")
		SetEqualizerState("BUS", BUS_2, "FONE EQ")
	else if(key = "F2")
		SetEqualizerState("BUS", BUS_3, "EAR EQ")
	else if(key = "F3")
		SetEqualizerState("BUS", BUS_4, "T7 EQ")
	else if(key = "F4")
		SetEqualizerState("BUS", BUS_5, "HDL EQ")

	else if(key = "1") ; MUTE PA
	{
		;playMuteState("STRIP", "IN_6", "PA")
		;Sleep, 500
		SetMuteVolume("BUS", BUS_1, "PA OUT")
	}
	else if(key = "2")	; MUTE FONE, EARDOTS, T7
	{
		;playMuteState("BUS", BUS_2, "FONE, EARDOTS, T7")
		SetMuteVolume("BUS", BUS_2, "FONE OUT")
		SetMuteVolume("BUS", BUS_3, "EARDOTS OUT")
		SetMuteVolume("BUS", BUS_4, "T7 OUT")
	}
	else if(key = "3")
		SetMuteVolume("STRIP", IN_6, "PC OUT")
	else if(key = "4")
		SetMuteVolume("STRIP", IN_2, "AUX IN")
	else if(key = "5")
	{
		if(audioSourceMute = 0)
		{
			audioSourceMute = 1
			if(!GetIsMuted("STRIP", IN_2))
				SetMuteVolume("STRIP", IN_2, "MIC AUX")
			if(GetIsMuted("STRIP", IN_6))
				SetMuteVolume("STRIP", IN_6, "PC IN")
			if(GetIsMuted("STRIP", IN_7))
				SetMuteVolume("STRIP", IN_7, "OPERA IN")
		}
		else
		{
			audioSourceMute = 0			
			if(GetIsMuted("STRIP", IN_2))
				SetMuteVolume("STRIP", IN_2, "MIC AUX")
			if(!GetIsMuted("STRIP", IN_6))
				SetMuteVolume("STRIP", IN_6, "PC IN")
			if(!GetIsMuted("STRIP", IN_7))
				SetMuteVolume("STRIP", IN_7, "OPERA IN")
		}
	}
	; VOLUME CONTROL
	; CHANNEL 1 (PA OUT) -> (Bus 0)
	else if(key = "q")
	{
		SetVolume("BUS", BUS_1, "up")
		load_sound_vol_up("STRIP", "IN_6")
	}
	else if(key = "a")
	{
		SetVolume("BUS", BUS_1, "down")
		load_sound_vol_down("STRIP", "IN_6")
	}
	else if(key = "z")
	{
		SetVolume("BUS", BUS_1, "0")
		load_sound_vol_down("STRIP", "IN_6")
	}

	; CHANNEL 2 (PHONE OUT) -> (Bus 1)
	else if(key = "w")
	{
		SetVolume("BUS", BUS_2, "up")
		SetVolume("BUS", BUS_3, "up")
		SetVolume("BUS", BUS_4, "up")
		load_sound_vol_up("STRIP", "IN_6")
	}
	else if(key = "s")
	{
		SetVolume("BUS", BUS_2, "down")
		SetVolume("BUS", BUS_3, "down")
		SetVolume("BUS", BUS_4, "down")
		load_sound_vol_down("STRIP", "IN_6")
	}
	else if(key = "x")
	{
		SetVolume("BUS", BUS_2, "0")
		SetVolume("BUS", BUS_3, "0")
		SetVolume("BUS", BUS_4, "0")
		load_sound_vol_down("STRIP", "IN_6")
	}

	else if(key = "e")
	{
		SetVolume("STRIP", IN_2, "up")
		load_sound_vol_up("STRIP", "IN_6")
	}
	else if(key = "d")
	{
		SetVolume("STRIP", IN_2, "down")
		load_sound_vol_down("STRIP", "IN_6")
	}
	else if(key = "c")
	{
		SetVolume("STRIP", IN_2, "0")
		load_sound_vol_down("STRIP", "IN_6")
	}

	else if(key = "r")
	{
		SetVolume("STRIP", IN_6, "up")
		load_sound_vol_up("STRIP", "IN_6")
	}
	else if(key = "f")
	{
		SetVolume("STRIP", IN_6, "down")
		load_sound_vol_down("STRIP", "IN_6")
	}
	else if(key = "v")
	{
		SetVolume("STRIP", IN_6, "0")
		load_sound_vol_down("STRIP", "IN_6")
	}

	else if(key = "space")
	{
		restart_audio_engine()
		soundCardInit()
		OpenSoundcardAnalisys()
	}
	else if(key = "tab")
		voicemeeter_show()
}

DrumModeKeyboard()
{

}

LemaModeKeyboard()
{

}

AltiumModeKeyboard()
{
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
	if(MediaMode = mode_Drum)
	{
		
	}
	else
	if(MediaMode = mode_Music)
	{
		SetMuteVolume("STRIP", IN_1, "MIC")
	}

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
	SetMuteVolume("STRIP", IN_7, "CSGO OUT")

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
	SetVolume("STRIP", IN_7, "up")
	else if(key = "semicolon")
	SetVolume("STRIP", IN_7, "down")
	else if(key = "slash")
	SetVolume("STRIP", IN_7, "0")

	else if(key = "left")
	{
		MediaModeLeft()
	}

	else if(key = "right")
	{
		MediaModeRigth()
	}
}

~F24::
FileRead, key, C:\AHK\MediaControl\keypressed.txt

;soundCardInit()

if(MediaMode = mode_Music) {
	MusicModeKeyboard()
}
else if(MediaMode = mode_Drum) {
	DrumModeKeyboard()
}
else if(MediaMode = mode_Lema) {
	LemaModeKeyboard()
}
else if(MediaMode = mode_Altium) {
	AltiumModeKeyboard()
}
Return ;from luamacros F24

;====================================================================================================================================================
; TOOLS
;====================================================================================================================================================
MediaModeRigth()
{
	if (MediaMode > 0)
	{
		MediaMode -= 1
	}
	if(MediaMode = mode_Music)
	{
		DefaultMusicSettings()
	}
	Else if(MediaMode = mode_Drum)
	{
		DefaultDrumSettings()
	}
	Else if(MediaMode = mode_Lema)
	{
		DefaultLemaSettings()
	}
	Else if(MediaMode = mode_Altium)
	{
		DefaultAltiumSettings()
	}
}

MediaModeLeft()
{
	if (MediaMode < 3)
	{
		MediaMode += 1
	}
	if(MediaMode = mode_Music)
	{
		DefaultMusicSettings()
	}
	Else if(MediaMode = mode_Drum)
	{
		DefaultDrumSettings()
	}
	Else if(MediaMode = mode_Lema)
	{
		DefaultLemaSettings()
	}
	Else if(MediaMode = mode_Altium)
	{
		DefaultAltiumSettings()
	}
}

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

		;MouseID_g305 := "\\?\HID#VID_046D&PID_C53F&MI_01&Col01#8&390bcb53&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
		;MouseID_3d := "\\?\HID#VID_1BCF&PID_0005#7&35a657bd&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
		;MouseID_bright := "\\?\HID#VID_04D9&PID_A01C&MI_01&Col01#8&15884e3e&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
		;MouseID_sculpt := "\\?\HID#VID_045E&PID_07A5&MI_01&Col01#8&181bbcc8&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
		;KeyBoarID_bright := "\\?\HID#VID_04D9&PID_A01C&MI_00#8&2583200&0&0000#{884b96c3-56ef-11d1-bc8c-00a0c91405dd}"

		Mouse := KeyboardName(ThisMouse)
		;MouseID := between(Mouse, "\\?\HID#", "0005#")
		;MouseID := MouseID_3d
		
		;Handle := NumGet(&uRawInput, 2 * 4, "UInt")
		;MsgBox, %Mouse%

		;HID0 = 1
		;HID%HID0%_Name   := AHKHID_GetDevName(HID0)
		;MsgBox, HID%HID0%_Name
		
		;MsgBox, %MouseID%
		;MsgBox, %Mouse%
		;MsgBox, %usButtonFlags%
		;MsgBox, %usButtonData%
		If (RegExMatch(Mouse, MouseID_3d))
		{
			if (usButtonData = 120) ;whell up
			{
				;MsgBox %DEVICE_PA_ID% %DEVICE_HECATE_ID% %DEVICE_LINE_OUT_ID%
				if(DEVICE_PA_ID_OK = 1)
					SoundSet, +2 , MASTER, VOLUME, DEVICE_PA_ID ;PA
				if(DEVICE_HECATE_ID_OK = 1)
					SoundSet, +2 , MASTER, VOLUME, DEVICE_HECATE_ID ;HECATE
				if(DEVICE_REDMI_ID_OK = 1)
					SoundSet, +2 , MASTER, VOLUME, DEVICE_REDMI_ID ;REDMI
				if(DEVICE_MI_ID_OK = 1)
					SoundSet, +2 , MASTER, VOLUME, DEVICE_MI_ID ;MI
				if(DEVICE_T7_ID_OK = 1)
					SoundSet, +2 , MASTER, VOLUME, DEVICE_T7_ID ;T7
				if(DEVICE_LINE_OUT_ID_OK = 1)
					SoundSet, +2 , MASTER, VOLUME, DEVICE_LINE_OUT_ID ;LINE OUT
			} 
			else if (usButtonData = -120) ;whell down
			{
				if(DEVICE_PA_ID_OK = 1)
					SoundSet, -2 , MASTER, VOLUME, DEVICE_PA_ID ;PA
				if(DEVICE_HECATE_ID_OK = 1)
					SoundSet, -2 , MASTER, VOLUME, DEVICE_HECATE_ID ;HECATE
				if(DEVICE_REDMI_ID_OK = 1)
					SoundSet, -2 , MASTER, VOLUME, DEVICE_REDMI_ID ;REDMI
				if(DEVICE_MI_ID_OK = 1)
					SoundSet, -2 , MASTER, VOLUME, DEVICE_MI_ID ;MI				
				if(DEVICE_T7_ID_OK = 1)
					SoundSet, -2 , MASTER, VOLUME, DEVICE_T7_ID ;T7
				if(DEVICE_LINE_OUT_ID_OK = 1)
					SoundSet, -2 , MASTER, VOLUME, DEVICE_LINE_OUT_ID ;LINE OUT
			}
			else if (usButtonFlags = 256) ;botao forwad
			{
				restart_audio_engine()
				soundCardInit()
				OpenSoundcardAnalisys()
			}
			else if (usButtonFlags = 64) ;botao backward
			{
				; MouseMove, 200, 100
				if(audioSourceMute = 0)				
				{
					audioSourceMute = 1
					if(!GetIsMuted("STRIP", IN_2))
						SetMuteVolume("STRIP", IN_2, "TABLET")
					if(GetIsMuted("STRIP", IN_6))
						SetMuteVolume("STRIP", IN_6, "PC AUDIO")
				}
				else
				{
					audioSourceMute = 0			
					if(GetIsMuted("STRIP", IN_2))
						SetMuteVolume("STRIP", IN_2, "TABLET")
					if(!GetIsMuted("STRIP", IN_6))
						SetMuteVolume("STRIP", IN_6, "PC AUDIO")
				}
			}
			else if (usButtonFlags = 32) ;whell click down
			{
				;DllCall("SetCursorPos", "int", 100, "int", 400)  ; The first number is the X-coordinate and the second is the Y (relative to the screen).
				;Send {Media_Play_Pause}
				; MouseMove, 200, 100
				if(audioSourceMute = 0)				
					{
						audioSourceMute = 1
						;.......... MUTE/UNMUTE BUS 0
						if(!GetIsMuted("BUS", BUS_1))
							SetMuteVolume("BUS", BUS_1, "PA OUT")
					
						;.......... MUTE/UNMUTE BUS 1
						if(!GetIsMuted("BUS", BUS_2))
							SetMuteVolume("BUS", BUS_2, "FONE OUT")
					
						;.......... MUTE/UNMUTE BUS 2
						if(!GetIsMuted("BUS", BUS_3))
						SetMuteVolume("BUS", BUS_3, "EAR OUT")
					
						;.......... MUTE/UNMUTE BUS 3
						if(!GetIsMuted("BUS", BUS_4))
							SetMuteVolume("BUS", BUS_4, "T7 OUT")
					}
					else
					{
						audioSourceMute = 0			
						;.......... MUTE/UNMUTE BUS 0
						if(GetIsMuted("BUS", BUS_1))
							SetMuteVolume("BUS", BUS_1, "PA OUT")
					
						;.......... MUTE/UNMUTE BUS 1
						if(GetIsMuted("BUS", BUS_2))
							SetMuteVolume("BUS", BUS_2, "FONE OUT")
					
						;.......... MUTE/UNMUTE BUS 2
						if(GetIsMuted("BUS", BUS_3))
						SetMuteVolume("BUS", BUS_3, "EAR OUT")
					
						;.......... MUTE/UNMUTE BUS 3
						if(GetIsMuted("BUS", BUS_4))
							SetMuteVolume("BUS", BUS_4, "T7 OUT")
					}

			}
		}
		If RegExMatch(Mouse, MouseID_bright)
		{
			if (usButtonData = 120) ;whell up
			{
				if(DEVICE_PA_ID > 0)
					SoundSet, +2 , MASTER, VOLUME, DEVICE_PA_ID ;PA
				if(DEVICE_HECATE_ID > 0)
					SoundSet, +2 , MASTER, VOLUME, DEVICE_HECATE_ID ;HECATE
				if(DEVICE_REDMI_ID > 0)
					SoundSet, +2 , MASTER, VOLUME, DEVICE_REDMI_ID ;REDMI
				if(DEVICE_MI_ID > 0)
					SoundSet, +2 , MASTER, VOLUME, DEVICE_MI_ID ;MI
				if(DEVICE_T7_ID > 0)
					SoundSet, +2 , MASTER, VOLUME, DEVICE_T7_ID ;T7
			} 
			else if (usButtonData = -120) ;whell down
			{
				if(DEVICE_PA_ID > 0)
					SoundSet, -2 , MASTER, VOLUME, DEVICE_PA_ID ;PA
				if(DEVICE_HECATE_ID > 0)
					SoundSet, -2 , MASTER, VOLUME, DEVICE_HECATE_ID ;HECATE
				if(DEVICE_REDMI_ID > 0)
					SoundSet, -2 , MASTER, VOLUME, DEVICE_REDMI_ID ;REDMI
				if(DEVICE_MI_ID > 0)
					SoundSet, -2 , MASTER, VOLUME, DEVICE_MI_ID ;MI
				if(DEVICE_T7_ID > 0)
					SoundSet, -2 , MASTER, VOLUME, DEVICE_T7_ID ;T7
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
		If RegExMatch(Mouse, MouseID_g305) || RegExMatch(Mouse, MouseID_g203) || RegExMatch(Mouse, MouseID_sculpt)
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
				; if (WheelMidState != "WheelMid_solto")
				; {
				; 	if(GetKeyState("LShift", "P"))
				; 	{
				; 		Send {LShift Up}
				; 	}
				; 	if(GetKeyState("Ctrl", "P"))
				; 	{
				; 		Send {LCtrl Up}
				; 	}
				; }
				; ;Send {RButton Up}
  				; WheelMidState := "WheelMid_solto"
			}
			else if (usButtonFlags = 16) ;whell click up
			{
				; if (WheelMidState != "WheelMid_clicado")
				; {
				; 	MouseClick, middle
				; 	if(GetKeyState("LShift", "P"))
				; 	{
				; 		Send {LShift Up}
				; 	}
				; 	if(GetKeyState("Ctrl", "P"))
				; 	{
				; 		Send {LCtrl Up}
				; 	}
				; }
				; ;Send {RButton Up}
  				; WheelMidState := "WheelMid_clicado"
			}
			else if (usButtonFlags = 8) ;botao direito solto------------------------------------------------------------
			{
				; if (RButtonState != "RButtonState_solto")
				; {
				; 	if(GetKeyState("LShift", "P"))
				; 	{
				; 		Send {LShift Up}
				; 	}
				; 	if(GetKeyState("Ctrl", "P"))
				; 	{
				; 		Send {LCtrl Up}
				; 	}
				; }
				; ;Send {RButton Up}
  				; RButtonState := "RButtonState_solto"	
			}
			else if (usButtonFlags = 4) ;botao direito clicado------------------------------------------------------------
			{
				; if (RButtonState != "RButtonState_clicado")
				; {
				; 	if(GetKeyState("LShift", "P"))
				; 	{
				; 		Send {LShift Down}
				; 	}
				; 	if(GetKeyState("LCtrl", "P"))
				; 	{
				; 		Send {LCtrl Down}
				; 	}
				; }
				; ;Send {RButton Down}
				; RButtonState := "RButtonState_clicado"
			}
			else if (usButtonFlags = 2) ;botao esquerdo solto------------------------------------------------------------
			{
				; if (LButtonState != "LButtonState_solto")
				; {
				; 	if(GetKeyState("Shift", "P"))
				; 	{
				; 		Send {LShift Up}
				; 	}
				; 	if(GetKeyState("Ctrl", "P"))
				; 	{
				; 		Send {LCtrl Up}
				; 	}
				; }
				; ;Send {LButton Up}
  				; LButtonState := "LButtonState_solto"			
			}
			else if (usButtonFlags = 1) ;botao esquerdo clicado------------------------------------------------------------
			{
				; if (LButtonState != "LButtonState_clicado")
				; {
				; 	if(GetKeyState("Shift", "P"))
				; 	{
				; 		Send {LShift Down}
				; 	}
				; 	if(GetKeyState("Ctrl", "P"))
				; 	{
				; 		Send {LCtrl Down}
				; 	}
				; }
				; ;Send {LButton Down}
				; LButtonState := "LButtonState_clicado"
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
	; KeyWait, WheelUp, D ; wait for MMB to be released
	; sendinput {WheelUp up}	
return

WheelDown::
	; KeyWait, WheelDown, D ; wait for MMB to be pressed down
	; sendinput {WheelDown down}
return

XButton1::
return

XButton2::
return

MButton::
	KeyWait, MButton, D ; wait for MMB to be pressed down
	sendinput {MButton down}

	KeyWait, MButton ; wait for MMB to be released
	sendinput {MButton up}	
return

Shift::
	KeyWait, LShift, D ; wait for MMB to be pressed down
	sendinput {LShift down}

	KeyWait, LShift ; wait for MMB to be released
	sendinput {LShift up}	
return

Ctrl::
	KeyWait, LControl, D ; wait for MMB to be pressed down
	sendinput {LControl down}

	KeyWait, LControl ; wait for MMB to be released
	sendinput {LControl up}	
return

; Shift & MButton::
; 	KeyWait, MButton, D ; wait for MMB to be pressed down
; 	sendinput {MButton down}{LShift down}

; 	KeyWait, MButton ; wait for MMB to be released
; 	sendinput {MButton up}{LShift up}		
; return

; ------------------------------ Includes --------------------------------------------
; ------------------------------ Definitions -----------------------------------------
; ------------------------------ Structures ------------------------------------------
; ------------------------------ Local Functions -------------------------------------
; ------------------------------ Variables -------------------------------------------
; ------------------------------ Implementation --------------------------------------