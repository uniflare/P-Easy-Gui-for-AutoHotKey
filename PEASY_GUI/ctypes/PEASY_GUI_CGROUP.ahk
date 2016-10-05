
; Custom Edit Container
Class PEASY_GUI_CGroup extends PEASY_GUI_CBase {
    __Type := "GroupBox"

    __New(GuiHwnd, OwnerAddress , Name , ActionMethodName , Options, DefaultValue){
        this._ConstructControl(GuiHwnd, OwnerAddress, Name, ActionMethodName, Options, DefaultValue)
    }

    ; Creates the control, binds FuncObj, then returns the control handle
    _AddControlToGUI(Options, VName, FuncObj) {
        static ; Static for "Gui, Add"
        local CtrlHwnd

        ; Create the GUI control
        Gui, % this.__GuiHwnd ":Add", % "GroupBox", % "hwndCtrlHwnd " Options , % this.__DefaultValue

        return CtrlHwnd
    }
}