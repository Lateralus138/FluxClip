;
; ╓─────────────────────────────────────────────────────╖
; ║ Ω FluxClip - Quick ScreenShot Utility               ║
; ║ Ω © 2020 Ian Pride - New Pride Software/Services    ║
; ║ Ω Take and preview screenshots by use of Hotkey     ║
; ║ Ω modifiers (Alt,Shift) + Left Mouse Button;        ║
; ║ Ω to make your selection you can either             ║
; ║ Ω (while holding Alt) Left Click and Drag to        ║
; ║ Ω endpoint or you can click the 1st point and       ║
; ║ Ω then click the 2nd point. If you want to change   ║
; ║ Ω 2nd point you can keep clicking to any new point. ║
; ║ Ω Once your selection is made release Alt and a     ║
; ║ Ω a preview will pop up where you can either Cancel ║
; ║ Ω or save it. If you hold Shift when left clicking  ║
; ║ Ω you will save a full screen shot automatically.   ║
; ╙─────────────────────────────────────────────────────╜
;
; ╓─────────────────────╖
; ║ Ω Init - Directives ║
; ╙─────────────────────╜
;
; ╓───────────────────────────────────────────────────────╖
; ║ Ω Disclaimer                                          ║
; ║ Ω I usually write the majority of my own code, but    ║
; ║ Ω Gdip_All is written well enough and perfect for     ║
; ║ Ω this FOSS project. I do actually plan my own verion ║
; ║ Ω of a GDIP library in AutoHotkey.                    ║
; ║ Ω I'm sorry I do not remember the original author;    ║
; ║ Ω If you kow then please contact me and I will give   ║
; ║ Ω the appropriate credit.                             ║
; ╙───────────────────────────────────────────────────────╜
;
#SingleInstance, Force
#KeyHistory, 0
SetBatchLines, -1
ListLines, Off
SendMode Input
SetWorkingDir, %A_ScriptDir%
SplitPath,A_ScriptName,,,,A_ThisScriptName
#MaxThreadsPerHotkey, 1
SetWinDelay, 0
SetMouseDelay, -1
OnMessage(0x201,"WM_LBUTTONDOWN")
OnMessage(0x200,"WM_MOUSEMOVE")
OnMessage(0x7B,"WM_CONTEXTMENU")
OnExit("CleanUp")
;
; ╓────────╖
; ║ Ω Vars ║
; ╙────────╜
;
bttn_clr_p:="Background0x1D1D1D c0xEDEDED +0x800000"
min_w:=480
global icon_res:=(A_IsCompiled?A_ScriptName:"Icon.dll")
global _title:="FluxClip"
global MENU, GUI
;
; ╓────────╖
; ║ Ω Menu ║
; ╙────────╜
;
MENU:=New _Menu(,_title " Screenshot Hotkeys","_Menu.DummyFunc","+Break",icon_res,1,1)
MENU.Icon(_title " Screenshot Hotkeys",icon_res,1,48)
MENU.NoStandard()
MENU.Color("0xFFFFFF")

MENU.Separator()
MENU.Add("Fullscreen" A_Tab "Shift+Left Click","_Menu.DummyFunc")
MENU.Add("Window" A_Tab "Ctrl+Left Click","_Menu.DummyFunc")
MENU.Add("Selection" A_Tab "Alt+Left (Click or Drag)","_Menu.DummyFunc")

MENU.Separator()
MENU.Add("Cancel" A_Tab "Ctrl+c","GuiEscape")
MENU.Add("Save" A_Tab "Ctrl+s","SaveAlt")

