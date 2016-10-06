MAIN := new MainClass()
return

#include Example1\Example1.peasygui

Class MainClass {
    __GUIObject :=

    __New() {
        ; Create the GUI window (Take note of gui name you provide")
        this.__GUIObject := new PEASY_GUI_PEAGUIWINDOW("SomeGuiName", "Some Default title", "")

        ; Hook any functions we want to the GUI controls
        this.__GUIObject.FuncHookControl("ClickMeHandler", &this, "Button", "btnClickMe")

        ; Show the window
        this.__GUIObject.Show("X0 Y0") ; coordinates optional
    }

    ; Takes the Control Container as argument
    ClickMeHandler(CtrlCntr) {
        local DDLCntnr

        ; To get any changes values since last submit, we need to manually submit.
        this.__GUIObject.Submit()

        DDLCntnr := this.__GUIObject.__GuiControls["ddlSomeDefaultList"]

        MsgBox, % "ClickMe was clicked!" "`n"
        . "Name = " CtrlCntr.__Name "`n"
        . "__VName = " CtrlCntr.__VName "`n"
        . "__Handle = " CtrlCntr.__Handle "`n"
        . "__GuiHwnd = " CtrlCntr.__GuiHwnd "`n"
        . "__DefaultValue = " CtrlCntr.__DefaultValue "`n"
        . "__Type = " CtrlCntr.__Type "`n"
        . "__VNamePrefix = " CtrlCntr.__VNamePrefix "`n"
        . "Dropdown Value = " DDLCntnr.GetValue() "`n"
    }
}

; Use the name you gave when creating the gui
SomeGuiNameGuiClose:
    ;MAIN.__GUIObject.Close()
    ExitApp
return