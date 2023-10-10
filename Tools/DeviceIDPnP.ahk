; Generated by Auto-GUI 3.0.1
#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

Gui Font, s9, Segoe UI
Gui Add, Tab3, x10 y10 w721 h680, Find|Configure
Gui Tab, 1
Gui Font
Gui Font, s17 Bold cBlack
Gui Add, Text, x180 y48 w360 h53 +0x200, USB Finder by XMCQCX 
Gui Font
Gui Font, s9, Segoe UI
Gui Add, Text, x20 y130, 1 - Press "Find USB" button and follow screen instructions
Gui Add, Button, gFindUSB x340 y118 w149 h38, &Find USB now!
Gui Add, Text, x20 y150, 2 - Listview will be full filled, select a line
Gui Add, ListView, x20 y180 w570 h285 +Report +Grid -Multi +LV0x4000, Name | ID

Gui Add, Button, gTestSelected x280 y490 w95 h28, Test Selected
Gui Add, Text, x20 y500, 3 - Press "Test Selected" button.
Gui Add, Text, x20 y525, 4 - Disconnect and connect your USB device, "Status device" text `n should change from Disconnected to Connected whenever you fisically disconnect and connect `n your Device.
Gui Add, Text, x20 y570, If you don't get both messages, test another item from the Listview.
Gui Font, s14, Segoe UI
Gui Add, Text, x20 y620, Device Status: 
Gui Tab


Gui Show, w744 h700, Window

Return

GuiEscape:
GuiClose:
    ExitApp




FindUSB:

/*
Script:    DeviceIDFinder.ahk
Author:    XMCQCX
Date:      2022-09-24
Version:   1.0.0
*/
MsgBox, 64, Find deviceID, Plug your device and press OK

For Device in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_PnPEntity")
    ListConnectedDeviceIDs .= device.name ":" A_Tab Device.DeviceID "`n"

;=============================================================================================

; Remove duplicates from ListConnectedDeviceIDs
Loop, Parse, ListConnectedDeviceIDs, "`n"
{
    ListConnectedDeviceIDs := (A_Index=1 ? A_LoopField : ListConnectedDeviceIDs . (InStr("`n" ListConnectedDeviceIDs
    . "`n", "`n" A_LoopField "`n") ? "" : "`n" A_LoopField ) )
}

;=============================================================================================

oConnectedDeviceIDs := {}
Loop, Parse, ListConnectedDeviceIDs, "`n"
    oConnectedDeviceIDs.Push({"DeviceID":A_Loopfield})

;=============================================================================================

MsgBox, 64, Find deviceID, Unplug your device and press OK

;=============================================================================================

For Device in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_PnPEntity")
    strListConnectedDeviceIDs .= device.name ":" A_Tab Device.DeviceID "`n"

;=============================================================================================

; Remove duplicates from ListConnectedDeviceIDs
Loop, Parse, strListConnectedDeviceIDs, "`n"
{
    strListConnectedDeviceIDs := (A_Index=1 ? A_LoopField : strListConnectedDeviceIDs . (InStr("`n" strListConnectedDeviceIDs
    . "`n", "`n" A_LoopField "`n") ? "" : "`n" A_LoopField ) )
}

;=============================================================================================

Loop, Parse, strListConnectedDeviceIDs, "`n"
{
    For Index, Element in oConnectedDeviceIDs  
    {
        If InStr(strListConnectedDeviceIDs, Element.DeviceID)
            oConnectedDeviceIDs.RemoveAt(Index)
    }
}

;=============================================================================================

For Index, Element in oConnectedDeviceIDs
    DeviceIDFound .= Element.DeviceID "`n"

;=============================================================================================

strDeviceIDFound := ""
For each, line in StrSplit(DeviceIDFound, "`n")
{
    RegExMatch(line, "`nm)^(.*?)" A_TAB "(.*)$", OutputVar)
    strDeviceIDFound .= OutputVar1 "`n" OutputVar2 "`n`n"

    if (OutputVar1 != "") && (OutputVar2 !=""){  ; Lepes
      LV_Add( , OutputVar1 , OutputVar2)
     
    }
}
LV_ModifyCol() ; Lepes
strDeviceIDFound := RTrim(strDeviceIDFound, "`n`n")

If !strDeviceIDFound
    strDeviceIDFound := "No device found !"
Return
; Lepes comment out this Gui
;=============================================================================================

;Gui, New
;Gui, Add, Text,, DeviceID:
;Gui, Add, Edit, vTextDeviceID ReadOnly, %strDeviceIDFound%
;Gui, Add, Button, w175 vCopyToClipboard gCopyToClipboard, Copy to Clipboard
;Gui, Add, Button, x+10 w175 gFindAnotherDeviceID, Find ID of another device
;Gui, Add, Button, x+10 w175 gExit, Exit
;GuiControl, Focus, CopyToClipboard
;Gui, Show
;return

;=============================================================================================

CopyToClipboard:
Clipboard := strDeviceIDFound
MsgBox, 64, Success, Device ID copied to Clipboard !
return


TestSelected:
/*
Script:    DeviceIDPnP.ahk
Author:    XMCQCX
Date:      2022-09-24
Version:   1.1.0

Changelog:
1.1.0 - Run or close scripts/programs if the device is connected/disconnected when the script start.
*/

;#NoEnv
;#SingleInstance, Force
;SendMode Input
;SetWorkingDir, %A_ScriptDir%

