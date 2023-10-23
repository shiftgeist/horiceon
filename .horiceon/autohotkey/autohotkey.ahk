; Compatible with v2.0.10
; https://www.autohotkey.com/docs/KeyList.htm

; Disable Capslock
#Capslock::LCtrl

; PrintScreen
PrintScreen::Run "C:\WINDOWS\system32\SnippingTool.exe"

; Win+Enter
#Enter::Run "C:\Users\fhungenberg\AppData\Local\Microsoft\WindowsApps\wt.exe"

; Win+Space = LWin
#Space::Send "{LWin}"

; Win+Tab = Alt+Tab
<#Tab::AltTab

; LWin + q = alt+f4
#q::Send "!{F4}"

; ALT+o/p ö/Ö
!o::Send "ö"
+!o::Send "Ö"
!p::Send "ö"
+!p::Send "Ö"

; ALT+u/y ü/Ü
!u::Send "ü"
+!u::Send "Ü"
!y::Send "ü"
+!y::Send "Ü"

; ALT+a/q ä/Ä
!a::Send "ä"
+!a::Send "Ä"
!q::Send "ä"
+!q::Send "Ä"

; ALT+s ß
!s::Send "ß"
+!s::Send "ß"

; ALT+E eur
!e::Send "€"
