
; Custom Edit Container
Class PEASY_GUI_CDropDown extends PEASY_GUI_CBase {
    __Type := "DropDownList"
    __InitialOptions := 

    __New(GuiHwnd, OwnerAddress , Name , ActionMethodName , Options, DefaultValue, SelectOptions){
        this.__InitialOptions := SelectOptions
        this._ConstructControl(GuiHwnd, OwnerAddress, Name, ActionMethodName, Options, DefaultValue)
    }
    
    ; Creates the control, binds FuncObj, then returns the control handle
    _AddControlToGUI(Options, VName, FuncObj) {
        static ; Static for "Gui, Add"
        local CtrlHwnd

        ; Create the GUI control
        Gui, % this.__GuiHwnd ":Add", % "DropDownList", % "hwndCtrlHwnd Choose" this.__DefaultValue " " Options " v" VName, % this.__InitialOptions

        ; Add bound func obj to OnChange control event
        if not FuncObj = ""
            GuiControl +g, % CtrlHwnd, % FuncObj

        return CtrlHwnd
    }

    ; Set the value
    SetValue(Value) {
        PEASY_GFUNC_uSetGlobalVariable(this.__VName, Value)
        GuiControl, Choose, % this.__Handle, % Value
        return
    }

    ; Set the default value
    SetDefaultValue() {
       this.SetValue(this.__DefaultValue)
        return
    }

    ; Set the option list
    SetOptions(Value) {
        PEASY_GFUNC_uSetGlobalVariable(this.__VName, Value)
        GuiControl, ,% this.__Handle, % "|" Value
        return
    }

    ; Add an option to the list
    AddOption(Value) {
        PEASY_GFUNC_uSetGlobalVariable(this.__VName, Value)
        GuiControl, ,% this.__Handle, % Value
        return
    }
}