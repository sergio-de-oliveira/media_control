#Requires AutoHotkey v2.0+
scGui := Gui(, "Sound Components")
scLV := scGui.Add(ListView, "w600 h400", ["Component", "#", "Device", "Volume", "Mute"])
devMap := Map()

soundCardInit()
{
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
    loop
    {
        ; For each loop iteration, try to get the corresponding device.
        try
            devName := SoundGetName(, dev := A_Index)
        catch  ; No more devices.
            break
        
        ; Qualify names with ":index" where needed.
        devName := Qualify(devName, devMap, dev)
        
        ; Retrieve master volume and mute setting, if possible.
        vol := mute := ""
        try vol := Round(SoundGetVolume( , dev), 2)
        try mute := SoundGetMute( , dev)
        
        ; Display the master settings only if at least one was retrieved.
        if vol != "" || mute != ""
            scLV.Add("", "", dev, devName, vol, mute)
        
        ; For each component, first query its name.
        cmpMap := Map()
        
        loop
        {
            try
                cmpName := SoundGetName(cmp := A_Index, dev)
            catch
                break
            ; Retrieve this component's volume and mute setting, if possible.
            vol := mute := ""
            try vol := Round(SoundGetVolume(cmp, dev), 2)
            try mute := SoundGetMute(cmp, dev)
            ; Display this component even if it does not support volume or mute,
            ; since it likely supports other controls via SoundGetInterface().
            scLV.Add("", Qualify(cmpName, cmpMap, A_Index), dev, devName, vol, mute)

            if(devName = "FONE (HECATE G1 GAMING HEADSET)" && ComponentString = "MASTER" && CurrControl = "VOLUME")
            {
                if(DEVICE_HECATE_ID_OK = 0)
                {
                    DEVICE_HECATE_ID_OK := 1
                    DEVICE_HECATE_ID := CurrMixerNum
                    ; MsgBox %DeviceName% %CurrMixerNum%
                    ; LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
                }
            }
            if((DeviceName = "PA (Realtek High Definition Audio)" || DeviceName = "PA (High Definition Audio Device)") && ComponentString = "MASTER" && CurrControl = "VOLUME")
            {
                if(DEVICE_PA_ID_OK = 0)
                {
                    DEVICE_PA_ID_OK := 1
                    DEVICE_PA_ID := CurrMixerNum
                    ; MsgBox %DeviceName% %CurrMixer%
                    ; LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
                }
            }
            if(DeviceName = "MI (Mi True Wireless EBs Basic 2 Stereo)" && ComponentString = "MASTER" && CurrControl = "VOLUME")
            {
                if(DEVICE_MI_ID_OK = 0)
                {
                    DEVICE_MI_ID_OK := 1
                    DEVICE_MI_ID := CurrMixerNum
                    ;MsgBox %DeviceName% %CurrMixer%
                    ; LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
                }
            }
            if(DeviceName = "REDMI (Redmi AirDots_R Stereo)" && ComponentString = "MASTER" && CurrControl = "VOLUME")
            {
                if(DEVICE_REDMI_ID_OK = 0)
                {
                    DEVICE_REDMI_ID_OK := 1
                    DEVICE_REDMI_ID := CurrMixerNum
                    ;MsgBox %DeviceName% %CurrMixer%
                    ; LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
                }
            }
            if(DeviceName = "T7 (T7 Stereo)" && ComponentString = "MASTER" && CurrControl = "VOLUME")
            {
                if(DEVICE_T7_ID_OK = 0)
                {
                    DEVICE_T7_ID_OK := 1
                    DEVICE_T7_ID := CurrMixerNum
                    ;MsgBox %DeviceName% %CurrMixer%
                    ; LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
                }
            }
            if( (DeviceName = "LINE_OUT (Generic USB Audio Device)" || DeviceName = "LINE_OUT (USB PnP Sound Device)") && ComponentString = "MASTER" && CurrControl = "VOLUME" )
            {
                if(DEVICE_LINE_OUT_ID_OK = 0)
                {
                    DEVICE_LINE_OUT_ID_OK := 1
                    DEVICE_LINE_OUT_ID := CurrMixerNum
                    ;MsgBox %DeviceName% %CurrMixer%
                    ; LV_Add("", ComponentString, CurrControl, Setting, CurrMixer, DeviceName)
                }
            }
        }
    }

    ; loop 5
    ;     scLV.ModifyCol(A_Index, 'AutoHdr Logical')
    scGui.Show()

    ; Qualifies full names with ":index" when needed.
    ; Qualify(name, names, overallIndex)
    ; {
    ;     if name = ''
    ;         return overallIndex
    ;     key := StrLower(name)
    ;     index := names.Has(key) ? ++names[key] : (names[key] := 1)
    ;     return (index > 1 || InStr(name, ':') || IsInteger(name)) ? name ':' index : name
    ; }
}