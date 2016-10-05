
Class PEASY_GUI_CBase {

    ; Class properties
    __Name := 
    __VName := 
    __Handle := 
    __GuiHwnd := 
    __DefaultValue := 
    __Type := 
    __VNamePrefix := "PEASY_GUIC_GVAR_"

; == PUBLIC METHODS

    ; Constructor (Default constructor doesn't call appropriate method - ie, you must extend and use ctor below)
    __New(){
    }

    ; Mimic GuiControlGet behavior.
    GuiControlGet(cmd := "", value := ""){
        local GuiC
        GuiControlGet, GuiC, % cmd, % this.__Handle, % value
        return GuiC
    }

    ; Get value after a submit
    GetValue() {
        return PEASY_GFUNC_uGetGlobalVariable(this.__VName)
    }

    ; Get raw value now
    GetValueNow() {
        return this.GuiControlGet()
    }

    ; Set the value
    SetValue(Value) {
        PEASY_GFUNC_uSetGlobalVariable(this.__VName, Value)
        GuiControl,,% this.__Handle, % Value
        return
    }

    ; Set the default value
    SetDefaultValue() {
        PEASY_GFUNC_uSetGlobalVariable(this.__VName, this.__DefaultValue)
        GuiControl,,% this.__Handle, % this.__DefaultValue
        return
    }

    ; Enable control
    Enable() {
        GuiControl,Enable,% this.__Handle
        return
    }

    ;Disable control
    Disable() {
        GuiControl,Disable,% this.__Handle
        return
    }

    ; Default dynamic constructor ()
    _ConstructControl(GuiHwnd, OwnerAddr , Name , ActionMethodName , Options, DefaultValue) {
        ; Store owner-window handle
        this.__GuiHwnd := GuiHwnd

        ; Store friendly name
        this._StoreName(Name)

        ; Generate VName
        this.__VName := this._GenerateVName()

        ; Save the default value
        this.__DefaultValue := DefaultValue
        
        ; Create and bind the control (Store handle for later)
        this.__Handle := this._AddControlToGUI(this._ParseOptions(Options), this.__VName, this._GenerateFuncObj(OwnerAddr, ActionMethodName))
    }

; == PRIVATE METHODS (override in extensions)

    ; Creates the control, binds FuncObj, then returns the control handle
    _AddControlToGUI(Options, VName, FuncObj) {
        static ; Static for "Gui, Add"
        local CtrlHwnd

        ; Create the GUI control
        Gui, % this.__OwnerHwnd ":Add", % "Edit", % "hwndCtrlHwnd " Options " v" VName, this.__DefaultValue

        ; Add bound func obj to OnChange control event
        if not FuncObj = ""
            GuiControl +g, % CtrlHwnd, % FuncObj

        return CtrlHwnd
    }

    _StoreName(Name) {
        ; Store friendly name
        this.__Name := Name
    }

    _GenerateVName() {
        local VName
        ; Prepend container address to obtain unique name that links to this class instance cvar.
        VName := this.__VNamePrefix . Object(this)
        
        ; Make sure the "__VName" variable is already a global
        PEASY_GFUNC_uSetGlobalVariable(VName, "")

        return VName
    }

    ; Parses optional parameters (array) into a string
    _ParseOptions(Options) {
        local OptionsString, _index, _element
        ; Make sure this string is empty first
        OptionsString := ""

        ; Concatenate each param
        for _index, _element in Options
            OptionsString := OptionsString . " " . _element

        return OptionsString
    }

    ; Generate a function object and bind parameters to it
    _GenerateFuncObj(OwnerAddress, ActionMethodName) {
        local FuncObj
        
        ; Check if we're binding an instanced method to OnChange event
        if not OwnerAddress = 0
            FuncObj := Func(g_PEASY_GFUNC_NAME).Bind(&this, OwnerAddress, ActionMethodName)

        ; Check if we're binding a global function to OnChange event
        else if not ActionMethodName = ""
            FuncObj := Func(ActionMethodName).Bind(&this)

        ; No func object needed
        else
            FuncObj := ""

        return FuncObj
    }
}