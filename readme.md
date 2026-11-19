# hot_key

Windows 热键脚本，基于 AutoHotkey v2.0。

## 功能

| 热键 | 作用 |
| --- | --- |
| `Esc` | 中文模式切到英文，同时发送 `Esc`；英文模式只发送 `Esc` |
| 双击 `Ctrl` | 复制选中内容，100 毫秒后发送 `F9`，用于欧路词典查词 |
| 中文模式连按两次 `/` | 输出 `//`；两次间隔不超过 600 毫秒 |
| `CapsLock` | 短按为点击鼠标左键，按住为拖动；不再切换大小写 |
| 按住 `Alt+F11` | 按住期间按下 `Ctrl` |

## 前置条件

- Windows 10 或更新版本
- AutoHotkey v2.0。本仓库 Releases 提供 2.0.10 安装包
- 双击 `Ctrl` 查词需要安装欧路词典

## 运行

1. 下载 `hot_key.ahk`。
2. 安装 AutoHotkey v2.0。
3. 双击 `hot_key.ahk`。
4. 右键托盘图标，选择 `Reload Script` 重新加载，选择 `Exit` 退出。

## 开机自启

1. 按 `Win+R`，输入 `shell:startup`，按回车。
2. 把 `hot_key.ahk` 的快捷方式放入打开的文件夹。

## 示例热键

以下热键默认注释。按需取消注释，并把路径改成自己的。

- `Alt+H` 后退，`Alt+L` 前进
- `F13` 启动指定程序
- `Ctrl+F12` 切换到 Qt Creator，并发送 `Ctrl+R`

## 原理与限制

微软拼音是 TSF 输入法。`ImmGetContext` 跨进程返回 0，脚本读不到中英状态。

脚本改为向当前窗口的 IME 窗口发送 `WM_IME_CONTROL`，读取转换模式。`IME_CMODE_NATIVE` 置位表示中文。

部分程序不支持这条消息。此时脚本判定为非中文模式，`Esc` 不做动作。
