;分号表示注释
;!表示ALT键
;+表示shift键
!h::!Left
!l::!Right
;+Space::+

#Requires AutoHotkey v2.0
;~RShift::#Space shift切换输入法，以下是改进版
         
; ============================================================
; 中/英模式状态追踪（系统读不到输入法模式，改用状态记录）
; InChinese: 记录的模式，true=中文 false=英文（默认中文）
; EscJustToggled: 防止自己发的Shift被算作手动切换
; 注意：若用鼠标点任务栏"中/英"图标切换，会与记录不同步
; ============================================================
global InChinese := true
global EscJustToggled := false

ClearEscGuard() {
    global EscJustToggled
    EscJustToggled := false
}

~LShift::{
    global InChinese, EscJustToggled
    if (EscJustToggled)   ; 刚由ESC发起的Shift，忽略
        return
    StartTime := A_TickCount
    KeyWait("LShift")
    if (A_PriorKey == "LShift")  and (A_TickCount-StartTime < 600)
        InChinese := !InChinese   ; 手动快速按Shift = 切中英，同步状态
    return
}
~RShift::{
    global InChinese, EscJustToggled
    if (EscJustToggled)   ; 刚由ESC发起的Shift，忽略
        return
    StartTime := A_TickCount
    KeyWait("RShift")
    if (A_PriorKey == "RShift")  and (A_TickCount-StartTime < 600)
        InChinese := !InChinese
    return
}
; ===== 新增的 F13 热键功能 =====
F13::Run "D:\project\QT\PinCodeScanner\build\debug\PinCodeScanner.exe"  ; 替换为你想启动的程序路径
;
;esc键：中文模式→切英文+esc；英文模式→只保留esc
~Esc::{
    global InChinese, EscJustToggled
    ; 安全网：若布局已是美式英语，直接当英文处理
    hwnd := WinExist("A")
    threadId := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt", 0, "Ptr")
    hkl := DllCall("GetKeyboardLayout", "UInt", threadId, "Ptr")
    if (Format("{:08x}", hkl & 0xFFFF) == "00000409") {
        InChinese := false
        return
    }
    if (InChinese) {
        EscJustToggled := true
        SetTimer(ClearEscGuard, -250)   ; 250ms内忽略Shift，防止自己发的Shift被算成手动切换
        Send "{Shift}"                  ; 中 → 英
        InChinese := false
    }
    return
}
;======新增切换qt并运行exe功能======
; 按 Ctrl+F12 切换到 Qt Creator 并执行 Ctrl+R
~^F12::{
    ; 激活 Qt Creator 窗口
    WinActivate("Qt Creator")
    
    ; 等待窗口完全激活
    WinWaitActive("Qt Creator", , 2)
    
    ; 方案1: 使用 SendPlay（更可靠的模拟物理按键）
    ;SendPlay("^r")
    
    ; 方案2: 如果上面的方法不起作用，可以尝试下面的替代方案
    ; SendInput("{Ctrl down}r{Ctrl up}")
    
    ; 方案3: 或者添加延时后再发送按键
     Sleep 100
     Send("^r")
    
    return
}


; 按下 Alt+F11 时按下 Ctrl
!F11::Send "{Ctrl down}"

; 释放 Alt+F11 时释放 Ctrl
!F11 Up::Send "{Ctrl up}"