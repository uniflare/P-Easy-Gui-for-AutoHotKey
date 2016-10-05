; Version: 0.001.26
; Author: maestrith
; License: Unspecified
; Git: https://github.com/maestrith/GUI_Creator

#SingleInstance,Force
DetectHiddenWindows,On
/*
if !A_IsCompiled{
	if (A_PtrSize=4){
		SplitPath,A_AhkPath,,apdir
		SplitPath,A_ScriptName,filename,dir
		run,%apdir%\AutoHotkeyU64.exe "%A_ScriptName%",%dir%
		ExitApp
	}
}
*/
if !FileExist("GuiCreator"){
	FileCreateDir,GuiCreator
	firstrun:=1
}
checkfiles()
v:=[],gui:=new xml("gui"),settings:=new xml("settings","GuiCreator\lib\settings.xml")
controls:=new xml("controls","GuiCreator\lib\controls.xml")
global settings,gui,v,controls
file:=settings.ssn("//last/@file").text
if !file
gui()
if settings.ssn("//last/@file").text
load_GUI(1)
WinSet,Redraw,,% hwnd([1])
mode_select(),snap()
if firstrun
help()
edit("GUI Settings")
return
t(x*){
	for a,b in x
	list.=b "`n"
	ToolTip,%list%
}
m(x*){
	for a,b in x
	list.=b "`n"
	MsgBox,% list
}
tt(x*){
	for a,b in x
	list.=b "`n"
	ToolTip,%list%,0,0,3
}
getpos(con){
	ControlGetPos,x,y,w,h,,ahk_id%con%
	x-=v.border,y-=v.border+v.caption
	return {x:x,y:y,w:w,h:h}
}
class xml{
	k:=[]
	__New(root,file=""){
		temp:=ComObjCreate("MSXML2.DOMDocument"),temp.setProperty("SelectionLanguage","XPath")
		this.xml:=temp
		If FileExist(file)
		temp.load(file),this.xml:=temp
		else
		this.xml:=this.CreateElement(temp,root)
		this.file:=file
		xml.k[root]:=this
	}
	CreateElement(doc,root){
		return doc.AppendChild(this.xml.CreateElement(root)).parentnode
	}
	unique(p,att,check){
		find:=IsObject(check)?"//" p "[text()='" att.text "']":"//" p "[@" check "='" att.att[check] "']"
		att["dup"]:=this.xml.SelectSingleNode(find)?0:1,current:=this.xml.SelectSingleNode(find)
		if att.dup
		return this.add(p,att)
		for a,b in att.att
		current.SetAttribute(a,b)
		if att.text
		current.text:=att.text
		return current
	}
	under(info){
		new:=info.under.appendchild(this.xml.createelement(info.node))
		for a,b in info.att
		new.SetAttribute(a,b)
		new.text:=info.text
		return new
	}
	remove(path){
		rem:=this.xml.SelectSingleNode(path),rem.ParentNode.RemoveChild(rem)
	}
	current(con){
		return this.ssn("//*[@hwnd='" con "']")
	}
	control(control){
		return this.ea("//*[@hwnd='" control "']")
	}
	__Get(x=""){
		return this.xml.xml
	}
	easy(node){
		x:=node.SelectNodes("@*"),ret:=[]
		while,xx:=x.item(A_Index-1)
		ret[xx.nodename]:=xx.text
		return ret
	}
	ea(path){
		nodes:=this.xml.SelectNodes(path "/@*"),obj:=[]
		while,n:=nodes.item(A_Index-1)
		obj[n.nodename]:=n.text
		return obj
	}
	sn(path){
		return this.xml.SelectNodes(path)
	}
	ssn(path){
		return this.xml.SelectSingleNode(path)
	}
	allsel(){
		selected:=this.sn("//selected/*")
		while,sel:=selected.item(A_Index-1)
		list.="@hwnd='" sel.text "' or "
		list:=SubStr(list,1,InStr(list,"or",0,0)-1)
		return list
	}
	save(x*){
		if x.1=1
		this.Transform()
		filename:=this.file?this.file:x.1.1
		file:=fileopen(filename,"rw","UTF-8")
		if (file.read()=this.xml.xml)
		return
		file.seek(0)
		file.write(this.xml.xml)
		file.length(file.position)
	}
	add(path,info=""){
		p:="/",dup:=this.ssn("//" path)?1:0
		next:=this.ssn("//" path)?this.ssn("//" path):this.ssn("//*")
		Loop,Parse,path,/
		last:=A_LoopField,p.="/" last,next:=this.ssn(p)?this.ssn(p):next.appendchild(this.xml.CreateElement(last))
		if (info.dup&&dup)
		next:=next.parentnode.appendchild(this.xml.CreateElement(last))
		for a,b in info.att {
		next.SetAttribute(a,b)
		}
		if info.text!="" {
		next.text:=info.text
		}
		return next
	}
	transform(){
		static
		if !IsObject(xsl){
			xsl:=ComObjCreate("MSXML2.DOMDocument")
			style=
			(
			<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
			<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
			<xsl:template match="@*|node()">
			<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:for-each select="@*">
			<xsl:text/>
			</xsl:for-each>
			</xsl:copy>
			</xsl:template>
			</xsl:stylesheet>
			)
			xsl.loadXML(style),style:=null
		}
		this.xml.transformNodeToObject(xsl,this.xml)
	}
}
sn(node,path){
	return node.SelectNodes(path)
}
ssn(node,path){
	return node.SelectSingleNode(path)
}
hwnd(number,wnd=""){
	static hwnd:=[]
	if number.remove{
		uu:=settings.unique("window/position",{att:{win:number.remove},text:winpos(number.remove).text},"win")
		Gui,% number.remove ":Destroy"
		return hwnd[number.remove]:=""
	}
	if IsObject(number)
	return hwnd[number.1].h
	if !wnd
	return hwnd[number].n
	hwnd[number]:={n:wnd,h:"ahk_id " wnd+0}
}
LButton(){
	LButton:
	MouseGetPos,x,y,win,con,2
	if !(win=hwnd(1))
	return
	gui.remove("//templist")
	Sleep,0 ;IMPORTANT!!!!!
	if (v.currentmode="interact"){
		if !con
		return edit("gui settings")
		Gui.remove("//selected"),Gui.Add("gui/selected/hwnd").text:=married(con)
		edit("controls"),v.last:=con
		return
	}
	if (con){
		GuiControl,2:Choose,SysTabControl321,1
		married(con)
		con:=married(con),v.last:=con
		Grid(x,y)
		changesel:=1
		con+=0
		selected:=gui.ssn("//selected/*[text()='" con "']")?gui.sn("//gui/selected/*[text()]"):gui.sn("//*[@hwnd='" con "']/@hwnd")
		if !(v.currentmode="Resize"||GetKeyState("Shift","P")){
			while,ss:=selected.item(A_Index-1).Text{
				des:=sn(gui.current(ss),"descendant-or-self::*[@hwnd]")
				while,dd:=des.item(A_Index-1){
					ea:=xml.easy(dd)
					if (v.currentmode="Move")
					Gui.unique("templist/control",{att:{x:ea.x-x,y:ea.y-y,control:ea.hwnd,type:ea.type}},"control")
				}
			}
		}
		if (v.currentmode="Resize"||GetKeyState("Shift","P"))
		while,ss:=selected.item(A_Index-1).Text{
			ea:=gui.ea("//*[@hwnd='" ss "']")
			uu:=Gui.unique("templist/control",{att:{w:ea.w,h:ea.h,control:ea.hwnd,type:ea.type}},"control")
		}
		templist:=gui.sn("//templist/*")
		while,GetKeyState("LButton","P"){
			MouseGetPos,xx,yy
			Grid(xx,yy)
			sleep,1
			if !(Abs(xx-x)>3||abs(yy-y)>3)
			continue
			changesel:=0
			killhighlight()
			if (v.currentmode="Resize"||GetKeyState("Shift","P"))
			resize(templist,x,y)
			if (v.currentmode="Move")
			move(templist,x,y)
		}
		;if things are in remove list just move them back to the main <window>
		;move the GroupBox last and have it check for inside stuff
		;no tabs!
		v.removelist:=[]
		if Abs(xx-x)>3||abs(yy-y)>3{
			templist:=gui.ssn("//templist")
			for a,b in [sn(templist,"*[@type!='GroupBox' and @type!='Tab' and @type!='Tab2']"),sn(templist,"*[@type='GroupBox' or @type='Tab' or @type='Tab2']")]
			while,qq:=b.item(A_Index-1)
			top(ssn(qq,"@control").text)
		}
		for a,b in v.removelist{
			current:=gui.current(b)
			des:=sn(current,"descendant::*")
			while,dd:=des.item(A_Index-1).SelectSingleNode("@hwnd").text{
				if WinExist("ahk_id" dd){
					move:=Gui.current(dd)
					place(move)
				}
			}
			current.ParentNode.RemoveChild(current)
		}
		v.removelist:=""
		if changesel{
			if !(GetKeyState("Shift","P")=1||GetKeyState("Control","P")=1)
			gui.remove("//gui/selected")
			current:=gui.ssn("//selected/hwnd[text()='" con "']")
			if current&&GetKeyState("Control","P")
			current.ParentNode.RemoveChild(current)
			else
			gui.unique("selected/hwnd",{text:con},["hwnd"])
		}
		sleep,0
		highlight()
		if (sn(gui.ssn("//selected"),"*").length&&con)
		edit()
	}
	else
	{
		list:=select(x,y)
		if !(GetKeyState("Shift","P")=1||GetKeyState("Control","P")=1)
		gui.remove("//gui/selected")
		selected:=gui.add("gui/selected")
		while,ll:=list.item(A_Index-1){
			current:=gui.ssn("//selected/hwnd[text()='" ll.text "']")
			if current&&GetKeyState("Control","P")
			current.ParentNode.RemoveChild(current)
			current:=!current?gui.add("selected/hwnd",{text:ll.text,dup:1}):""
			Gui.unique("templist/control",{att:{control:ll.text}},"control")
		}
		highlight()
		if sn(selected,"*").length{
			GuiControl,2:Choose,SysTabControl321,1
			edit()
		}
		if gui.sn("//selected/*").length
		edit("controls")
		else
		edit("gui settings")
	}
	return
	notactive:
	sleep,1
	MouseGetPos,,,win,con,2
	if (win=hwnd(1)){
		v.last:=con+0
		WinActivate,% hwnd([1])
		WinWaitActive,% hwnd([1])
		LButton()
	}
	return
}
place(move){
	while,move.ParentNode.nodename="control"
	move.ParentNode.ParentNode.AppendChild(move)
	if move.ParentNode.nodename="GroupBox"&&ssn(move,"@type").text!="GroupBox"
	win:=gui.ssn("//window"),win.AppendChild(move)
}
top(con){
	current:=gui.ssn("//*[@hwnd='" con "']"),att:=gui.ea("//*[@hwnd='" con "']")
	if InStr(att.type,"Tab")
	return
	if tab:=gui.ssn("//*[@x<'" att.x "' and @x+@w>'" att.x "' and @y<'" att.y "' and @y+@h>'" att.y "' and (@type='Tab2' or @type='Tab')]"){
		if !ssn(tab,"descendant::*[@hwnd='" con "']"){
			DllCall("DestroyWindow",uint,att.hwnd),att.tab:=""
			newcon:=add_control(att.type,att)
			current:=gui.current(newcon.hwnd)
			v.removelist.Insert(con)
			gui.add("selected/hwnd",{text:newcon.hwnd})
			v.last:=newcon.hwnd
		}
	}
	else if att.tab{
		DllCall("DestroyWindow",uint,att.hwnd)
		att.remove("tab")
		newcon:=add_control(att.type,att)
		current:=gui.current(newcon.hwnd)
		v.last:=newcon.hwnd
		gui.add("selected/hwnd",{text:newcon.hwnd})
		v.removelist.Insert(con)
	}
	else if (att.type="GroupBox"){
		current:=gui.current(att.hwnd)
		list:=gui.sn("//*[@x>" att.x " and @x<" att.x+att.w " and @y>" att.y " and @y<" att.y+att.h " and @tab='" att.tab "' and @hwnd!='" ea.hwnd "']")
		Loop,% list.length{
			ll:=list.item(A_Index-1)
			if !ssn(current,"descendant::ll")
			current.AppendChild(list.item(A_Index-1))
		}
	}
	if list:=gui.ssn("//*[@x<" att.x " and @x+@w>" att.x " and @y<" att.y " and @y+@h>" att.y " and @tab='" att.tab "' and @type='GroupBox']"){
		if !ssn(list,"descendant::*[@hwnd='" att.hwnd "']")
		list.AppendChild(gui.current(att.hwnd))
	}
	if ancestor:=ssn(current,"ancestor::*[@type='GroupBox']"){
		if !list:=gui.ssn("//*[@x<" att.x " and @x+@w>" att.x " and @y<" att.y " and @y+@h>" att.y " and @tab='" att.tab "' and @type='GroupBox']")
		place(Gui.current(att.hwnd))
	}
	return
}
gui(hide=""){
	Gui,1:Destroy
	Gui,+Resize -0x30000 +hwndhwnd
	OnMessage(0x231,"killhighlight")
	OnMessage(0x136,"display_grid"),OnMessage(0x232,"snap")
	SysGet,border,32
	SysGet,caption,4
	Gui,Margin,10,10
	Hotkey,IfWinActive,ahk_id%hwnd%
	Hotkey,*~LButton,LButton,On
	Hotkey,!~LButton,interact,On
	Hotkey,IfWinNotActive,ahk_id%hwnd%
	Hotkey,*~LButton,notactive,On
	v.border:=border,v.caption:=caption
	hwnd(1,hwnd)
	hide:=hide?"Hide":""
	Gui,Show,% size(1,"w500 h500 Center") " " hide,GUI Creator : Right Click For The Menu
	gui_hotkey()
	return
	GuiEscape:
	GuiClose:
	MsgBox,259,GUI Creator,Save your current GUI?
	IfMsgBox,Yes
	save_gui()
	IfMsgBox,Cancel
	return
	if hwnd(2)
	hwnd({remove:2})
	hwnd({remove:1})
	settings.save(1)
	ExitApp
	return
}
interact:
return
new_gui(x=""){
	gui(x),gui:=new xml("gui"),snap()
}
gui_hotkey(){
	static personal:=[{hotkey:{label:"modesel",main:"LButton Mode Change"},keys:[["Next Mode","+up"],["Previous Mode","+down"]]}
	,{hotkey:{label:"adjust",main:"Adjust Selected Controls Position"},keys:[["Up","Up"],["Down","Down"],["Left","Left"],["Right","Right"]]}
	,{hotkey:{label:"allkeys",main:"Hotkeys"},keys:[["Copy GUI to Clipboard","^E"],["Export GUI","!E"]
	,["Show Code","S"],["Reorder GUI","!R"],["Test GUI","^T"],["Edit Labels","F1"]]}]
	v.personal:=personal
	for a,b in personal{
		if !main:=settings.ssn("//actions/hotkey[@label='" b.hotkey.label "']")
		main:=settings.add("actions/hotkey",{att:{label:b.hotkey.label,main:b.hotkey.main},dup:1})
		for c,d in b.keys{
			if !ssn(main,"//actions/hotkey/key[@desc='" d.1 "']")
			settings.under({under:main,node:"key",att:{desc:d.1,value:d.2}})
		}
	}
	list:=settings.sn("//hotkeys/*")
	Hotkey,IfWinActive,% hwnd([1])
	while,ll:=list.item(A_Index-1)
	if ll.text
	hotkey,% ll.text,addcontrol,On
	for a,b in personal{
		for c,d in b.keys{
			key:=settings.ssn("//hotkey[@label='" b.hotkey.label "']/key[@desc='" d.1 "']/@value").text
			key:=key?key:d.2
			Hotkey,%key%,% b.hotkey.label,On
		}
	}
	Hotkey,^a,selectall,On
	Hotkey,Delete,delete,On
	return
	addcontrol:
	MouseGetPos,x,y,win
	if (win!=hwnd(1))
	return m("Please have your mouse over the GUI Creator window")
	x-=v.Border,y-=v.Border+v.Caption
	grid(x,y)
	cl:=settings.ssn("//hotkeys/*[text()='" A_ThisHotkey "']").nodename
	if (cl="Picture"){
		FileSelectFile,picture,,,Select an image.,*.gif;*.jpg;*.png
		if ErrorLevel||picture=""
		return
	}
	value:=picture?picture:cl
	add_control(cl,{x:x,y:y,value:value,type:cl})
	return
	allkeys:
	ea:=clean(casessn(settings.xml,"value",A_ThisHotkey,"@desc").text)
	if IsFunc(ea)
	%ea%()
	return
}
casessn(node,attribute,find,att=""){
	StringLower,find,find
	att:=att?"/" att:""
	return ssn(node,"//*[translate(@" attribute ",'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='" find "']" att)
}
add_control(type,att){
	static tt:={Button:"Button",Checkbox:"Checkbox",ComboBox:"ComboBox",DateTime:"DateTime",DropDownList:"DropDownList",Edit:"Edit",GroupBox:"GroupBox",Hotkey:"Hotkey",Listbox:"Listbox",ListView:"ListView",MonthCal:"MonthCal",Picture:"Picture",Progress:"Progress",Radio:"Radio",Slider:"Slider",Tab:"Tab",Tab2:"Tab2",Text:"Text",Treeview:"Treeview",UpDown:"UpDown"}
	static controllist:=[]
	position:=""
	if (type="DateTime")
	att.value:="LongDate"
	if !att.tab
	att.tab:="" ;required
	att.type:=tt[att.type]
	if RegExMatch(att.type,"(ComboBox|DDL|DropDownList)")
	att.h:=500
	if InStr(att.options,"Password")
	att.remove("h"),att.options:=RegExReplace(att.options,"i)Multi")
	list:=att.r?"x,y,w":"x,y,w,h"
	for a,b in att
	if a in %list%
	if b
	position.=a b " "
	if att.r
	position.=" r" att.r " "
	options.=type="ListView"?" -Multi":""
	type:=type="Tab"?"Tab2":type
	if !InStr(type,"tab")
	tab:=whichtab(att)
	if tab.tab
	att.tab:=tab.tab
	options.=" " att.options
	if att.Background
	options.=" Background" att.Background
	value:=RegExReplace(att.value,"(``r|``n)","`n")
	value:=value?value:att.value
	Gui,1:Font,% compilefont(att),% att.font
	border:=settings.ssn("//options/Borders").text?"Border":""
	Gui,1:Add,%type%,%position% hwndhwnd %options% %border%,% value
	if type=TreeView
	root:=TV_Add("Treeview",0,"Expand"),TV_Add("This will not be in your compiled version",root)
	Gui,1:Font
	Gui,1:Tab
	att.type:=tt[att.type]
	married()
	for a,b in getpos(hwnd)
	att[a]:=b
	if RegExMatch(att.type,"(ComboBox|DDL|DropDownList)")
	att.remove("h")
	att["hwnd"]:=hwnd+0,att["type"]:=att.type
	if tab.ctrl{
		SplashTextOff
		root:=gui.ssn("//*[@hwnd='" tab.hwnd "']")
		if !current:=ssn(root,"tab[@tab='" tab.tab "']")
		current:=gui.under({under:root,node:"tab",att:{tab:tab.tab},dup:1})
		if before:=ssn(root,"tab[@tab='" tab.tab+1 "']")
		current:=root.insertbefore(current,before)
		current:=gui.under({under:current,node:"control",att:att})
	}
	else
	current:=Gui.add("window/control",{att:att,dup:1})
	if GroupBox:=gui.ssn("//*[@x<'" att.x "' and @x+@w>'" att.x "' and @y<'" att.y "' and @y+@h>'" att.y "' and @hwnd!='" ea.hwnd "'  and @type='GroupBox']"){
		if ssn(GroupBox,"@tab").text=att.tab&&current
		GroupBox.AppendChild(current)
	}
	if (att.type="GroupBox"){
		list:=gui.sn("//*[@x>" att.x " and @x<" att.x+att.w " and @y>" att.y " and @y<" att.y+att.h " and @tab='" att.tab "']/@hwnd")
		Loop,% list.length
		gui.current(att.hwnd).AppendChild(gui.current(list.item(A_Index-1).text))
	}
	if (att.type="ListView"){
		Loop,2
		LV_Add("","Test Item" A_Index)
	}
	if InStr(att.type,"Tab")
	Gui.Add("tablist/tab",{text:att.hwnd,att:{num:gui.sn("//tablist/*").length+1},dup:1})
	lastcl:=cl
	return att
}
grid(ByRef x,ByRef y,adjust=""){
	if adjust
	x-=v.Border,y-=v.border+v.caption
	if settings.ssn("//options/Snap_To_Grid").text
	x:=Round(x,-1),y:=Round(y,-1)
}
married(byref info=""){
	static married:=[],list
	if info
	return info:=married[info]?married[info]+0:info+0
	WinGet,cl,ControlListHWND,% hwnd([1])
	out:=RegExReplace(cl,(RegExReplace(list,"\n","|")))
	if RegExMatch(out,"O)(\w+)\s+(\w+)",found)
	married[found.2+0]:=found.1+0
	list:=cl
}
;check the ideas
debug(info=""){
	if v.loading
	return
	info:=info?info:gui
	if (WinExist(hwnd([98]))!=0&&hwnd(98)=""){
		Gui,98:+hwndhwnd
		hwnd(98,hwnd)
		Gui,98:Add,Edit,w800 h500 -Wrap
		Gui,98:Show,x0 y0,Debug
		WinActivate,% hwnd([1])
	}
	info.Transform()
	ll:=info.sn("//@hwnd")
	GuiControl,98:,Edit1,% info[] "`n`ncount: " ll.length
	Gui,1:Default
	return
	98GuiEscape:
	98GuiClose:
	hwnd({remove:98})
	return
}
winpos(win){
	VarSetCapacity(size,A_PtrSize*4,0),DllCall("user32\GetClientRect","uint",hwnd(win),"uint",&size),w:=NumGet(size,8),h:=NumGet(size,12)
	WinGetPos,x,y,,,% hwnd([win])
	if x&&y&&w&&h
	return {text:"x" x " y" y " w" w&0xffff " h" h,obj:{x:x,y:y,w:w&0xffff,h:h}}
}
select(xx,yy){
	Random,color,0xaaaaaa,0xeeeeee
	gui,59:-caption +alwaysontop +E0x20 +hwndselect +Owner1
	WinGetPos,wx,wy,ww,wh,% hwnd([1])
	gui,59:show,% "x" wx " y" wy " w" ww " h" wh  " noactivate hide"
	gui,59:color,%color%
	gui,59:show,NoActivate
	WinSet,Transparent,20,ahk_id %select%
	while,GetKeyState("LButton","P"){
		mousegetpos,x,y
		winset,region,%xx%-%yy% %x%-%yy% %x%-%y% %xx%-%y% %xx%-%yy%,ahk_id %select%
	}
	Gui,59:Destroy
	xsub:=v.border,ysub:=v.Border+v.Caption,inside:=[]
	for a,b in {x:x-xsub,xx:xx-xsub,y:y-ysub,yy:yy-ysub}{
		inside[InStr(a,"x")?"x":"y",b]:=1
	}
	return inside(inside)
}
inside(control){
	/*
		if !IsObject(control){
			cc:=control+0,ea:=gui.control(cc),control:=[]
			if !RegExMatch(ea.type,"(GroupBox|Tab|Tab2)")
			return
			control["x",ea.x]:=1,control["x",ea.x+ea.w]:=1
			control["y",ea.y]:=1,control["y",ea.y+ea.h]:=1
		}
		if ea.type="GroupBox"
		list:=gui.sn("//*[@x>" control.x.MinIndex() " and @x<" control.x.MaxIndex() " and @y>" control.y.MinIndex() " and @y<" control.y.MaxIndex() "  and @tab='" ea.tab "']/@hwnd")
		else
		m(control.x.minindex(),control.x.MaxIndex(),control.y.MinIndex(),control.y.MaxIndex())
	*/
	list:=gui.xml.SelectNodes("//*[@x>'" control.x.MinIndex() "' and @x<'" control.x.MaxIndex() "' and @y>'" control.y.MinIndex() "' and @y<'" control.y.MaxIndex() "']/@hwnd")
	return list
}
highlight(){
	if (v.currentmode="interact")
	return killhighlight()
	WinGetPos,x,y,w,h,% hwnd([1])
	Gui,98:Destroy
	Gui,98:+LastFound +Owner1 +E0x20 -Caption +hwndsh +ToolWindow 
	hwnd(98,sh)
	WinSet,TransColor,0xF0F0F0 100
	Gui,98:Color,0xF0F0F0,0xFF
	for a,b in Pos
	p.=a b " "
	Gui,98:Default
	x+=v.Border,y+=v.Border+v.Caption,w-=(v.border*2),h-=(v.Border*2)+v.Caption
	ll:=gui.sn("//selected/hwnd")
	plain:=[],group:=[],tab:=[]
	while,l:=ll.item(A_Index-1){
		ea1:=xml.easy(gui.ssn("//*[@hwnd='" married(l.text) "']"))
		ea:=getpos(married(l.text))
		if !(ea.x&&ea.y&&ea.w&&ea.h)
		continue
		info:="c" color " x" ea.x " y" ea.y " w" ea.w " h" ea.h
		if InStr(ea.type,"Tab")
		tab[ea1.hwnd]:=info
		else if InStr(ea1.type,"GroupBox")
		group[ea1.hwnd]:=info
		else
		plain[ea1.hwnd]:=info
	}
	for a,b in plain
	Gui,Add,Progress,%b%,100
	for a,b in group
	Gui,Add,Progress,%b%,100
	for a,b in tab
	Gui,Add,Progress,%b%,100
	Gui,98:Show,x%x% y%y% w%w% h%h% NoActivate
	if hwnd(2)
	WinSet,Top,,% hwnd([2])
	if hwnd(3)
	WinSet,Top,,% hwnd([3])
}
killhighlight(a*){
	if a.1!=""
	ToolTip,,,,3
	Gui,98:Destroy
	if hwnd(44)
	hwnd({remove:44})
}
load_gui(file=""){
	v.loading:=1
	if (file=1)
	file:=settings.ssn("//last/@file").text
	if (file=""||file=1){
		FileSelectFile,file,,,Select the GUI file to load,*.xml
		if ErrorLevel||FileExist(file)=""
		return
	}
	if !FileExist(file)
	return m("can't find the file"),gui()
	SplashTextOn,200,50,Loading File,Please wait...
	settings.add("last",{att:{file:file}})
	gui(1),gui:=new xml("gui")
	Gui,1:Default
	temp:=new xml("temp")
	temp.xml.load(file),tabcount:=0
	ctrl:=temp.sn("//@hwnd/..")
	while,ct:=ctrl.item(A_Index-1){
		ea:=xml.easy(ct)
		if ea.tabnum&&!ea.tab	;<---This is for
		ea.tab:=ea.tabnum		;<---backward compatibility.
		add_control(ea.type,ea)
	}
	splitpath,file,filename,dir
	filename:=temp.ssn("//file/filename").text
	dir:=temp.ssn("//file/dir").text
	gui.add("file/filename").text:=filename
	Gui.add("file/dir").text:=dir
	ea:=temp.ea("//show")
	ea.options:=RegExReplace(ea.options,"i)(Hide|Minimize|NA|NoActivate)")
	ss:=temp.ssn("//show")
	if ss
		gui.ssn("*").AppendChild(ss)
	for a,b in ea
		if a in x,y,w,h
			if b
				position.=a b " "
	SplashTextOff
	Gui,Show,% position " " ea.options
	v.loading:=0
	WinSetTitle,GUI Creator,,GUI Creator : %filename%
	if temp.ssn("//labels")
	gui.ssn("//*").AppendChild(temp.ssn("//labels"))
	snap(1)
}
save_gui(filename=""){
	option:=settings.ssn("//options/Warn_Overwrite").text?"S16":""
	if !filename{
		file:=gui.ssn("//file/filename").text,dir:=gui.ssn("//file/dir").text
		if file&&dir
		if FileExist(dir "\" file)
		filename:=dir "\" file
	}
	if !filename
	FileSelectFile,filename,%option%,,Save Current GUI,*.xml
	if ErrorLevel||filename=""
	return
	filename:=InStr(filename,".xml")?filename:filename ".xml"
	SplitPath,filename,filename,dir
	gui.add("file/filename").text:=filename
	Gui.add("file/dir").text:=dir
	Gui.Transform()
	gui.save([dir "\" filename])
	settings.add("last",{att:{file:dir "\" filename}})
}
snap(a*){
	local attObj
	WinGetPos,,,w,h,% hwnd([1])
	Grid(w,h)
	w-=4,h-=1
	WinMove,% hwnd([1]),,,,% w,% h
	highlight()
	attObj := winpos(1).obj
	attObj["title"] := gui.ssn("//show/@title").text
	gui.add("show",{att:attObj,text:winpos(1).text})
	if hwnd(2)
	edit("gui settings")
	if hwnd(3)
	WinSet,Top,,% hwnd([3])
}
display_grid(x=""){
	Static wBrush
	if x=removebrush
	wbrush:=""
	if A_Gui!=1
	return
	if settings.ssn("//options/Grid").text
	tile:="GuiCreator\tile.bmp"
	else
	return
	If !wBrush
	hBM:=DllCall("LoadImage",Int,0,Str,"GuiCreator\tile.bmp",Int,0,Int,0,Int,0,UInt,0x2010,"cdecl"),wBrush:=DllCall("CreatePatternBrush",UInt,hBM,"cdecl")
	Return wBrush
}
size(win,default=""){
	pos:=settings.ssn("//window/position[@win='" win "']").text
	pos:=pos?pos:default
	return pos
}
whichtab(att){
	if !tab:=gui.ssn("//*[@x<'" att.x "' and @x+@w>'" att.x "' and @y<'" att.y "' and @y+@h>'" att.y "' and @type='Tab2']/@hwnd").text
	tab:=gui.ssn("//*[@x<'" att.x "' and @x+@w>'" att.x "' and @y<'" att.y "' and @y+@h>'" att.y "' and @type='Tab']/@hwnd").text
	if !tab return
	sleep,1
	hwnd:=tab
	ControlGet,tabnum,tab,,,ahk_id%tab%
	tt:=Gui.sn("//*[contains(@type,'Tab')]")
	ctrl:=gui.ssn("//tablist/tab[text()='" tab "']/@num").text
	if att.tab
	tabnum:=att.tab
	if tabnum&&ctrl{
		tab:=[]
		Gui,1:Tab,%tabnum%,%ctrl%
		tab.tab:=tabnum,tab.ctrl:=ctrl,tab.hwnd:=hwnd
		return tab
	}
}
edit(switch=""){
	tabswitch:
	if WinExist(hwnd([2]))=0&&hwnd(2)
	hwnd({remove:2})
	if (hwnd(2)=""){
		static tab
		Gui,2:Default
		Menu,Edit,Add,Help,editmenu
		Gui,2:Menu,Edit
		Gui,+Owner1
		Gui,-0x30000 +hwndhwnd
		Gui,Add,Tab,Buttons w300 h100 hwndtab gtabswitch vtab,Controls|GUI Settings|Settings
		v.tab:=tab
		Gui,Tab
		Gui,Add,StatusBar,,foo
		hwnd(2,hwnd),VarSetCapacity(rect,A_PtrSize*4)
		SendMessage,(0x1300|10),1,&rect,,ahk_id%tab% ;TCM_GETITEMRECT
		height:=NumGet(rect,12)
		SysGet,h,55
		height+=h-3
		ControlMove,SysTabControl321,,,,% height-h+3,% hwnd([2])
		Gui,Add,TreeView,w300 h600 xm y%height% AltSubmit geditsort Section hwndhwnd Checked
		Gui,Show,% size(2,"x5") " AutoSize NA",Edit Control
		mode_select()
	}
	Gui,2:Submit,Nohide
	tab:=switch?switch:tab
	GuiControl,2:ChooseString,SysTabControl321,%Tab%
	Gui,2:Default
	GuiControl,2:-Redraw,SysTreeView321
	TV_Delete()
	v.editvalue:=[],v.tvrem:=[]
	if (tab="settings"){
		roots:=[]
		con:=controls.sn("//controls/*")
		root:=TV_Add("Hotkeys",0,"Expand")
		v.tvrem[root]:=1
		while,cc:=con.item(a_index-1)
		child:=TV_Add(cc.nodename " : " settings.ssn("//hotkeys/" cc.nodename).text,root),v.editvalue[child]:={desc:cc.nodename,control:cc.nodename,hotkey:1},v.tvrem[child]:=1
		for a,b in v.personal{
			root:=TV_Add(b.hotkey.main,0,"Expand")
			v.tvrem[root]:=1
			for c,d in b.keys{
				key:=settings.ssn("//hotkey[@label='" b.hotkey.label "']/key[@desc='" d.1 "']/@value").text
				key:=key?key:d.2
				child:=TV_Add(d.1 " : " key,root),v.editvalue[child]:={value:key,desc:d.1,gui:1,parent:"settings",root:cc.nodename}
				v.tvrem[child]:=1
			}
		}
		root:=TV_Add("Quick Options",0,"Expand"),v.quick:=root
		for a,b in ["Snap To Grid","Grid","Borders","Warn Overwrite"]
		child:=TV_Add(b,root,settings.ssn("//options/" clean(b)).text?"Check":""),v.editvalue[child]:={quick_options:1,value:b}
		v.tvrem[root]:=1
		GuiControl,2:+Redraw,SysTreeView321
		hidecheck()
		return
	}
	if (tab="GUI Settings"){
		info:=controls.sn("//window/*"),stop:=[]
		style:=TV_Add("GUI",0,"Expand"),oo:=TV_Add("Options",0,"Expand")
		constants:=TV_Add("Constants",0,"Expand")
		for a,b in [style,constants,oo]
		v.tvrem[b]:=1
		qa:=gui.ea("//show")
		while,in:=info.item(A_Index-1){
			ea:=xml.easy(in),options:=qa[in.nodename],options:=RegExReplace(options," ",","),value:=ea.value
			if value in %options%
			{
				check=Check
				if value in center,xcenter,ycenter
				stop[value]:=1
			}
			else
			check=
			if (in.nodename="gui")
			child:=TV_Add(ea.value " : " ea.desc,style,Check),v.editvalue[child]:={value:ea.value,desc:ea.desc,gui:2,parent:"gui"}
			if in.nodename="options"
			child:=TV_Add(ea.value " : " ea.desc,oo,Check),v.editvalue[child]:={value:ea.value,desc:ea.desc,gui:2,parent:"options"}
			if (in.nodename="constants"){
				if (ea.value="x"||ea.value="y")&&(stop[ea.value "center"]||stop.center)
				continue
				child:=TV_Add(ea.desc " : " qa[ea.value],constants,Check),v.editvalue[child]:={value:ea.value,desc:ea.desc,gui:2,parent:"constants",start:qa[ea.value]}
				v.tvrem[child]:=1
			}
		}
		GuiControl,2:+Redraw,SysTreeView321
		hidecheck()
		return
	}
	; all of these are to use the v.editvalue[child]:={value:ea.value,desc:ea.desc} structure
	; ^----type:=type of control
	if (tab="Controls"){
		selected:=gui.sn("//selected/*"),typecount:=0,types:=[],expand:=selected.length>1?"":" Expand"
		search:=selected.length>1?"//multi/Constants/*":"//constants/Constants/*"
		while,sel:=selected.item(A_Index-1){
			ea:=xml.easy(gui.current(sel.text)),options:=RegExReplace(ea.options," ","|")
			if !ea.Type
			continue
			if types[ea.type]
			continue
			root:=TV_Add(ea.type,0,"Sort" expand),style:=TV_Add("Style",root,"expand"),constants:=TV_Add("Constants",root,"expand"),v.tvrem[root]:=1
			v.tvrem[style]:=1,v.tvrem[constants]:=1
			info:=controls.sn("//" ea.type "/*|" search)
			while,in:=info.item(A_Index-1){
				ee:=xml.easy(in),check:=""
				if (in.nodename="style"&&options)
				check:=RegExMatch(ee.value,"(" options ")\b")?"Check":""
				if (in.nodename="style")
				child:=TV_Add(ee.value " : " ee.desc,style,check),v.editvalue[child]:={value:ee.value,desc:ee.desc,type:ea.type,parent:"style"}
				if (in.nodename="constants")
				child:=TV_Add(selected.length=1?ee.desc " : " ea[ee.value]:ee.desc,constants),v.editvalue[child]:={value:ee.value,desc:ee.desc,type:ea.type,parent:"constants"},v.tvrem[child]:=1
			}
			types[ea.type]:=1
		}
		if !(Expand){
			root:=TV_Add("All Selected",0,"Expand")
			for a,b in {Font:"font",Color:"color"}
			child:=TV_Add(a,root),v.editvalue[child]:={value:b,desc:b,type:"All",parent:"All Selected"},v.tvrem[child]:=1
			v.tvrem[root]:=1
		}
		hidecheck()
	}
	GuiControl,2:+Redraw,SysTreeView321
	return
	editsort:
	if !A_EventInfo
	return
	if !v.editvalue[A_EventInfo]
	return
	ev:=v.editvalue[A_EventInfo],v.lastev:=ev
	if (ev.quick_options){
		option:=settings.add("options/" clean(ev.value))
		option.text:=check:=TV_Get(A_EventInfo,"Check")?1:0
		if (ev.value="Borders"){
			reload(),Edit("Settings")
			ControlSend,SysTreeView321,^{End},% hwnd([2])
			WinActivate,% hwnd([2])
		}
			TV_Modify(v.quick,"Select Vis Focus")
		if (ev.value="warn overwrite")
		return
		refresh:
		WinSet,Redraw,,% hwnd([1])
		return
	}
	if (ev.parent="settings"){
		smalledit(ev.desc,ev.value)
		return
	}
	if (ev.hotkey){
		ea:=[],ea[ev.desc]:=settings.ssn("//hotkeys/" ev.desc).text
		smalledit(ev.desc,ea)
		return
	}
	if (ev.desc="grid color"||ev.desc="dot color"){
		type:=ev.desc="grid color"?"grid":"dot"
		ea:=settings.ea("//settings/grid")
		color:=RGB(dlg_color(RGB(ea[type])))
		settings.add("grid").SetAttribute(type,color)
		makeblock()
		return
	}
	if (ev.gui){
		return guiedit(ev)
	}
	if (ev.gui){
		current:=gui.ssn("//show"),options:=ssn(current,"@options").text,new:=""
		if (ev.parent="styles"){
			check:=TV_Get(A_EventInfo,"Check")?ev.value:""
			if Check
			options.=" " check
			if (Check=""){
				Loop,Parse,options,%A_Space%,%A_Space%
				if (A_LoopField!=ev.value)
				new.=A_LoopField " "
			}
			options:=new?new:options
			current.SetAttribute("options",Trim(options))
			options:=RegExReplace(options,"i)(Hide|Minimize)")
			Gui,1:Show,%options%
			mode_select()
		}
		if (ev.parent="constants")
		smalledit(ev.value,gui.ea("//show"))
		return
	}
	if (ev.type="Picture"&&InStr(ev.desc,"name of control")){
		current:=gui.current(v.last),ea:=xml.easy(current)
		FileSelectFile,file,,% ea.value,Select a new file.,*.png;*.gif;*.jpg
		if ErrorLevel||file=""
		return
		current.SetAttribute("value",file)
		update(current),edit()
		if (v.currentmode!="interact")
		highlight()
		return
	}
	if (ev.desc="font"){
		if !gui.allsel()
		return
		if ev.parent="all selected"
		list:=gui.ssn("//*[(" gui.allsel() ") and @font]"),ea:=xml.easy(list)
		else
		list:=gui.ssn("//*[(" gui.allsel() ") and @font and @type='" ev.type "']"),ea:=xml.easy(list)
		if !ea.font
		ea:={font:"Tahoma"}
		dlg_font(ea)
		if (ev.parent="all selected"){
			selected:=gui.sn("//selected/*")
			while,sel:=selected.item(A_Index-1){
				current:=gui.current(sel.text)
				if !RegExMatch(ssn(current,"@type").text,"(Picture|Slider|Progress)")
				for a,b in ea
				current.SetAttribute(a,b)
				update(current)
			}
		}
		else if (ev.parent="constants"){
			list:=gui.allsel()
			list:=gui.sn("//*[(" list ") and @type='" ev.type "']")
			while,ll:=list.item(A_Index-1){
				for a,b in ea
				ll.SetAttribute(a,b)
				update(ll)
			}
		}
		edit()
		return
	}
	if (ev.desc="color"||ev.desc="background color"){
		selected:=gui.sn("//selected/*"),allsel:=gui.allsel()
		if allsel{
			allsel:="(" allsel ") and @" ev.value
			color:=gui.ssn("//*[" allsel "]/@" ev.value).text
			color:=RGB(dlg_color(RGB(color)))
			while,sel:=selected.item(a_index-1){
				current:=gui.current(sel.text),current.SetAttribute(ev.value,color)
				update(current)
			}
			highlight()
		}
		return
	}
	if (ev.parent="style")
	return styles()
	;messed up
	if ev.value
	hwnd({remove:44}),smalledit(ev.value,gui.ea("//*[@hwnd='" v.last "']"))
	return
	2GuiEscape:
	2GuiClose:
	hwnd({remove:2})
	return
	editgo:
	Gui,2:Default
	ControlGetText,newval,Edit2,% hwnd([44])
	hwnd({remove:44})
	ev:=v.lastev
	if ev.Gui=2
	return guiedit(ev,newval)
	if (ev.parent="settings"){
		TV_Modify(TV_GetSelection(),"",ev.desc " : " newval)
		settings.ssn("//actions/hotkey/key[@desc='" ev.desc "']").SetAttribute("value",newval)
		gui_hotkey()
		return
	}
	if (ev.gui){
		current:=gui.ssn("//show")
		current.SetAttribute(ev.value,newval)
		ea:=xml.easy(current)
		if RegExMatch(ev.value,"(x|y|w|h)")
		WinMove,% hwnd([1]),,% ea.x,% ea.y,% ea.w+(v.Border*2),% ea.h+(v.Border*2)+v.Caption
		edit(),dupcheck()
		return
	}
	if (ev.hotkey){
		TV_Modify(TV_GetSelection(),"",ev.desc " : " newval)
		settings.add("hotkeys/" ev.desc).text:=newval
		gui_hotkey()
		return
	}
	list:=gui.sn("//*[(" gui.allsel() ") and @type='" ev.type "']")
	TV_Modify(TV_GetSelection(),"Select Vis Focus",ev.desc " : " newval)
	current:=gui.current(v.last),old:=xml.easy(current)
	if ev.value="g"
	newval:=clean(newval)
	current.SetAttribute(ev.value,newval)
	att:=xml.easy(current)
	;do a reload of a single control here.
	if (att.type="ListView"&&ev.value="value"){
		gui.remove("//*[@hwnd='" att.hwnd "']")
		DllCall("DestroyWindow",uint,att.hwnddd)
		newcon:=add_control(att.type,att)
		current:=gui.current(newcon.hwnd)
		v.removelist.Insert(con)
		gui.add("selected/hwnd",{text:newcon.hwnd})
		v.last:=newcon.hwnd
	}
	update(current,ev.value,old[ev.value]),highlight()
	if InStr(ev.desc,"will reload")
	reload()
	hwnd({remove:44}),edit()
	dupcheck()
	return
}
smalledit(ll,last){
	num:=ssn(controls.ssn("//*[@value='" ll "']"),"@type").text?"number":""
	VarSetCapacity(rect,A_PtrSize*4),NumPut(A_EventInfo,rect,0,"UPtr")
	SendMessage,(0x1100|4),true,&rect,SysTreeView321,% hwnd([2])
	y:=NumGet(rect,4)&0xffff
	ControlGet,hwnd,hwnd,,SysTreeView321,% hwnd([2])
	WinGetPos,x,yy,,,ahk_id%hwnd%
	if hwnd(44)
	hwnd({remove:44})
	Gui,44:Default
	Gui,44:-Caption +hwndhwnd Owner2
	Gui,44:Margin,0,0
	text:=controls.ssn("//*[@value='" ll "']/@desc").text,hwnd(44,hwnd)
	Gui,Add,Edit,Disabled,% v.editvalue[A_EventInfo].desc " :"
	Gui,Add,Edit,%num% x+0 w150,% IsObject(last)?last[ll]:last
	Gui,Add,Button,x+0 y-1 Default geditgo,Done
	x:=x+2+NumGet(rect,0)&0xffff,y:=y+yy
	Gui,Show,x%x% y%y%
	v.editing:=A_EventInfo
	return
	44GuiEscape:
	hwnd({remove:44})
	return
}
hidecheck(){
	Gui,2:Default
	for id in v.tvrem{
		VarSetCapacity(tvitem,A_PtrSize*4)
		info:=A_PtrSize=4?{0:8,4:id,12:0xf000}:{0:8,8:id,20:0xf000}
		for a,b in info
		NumPut(b,tvitem,a)
		SendMessage,4415,0,&tvitem,SysTreeView321,% hwnd([2])
	}
}
update(node,change="",old="",noredraw=""){
	ea:=xml.easy(node)
	if (RegExMatch(change,"i)(w|h)")&&ea.type="Picture"){
		MsgBox,4,Resize Image,Keep Aspect Ratio?
		IfMsgBox,Yes
		{
			other:=change="w"?"h":"w",ea[other]:=ea[other]*ea[change]/old,ea[other]:=Floor(ea[other])
			node.SetAttribute(other,ea[other])
		}
		WinActivate,% hwnd([1])
		WinSet,Redraw,,% hwnd([1])
		GuiControl,1:movedraw,% ea.hwnd,% "w" ea.w " h" ea.h
		GuiControl,1:,% ssn(node,"@hwnd").text,% "*w-1 " ssn(node,"@value").text
	}
	else if (ea.Type="Picture"){
		current:=gui.current(ea.hwnd)
		GuiControl,1:,% ssn(node,"@hwnd").text,% "*w-1 " ea.value
		GuiControl,1:movedraw,% ea.hwnd
		for a,b in getpos(ea.hwnd)
		if a not in x,y
		current.SetAttribute(a,b)
		ea:=xml.easy(current)
	}
	value:=RegExMatch(ea.type,"i)(ComboBox|Tab|Tab2|DropDownList|ListBox)")?"|" ea.value:ea.value
	GuiControl,1:,% ea.hwnd,%value%
	for a,b in ea
	if a in x,y,w,h
	pos.=a b " "
	ea.x+=v.Border,ea.y+=v.Border+v.Caption
	grid(ea.x,ea.y,1)
	Gui,1:Default
	Gui,1:Font,% compilefont(ea),% ea.font
	GuiControl,1:Font,% ea.hwnd
	GuiControl,1:movedraw,% ea.hwnd,%pos%	
	Gui,1:Font
	return
}
checkfiles(){
	temp:=ComObjCreate("MSXML2.DOMDocument")
	if !fileexist("GuiCreator")
	FileCreateDir,GuiCreator
	if !fileexist("GuiCreator\lib")
	FileCreateDir,GuiCreator\lib
	list:=[]
	for a,b in {"controls.xml":{path:"GuiCreator\lib\controls.xml",version:"0.001.5"},"GuiCreator\tile.bmp":{path:"GuiCreator\tile.bmp"}}{
		temp.load(b.path),vers:=ssn(temp,"//version").text,verver:=b.version
		if b.version
		{
			if instr(vers,"auto_version")
			continue
			if (vers<verver)
			FileDelete,% b.path
		}
		if !FileExist(b.path)
		list[a]:=b.path
	}
	for a,b in list{
		if (InStr(a,".xml")){
			con:=URLDownloadToVar("http://www.maestrith.com/files/NewGUICreator/" a,400,50,"Downloading controls.xml","Please wait...")
			FileAppend,%con%,% b
		}
		else
		{
			FileDelete,%b%
			UrlDownloadToFile,http://www.maestrith.com/files/GUICreator/%a%,%b%
		}
	}
	SplashTextOff
	temp:=""
}
rcm(){
	GuiContextMenu:
	MouseGetPos,x,y,,con,2
	Grid(x,y,1),con:=married(con),v.last:=con
	current:=gui.current(con)
	ancestor:=ssn(current,"ancestor::*[@type='Tab' or @type='Tab2']/@hwnd")
	SendMessage, 0x1304,,,,% "ahk_id" ancestor.text
	tabcount:=ErrorLevel
	c:=controls.sn("//controls/*")
	while,b:=c.item(A_Index-1).nodename
	Menu,Add,Add,%b%,Add
	Menu,rcm,Add,&Add,:Add
	if (tabcount>1&&tabcount!="FAIL"){
		Loop,%tabcount%
		Menu,movetab,Add,%A_Index%,movetab
		Menu,rcm,Add,Move to tab,:movetab
	}
	Menu,rcm,Add
	menu:=[{["File","menu"]:["New GUI","Load GUI","Save GUI","Save GUI As","Export GUI","Reload","Test GUI"]}
	,{["Edit","menu"]:["Copy GUI to Clipboard","Remove Selected","Reorder GUI"]}
	,{["About","menu"]:["GUI Creator Version"]}
	,{["Settings","settings"]:["GUI Settings","Settings"]}
	,{["Refresh"]:["Refresh","split"]}
	,{["Help"]:["editmenu"]}]
	for a,b in menu
	for c,d in b{
		menu:=c.1 2
		if c.2
		for e,f in d{
			Menu,%menu%,Add,%f%,% c.2
			Menu,rcm,Add,% c.1,:%menu%
			lastmenu:=c.2
		}
		else
		{
			if d.2="split"
			Menu,rcm,Add
			Menu,rcm,Add,% c.1,% d.1
		}
	}
	Menu,rcm,Show
	Menu,rcm,DeleteAll
	if (tabcount>1&&tabcount!="FAIL"){
		Menu,movetab,DeleteAll
		Menu,movetab,Delete
	}
	return
	menu:
	fun:=clean(A_ThisMenuItem)
	if IsFunc(fun)
	%fun%()
	return
	add:
	value:=""
	if (A_ThisMenuItem="Picture"){
		FileSelectFile,file,,,Select an image,*.jpg;*.png;*.gif
		if ErrorLevel||file=""
		return
		value:=file
	}
	value:=value?value:A_ThisMenuItem
	add_control(A_ThisMenuItem,{x:x,y:y,value:value,type:A_ThisMenuItem})
	return
	settings:
	select:=A_ThisMenuItem="settings"?3:2
	edit(A_ThisMenuItem)
	return
	editmenu:
	mm:=A_ThisMenuItem
	if (mm="help")
	help()
	return
}
clean(info,options=""){
	if !options
	return RegExReplace(info," ","_")
	return RegExReplace(info,"_"," ")
}
save_gui_as(){
	option:=settings.ssn("//options/Warn_Overwrite").text?"S16":""
	FileSelectFile,save,%option%,,Save GUI As:,*.xml
	if (ErrorLevel||save="")
	return
	save:=InStr(save,".xml")?save:save ".xml"
	save_gui(save)
}
Dlg_Font(ByRef Style,window="",effects=1){
	window:=window?window:hwnd(2)
	style.color:=RGB(style.color)
	VarSetCapacity(logfont,60),LogPixels:=DllCall("GetDeviceCaps","uint",DllCall("GetDC","uint",0),"uint",90),Effects:=0x041+(Effects?0x100:0)
	for a,b in fontval:={16:style.bold?700:400,20:style.italic,21:style.underline,22:style.strikeout,0:style.size?Floor(style.size*logpixels/72):16}
	NumPut(b,logfont,a)
	cap:=VarSetCapacity(choosefont,A_PtrSize=8?103:60,0)
	NumPut(hwnd,choosefont,A_PtrSize)
	for index,value in [[cap,0,"Uint"],[&logfont,A_PtrSize=8?24:12,"Uptr"],[effects,A_PtrSize=8?36:20,"Uint"],[style.color,A_PtrSize=4?6*A_PtrSize:5*A_PtrSize,"Uint"]]
	NumPut(value.1,choosefont,value.2,value.3)
	if (A_PtrSize=8)
	strput(style.font,&logfont+28),r:=DllCall("comdlg32\ChooseFont","uptr",&CHOOSEFONT,"cdecl"),name:=strget(&logfont+28)
	else
	strput(style.font,&logfont+28,32,"utf-8"),r:=DllCall("comdlg32\ChooseFontA","uptr",&CHOOSEFONT,"cdecl"),name:=strget(&logfont+28,32,"utf-8")
	if !r
	return 0
	st:=[]
	for a,b in {bold:16,italic:20,underline:21,strikeout:22}
	st[a]:=NumGet(logfont,b,"UChar")
	st.bold:=st.bold<188?0:1
	st.color:=RGB(NumGet(choosefont,A_PtrSize=4?6*A_PtrSize:5*A_PtrSize))
	st.size:=NumGet(CHOOSEFONT,A_PtrSize=8?32:16,"UChar")//10
	st.font:=name
	style:=st
}
rgb(c){
	setformat,IntegerFast,H
	c:=(c&255)<<16 | (c&65280) | (c>>16),c:=SubStr(c,1)
	SetFormat, integerfast,D
	return c
}
Dlg_Color(Color,hwnd=""){
	static
	if !cc{
		VarSetCapacity(cccc,16*A_PtrSize,0),cc:=1,size:=VarSetCapacity(CHOOSECOLOR,9*A_PtrSize,0)
		Loop,16{
			IniRead,col,GuiCreator\color.ini,color,%A_Index%,0
			NumPut(col,cccc,(A_Index-1)*4,"UInt")
		}
	}
	NumPut(size,CHOOSECOLOR,0,"UInt"),NumPut(hwnd,CHOOSECOLOR,A_PtrSize,"UPtr")
	,NumPut(Color,CHOOSECOLOR,3*A_PtrSize,"UInt"),NumPut(3,CHOOSECOLOR,5*A_PtrSize,"UInt")
	,NumPut(&cccc,CHOOSECOLOR,4*A_PtrSize,"UPtr")
	ret:=DllCall("comdlg32\ChooseColorW","UPtr",&CHOOSECOLOR,"UInt")
	if !ret
	exit
	Loop,16
	IniWrite,% NumGet(cccc,(A_Index-1)*4,"UInt"),GuiCreator\color.ini,color,%A_Index%
	IniWrite,% Color:=NumGet(CHOOSECOLOR,3*A_PtrSize,"UInt"),GuiCreator\color.ini,default,color
	return Color
}
compilefont(ea){
	if ea.size
	font.="s" ea.size
	if ea.color!=""
	font.=" c" ea.color
	for a,b in {Bold:ea.bold,Italic:ea.italic,Strikeout:ea.strikeout,Underline:ea.underline}
	if b
	font.=" " a " "
	return Trim(font)
}

styles(){
	styles:
	if A_GuiEvent!=Normal
	return
	if !A_EventInfo
	return
	ControlGet,tab,tab,,SysTabControl321,% hwnd([2])
	if Tab>1
	goto styleend
	if !v.editvalue[A_EventInfo].value
	return
	check:=TV_Get(A_EventInfo,"Check")?1:0
	value:=v.editvalue[A_EventInfo].value
	current:=gui.current(v.last),ea:=xml.easy(current),option:=A_EventInfo
	op:=ea.options,contain:=0
	Loop,Parse,op,%A_Space%,%A_Space%
	if (A_LoopField==value)
	contain:=1
	if check&&contain=0
	ea.options.=" " value
	if (check=0&&contain){
		op:=ea.options,list:=""
		Loop,Parse,op,%A_Space%,%A_Space%
		if (A_LoopField!=value)
		list.=A_LoopField " "
		ea.options:=Trim(list)
	}
	if InStr(value,"-")
	flip:=check=0?RegExReplace(value,"\-","+"):value
	if !InStr(value,"-")
	flip:=check=0?"-" value:"+" value
	sel:=gui.sn("//selected/*")
	TV_GetText(parent,TV_GetParent(TV_GetParent(A_EventInfo)))
	while,hwnd:=sel.item(A_Index-1).text{
		current:=gui.current(hwnd)
		type:=ssn(current,"@type").text
		if (type!=parent)
		continue
		current.SetAttribute("options",Trim(ea.options))
		if (InStr(flip,"Multi")&&type="ListView")
		continue
		GuiControl,1:%flip%,% hwnd
		GuiControl,1:movedraw,% hwnd
	}
	if InStr(v.editvalue[A_EventInfo].desc,"GUI Will Reload")
	reload()
	return
	styleend:
	if (tab=2){
		check:=TV_Get(A_EventInfo,"Check")?1:0
		setting:=v.windowoptions[A_EventInfo],new:=""
		show:=gui.ssn("//show/@options")
		ss:=show.text
		if check
		new:=Trim(ss " " setting)
		else
		Loop,Parse,ss,%A_Space%,%A_Space%
		if (A_LoopField!=setting)
		new:=Trim(new " " A_LoopField)
		gui.add("gui/show",{att:{options:new}})
	}
	return
}
reload(){
	current:=gui.xml.xml
	v.loading:=1
	Gui,1:Default
	gui(1),gui:=new xml("gui")
	temp:=new xml("temp")
	temp.xml.loadxml(current),tabcount:=0
	ctrl:=temp.sn("//@hwnd/..")
	while,ct:=ctrl.item(A_Index-1){
		ea:=xml.easy(ct)
		if ea.tabnum&&!ea.tab	;<---This is for
		ea.tab:=ea.tabnum		;<---backward compatibility.
		add_control(ea.type,ea)
	}
	filename:=temp.ssn("//file/filename").text
	dir:=temp.ssn("//file/dir").text
	gui.add("gui/file/filename").text:=filename
	Gui.add("gui/file/dir").text:=dir
	gui.Transform()
	ea:=temp.ea("//show"),gui.ssn("*").AppendChild(temp.ssn("//show"))
	ea.options:=RegExReplace(ea.options,"i)(Hide|Minimize|NA|NoActivate)")
	for a,b in ea
	if a in x,y,w,h
	if b
	position.=a b " "
	Gui,Show,% position " " ea.options
	v.loading:=0
	WinSetTitle,% hwnd([1]),,GUI Creator : %filename%
	snap(1),gui_hotkey()
}
select_all(){
	selectall:
	gui.remove("//gui/selected")
	selected:=gui.add("gui/selected")
	all:=gui.sn("//*[@hwnd]/@hwnd")
	while,aa:=all.item(A_Index-1){
		gui.add("gui/selected/hwnd",{dup:1}).text:=aa.text
		Gui.unique("templist/control",{att:{control:aa.text}},"control")
	}
	highlight(),edit()
	return
}
compile_gui(ret=""){
	gui.Transform()
	compile:=[]
	find_duplicates()
	www:=gui.sn("//*[@font='' or @type='Picture' or @type='MonthCal']/@hwnd")
	while,ww:=www.item(A_Index-1){
		current:=gui.current(ww.text)
		for a,b in ["bold","italic","underline","strikeout","font","size"]
		current.RemoveAttribute(b)
	}
	temp:=new xml("temp"),list:=[]
	biglist:=gui.sn("//*[@hwnd]")
	if gg:=gui.ssn("//show/@gui").Text
	total:="Gui," gg "`n"
	while,bl:=biglist.item(A_Index-1){
		ea:=xml.easy(bl),position:=""
		list:=att.r?["x","y","w"]:["x","y","w","h"]
		for a,b in list
		if ea[b]
		position.=b ea[b] " "
		if ea.r
		position.="r" ea.r " "
		cf:=compilefont(ea)
		fm:=ea.font?cf:""
		if (ea.tab!=lasttab)
		total.="Gui,Tab," ea.tab "`r`n"
		if (lastfont&&ea.font="")
		total.="Gui,Font`r`n"
		if (lastfont!=cf ea.font&&ea.font)
		total.="Gui,Font,Normal " compilefont(ea) "," ea.font "`r`n"
		color:=ea.color?"c" ea.color:""
		options:=ea.options?ea.options " ":""
		glabel:=ea.g?" g" ea.g:""
		var:=ea.v?" v" ea.v:""
		back:=ea.background?" Background" ea.background:""
		toption:=Trim(RegExReplace(position options color var glabel back,"\s\s"," "))
		total.="Gui,Add," ea.type "," toption "," ea.value "`r`n"
		lastfont:=cf ea.font
		lasttab:=ea.tab
		var:=glabel:=back:=""
		if InStr(ea.type,"Tab")
		lasttab:=""
	}
	winoptions:=" " gui.ssn("//show/@options").Text
	ea:=gui.ea("//show"),position:=""
	if !InStr(ea.gui,"Resize")
	ea.x+=Round(v.border/2),ea.y+=Round(v.border/2)
	if !RegExMatch(ea.options,"i)\bcenter\b"){
		if !InStr(ea.options,"xcenter")
		position.="x" ea.x
		if !InStr(ea.options,"ycenter")
		position.=" y" ea.y
	}
	position.=" w" ea.w " h" ea.h
	total.="Gui,Show," position winoptions "," gui.ssn("//show/@title").text "`r`nReturn`r`n"
	labels:=gui.sn("//*[@g!='']"),one:=[]
	while,lab:=labels.item(a_index-1){
		ea:=xml.easy(lab)
		if !one[ea.g]{
			total.=ea.g ":`r`n"
			if prog:=gui.ssn("//labels/" ea.g).text
			total.=RegExReplace(prog,"\n","`r`n") "`r`n"
			total.="Return`r`n"
		}
		one[ea.g]:=1
	}
	total.="GuiClose:`r`nExitApp`r`nReturn"
	if ret
	return total
	show_code()
}
find_duplicates(){
	dup:=gui.sn("//*[@v!='']"),duplicate:=[]
	while,dd:=dup.item(A_Index-1){
		ea:=gui.easy(dd)
		check:=sn(dd,"//*[@v='" ea.v "']")
		if check.length>1
		while,cc:=check.item(A_Index-1)
		duplicate[ea.hwnd]:=1
	}
	if duplicate.MinIndex(){
		hwnd({remove:2})
		gui.remove("//gui/selected")
		for a,b in duplicate
		gui.add("gui/selected/hwnd",{text:a,dup:1}),highlight()
		m("The highlighted controls have duplicate variables.","Please fix this.")
		Exit
	}
}
/*
edithotkey(){
	edithotkey:
	global hot
	if A_GuiEvent!=Normal
	return
	WinGetPos,xx,yy,,,% hwnd([2])
	Gui,2:ListView,SysListView322
	ControlGetPos,x,y,w,h,SysListView322,% hwnd([2])
	VarSetCapacity(rect,16)
	SendMessage,(0x1000|14),LV_GetNext()-1,&rect,SysListView322,% hwnd([2])
	Gui,44:+Owner2 +hwndhwnd -Caption
	LV_GetText(control,LV_GetNext(),2),y:=NumGet(rect,4)+y+yy,x:=xx+x+1,LV_GetText(key,LV_GetNext())
	Gui,44:Add,Hotkey,ghotkey vhot,%key%
	Gui,44:Add,Edit,x+0 Disabled,%control%
	Gui,44:Add,Button,x+0 gehk,Done
	Gui,44:Add,Button,x+0 gehk,Clear
	Gui,44:Show,x%x% y%y%
	return
	ehk:
	if (A_GuiControl="Done")
	goto 44GuiEscape
	if (A_GuiControl="Clear")
	settings.remove("//hotkeys/" control),LV_Modify(LV_GetNext(),"Col1","")
	44GuiEscape:
	Gui,44:Destroy
	gui_hotkey()
	return
	hotkey:
	Gui,44:Submit,Nohide
	Gui,2:Default
	Gui,2:ListView,SysListView322
	settings.add("hotkeys/" control).text:=hot
	LV_Modify(LV_GetNext(),"Col1",hot)
	return
}
*/
mode_select(){
	static modes:={0:"Move",1:"Resize",2:"Interact"},mode=0
	modesel:
	if A_ThisHotkey
	ea:=settings.ssn("//key[@value='" A_ThisHotkey "']/@desc").text
	if (ea="previous mode"){
		if mode>0
		mode--
		else if mode=0
		mode:=2
	}
	if (ea="next mode"){
		mode++
		mode:=Mod(mode,3)
	}
	sleep,1
	Gui,2:Default
	SB_SetText("LButton mode : " modes[mode])
	v.currentmode:=modes[mode]
	Gui,1:Default
	if !hwnd(2)
	TrayTip,GUI Creator,% "LButton mode : " modes[mode]
	else
	TrayTip
	return
}
resize(templist,x,y){
	Grid(x,y)
	while,GetKeyState("LButton","P"){
		MouseGetPos,xx,yy
		Grid(xx,yy)
		offw:=xx-x,offh:=yy-y
		change:=lastx=xx?"h":"w",other:=change="w"?"h":"w",oo:=[]
		if !(lastx=xx&&lasty=yy)
		while,tl:=templist.item(A_Index-1){
			ea:=xml.easy(tl),w:=ea.w+offw,h:=ea.h+offh
			if (ea.type="Picture")
			w:=ea.w*h/ea.h,picture:=1
			GuiControl,1:movedraw,% ea.control,% "w" w " h" h
			ct:=gui.current(ea.control),ct.SetAttribute("w",w),ct.SetAttribute("h",h)
		}
		sleep,30
		lastx:=xx,lasty:=yy
	}
	if (picture){
		while,tl:=templist.item(a_index-1)
		if (ssn(tl,"@type").Text="Picture")
		update(gui.current(ssn(tl,"@control").text))
	}
}
help(){
	help=
	(
	GUI Creator Help,Help:
	Press Ctrl+A to select all controls
	Hold Ctrl+LButton to toggle an items select state
	Hold Shift+LButton to add a control to the selection
	Hold Alt+LButton to interact with the control
	Scroll your mouse wheel to change LButton mode 
	-(Current mode is on the bottom of the edit window)
	Delete deletes all selected controls.
	)
	MsgBox,32,GUI Creator,% RegExReplace(help,"\t")
}
remove_selected(){
	delete:
	selected:=gui.sn("//selected/*")
	while,sel:=selected.item(a_index-1){
		con:=sel.text
		WinGetClass,out,ahk_id%con%
		if InStr(out,"SysTabControl"){
			current:=gui.ssn("//*[@hwnd='" con "']")
			current.SetAttribute("deleted",1)
			gui.remove("//*[@hwnd='" con "']")
			ControlMove,,-55,-44,0,0,ahk_id%con%
			del:=sn(current,"descendant::*[@hwnd]")
			while,dd:=del.item(a_index-1){
				con:=ssn(dd,"@hwnd").text
				DllCall("DestroyWindow",uint,con)
				gui.remove("//*[@hwnd='" con "']")
			}
			continue
		}
		DllCall("DestroyWindow",uint,con)
		WinGet,cl,ControlList,% hwnd([1])
		Gui,1:Tab
		gui.remove("//*[@hwnd='" con "']")
	}
	highlight()
	WinSet,Redraw,,% hwnd([1])
	return
}
gui_creator_version(){
	Gui,88:Destroy
	Gui,88:Default
	Gui,88:+hwndhwnd
	hwnd(88,hwnd)
	Gui,Add,Edit,w500 h500,% URLDownloadToVar("http://files.maestrith.com/NewGUICreator/GUI Creator.text",250,50,"Downloading latest version info","Please wait...")
	Gui,Add,Button,gvupd,Update Script
	Gui,Show,,Version=0.001.26
	ControlSend,Edit1,^{Home},% hwnd([88])
	return
	vupd:
	Version=0.001.26
	ext:=A_IsCompiled?".exe":".ahk"
	FileMove,%A_ScriptName%,Backup-%version%-%A_ScriptName%,1
	SplashTextOn,200,50,Downloading,Please wait
	URLDownloadToFile,http://files.maestrith.com/NewGUICreator/GUI Creator%ext%,%A_ScriptName%
	SplashTextOff
	Run,%A_ScriptName%
	ExitApp
	return
	88GuiEscape:
	88GuiClose:
	hwnd({remove:88})
	return
}
URLDownloadToVar(url,info*){
	if info.1
	SplashTextOn,% info.1,% info.2,% info.3,% info.4
	hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open("GET",url)
	hObject.Send()
	SplashTextOff
	return hObject.ResponseText
}
Copy_GUI_to_Clipboard(){
	Copy_GUI_to_Clipboard:
	Clipboard:=compile_gui(1)
	TrayTip,GUI Creator,Script copied to your Clipboard
	return
}
makeblock(){
	ea:=settings.ea("//settings/grid")
	dot:=ea.dot?ea.dot:0,grid:=ea.grid!=""?ea.grid:0xEEEEEE
	image:=ComObjCreate("WIA.ImageFile")
	vector:=ComObjCreate("WIA.Vector")
	dot+=0,grid+=0
	vector.add(dot)
	loop,99
	vector.add(grid)
	image:=vector.imagefile(10,10)
	FileDelete,GuiCreator\tile.bmp
	image.savefile("GuiCreator\tile.bmp")
	display_grid("removebrush")
	WinSet,Redraw,,% hwnd([1])
}
adjust(){
	adjust:
	templist:=gui.sn("//templist/*")
	Gui.Transform()
	if !templist.length
	return
	killhighlight(),grid:=settings.ssn("//options/Snap_To_Grid").text
	direction:=settings.ssn("//key[@value='" A_ThisHotkey "']/@desc").text
	while,tl:=templist.item(A_Index-1){
		ea:=xml.easy(tl)
		pos:=getpos(ea.control)
		if direction=Left
		pos.x-=grid?10:1
		if direction=Right
		pos.x+=grid?10:1
		if direction=up
		pos.y-=grid?10:1
		if direction=down
		pos.y+=grid?10:1
		grid(pos.x,pos.y)
		GuiControl,1:movedraw,% ea.control,% "x" pos.x " y" pos.y
		ct:=gui.current(ea.control),ct.SetAttribute("x",pos.x),ct.SetAttribute("y",pos.y)
	}
	highlight()
	return
}
Export_GUI(){
	option:=settings.ssn("//options/Warn_Overwrite").text?"S16":""
	FileSelectFile,file,%option%,,Choose a file to save the GUI.,*.ahk
	if ErrorLevel||file=""
	return
	file:=InStr(file,".ahk")?file:file ".ahk"
	gg:=compile_gui(1)
	FileDelete,%file%
	FileAppend,%gg%,%file%
}
show_code(){
	info:=compile_gui(1)
	Gui,58:Destroy
	Gui,58:Add,Edit,w800 h800 -Wrap,% info
	Gui,58:Show
	return
	58GuiEscape:
	Gui,58:Destroy
	return
}
dupcheck(){
	vars:=gui.sn("//*[@v!='']"),list:=[]
	while vv:=vars.item(a_index-1){
		ea:=xml.easy(vv)
		count:=gui.sn("//*[@v='" ea.v "']")
		if RegExReplace(gui[],"i)v=" Chr(34) ea.v Chr(34),,count)&&count>1
		list[ea.hwnd]:=1
	}
	if list.maxindex(){
		gui.remove("//selected")
		for a in list
		gui.add("gui/selected/hwnd",{dup:1}).text:=a
		highlight()
		MsgBox,48,Variable Conflict!,The selected controls share the same Variable.  Please change them
	}
}
move(templist,x,y){
	while,GetKeyState("LButton","P"){
		MouseGetPos,xx,yy
		Grid(xx,yy)
		if !(lastx=xx&&lasty=yy)
		while,tl:=templist.item(A_Index-1){
			ea:=xml.easy(tl),x:=ea.x+xx,y:=ea.y+yy
			grid(x,y)
			GuiControl,1:movedraw,% ea.control,% "x" x " y" y
			ct:=gui.current(ea.control),ct.SetAttribute("x",x),ct.SetAttribute("y",y)
		}
		sleep,30
		lastx:=xx,lasty:=yy
	}
}
reorder_gui(){
	static clist,tvlist
	Gui,3:Destroy
	Gui,3:Default
	Gui,+Owner1 +hwndhwnd
	hwnd(3,hwnd)
	Hotkey,IfWinActive,% hwnd([3])
	Hotkey,+up,moveit,On
	Hotkey,+down,moveit,On
	Gui,Add,Text,,Usage: Press either Shift+Up or Shift+Down to move a control`nControls may be re-ordered if`n1.You move a control from a tab to the main GUI`n2.If you move a control from a GroupBox to the main Gui
	Gui,Add,TreeView,w300 h500 AltSubmit greorder
	reorderpop:
	gg:=gui.sn("//*[@hwnd]"),clist:=[],tvlist:=[],tablist:=[]
	while,control:=gg.item(a_index-1){
		if ssn(control,"@tab").text{
			node:=control
			while,node.nodename!="tab"
			node:=node.ParentNode
			last:=node.xml
			if (!tablist[node.xml]){
				lasttab:=TV_Add("Tab " ssn(control,"@tab").text,lastcontrol,"Expand")
				parent:=lastcontrol
				tablist[node.xml]:=lasttab
			}
			parent:=tablist[node.xml]
			if ssn(control.ParentNode,"@type").text="GroupBox"
			parent:=lastgroup
		}
		else if (control.ParentNode.nodename!="window")
		parent:=lastgroup
		else
		parent:=0
		con:=TV_Add(ssn(control,"@type").text,parent,"Expand")
		clist[con]:=ssn(control,"@hwnd").text
		tvlist[ssn(control,"@hwnd").text]:=con
		if InStr(ssn(control,"@type").text,"Tab")
		lastcontrol:=con
		if InStr(ssn(control,"@type").text,"GroupBox")
		lastgroup:=con
	}
	TV_Modify(TV_GetNext(),"Select Focus")
	if A_ThisLabel=menu
	gosub high
	Gui,Show,,Reorder GUI
	return
	3GuiEscape:
	3GuiClose:
	Gui,3:Destroy
	return
	reorder:
	if A_GuiEvent not in normal,k
	return
	if A_GuiEvent=k
	if A_EventInfo=16
	return
	high:
	if !hwnd:=clist[TV_GetSelection()]
	return
	Gui.remove("//selected"),Gui.Add("gui/selected/hwnd").text:=hwnd
	highlight()
	current:=gui.ssn("//*[@hwnd='" hwnd "']")
	if tab:=ssn(current,"@tab").text{
		phwnd:=ssn(current,"ancestor::*[@type='Tab' or @type='Tab2']/@hwnd").text
		GuiControl,1:Choose,%phwnd%,%tab%
	}
	Gui,3:Default
	WinSet,Top,,% hwnd([3])
	return
	moveit:
	Gui,3:Default
	TV_GetText(tt,TV_GetSelection())
	if InStr(tt,"tab ")
	return m("Can not move tabs")
	nextitem:=A_ThisHotkey="+up"?TV_GetPrev(TV_GetSelection()):TV_GetNext(TV_GetSelection())
	first:=gui.ssn("//*[@hwnd='" clist[TV_GetSelection()] "']")
	second:=gui.ssn("//*[@hwnd='" clist[nextitem] "']")
	if !second
	return
	first.SetAttribute("reorder",1)
	top:=first.ParentNode
	if A_ThisHotkey=+up
	top.insertbefore(first,second)
	else
	top.insertbefore(second,first)
	GuiControl,-Redraw,SysTreeView321
	TV_Delete()
	gosub reorderpop
	select:=gui.ssn("//@reorder/..")
	select.RemoveAttribute("reorder")
	TV_Modify(tvlist[ssn(select,"@hwnd").text],"Select Vis Focus")
	GuiControl,+Redraw,SysTreeView321
	return
}
/*
	Move_Selected_Item_Up(){
		GuiControl,-Redraw,SysTreeView321
		current:=current()
		if b4:=current.previousSibling{
			current.SetAttribute("here",1)
			new:=b4.parentnode.insertBefore(current,b4)
			load_menu(x)
			clear_here()
		}
		GuiControl,+Redraw,SysTreeView321
	}
	Move_Selected_Item_Down(){
		GuiControl,-Redraw,SysTreeView321
		current:=current()
		if b4:=current.nextSibling{
			current.SetAttribute("here",1)
			new:=b4.parentnode.insertBefore(b4,current)
			load_menu(x)
			clear_here()
		}
		GuiControl,+Redraw,SysTreeView321
	}
*/
move_to_tab(){
	movetab:
	current:=gui.current(v.last)
	current.SetAttribute("tab",A_ThisMenuItem)
	ea:=xml.easy(current),hwnd:=ea.hwnd
	add_control(ea.type,ea)
	DllCall("DestroyWindow",uint,gui.ea("//*[@hwnd='" hwnd "']").hwnd)
	current.ParentNode.RemoveChild(current),highlight()
	return
}
guiedit(ev,value=""){
	if A_GuiEvent!=Normal
	return
	if (value){
		gui.ssn("//show/@" ev.value).text:=value
		edit("GUI Settings"),vv:=ev.value,ea:=gui.ea("//show")
		if vv in x,y,w,h
		WinMove,% hwnd([1]),,% ea.x,% ea.y,% ea.w+(v.Border*2),% ea.h+(v.Border*2+v.Caption)
		return
	}
	if ev.parent="constants"
	return smalledit(ev.desc,ev.start)
	if !gui.ssn("//show/@" ev.parent)
	Gui.ssn("//show").SetAttribute(ev.parent,"")
	toggle(gui.ssn("//show/@" ev.parent),ev.value,TV_Get(A_EventInfo,"Check"))
	if ev.parent="options" or ev.parent="title"
	Gui,1:Show,% RegExReplace(gui.ssn("//show/@options").text,"i)(Hide|Minimize|NA|NoActivate)"), gui.ssn("//show/@title").text
	edit("GUI Settings")
}
toggle(node,value,check){
	values:=[],vv:=node.text " " value
	Loop,Parse,vv,%A_Space%,%A_Space%
	values[A_LoopField]:=1
	if !check
	values.remove(value)
	for a in values
	list.=a " "
	node.text:=Trim(list)
}
test_gui(){
	static pid
	info:="#SingleInstance,Force`n" compile_gui(1)
	pid:=dynarun(info)
	ea:=gui.ea("//show")
	x:=ea.x,y:=ea.y
	if InStr(gui.ssn("//show/@gui").text,"-Caption"){
		Gui,33:Destroy
		Gui,33:+AlwaysOnTop
		Gui,33:Add,Text,,This window pops up when you select no caption
		Gui,33:Add,Button,gshow,Show Window
		Gui,33:Add,Button,gkill,Kill Window
		Gui,33:Show,Center,Window control
	}
	return
	show:
	WinActivate,ahk_pid%pid%
	return
	33GuiClose:
	33GuiEscape:
	kill:
	WinKill,ahk_pid%pid%
	Gui,33:Destroy
	Gui,1:Default
	return
}
edit_labels(){
	static
	labels:=gui.sn("//*[@g!='']/@g")
	Gui,4:Destroy
	Gui,4:+hwndhwnd
	hwnd(4,hwnd)
	Gui,4:Add,ListView,w150 h300 AltSubmit gpop,Labels
	Gui,4:Add,Edit,x+10 w500 h300 geditlabel veditlabel
	Gui,4:Default
	while,ll:=labels.item(a_index-1)
	LV_Add("",ll.text)
	Gui,4:Show,,Label Editor
	LV_Modify(1,"Focus Vis Select")
	return
	editlabel:
	Gui,4:Submit,Nohide
	LV_GetText(label,LV_GetNext())
	gui.add("labels/" label).text:=editlabel
	return
	pop:
	Gui,4:Default
	LV_GetText(label,LV_GetNext())
	ControlSetText,Edit1,% RegExReplace(gui.ssn("//labels/" label).text,"\n","`r`n"),% hwnd([4])
	return
	4GuiClose:
	4GuiEscape:
	hwnd({remove:4})
	return
}
;http://www.autohotkey.com/community/viewtopic.php?t=63916
DynaRun(TempScript){
	static _:="uint"
	@:=A_PtrSize?"Ptr":_
	name := "GUI Creator Test"
	__PIPE_GA_ := DllCall("CreateNamedPipe","str","\\.\pipe\" name,_,3,_,0,_,255,_,0,_,0,@,0,@,0)
	__PIPE_    := DllCall("CreateNamedPipe","str","\\.\pipe\" name,_,3,_,0,_,255,_,0,_,0,@,0,@,0)
	if (__PIPE_=-1 or __PIPE_GA_=-1)
	Return 0
	Run, %A_AhkPath% "\\.\pipe\%name%",,UseErrorLevel HIDE,PID
	If ErrorLevel
	MsgBox, 262144, ERROR,% "Could not open file:`n" __AHK_EXE_ """\\.\pipe\" name """"
	DllCall("ConnectNamedPipe",@,__PIPE_GA_,@,0)
	DllCall("CloseHandle",@,__PIPE_GA_)
	DllCall("ConnectNamedPipe",@,__PIPE_,@,0)
	script := (A_IsUnicode ? chr(0xfeff) : (chr(239) . chr(187) . chr(191))) . TempScript
	if !DllCall("WriteFile",@,__PIPE_,"str",script,_,(StrLen(script)+1)*(A_IsUnicode ? 2 : 1),_ "*",0,@,0)
	Return A_LastError
	DllCall("CloseHandle",@,__PIPE_)
	Return PID
}