MENU.Separator()
MENU.Add("&Pause " _title A_Tab "Win+Shift+p","Suspend")
MENU.Icon("&Pause " _title A_Tab "Win+Shift+p",icon_res,2,48)
MENU.Add("E&xit " _title,"Exit")
MENU.Icon("E&xit " _title,icon_res,3,48)
;
; ╓──────────────────╖
; ║ Ω Init - Program ║
; ╙──────────────────╜
;
SetTimer,CheckAlt,1
FreeMem()
return
;
; ╓───────────╖
; ║ Ω Hotkeys ║
; ╙───────────╜
;
~!LButton::
    if (GUI)
    {
        Gui,Destroy
        stamp:=bit_map:=token:=end_y:=end_x:=start_y:=start_x:=""
        bit_map_width:=bit_map_height:=bttn_w:=GUI:=curs:=""
    }
    CoordMode,Mouse,Screen
    MouseGetPos,start_x,start_y
    While (GetKeyState("Alt","P"))
    {
        continue
    }
    While (GetKeyState("LButton","P"))
    {
        continue
    }
    MouseGetPos,end_x,end_y
    CoordMode,Mouse
    token:=Gdip_Startup()
    bit_map:=Gdip_BitmapFromScreen( start_x "|"
                                    .   start_y "|"
                                    .   (end_x-start_x) "|"
                                    .   (end_y-start_y)
                                ,   0x00EE0086)
    bit_map_width:=Gdip_GetImageWidth(bit_map)
    real_width:=((bit_map_width<=min_w)?min_w:bit_map_width)
    real_x:=((bit_map_width>min_w)?0:Round((min_w*0.5)-(bit_map_width*0.5)))
    bit_map_height := Gdip_GetImageHeight(bit_map)
    FormatTime,stamp,,ddMMyyyy_Hmmss
    screen_file:=A_Desktop "\Screenshot_" stamp ".png"
    h_bit_map := Gdip_CreateHBITMAPFromBitmap(bit_map)
    bttn_w:=Round(real_width/2)
    GUI:=New _Gui(,_title)
    GUI.Margin(0,0)
    GUI.Color("0x1D1D1D","0x000000")
    GUI.Options("-Caption +Border")
    GUI.Font("Segoe UI","s12 c0x1D1D1D")
    GUI.Add("Link","   Menu","x" real_x " y24 w64 h24 +0x800000 +0x400000")
    GUI.Add("Picture","HBITMAP:" h_bit_map,"HwndPicHwnd +0x40 +0x800000 x" real_x " y50 w" bit_map_width " h" bit_map_height)
    GUI.Font("Segoe UI","s12 c0xEDEDED")
    GUI.Add("Text","Save this selection to: `n" screen_file,"x0 y+12 w" real_width " h50 +Center " ((bit_map_width>600)?"+0x200":""))
    GUI.Font("Segoe UI","s14")
    GUI.Button("0","+12",bttn_w,40,"&Cancel","BTTNAPHWND","BTTNATHWND",bttn_clr_p)
    GUI.Button("+0","p",bttn_w,40,"&Save","BTTNBPHWND","BTTNBTHWND",bttn_clr_p)
    GUI.Show("AutoSize Hide")
    id:=GUI.getId()
    AnimateWindowEx(id,"SlideDown",200,True)
    GUI.Show("AutoSize")
    WinSet,AlwaysOnTop,Off,ahk_id %id%
    FreeMem()
return
~+LButton::
    token:=Gdip_Startup()
    WinGetPos,x,y,w,h,A
    bit_map:=Gdip_BitmapFromScreen(x "|" y "|" w "|" h,0x00EE0086)
    FormatTime,stamp,,ddMMyyyy_Hmmss
    Gdip_SaveBitmapToFile(bit_map,A_Desktop "\Screenshot_" stamp ".png")
    Gdip_DisposeImage(bit_map)
    Gdip_ShutDown(token)
    token:=bit_map:=stamp:=""
    FreeMem()
return
~^LButton::
    token:=Gdip_Startup()
    WinGetPos,x,y,w,h,A
    bit_map:=Gdip_BitmapFromScreen("hwnd:" WinExist("A"))
    FormatTime,stamp,,ddMMyyyy_Hmmss
    Gdip_SaveBitmapToFile(bit_map,A_Desktop "\Screenshot_" stamp ".png")
    Gdip_DisposeImage(bit_map)
    Gdip_ShutDown(token)
    token:=bit_map:=stamp:=""
    FreeMem()
