#Include PEASY_GUI_Global.ahk
#Include base\PEASY_GUI_CBase.ahk

Class PEASY_GUI_BASE {

    __GuiControls := {}
    __Handle :=
    __Title :=
    __TriggerChangeHandlers := false
    __GuiWindowOptions := 
    __GuiWindowCreationOptions := 
	__Width := 400
	__Height := 150

    ; Public methods

    __GUI_OnChange_Handler(CtrlCntnrAddr, CtrlHwnd, GuiEvent, EventInfo, ErrorLev:="") {
        local CtrlCntnr, BtnFuncInst, MethodName, InstName, VarName, tGFCType, tGFCTypeO

        if this.__TriggerChangeHandlers = false
            return

        ; Get the instance from the Container Object Address
        CtrlCntnr := Object(CtrlCntnrAddr)

        ; Disable button (Since it wont work anyway)
        if (CtrlCntnr.__Type != "Edit")
            CtrlCntnr.Disable()

        ; Check for global control handler
        if this.__GuiFunc != ""
            this._DoControlHandlers(CtrlCntnr, "__GuiFunc")
        
        ; Check for type specific control handler
        if this["__GuiFunc_" CtrlCntnr.__Type] != ""
            this._DoControlHandlers(CtrlCntnr, "__GuiFunc_" CtrlCntnr.__Type)

        ; Check for type and name specific control handler
        if this["__GuiFunc_" CtrlCntnr.__Type "_" CtrlCntnr.__Name] != ""
            this._DoControlHandlers(CtrlCntnr, "__GuiFunc_" CtrlCntnr.__Type "_" CtrlCntnr.__Name)
            
        ; Re-enable
        CtrlCntnr.Enable()

        return
    }

    _DebugMsgShowThis() {
        local DebugMessage
        DebugMessage := ""

        For Name, Value in this {
            DebugMessage := DebugMessage "this." Name " = " Value "`n"
        }

        MsgBox, % "_DebugMsgShowThis()`n" DebugMessage
    }

    _DoControlHandlers(ByRef CtrlCntnr, HandlerVarName) {

        ; Instance
        if this[HandlerVarName "InstAddr"] != ""
        {
            ; Store name of variable that should hold the method/function instance container name
            InstAddr := this[HandlerVarName "InstAddr"]

            InstObj := Object(InstAddr)
            InstObj[this[HandlerVarName]](CtrlCntnr)
        }
        ; Global function
        else
        {
            if (IsFunc(this[HandlerVarName])) {
                this[HandlerVarName](CtrlCntnr)
            }
        }
    }

    __New(GUI_UID, GUI_Title, Options, bDefault=0) {
        local GuiHwnd

        ; Load Config
        PEASY_GFUNC_uSetGlobalVariable("g_PEASY_GFUNC_NAME", "PEASY_GFUNC_ControlCoordinator")

        ; Options
        Options := "+HwndGuiHwnd " Options " " this.__GuiWindowCreationOptions

        ; Save Title
        if (GUI_Title != "")
            this.__Title := GUI_Title

        ; Create new GUI window
        Gui, % GUI_UID ":New", % Options, % this.__Title
        
        ; Set as default GUI
        if (bDefault)
            Gui % GUI_UID ":Default"

        ; Store the GUI handle
        this.__Handle := GuiHwnd

        ; Add GUI Controls
        this._ConstructWindow()

        ; Enable any control action handlers/change handlers
        this.__TriggerChangeHandlers := true
    }

    __Delete() {
		;MsgBox, % "Destroyed Window: " this.__Handle
        Gui, % this.__Handle ":Destroy"

        return
    }

    ; Use this to set a function/method to be called on control change/submit
    FuncHookControl(MethodName, OwnerInstAddr="", CType="", CName="") {
        local VarName

        if (CType != "")
            if (CName != "")
                ; Type AND Name Specified
                VarName := "__GuiFunc_" CType "_" CName
            else
                ; Type Specified
                VarName := "__GuiFunc_" CType
        else
            ; Global Handler
            VarName := "__GuiFunc"
        
        ; Set the action handler name
        this[VarName] := MethodName

        ; Set the instance owner of the action handler
        if OwnerInstAddr != "" 
            this[VarName "InstAddr"] := OwnerInstAddr

        return
    }

    Show(Options="", b_TriggerHandlers=false) {
        this.__TriggerChangeHandlers := b_TriggerHandlers

        if (Options="")
            Options := this.__GuiWindowOptions
        
        Options := "w" this.__Width " h" this.__Height " " Options

        Gui, % this.__Handle ":Show", % Options, % this.__Title

        this.__TriggerChangeHandlers := true
        return
    }

    Close() {
        Gui, % this.__Handle ":Cancel"
        return
    }

    Destroy() {
        Gui, % this.__Handle ":Destroy"
        return
    }

    Submit(Silent=false) {
        if (Silent)
            this.__TriggerChangeHandlers := false
        Gui, % this.__Handle ":Submit", NoHide
        if (Silent)
            this.__TriggerChangeHandlers := true
        return
    }
    
    SetControlValues(ByRef ValuesMap, bTriggerHandlers=false) {
        this.__TriggerChangeHandlers := bTriggerHandlers

        For name, value in ValuesMap
            this.__GuiControls[name].SetValue(value)

        this.__TriggerChangeHandlers := true
    }

    GetControlValues(GuiName="") {
        local CVals

        if (GuiName != "")
            return this.__GuiControls[GuiName].GetValue()

        CVals := {}
        For name, value in this.__GuiControls
            CVals[name] := this.__GuiControls[name].GetValue()
        
        return CVals
    }

    SetAlwaysOnTop(AlwaysOnTop) {
        if (AlwaysOnTop)
            Gui, % this.__Handle ":+AlwaysOnTop"
        else
            Gui, % this.__Handle ":-AlwaysOnTop"
    }

    SetOwnDialogs(OwnDialogs) {
        if (OwnDialogs)
            Gui, % this.__Handle ":+OwnDialogs"
        else
            Gui, % this.__Handle ":-OwnDialogs"
    }
}