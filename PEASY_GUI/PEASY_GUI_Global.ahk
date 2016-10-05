; Global variable helpers
PEASY_GFUNC_uSetGlobalVariable(GlobalVarName, GlobalVarValue) {
    Global
    %GlobalVarName% := GlobalVarValue
}
PEASY_GFUNC_uGetGlobalVariable(GlobalVarName) {
    Global
    local var := %GlobalVarName%
    return var
}

; Globally defined function for handling onChange events via instanced methods
PEASY_GFUNC_ControlCoordinator(CtrlCntnrAddr, OwnerObjAddr, OwnerMeth, CtrlHwnd, GuiEvent, EventInfo, ErrorLev:="") {
    local OwnerObj

    ; Call the ControlOnChange instance method for this control
    OwnerObj := Object(OwnerObjAddr)
    OwnerObj[OwnerMeth](CtrlCntnrAddr, CtrlHwnd, GuiEvent, EventInfo, ErrorLev)
}