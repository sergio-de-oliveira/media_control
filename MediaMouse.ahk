#MaxHotkeysPerInterval 200
#Include AHKHID.ahk

;get_hid()

;Get count
;iCount := AHKHID_GetDevCount()
LastMouseState := ""
LButtonState := "LButtonState_solto"

;Set up the constants
AHKHID_UseConstants()
md := new mouseDelta(func("f"))
Mouse2_ID := ""
md.start()
wheelup::
wheeldown::
XButton1::
XButton2::
MButton::
LButton::
RButton::
return
;esc::exitapp

;---------------------------------------------------------------------------------
f(id,dx,dy,flags,data){
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

;---------------------------------------------------------------------------------
myMouseMove(axis,dir){
	static step_size := 10	; Step size in pixels
	static sign := -1		; Change to 1 to change the direction of the movements
	local x:=0, y:=0
	%axis% := round(sign*dir * step_size / 120)
	mousemove, x, y, 0, R
}

;---------------------------------------------------------------------------------
Class MouseDelta
{
	State := 0
	__New(callback){
		this.MouseMovedFn := this.MouseMoved.Bind(this)
		this.Callback := callback
	}

	;------------------------------------------------------------
	Start(){
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
	Stop(){
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
	toggle(){
		return this.setState(!this.state)
	}
	
	;------------------------------------------------------------
	getState(){
		return this.state
	}
	
	;------------------------------------------------------------
	SetState(state){
		if (state && !this.State)
			this.Start()
		else if (!state && this.State)
			this.Stop()
		return this	; allow chaining
	}
	
	;------------------------------------------------------------
	Delete(){
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
		
		Mouse := MouseName(ThisMouse)
		MouseID := between(Mouse, "\\?\HID#", "0005#")
		
		;MsgBox, %MouseID%
		;MsgBox, %usButtonFlags%
		
		; \\?\HID#VID_1BCF&PID_0005#7&35a657bd&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd} (3D Mouse Happens)
		; \\?\HID#VID_046D&PID_C53F&MI_01&Col01#8&390bcb53&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd} (G305)
		; \\?\HID#VID_04D9&PID_A01C&MI_01&Col01#8&35678ec0&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd} (Mouse Bright)
		; \\?\HID#DRIVERENUM&Col01#6&15d781bd&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}
		; \\?\ACPI#SYN1222#3#{378de44c-56ef-11d1-bc8c-00a0c91405dd}

		MouseID_g305 := "\\?\HID#VID_046D&PID_C53F&MI_01&Col01#8&390bcb53&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
		MouseID_3d := "\\?\HID#VID_1BCF&PID_0005#7&35a657bd&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"
		MouseID_bright := "\\?\HID#VID_04D9&PID_A01C&MI_01&Col01#8&35678ec0&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}"

		;if(MouseID = "VID_1BCF&PID_") {
		if((Mouse = MouseID_3d) || (Mouse = MouseID_bright)) {
			if (usButtonData = 120) {
				Send {Volume_Up}
			} 
			else if (usButtonData = -120) {
				Send {Volume_Down}
			}
			else if (usButtonFlags = 256) {
				;Send {Media_Next}
			}
			else if (usButtonFlags = 64) {
				;Send {Media_Prev}
			}
			else if (usButtonFlags = 32) {
				;Send {Media_Play_Pause}
			}
		}	
		else if(Mouse = MouseID_g305) {
			if (usButtonData = 120) { ;whell up
				MouseClick, WheelUp
			}
			else if (usButtonData = -120) { ;whell down
				MouseClick, WheelDown
			}
			else if (usButtonFlags = 256) { ;botao forwad
				Send {XButton2}
			}
			else if (usButtonFlags = 64) { ;botao back
				Send {XButton1}
			}
			else if (usButtonFlags = 32) { ;whell mid
				Send {MButton}
			}
			else if (usButtonFlags = 8) { ;botao direito solto
				;MouseClick, right
			}
			else if (usButtonFlags = 4) { ;botao direito clicado
				MouseClick, right
			}
			else if (usButtonFlags = 2) { ;botao esquerdo solto
				if (LButtonState != "LButtonState_solto")
				{
					Send {LButton Up}
				}
				if(!GetKeyState("Shift", "P"))
				{
					Send {Shift Up}
				}
  				LButtonState := "LButtonState_solto"			
			}
			else if (usButtonFlags = 1) { ;botao esquerdo clicado
				if (LButtonState != "LButtonState_clicado")
				{
					if(GetKeyState("Shift", "P"))
					{
						Send {ShiftDown}
					}
					Else
					{
						Send {LButton Down}
					}
				}
				LButtonState := "LButtonState_clicado"
			}
		}
	}
}

;------------------------------------------------------------
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

;------------------------------------------------------------
;Retrieve info for each device
get_hid() {
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

;---------------------------------------------------------------------------------
;XButton1::
	;Send {Media_Prev}
;return

;---------------------------------------------------------------------------------
;XButton2::
	;Send {Media_Next}
;return

;---------------------------------------------------------------------------------
;MButton::
	;Send {Media_Play_Pause}
;return