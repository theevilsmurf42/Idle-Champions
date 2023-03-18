#include %A_LineFile%\..\IC_MemoryPointer_Class.ahk
; DialogManager class contains IC's DialogManager class structure. Useful for finding information in dialogues such as what Favor needs to be converted.
; DialogList needs to open a BlessingsStoreDialog object instead of a Dialog object.
; Searching for ptr depth of 1 has been fine.
class IC_DialogManager_Class extends IC_MemoryPointer_Class
{
    GetVersion()
    {
        return "v2.1.0, 2023-03-18"
    }

    Refresh()
    {
        this.Main := new _ClassMemory("ahk_exe " . g_userSettings[ "ExeName"], "", hProcessCopy)
        this.BaseAddress := this.Main.getModuleBaseAddress("mono-2.0-bdwgc.dll")+this.moduleOffset
        this.UnityGameEngine := {}
        this.UnityGameEngine.Dialogs := {}
        structureOffsetsOverlay := this.structureOffsets.Clone()
        structureOffsetsOverlay[1] += 0x0 ;0x010
        offsets := (this.HasOverlay() AND this.Main.isTarget64bit) ? structureOffsetsOverlay : this.structureOffsets
        this.UnityGameEngine.Dialogs.DialogManager := new GameObjectStructure(offsets)
        this.UnityGameEngine.Dialogs.DialogManager.Is64Bit := this.Main.isTarget64bit
        this.UnityGameEngine.Dialogs.DialogManager.BaseAddress := this.BaseAddress
        if(!this.Main.isTarget64bit)
        {
            #include *i %A_LineFile%\..\Imports\IC_DialogManager32_Import.ahk
        }
        else
        {
            #include *i %A_LineFile%\..\Imports\IC_DialogManager64_Import.ahk
        }
    }

    ; GfxPluginEOSLoader_x64 and EOSSDK-Win64-Shipping.dll are EGS specific DLLs for its overlay.
    ; Since they are either removed by some people or a 64 bit version may not include them, the pointer could change depending on if they exist.
    HasOverlay()
    {
        overlayDLL1 := this.Main.getModuleBaseAddress("GfxPluginEOSLoader_x64.dll")
        overlayDLL2 := this.Main.getModuleBaseAddress("EOSSDK-Win64-Shipping.dll")
        return (overlayDLL1 != -1 AND overlayDLL2 != -1)
    }
}