
; Custom Edit Container
Class PEASY_GUI_CCheckbox extends PEASY_GUI_CBase {
    __InitCheckedState :=
    __Type := "CheckBox"

    __New(GuiHwnd, OwnerAddress , Name , ActionMethodName , Options, DefaultValue, CheckedState){
        this.__InitCheckedState := CheckedState
        this._ConstructControl(GuiHwnd, OwnerAddress, Name, ActionMethodName, Options, DefaultValue)
    }

    ; Creates the control, binds FuncObj, then returns the control handle
    _AddControlToGUI(Options, VName, FuncObj) {
        static ; Static for "Gui, Add"
        local CtrlHwnd
        
        ; Create the GUI control
        Gui, % this.__GuiHwnd ":Add", % "CheckBox", % "hwndCtrlHwnd Checked" this.__InitCheckedState " " Options " v" VName, % this.__DefaultValue

        ; Add bound func obj to OnChange control event
        if not FuncObj = ""
            GuiControl +g, % CtrlHwnd, % FuncObj

        return CtrlHwnd
    }

    ; Set the default value
    SetDefaultValue() {
       this.SetValue(this.__InitCheckedState)
       return
    }
}