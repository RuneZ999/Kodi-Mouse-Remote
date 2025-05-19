/*
This code illustrates how to use Interception driver to handle a secondary mouse for macros

USAGE:
---------------------------------------------------------------------------------------------------------
Left Click -> Space 
Long Left Click -> Enter
Right Click -> Backspace
Long Right Click -> Volume Control
Scroll Up - Up Arrow (in Vertical mode) Right Arrow (in Horizontal mode) Volume Up (in Volume mode)
Scroll Down -> Down Arrow (in Vertical mode) Left Arrow (in Horizontal mode) Volume Down (in Volume mode)
Middle Click (Scroll Click) -> Left Click
Long Middle Click (Scroll Click) -> Change scroll mode from Vertical to Horizontal
---------------------------------------------------------------------------------------------------------
*/
#SingleInstance force ; Ensures that only one instance of the script can run at a time
#Persistent ; Keeps the script running until explicitly exited
#include Lib\AutoHotInterception.ahk ; Includes the AutoHotInterception library for handling mouse events

; This changes the changest the icon of he script in the tray
Menu, Tray, Add, Exit, ExitApp
Menu, Tray, Default, Exit
Menu, Tray, Click, 1
Menu, Tray, Icon, shell32.dll, 147 ; (Green arrow pointing from right bottom to top right) - Icons are counted vertically from 1
Menu, Tray, Tip, Kodi Secondary Mouse Remote v1.0 (middle or left click to exit)
Menu, Tray, NoStandard ; No standard tray menu