oMyDevices := {}
;Lepes
RowNumber := LV_GetNext(0,"Focused")
LV_GetText(DeviceName, RowNumber, 1)
LV_GetText(dID, RowNumber, 2)
oMyDevices.Push({"DeviceName": DeviceName, "DeviceID": dID})
tooltip, % DeviceName " - " dID
;oMyDevices.Push({"DeviceName":"USB Kingston DataTraveler 3.0","DeviceID":"USBSTOR\DISK&VEN_KINGSTON&PROD_DATATRAVELER_3.0&REV_\E0D55EA573DCF450E97C104C&0", "Status":""})
;oMyDevices.Push({"DeviceName":"PLAYSTATION(R)3 Controller","DeviceID":"BTHPS3BUS\{53F88889-1AAF-4353-A047-556B69EC6DA6}&DEV&VID_054C&PID_0268&04766E9094F3\9&320AC31D&0&0", "Status":""})
;oMyDevices.Push({"DeviceName":"HDMI Samsung TV","DeviceID":"SWD\MMDEVAPI\{0.0.0.00000000}.{ED3C7A62-B05B-44C6-ACD8-BCAA1E894265}", "Status":""})

;=============================================================================================

; List all devices connected
For Device in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_PnPEntity")
    ListDevicesConnected .= Device.DeviceID "`n"

;=============================================================================================

; Establish the status of the devices in oMyDevices
For Index, Element in oMyDevices
{
    If InStr(ListDevicesConnected, Element.DeviceID)
        oMyDevices[Index].Status := "Connected"
    Else
        oMyDevices[Index].Status := "Disconnected"
}

;=============================================================================================

; Run or close scripts/programs if the device is connected/disconnected when the script start.
oMyDevicesCount := oMyDevices.Count()
Loop % oMyDevicesCount
{
    ThisDeviceStatusAtStartup := oMyDevices[A_Index].DeviceName A_Space oMyDevices[A_Index].Status
    DeviceActions(ThisDeviceStatusAtStartup, DontShowToolTip := "true")
}

;=============================================================================================

OnMessage(0x219, "notify_change") 
notify_change(wParam, lParam, msg, hwnd)
{
    SetTimer, CheckDevicesStatus , -25
}
Return

;=============================================================================================

CheckDevicesStatus:

    ; Prevent the script to continue if it already previously run during the last 1250ms.
    ElapsedTime := A_TickCount - StartTime
    if ElapsedTime between 1 and 1250
    {
        StartTime := A_TickCount
        return
    }

    ;=============================================================================================
    
    ; List all devices connected
    ListDevicesConnected := ""
    For Device in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_PnPEntity")
        ListDevicesConnected .= Device.DeviceID "`n"

    ;=============================================================================================

    ; Find which device status has changed in oMyDevices
    ThisDeviceStatusHasChanged := ""
    For Index, Element in oMyDevices
    {
        If InStr(ListDevicesConnected, Element.DeviceID)
            If (oMyDevices[Index].Status = "Disconnected"), oMyDevices[Index].Status := "Connected"
                ThisDeviceStatusHasChanged := Element.DeviceName " Connected"

        If !InStr(ListDevicesConnected, Element.DeviceID)
            If (oMyDevices[Index].Status = "Connected"), oMyDevices[Index].Status := "Disconnected"
                ThisDeviceStatusHasChanged := Element.DeviceName " Disconnected"
    }

    ;=============================================================================================

    ; If a device in oMyDevices status has changed go to DeviceActions()
    If ThisDeviceStatusHasChanged
        DeviceActions(ThisDeviceStatusHasChanged, DontShowToolTip := "")
    
    StartTime := A_TickCount

return

;=============================================================================================

DeviceActions(ThisDeviceStatusHasChanged, DontShowToolTip := "") {

    If (!DontShowToolTip) {
        CoordMode, ToolTip, Window
        Tooltip, % ThisDeviceStatusHasChanged, 150, 640
        SetTimer, RemoveToolTip, -5000
        
    }

    ;=============================================================================================

    If (ThisDeviceStatusHasChanged = "USB Kingston DataTraveler 3.0 Connected")
        If !WinExist("ahk_exe Notepad.exe")
            Run, Notepad.exe

    If (ThisDeviceStatusHasChanged = "USB Kingston DataTraveler 3.0 Disconnected")
        If WinExist("ahk_exe Notepad.exe")
            Winclose, % "ahk_exe Notepad.exe"

    ;=============================================================================================

    If (ThisDeviceStatusHasChanged = "PLAYSTATION(R)3 Controller Connected")
        If !WinExist("ahk_exe wordpad.exe")
            Run, wordpad.exe

    If (ThisDeviceStatusHasChanged = "PLAYSTATION(R)3 Controller Disconnected")
        If WinExist("ahk_exe wordpad.exe")
            Winclose, % "ahk_exe wordpad.exe"

    ;=============================================================================================

    If (ThisDeviceStatusHasChanged = "HDMI Samsung TV Connected")
        If !WinExist("ahk_exe mspaint.exe")
            Run, mspaint.exe
    
    If (ThisDeviceStatusHasChanged = "HDMI Samsung TV Disconnected")
        If WinExist("ahk_exe mspaint.exe")
            Winclose, % "ahk_exe mspaint.exe"

    ;=============================================================================================

    ThisDeviceStatusHasChanged := ""
}

RemoveToolTip:
ToolTip
return