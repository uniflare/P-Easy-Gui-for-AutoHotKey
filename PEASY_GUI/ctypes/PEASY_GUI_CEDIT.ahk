
; Custom Edit Container
Class PEASY_GUI_CEdit extends PEASY_GUI_CBase {
    __Type := "Edit"
    
    __New(GuiHwnd, OwnerAddress , Name , ActionMethodName , Options, DefaultValue){
        this._ConstructControl(GuiHwnd, OwnerAddress, Name, ActionMethodName, Options, DefaultValue)
    }

    ; Creates the control, binds FuncObj, then returns the control handle
    _AddControlToGUI(Options, VName, FuncObj) {
        static ; Static for "Gui, Add"
        local CtrlHwnd

        ; Create the GUI control
        Gui, % this.__GuiHwnd ":Add", % "Edit", % "hwndCtrlHwnd " Options " v" VName, % this.__DefaultValue

        ; Add bound func obj to OnChange control event
        if not FuncObj = ""
            GuiControl +g, % CtrlHwnd, % FuncObj

        return CtrlHwnd
    }
}