; Initialize AHI (AutoHotInterception) - Interception driver needs to be installed on the machine first (install-interception.exe /install)
AHI := new AutoHotInterception() ; Create a new instance of the AutoHotInterception class
; VID/PID obtained by using Monitor.ahk
; Working pair 0x1919, 0x1919
; Testing pair 0x413C, 0x301A
mouseId := AHI.GetMouseId(0x413C, 0x301A) ; Get the mouse ID using the VID/PID of your device (replace with your device's VID/PID)

; Subscribe to mouse button events from the tablet
AHI.SubscribeMouseButtons(mouseId, true, Func("MouseButtonEvent")) ; Subscribe to mouse button events and link them to the MouseButtonEvent function
return ; End of the auto-execute section

ExitApp:
    ExitApp

; Initialize variables to track scroll direction and count
scroll_direction := 0 ; 0 = none, 1 = up, -1 = down
scroll_count := 0
scroll_mode := "vertical" ; Start in vertical mode

middle_button_pressed := false ; Track the state of the middle button
middle_button_timer := 0 ; Timer for long press detection

left_button_pressed := false ; Track the state of the left button
left_button_timer := 0 ; Timer for long press detection

right_button_pressed := false ; Track the state of the right button
right_button_timer := 0 ; Timer for long press detection

; Function to handle mouse button events
MouseButtonEvent(code, state) {
    global scroll_direction, scroll_count, scroll_mode, middle_button_pressed, middle_button_timer, left_button_pressed, left_button_timer, right_button_pressed, right_button_timer ; Make the variables accessible in this function
    scroll_mode := (scroll_mode = "") ? "vertical" : scroll_mode
    switch (code) { ; Switch statement to handle different mouse button codes
        case 5: ; Code for scroll wheel
            if (state = -1) { ; If the scroll wheel is scrolled down
                if (scroll_direction = -1) {
                    scroll_count++ ; Increment count if the same direction is scrolled
                } else {
                    scroll_direction := -1 ; Set direction to down
                    scroll_count := 1 ; Reset count
                }
                if (scroll_count = 2) { ; Trigger action on the second scroll down
                    if (scroll_mode = "vertical") {
                        Send {Down} ; Send the Down arrow key
                    }
                    else if (scroll_mode = "horizontal") {
                        Send {Left} ; Send the Left arrow key
                    }
                    else if (scroll_mode = "volume") {
                        Send {Volume_Down} ; Send the Volume Down command
                    }
                    scroll_count := 0 ; Reset count after action
                }
            } else if (state = 1) { ; If the scroll wheel is scrolled up
                if (scroll_direction = 1) {
                    scroll_count++ ; Increment count if the same direction is scrolled
                } else {
                    scroll_direction := 1 ; Set direction to up
                    scroll_count := 1 ; Reset count
                }
                if (scroll_count = 2) { ; Trigger action on the second scroll up
                    if (scroll_mode = "vertical") {
                        Send {Up} ; Send the Up arrow key
                    }
                    else if (scroll_mode = "horizontal") {
                        Send {Right} ; Send the Right arrow key
                    }
                    else if (scroll_mode = "volume") {
                        Send {Volume_Up} ; Send the Volume Up command
                    }
                    scroll_count := 0 ; Reset count after action
                }
            }
            return ; Exit the function after handling scroll events

        case 2: ; Code for middle mouse button (click on scroll)
            if (state = 1) { ; If the middle button is pressed
                middle_button_pressed := true ; Set the pressed state
                middle_button_timer := A_TickCount ; Start the timer
            } else if (state = 0) { ; If the middle button is released
                if (middle_button_pressed) {
                    if (A_TickCount - middle_button_timer >= 500) { ; Check if it was a long press
                        scroll_mode := (scroll_mode = "vertical") ? "horizontal" : "vertical" ; Toggle between vertical and horizontal
                        guidisp("Scroll mode: " . scroll_mode, 50, 50)
                    } else {
                        ;guidisp("Left Click", 50, 50)
                        Send {LButton} ; Send a left click for short press
                    }
                }
                middle_button_pressed := false ; Reset the pressed state
            }
            return ; Exit the function after handling middle button click

        case 1: ; Code for right mouse button
            if (state = 1) { ; If the right button is pressed
                right_button_pressed := true ; Set the pressed state
                right_button_timer := A_TickCount ; Start the timer
            } else if (state = 0) { ; If the right button is released
                if (right_button_pressed) {
                    if (A_TickCount - right_button_timer >= 500) { ; Check if it was a long press
                        scroll_mode := "Volume"
                        guidisp("Scroll mode: " . scroll_mode, 50, 50)
                    } else {
                        ;guidisp("BackSpace", 50, 50)
                        Send {BackSpace} ; Send the BackSpace key
                    }
                }
                right_button_pressed := false ; Reset the pressed state
            }
            ; No return here to allow fall-through to the next case

        case 0: ; Code for left mouse button
            if (state = 1) { ; If the left button is pressed
                left_button_pressed := true ; Set the pressed state
                left_button_timer := A_TickCount ; Start the timer
            } else if (state = 0) { ; If the left button is released
                if (left_button_pressed) {
                    if (A_TickCount - left_button_timer >= 500) { ; Check if it was a long press
                        ;guidisp("Enter", 50, 50)
                        Send {Enter}
                    } else {
                        ;guidisp("Space", 50, 50)
                        Send {Space} ; Send Space for short press
                    }
                }
                left_button_pressed := false ; Reset the pressed state
            }
    }
}

guidisp(text, x, y, delay = 700) {
    ; Create a hidden GUI to measure the text width
    Gui, New, +AlwaysOnTop +ToolWindow -SysMenu -Caption +HwndGuiHwnd
    Gui, Color, ffffff ; changes background color
    Gui, Font, 000000 s20 wbold, Verdana ; changes font color, size and font
    Gui, Add, Text, x20 y10, %text% ; the text to display

    Gui, Show, x%x% y%y% NoActivate
    Sleep, delay
    Gui, Destroy
}

; This code is for debug mode only and can be removed in production
/*
^Esc:: ; Hotkey to exit the application
    ExitApp ; Exit the script when Ctrl + Esc is pressed
*/