return
#+p::
    Suspend()
    FreeMem()
return
#IfWinActive,FluxClip
^c::
    SetTimer,GuiEscape,-1
return
^s::
    Gui,Destroy
    WinWaitClose,Screen From Selection
    Gdip_SaveBitmapToFile(bit_map,A_Desktop "\Screenshot_" stamp ".png")
    Gdip_DisposeImage(bit_map)
    Gdip_ShutDown(token)
    stamp:=bit_map:=token:=end_y:=end_x:=start_y:=start_x:=""
    bit_map_width:=bit_map_height:=bttn_w:=GUI:=""
    FreeMem()
return
#IfWinActive
;
; ╓────────────────╖
; ║ Ω Init - Class ║
; ╙────────────────╜
;
#Include, _Gui.aclass
#Include, _Menu.aclass
#Include, Gdip_All.ahk
#Include, _MsgBox.aclass
#Include, _Cursor.aclass
Class Mem
{	EmptyMem(pid="")
	{	pid:=!pid?DllCall("GetCurrentProcessId"):pid
		hVar:=DllCall("OpenProcess","UInt",0x001F0FFF,"Int",0,"Int",pid)
		DllCall("SetProcessWorkingSetSize", "UInt", hVar, "Int", -1, "Int", -1)
		DllCall("CloseHandle","Int",hVar)
	}
	FreeRam(pid:="")
	{	if ! pid
			for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
				this.EmptyMem(process.processID)
		else	this.EmptyMem(pid)
	}
}
;
; ╓───────────────────╖
; ║ Ω Init - Function ║
; ╙───────────────────╜
;
FreeMem()
{
    WinGet,this_pid,PID,ahk_id %A_ScriptHwnd%
    Mem.EmptyMem(this_pid)
}
ToggleSuspendPause(mode:="Suspend",window*)
{
    option  :=  {   s:65305 ,suspend:65305  ,65305:65305
                ,   p:65306 ,pause:65306    ,65306:65306 }
    if (option[mode])
    {
        mode:=option[mode]
        DetectHiddenWindows,On
        PostMessage,0x111,%mode%,,,% window[1],% window[2],% window[3],% window[4]
        DetectHiddenWindows,Off
        return (!ErrorLevel)
    }
}
Suspend()
{
    static t
    global paused
    t:=!t
    paused:=t
    a:="&Pause " _title A_Tab "Win+Shift+p"
    b:="R&esume " _title A_Tab "Win+Shift+p"
    ab:=(t?a:b)
    ba:=(t?b:a)
    MENU.Rename(ab,ba)
    MENU.Icon(ba,icon_res,(ba=b?4:2),48)
    Hotkey,~^LButton,Toggle
    Hotkey,~+LButton,Toggle
    Hotkey,~!LButton,Toggle
    Hotkey,^s,Toggle,UseErrorLevel
    Hotkey,^c,Toggle,UseErrorLevel
    return (!ErrorLevel)
}
Reload()
{
    Reload
}
Exit()
{
    ExitApp
}
WM_CONTEXTMENU()
{   
    global
    MENU.Show(real_x+2,50)
}
WM_LBUTTONDOWN()
{
    global
    local _ctrl
    MouseGetPos,,,,_ctrl
    if (_ctrl="SysLink1")
    {
        SetBatchLines,10ms
        MENU.Show(real_x+2,50)
        SetBatchLines,-1
    } 
    if (_ctrl="Static3")
    {
        SetTimer,GuiEscape,-1
    }
    if (_ctrl="Static4")
    {
        SetTimer,SaveAlt,-1
    }
    PostMessage,0xA1,2
}
WM_MOUSEMOVE()
{
    static STATEA,STATEB
    MouseGetPos,,,,ctrl
    if ((ctrl="Static3") And (! STATEA))
    {
        STATEA:=True
        GuiControl,+Background0x1D1D1D +c0x1D1D1D,msctls_progress321
        GuiControl,+c0xEDEDED,Static3
        GuiControl,+Redraw,Static3
    }
    else if ((ctrl!="Static3") And (STATEA))
    {
        STATEA:=False
        GuiControl,+Background0x1D1D1D +C0xEDEDED,msctls_progress321
        GuiControl,+c0x1D1D1D,Static3
        GuiControl,+Redraw,Static3        
    }
    if ((ctrl="Static4") And (! STATEB))
    {
        STATEB:=True
        GuiControl,+Background0x1D1D1D +c0x1D1D1D,msctls_progress322
        GuiControl,+c0xEDEDED,Static4
        GuiControl,+Redraw,Static4
    }
    else if ((ctrl!="Static4") And (STATEB))
    {
        STATEB:=False
        GuiControl,+Background0x1D1D1D +C0xEDEDED,msctls_progress322
        GuiControl,+c0x1D1D1D,Static4
        GuiControl,+Redraw,Static4        
    }
}
CleanUp()
{
    id:=GUI.getId()
    WinGet,style,Style,ahk_id %id%
    if (style&0x10000000)
    {
        AnimateWindowEx(id,"Hide|SlideDown",500)
        GUI.Destroy()
    }
    _Cursor.Reset()
}
AnimateWindowEx(hwnd,opts,time:=200,ontop:=False)
{	DetectHiddenWindows,On
	if WinExist("ahk_id " hwnd)
	{	DetectHiddenWindows,Off
		options := 0
		optList :=	{	"Activate" 	: 0x00020000,	"Blend" 	: 0x00080000
					,	"Center"   	: 0x00000010,	"Hide" 		: 0x00010000
					,	"RollRight"	: 0x00000001,	"RollLeft"  : 0x00000002
					,	"RollDown" 	: 0x00000004,	"RollUp"   	: 0x00000008
					,	"SlideRight": 0x00040001,	"SlideLeft"	: 0x00040002
					,	"SlideDown"	: 0x00040004,	"SlideUp"	: 0x00040008	}
		loop,parse,opts,|
			options |= optList[A_LoopField]
        if (ontop)
        {
            WinSet,AlwaysOnTop,On,ahk_id %hwnd%
        }
		return DllCall("AnimateWindow","UInt",hwnd,"Int",time,"UInt",options)
	}
	DetectHiddenWindows,Off
}
range(from,to,step:=1){
    range:=[]
    if (from<=to) {
        while (from<=to) {
			range.Push(from)
			from+=step
		}
    }   else    {
        while (from>=to) {
			range.Push(from)
			from-=step
		}
    }
    return range
}
;
; ╓───────────────╖
; ║ Ω Init - Subs ║
; ╙───────────────╜
;
SaveAlt:
    Gui,Destroy
    WinWaitClose,Screen From Selection
    Gdip_SaveBitmapToFile(bit_map,A_Desktop "\Screenshot_" stamp ".png")
    Gdip_DisposeImage(bit_map)
    Gdip_ShutDown(token)
    stamp:=bit_map:=token:=end_y:=end_x:=start_y:=start_x:=""
    bit_map_width:=bit_map_height:=bttn_w:=GUI:=""
return
GuiClose:
GuiEscape:
    _Cursor.Reset()
    id:=GUI.getId()
    AnimateWindowEx(id,"Hide|SlideDown",200)
    id:=""
    GUI.Destroy()
    stamp:=bit_map:=token:=end_y:=end_x:=start_y:=start_x:=""
    bit_map_width:=bit_map_height:=bttn_w:=GUI:=""
    FreeMem()
return
CheckAlt:
    if (GetKeyState("Alt","P") And (!paused))
    {
        if (GUI)
        {
            Gui,Destroy
            stamp:=bit_map:=token:=end_y:=end_x:=start_y:=start_x:=""
            bit_map_width:=bit_map_height:=bttn_w:=GUI:=curs:=""
        }
        _Cursor.Set(A_WinDir "\System32\imageres.dll","w32 Icon226")
        FreeMem()
    }   else    _Cursor.Reset()
return