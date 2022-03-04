; https://www.autohotkey.com/docs/KeyList.htm

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Capslock::LCtrl
#Insert::Capslock
PrintScreen::Run "C:\WINDOWS\system32\SnippingTool.exe"
#Enter::Run "C:\Users\fhungenberg\AppData\Local\Microsoft\WindowsApps\wt.exe" ; Win+Enter

!o::Send, ö
+!o::Send, Ö
!p::Send, ö
+!p::Send, Ö
!u::Send, ü
+!u::Send, Ü
+!y::Send, Ü
!a::Send, ä
+!a::Send, Ä
!q::Send, ä
+!q::Send, Ä
!s::Send, ß
+!s::Send, ß
!e::Send, €

#Space::Send, {LWin}  ; win + space -> win left
#q::Send, !{F4}       ; win + q -> alt + f4
