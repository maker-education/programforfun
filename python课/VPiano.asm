.386
.model flat,stdcall
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
include         \masm32\include\windows.inc
include         \masm32\include\user32.inc
include         \masm32\include\kernel32.inc
include         \masm32\include\gdi32.inc
include         \masm32\include\winmm.inc
includelib      \masm32\lib\user32.lib
includelib      \masm32\lib\kernel32.lib
includelib      \masm32\lib\gdi32.lib
includelib      \masm32\lib\winmm.lib

.data
ClassName       db "SimpleWinClass",0
AppName         db "SimpleVirtualPiano",0
szText          db "钢琴程序  由 刘卫 于 2003.11.19 制作",0h
arPu            dd -24, -12, 0, 12, 24
arYu            dd 3ch, 3eh, 40h, 41h, 43h, 45h, 47h
arYuB           dd 3dh, 3fh, 42h, 44h, 46h

.data?
hInstance       HINSTANCE ?
hdc             HDC ?
midiFlag        BYTE ?
midiPu          DWORD ?
midiYu          DWORD ?
midiPlayFlag    BYTE ?

.code
start:
    invoke      GetModuleHandle, NULL
    mov         hInstance, eax
    invoke      WinMain, hInstance, NULL, NULL, SW_SHOWDEFAULT
    invoke      ExitProcess, eax

WinMain proc    hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    local       wc:WNDCLASSEX
    local       msg:MSG
    local       hwnd:HWND
    mov         wc.cbSize,SIZEOF WNDCLASSEX
    mov         wc.style, CS_HREDRAW or CS_VREDRAW
    mov         wc.lpfnWndProc, OFFSET WndProc
    mov         wc.cbClsExtra,NULL
    mov         wc.cbWndExtra,NULL
    push        hInst
    pop         wc.hInstance
    mov         wc.hbrBackground,COLOR_WINDOW+1
    mov         wc.lpszMenuName,NULL
    mov         wc.lpszClassName,OFFSET ClassName
    invoke      LoadIcon,NULL,IDI_APPLICATION
    mov         wc.hIcon,eax
    mov         wc.hIconSm,eax
    invoke      LoadCursor,NULL,IDC_ARROW
    mov         wc.hCursor,eax
    invoke      RegisterClassEx, addr wc
    invoke      CreateWindowEx, NULL, ADDR ClassName, ADDR AppName, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT,\
                    CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, NULL, hInst,NULL
    mov         hwnd, eax
    invoke      ShowWindow, hwnd, SW_SHOWNORMAL
    invoke      UpdateWindow, hwnd
    invoke      midiOutOpen, ADDR hdc, -1, NULL, NULL, NULL
    mov         midiYu, 0h
    mov         midiPlayFlag, 1h
    .WHILE TRUE
        invoke GetMessage, ADDR msg, NULL, 0, 0
        .BREAK .IF (!eax)
        invoke TranslateMessage, ADDR msg
        invoke DispatchMessage, ADDR msg
    .ENDW
    mov     eax,msg.wParam
    ret
WinMain endp

WndProc proc    hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    local       @stPs:PAINTSTRUCT
    local       @stRect:RECT
    local       @hDc
    local       @playf:WORD
    .IF         uMsg == WM_DESTROY
        invoke      midiOutClose, hdc
        invoke      PostQuitMessage, NULL
    .ELSEIF     uMsg == WM_PAINT
        invoke      BeginPaint,hWnd,addr @stPs
        mov         @hDc,eax
        invoke      GetClientRect,hWnd,addr @stRect
        invoke      DrawText, @hDc, addr szText, -1, addr @stRect, DT_SINGLELINE or DT_CENTER or DT_VCENTER
        invoke      EndPaint, hWnd, addr @stPs
    .ELSEIF     uMsg == WM_CHAR
        mov @playf, 0h
        push wParam
        pop midiPu
    .IF         midiPu == WM_DEVMODECHANGE                   ;1bh
        invoke      midiOutClose, hdc
        invoke      PostQuitMessage, NULL
    .ENDIF
    ;--------------  音阶 ---------------------
    .IF         midiPu >= 61h
        .IF         midiPu <= 65h
                mov eax, midiPu
                sub eax, 61h
                mov eax, arPu[4 * eax]
                mov midiYu, eax
        .ENDIF
    .ENDIF
    ;=============== 全音======================
    .IF         midiPu >= 31h
        .IF         midiPu <= 37h
                mov eax, midiPu
                sub eax, 31h
                mov eax, arYu[4 * eax]
                mov midiPu, eax
                mov @playf,1
        .ENDIF
    .ENDIF
    ;=============== 半音======================
    .IF         midiPu == 71h
        mov midiPu, 3dh
        mov @playf, 1
    .ELSEIF     midiPu == 77h
        mov midiPu, 3fh
        mov @playf, 1
    .ELSEIF     midiPu == 72h
        mov midiPu,42h
        mov @playf,1
    .ELSEIF     midiPu == 74h
        mov midiPu,44h
        mov @playf,1
    .ELSEIF     midiPu == 79h
        mov midiPu,46h
        mov @playf,1
    .ENDIF
    ;-------------------------------------------
    .IF @playf==1
        mov eax,midiYu
        add midiPu,eax
        mov cl,8
        shl midiPu,cl
        and midiPu,0ff00h
        add midiPu,680090h
        .IF midiPlayFlag == 1h
            ;================调用声卡的代码==============
            invoke midiOutShortMsg,hdc,midiPu
            mov  midiPlayFlag,0h
        .ENDIF
    .ENDIF
    .ELSEIF uMsg == WM_KEYUP
        mov midiPlayFlag, 1h
    .ELSE
        invoke  DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .ENDIF
    xor    eax,eax
    ret
WndProc endp
end start

