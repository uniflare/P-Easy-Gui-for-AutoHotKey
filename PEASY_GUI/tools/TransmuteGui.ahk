; Globals
#SingleInstance,Force
LocalVariableString := ""
DefaultVariableString := ""

fInit()
return

fInit() {
    local InFileName, XMLObject, XMLWindow, XMLShow, AHKText, GUIText, SelectedFile
	
	InFileName := ""
    OutFileName := ""
	
	FileSelectFile, InFileName, 3, guis , Choose GUI XML file to convert, Gui Creator XML (*.xml)
	if (InFileName = "")
		ExitApp
		
	SplitPath, InFileName , , , , SelectedFile
	
	FileSelectFile, OutFileName, S18, guis\%SelectedFile% , Choose location of output file, PEASY GUI Construct (*.peasygui)
	if (OutFileName = "")
		ExitApp
		
		
	if (SubStr(OutFileName, -7) != ".peasygui")
		OutFileName := OutFileName ".peasygui"

    ;OutFileName := "MainGui.gui"
    ;InFileName := "3rd\gui.xml"

    ; Load XML Text
    XMLObject := fLoadXML(InFileName)

    ; Parse XML Document using XPath
    XMLWindow:= XMLObject.selectSingleNode("/gui/window")
    XMLShowNode := XMLObject.selectSingleNode("/gui/show")

    ; Generate PEASY GUI Construction Code
    GUIText := _ExpandControlNode(XMLWindow, "`n`n")

    ; Prepend Default
    GUIText := "`t`t; Default Values: `n" DefaultVariableString
        . GUIText 

    ; Prepend Locals
    GUIText := "`n`t`tlocal " LocalVariableString "`n`n"
        . GUIText 

    ; Prepend Fuction Signature
    GUIText := "`t_ConstructWindow() {`n" GUIText

    ; Append Fuction return
    GUIText := GUIText "`n`t`treturn`n`t}"

    ; Prepend Class Definition
    GUIText := ""
    . "#Include %A_ScriptDir%\..\PEASY_GUI`n"
    . "#Include base\PEASY_GUI_Base.ahk`n"
    . "#Include ctypes\PEASY_GUI_CEDIT.ahk`n"
    . "#Include ctypes\PEASY_GUI_CDROPDOWN.ahk`n"
    . "#Include ctypes\PEASY_GUI_CBUTTON.ahk`n"
    . "#Include ctypes\PEASY_GUI_CCHECKBOX.ahk`n"
    . "#Include ctypes\PEASY_GUI_CLABEL.ahk`n"
    . "#Include ctypes\PEASY_GUI_CGROUP.ahk`n"
    . "#Include ctypes\PEASY_GUI_CPROGRESS.ahk`n"
    . "#Include %A_ScriptDir%`n"
    . "`n"
    . "Class PEASY_GUI_" GenerateUniqueSafeName(XMLShowNode.getAttribute("title")) "WINDOW extends PEASY_GUI_BASE {`n"
    . "`t__Title := """ XMLShowNode.getAttribute("title") """`n"
    . "`t__Width := " XMLShowNode.getAttribute("w") "`n"
    . "`t__Height := " XMLShowNode.getAttribute("h") "`n"
    . "`t__GuiWindowOptions := """ XMLShowNode.getAttribute("options") """`n"
    . "`t__GuiWindowCreationOptions := """ XMLShowNode.getAttribute("gui") """`n"
    . "`n" GUIText

    ; Append Class Close Brace

    GUIText := GUIText
	. "}"

    ; Save Gui Code
    FileDelete, % OutFileName
    FileAppend, % GUIText, % OutFileName, UTF-8

    msgbox, % "Done"
    ExitApp
}

fLoadXML(InFileName) {
    
    local XMLObject, XMLText

    ; Check if file exists
    if (!FileExist(InFileName))
        return false

    ; Load File Text into XMLText
    FileRead, XMLText, % InFileName
    
    ; Make XML Object
    XMLObject := ComObjCreate("MSXML2.DOMDocument.6.0")
    XMLObject.async := false
    XMLObject.LoadXML(XMLText)

    return XMLObject
}

_ExpandControlNode(XMLNode, OutText) {
    local ChildNode, ControlTypes, Attr, Options, FontStruct, hasFont, forItem, FontText

    FontStruct := {}

    ControlTypes := {"GroupBox":"PEASY_GUI_CGroup"
        , "Text":"PEASY_GUI_CLabel"
        , "Edit":"PEASY_GUI_CEdit"
        , "Button":"PEASY_GUI_CButton"
        , "DropDownList":"PEASY_GUI_CDropDown"
        , "Checkbox":"PEASY_GUI_CCheckBox"
        , "Progress":"PEASY_GUI_CProgress"}

    if (XMLNode.getAttribute("v") != "") {

        Attr := { "type":XMLNode.getAttribute("type")
            ,"x":XMLNode.getAttribute("x"),"y":XMLNode.getAttribute("y")
            ,"w":XMLNode.getAttribute("w"),"h":XMLNode.getAttribute("h")
            ,"options":XMLNode.getAttribute("options")
            ,"g":XMLNode.getAttribute("g")
            ,"v":XMLNode.getAttribute("v")
            ,"value":XMLNode.getAttribute("value")
            ,"background":XMLNode.getAttribute("background")
            ,"bold":XMLNode.getAttribute("bold")
            ,"color":XMLNode.getAttribute("color")
            ,"font":XMLNode.getAttribute("font")
            ,"italic":XMLNode.getAttribute("italic")
            ,"size":XMLNode.getAttribute("size")
            ,"strikeout":XMLNode.getAttribute("strikeout")
            ,"tab":XMLNode.getAttribute("tab")
            ,"underline":XMLNode.getAttribute("underline") }

        if (LocalVariableString != "") 
            LocalVariableString := LocalVariableString "`n`t`t`t,"

        LocalVariableString := LocalVariableString "gui_" Attr["v"]

        Options := ""
        if (Attr["x"] != "")
            Options := Options " x" Attr["x"]
        if (Attr["y"] != "")
            Options := Options " y" Attr["y"]
        if (Attr["w"] != "")
            Options := Options " w" Attr["w"]
        if (Attr["h"] != "")
            Options := Options " h" Attr["h"]
        if (Attr["options"] != "")
            Options := Options " " Attr["options"] " "

        if(Attr["type"] = "DropDownList")
            Options := Options " AltSubmit "

        ; Fonts

        if (Attr["bold"] != "")
            FontStruct["bold"] := Attr["bold"] " "

        if (Attr["color"] != "")
            FontStruct["color"] := "c" Attr["color"] " "

        if (Attr["font"] != "")
            FontStruct["font"] := Attr["font"] " "

        if (Attr["italic"] != "")
            FontStruct["italic"] := Attr["italic"] " "

        if (Attr["size"] != "")
            FontStruct["size"] := "s" Attr["size"] " "

        if (Attr["strikeout"] != "")
            FontStruct["strikeout"] := Attr["strikeout"] " "

        if (Attr["underline"] != "")
            FontStruct["underline"] := Attr["underline"] " "

        ; Font
        for forItem in FontStruct {
            if (Attr["type"] != "Progress" and Attr["type"] != "Button")
                OutText := OutText
                . "`t`tGui,Font,Normal " FontStruct["size"] FontStruct["color"] FontStruct["bold"] FontStruct["italic"] FontStruct["strikeout"] FontStruct["underline"] "," FontStruct["font"] "`n"
            else {
                if (Attr["background"] != "") {
                    Options := Options " Background" Attr["background"]
                }
                if (Attr["color"] != "") {
                    Options := Options " c" Attr["color"]
                }
            }
            break
        }
        
        OutText := OutText 
        . "`t`tthis.__GuiControls[""" Attr["v"] """] := new " ControlTypes[Attr["type"]] "(this.__Handle`n"
        . "`t`t, &this`n"
        . "`t`t,""" Attr["v"] """`n"
        . "`t`t, ""__GUI_OnChange_Handler""`n"
        . "`t`t, [""" Options """]`n"


        if (Attr["type"] = "DropDownList" ) {
            OutText := OutText 
            . "`t`t, gui_" Attr["v"] "`n"
            . "`t`t, gui_" Attr["v"] "Options)`n"

            DefaultVariableString := "`t`tgui_" Attr["v"] "Options := """ Attr["value"] """`n" DefaultVariableString
            DefaultVariableString := "`t`tgui_" Attr["v"] " := " Attr["g"] "`n" DefaultVariableString
            
            if (LocalVariableString != "") 
                LocalVariableString := LocalVariableString "`n`t`t`t,"

            LocalVariableString := LocalVariableString "gui_" Attr["v"] "Options"
        }
        else if (XMLNode.getAttribute("type") = "CheckBox") {
            OutText := OutText 
            . "`t`t, """ Attr["value"] """`n"
            . "`t`t, gui_" Attr["v"] ")`n"

            DefaultVariableString := "`t`tgui_" Attr["v"] "Text := """ Attr["value"] """`n" DefaultVariableString
            DefaultVariableString := "`t`tgui_" Attr["v"] " := " Attr["g"] "`n" DefaultVariableString
            
            if (LocalVariableString != "") 
                LocalVariableString := LocalVariableString "`n`t`t`t,"

            LocalVariableString := LocalVariableString "gui_" Attr["v"] "Text"
        }
        else
        {
            OutText := OutText 
            . "`t`t, """ Attr["value"] """)`n"

            DefaultVariableString := "`t`tgui_" Attr["v"] " := """ Attr["value"] """`n" DefaultVariableString
        }

        ; Font
        for forItem in FontStruct {
            if (Attr["type"] != "Progress" and Attr["type"] != "Button")
                OutText := OutText
                . "`t`tGui,Font`n"
            break
        }

        OutText := OutText "`n"
    }

    for ChildNode in XMLNode.childNodes {
        OutText := _ExpandControlNode(ChildNode, OutText)
    }

    return OutText
}

GenerateUniqueSafeName(GUITitle) {
    local safename, charpos

    safename := ""
    charpos := 0

    Loop, 3 {
        charpos += _CharPos(SubStr(GUITitle, charpos))
        if (charpos) {
            safename := safename SubStr(GUITitle, charpos, 1)
        } else {
            msgbox, % "Not enough characters in title"
            break
        }
    }
    charpos += (_SpacePos(SubStr(GUITitle, charpos)) - 1)
    if (charpos) {
        charpos += _CharPos(SubStr(GUITitle, charpos)) - 1
        Loop, 3 {
            if (charpos) {
                safename := safename SubStr(GUITitle, charpos, 1)
                charpos += _CharPos(SubStr(GUITitle, charpos))
            } else {
                msgbox, % "Not enough characters in title"
                break
            }
        }
    } else {
        msgbox, % "Not enough words in title"
    }

    StringUpper, safename, safename
    ; get first 6 characters minimum.
    ; turn uppercase
    ; return or error if not 6 chars

    return safename
}

_CharPos(Text) {
    return RegExMatch(Text, "i)[a-zA-Z0-9_]")
}

_SpacePos(Text) {
    return RegExMatch(Text, "i)[ ]")
}