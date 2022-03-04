; https://www.autohotkey.com/docs/KeyList.htm

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Capslock::LCtrl
#Insert::Capslock
PrintScreen::Run "C:\WINDOWS\system32\SnippingTool.exe"
#Enter::Run "C:\Users\fhungenberg\AppData\Local\Microsoft\WindowsApps\wt.exe" ; Win+Enter
!o::
Send, ö
return

+!o::
Send, Ö
return

!p::
Send, ö
return

+!p::
Send, Ö
return

!u::
Send, ü
return

+!u::
Send, Ü
!y::
Send, ü
return

+!y::
Send, Ü
return

!a::
Send, ä
return

+!a::
Send, Ä
return

!q::
Send, ä
return

+!q::
Send, Ä
return

!s::
Send, ß
return

+!s::
Send, ß
return

!e::
Send, €
return

#Space::
Send, {LWin}
return
