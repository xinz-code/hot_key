#Requires AutoHotkey v2.0
#SingleInstance Force

;分号表示注释
;!表示ALT键
;+表示shift键

; ===== 示例热键（按需取消注释）：Alt+H 后退，Alt+L 前进 =====
;!h::!Left
;!l::!Right
;+Space::+


; ============================================================
; 输入法状态读取
; 微软拼音是 TSF 输入法，ImmGetContext 跨进程恒返回 0，读不到模式。
; 改为向目标窗口的 IME 窗口发 WM_IME_CONTROL：
;   IMC_GETCONVERSIONMODE(0x1)，IME_CMODE_NATIVE(0x1) 置位 = 中文
; 实测（VSCode）：中文 1025，英文 0
; ============================================================
ImeConv(hwnd) {
    if !hwnd
        return -1
    imeWin := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    if !imeWin
        return -1
    res := 0
    ok := DllCall("SendMessageTimeoutW", "Ptr", imeWin, "UInt", 0x0283, "Ptr", 1, "Ptr", 0, "UInt", 0x0002, "UInt", 200, "Ptr*", &res, "Ptr")
    return ok ? res : -1
}

; 当前窗口处于中文模式返回 true。读不到状态时返回 false，Esc 不做动作
ImeChinese() {
    conv := ImeConv(WinExist("A"))
    return (conv >= 0) ? ((conv & 1) ? true : false) : false
}
; ===== 示例热键（按需取消注释）：F13 启动程序，路径改成自己的 =====
;F13::Run "D:\project\QT\PinCodeScanner\build\debug\PinCodeScanner.exe"
;
;esc键：中文模式→切英文+esc；英文模式→只保留esc
; 先读实际模式，仅中文时发 Shift。状态来自系统，不会出现记录与实际相反
~Esc::{
    if !ImeChinese()
        return
    Send "{Shift}"
    return
}
; ===== 示例热键（按需取消注释）：Ctrl+F12 切到 Qt Creator 并按 Ctrl+R 运行 =====
;~^F12::{
;    WinActivate("Qt Creator")
;    WinWaitActive("Qt Creator", , 2)
;    Sleep 100
;    Send "^r"
;    return
;}

; ============================================================
; 双击 Ctrl：复制选中内容，100ms 后唤起欧路词典并查询
; 判定：两次 Ctrl 按下间隔不大于 350ms，且两次都没与其他键组合
; 组合判断用 Ctrl Up 时的 A_PriorKey：干净单击等于 LControl/RControl；
; 按住 Ctrl 再按其他键（Ctrl+C 等）时等于那个键
; ============================================================
global LastCtrlTap := 0    ; 上一次干净单击的按下时间
global CtrlDownAt := 0     ; 本次按下时间

~Ctrl::
{
    global CtrlDownAt
    CtrlDownAt := A_TickCount
}

~Ctrl Up::
{
    global LastCtrlTap, CtrlDownAt
    if !(A_PriorKey = "LControl" or A_PriorKey = "RControl")
        return
    if (LastCtrlTap and CtrlDownAt - LastCtrlTap <= 350) {
        LastCtrlTap := 0
        Send "^c"                       ; 复制当前选中的内容
        Sleep 100
        Send "{F9}"                     ; 欧路词典的查询热键
        return
    }
    LastCtrlTap := CtrlDownAt
}

; 按下 Alt+F11 时按下 Ctrl
!F11::Send "{Ctrl down}"

; 释放 Alt+F11 时释放 Ctrl
!F11 Up::Send "{Ctrl up}"


; ============================================================
; 新增：中文模式下，双击「/」键（输入法会打出「、、」）自动转为 // 注释符
; 原理：拦截 / 键，第一次按下输出顿号「、」；
;       600ms内连续第二次按下时，删掉顿号，改用 SendText 直接插入 //（绕过输入法，不会被转回顿号）
; Shift/Ctrl/Alt 组合（？、Ctrl+/ 等）保留原功能
; #InputLevel 1：防止脚本自己 Send 的按键再次触发本热键
; 中文模式判断改用 ImeChinese()，与 Esc 使用同一来源
; ============================================================
global SlashPending := false
global SlashLastTime := 0

#HotIf ImeChinese()
#InputLevel 1
/::
{
    global SlashPending, SlashLastTime
    if GetKeyState("Shift", "P") or GetKeyState("Ctrl", "P") or GetKeyState("Alt", "P") {
        Send "{Blind}/"
        return
    }
    now := A_TickCount
    if (SlashPending and A_PriorKey == "/" and now - SlashLastTime <= 600) {
        SlashPending := false
        Send "{Backspace}"
        SendText "//"
        return
    }
    SlashPending := true
    SlashLastTime := now
    SendText "、"
    return
}
#InputLevel 0
#HotIf

; ============================================================
; 新增：CapsLock 改作鼠标左键（轻点=单击，按住=拖动）
; CapsLock 成为热键后不再切换大小写（废弃该功能）
; ============================================================
CapsLock::
{
    Send "{LButton down}"
    KeyWait("CapsLock")
    Send "{LButton up}"
    return
}