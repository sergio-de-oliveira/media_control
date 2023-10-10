List := EnumAudioEndpoints()

scGui := Gui(, "Sound Components")
scLV := scGui.Add('ListView', "w600 h700", ["Component", "#", "Device", "Volume", "Mute"])

devMap := Map()

SoundDeviceFile := "C:\AHK\MediaControl\SoundDeviceFile.txt"
try FileDelete SoundDeviceFile  ; In case previous run was terminated prematurely.

; Save := "Hello"
; FileAppend "TESTE", "C:\AHK\MediaControl\Tools\SoundDeviceFile.txt"

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
        if(dev <= 9)
            FileAppend " ", "C:\AHK\MediaControl\SoundDeviceFile.txt"
        FileAppend dev, "C:\AHK\MediaControl\SoundDeviceFile.txt"
        FileAppend "|", "C:\AHK\MediaControl\SoundDeviceFile.txt"
        FileAppend devName, "C:\AHK\MediaControl\SoundDeviceFile.txt"
        FileAppend "`n", "C:\AHK\MediaControl\SoundDeviceFile.txt"
    }
}

loop 5
    scLV.ModifyCol(A_Index, 'AutoHdr Logical')
; scGui.Show()

; Qualifies full names with ":index" when needed.
Qualify(name, names, overallIndex)
{
    if name = ''
        return overallIndex
    key := StrLower(name)
    index := names.Has(key) ? ++names[key] : (names[key] := 1)
    return (index > 1 || InStr(name, ':') || IsInteger(name)) ? name ':' index : name
}

;====================================================================================================================================================
; SOUND CARD SELECT
;====================================================================================================================================================
/*
    Generates a collection of audio endpoint devices that meet the specified criteria.
    Parameters:
        DataFlow:
            The data-flow direction for the endpoint devices in the collection.
            0   Audio rendering stream. Audio data flows from the application to the audio endpoint device, which renders the stream.
            1   Audio capture stream. Audio data flows from the audio endpoint device that captures the stream, to the application.
            2   Audio rendering or capture stream. Audio data can flow either from the application to the audio endpoint device, or from the audio endpoint device to the application.
        StateMask:
            The state or states of the endpoints that are to be included in the collection.
            1   Active. The audio adapter that connects to the endpoint device is present and enabled. In addition, if the endpoint device plugs into a jack on the adapter, then the endpoint device is plugged in.
            2   Disabled. The user has disabled the device in the Windows multimedia control panel (Mmsys.cpl).
            4   Not present. The audio adapter that connects to the endpoint device has been removed or disabled.
            8   Unplugged. The audio adapter that contains the jack for the endpoint device is present and enabled, but the endpoint device is not plugged into the jack. Only a device with jack-presence detection can be in this state.
    Return value:
        Returns an array of Map objects with the following keys:
        ID      Endpoint ID string that identifies the audio endpoint device.
        Name    The friendly name of the endpoint device.
*/
EnumAudioEndpoints(DataFlow := 2, StateMask := 1)
{
    List := []

    ; IMMDeviceEnumerator interface.
    ; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immdeviceenumerator
    IMMDeviceEnumerator := ComObject("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")

    ; IMMDeviceEnumerator::EnumAudioEndpoints method.
    ; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nf-mmdeviceapi-immdeviceenumerator-enumaudioendpoints
    ComCall(3, IMMDeviceEnumerator, "UInt", DataFlow, "UInt", StateMask, "UPtrP", &IMMDeviceCollection:=0)

    ; IMMDeviceCollection::GetCount method.
    ; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nf-mmdeviceapi-immdevicecollection-getcount
    ComCall(3, IMMDeviceCollection, "UIntP", &DevCount:=0)  ; Retrieves a count of the devices in the device collection.

    loop DevCount
    {
        List.Push(Device := Map())

        ; IMMDeviceCollection::Item method.
        ; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nf-mmdeviceapi-immdevicecollection-item
        ComCall(4, IMMDeviceCollection, "UInt", A_Index-1, "UPtrP", &IMMDevice:=0)

        ; IMMDevice::GetId method.
        ; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nf-mmdeviceapi-immdevice-getid
        ComCall(5, IMMDevice, "PtrP", &pBuffer:=0)
        Device["ID"] := StrGet(pBuffer)
        DllCall("Ole32.dll\CoTaskMemFree", "UPtr", pBuffer)

        ; MMDevice::OpenPropertyStore method.
        ; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nf-mmdeviceapi-immdevice-openpropertystore
        ComCall(4, IMMDevice, "UInt", 0x00000000, "UPtrP", &IPropertyStore:=0)

        Device["Name"] := GetDeviceProp(IPropertyStore, "{A45C254E-DF1C-4EFD-8020-67D146A850E0}", 14)

        ObjRelease(IPropertyStore)
        ObjRelease(IMMDevice)
    }

    ObjRelease(IMMDeviceCollection)
    SetDefaultEndpoint( GetDeviceID(List, "VoiceMeeter Input (VB-Audio VoiceMeeter VAIO)") )
	SetDefaultEndpoint( GetDeviceID(List, "VoiceMeeter Output (VB-Audio VoiceMeeter VAIO)") )

    ; return List
}

/*
    Set default audio render endpoint.
    Role:
        0x1   Default Device.
        0x2   Default Communication Device.
*/
SetDefaultEndpoint(DeviceID, Role := 3)
{
    ; Undocumented COM-interface IPolicyConfig.
    IPolicyConfig := ComObject("{870AF99C-171D-4F9E-AF0D-E63Df40c2BC9}", "{F8679F50-850A-41CF-9C72-430F290290C8}")
    if (Role & 0x1)
        ComCall(13, IPolicyConfig, "Str", DeviceID, "Int", 0)  ; Default Device
    if (Role & 0x2)
        ComCall(13, IPolicyConfig, "Str", DeviceID, "Int", 2)  ; Default Communication Device
}

/*
    Device Properties (Core Audio APIs)
    https://docs.microsoft.com/en-us/windows/win32/coreaudio/device-properties

    026E516E-B814-414B-83CD-856D6FEF4822, 2   The friendly name of the audio adapter to which the endpoint device is attached.
    A45C254E-DF1C-4EFD-8020-67D146A850E0, 2   The device description of the endpoint device.
    A45C254E-DF1C-4EFD-8020-67D146A850E0,14   The friendly name of the endpoint device.
*/
InitDeviceProp(clsid, n)
{
    clsid := CLSIDFromString(clsid, Buffer(16+4))
    NumPut("Int", n, clsid, 16)
    return clsid
}

GetDeviceProp(ptr, clsid, n)
{
    ; IPropertyStore::GetValue method.
    ; https://docs.microsoft.com/en-us/windows/win32/api/propsys/nf-propsys-ipropertystore-getvalue
    ComCall(5, ptr, "Ptr", InitDeviceProp(clsid, n), "Ptr", pvar := PropVariant())
    return String(pvar)
}

GetDeviceID(list, name)
{
    for device in list
        if InStr(device["Name"], name)
            return device["ID"]
    throw
}

CLSIDFromString(Str, Buffer := 0)
{
    if (!Buffer)
        Buffer := Buffer(16)
    DllCall("Ole32\CLSIDFromString", "Str", Str, "Ptr", Buffer, "HRESULT")
    return Buffer
}

class PropVariant
{
    __New()
    {
        this.buffer := Buffer(A_PtrSize == 4 ? 16 : 24)
        this.ptr    := this.buffer.ptr
        this.size   := this.buffer.size
    }

    __Delete()
    {
        DllCall("Ole32\PropVariantClear", "Ptr", this.ptr, "HRESULT")
    }

    ToString()
    {
        return StrGet(NumGet(this.ptr, 8, "UPtr"))  ; LPWSTR PROPVARIANT.pwszVal
    }
}