; This is Talky's Downloader Api, which includes an easy to use inetget downloader function.

Opt("GUIOnEventMode", 1)

; #FUNCTION# ====================================================================================================================
; Name ..........: _Download
; Description ...:
; Syntax ........: _Download($sLink, $sLocation[, $sDownName = ""[, $fShowWin = 1]])
; Parameters ....: $sLink                - The link to download from.
;                  $sLocation            - The location to save the download to.
;                  $sDownName            - [optional] The name of the download shown in the window. Default is "".
;                  $fShowWin             - [optional] Boolean. Shows a progress window of the download if true. Default is true.
; Return values .: Boolean: True if successful download.
; Author ........: Talkar
; Downloader Reference:
; ===============================================================================================================================


Func _Download($sLink, $sLocation, $sDownName = "", $sDownWinName = "Downloader", $fShowWin = true)

; Initializes several variables.
	Local $nNumerator
	Local $nRoundedFinal
	Local $hDownloaderMainWin
	Local $hDownloaderLabel
	Local $hDownloaderProgress
	Local $hDownHandle

; Opens the window if applicable.
	If $fShowWin Then
		$hDownloaderMainWin = GUICreate($sDownWinName, 245, 110, -1, -1, 0x00C00000)
		$hDownloaderLabel = GUICtrlCreateLabel("Downloading initializing - Please Wait.", 5, 10, 235, 50, 0x01)
		$hDownloaderProgress = GUICtrlCreateProgress(10, 70, 225, 25)
		GUISetState(@SW_SHOW, $hDownloaderMainWin)
	EndIf

; Sets the initial download text.
	If $sDownName <> "" Then
		GUICtrlSetData($hDownloaderLabel, "Download initializing for " & @CRLF & @CRLF & $sDownName & " - Please wait.")
	EndIf



; Get the download size.
	$nDlSize = InetGetSize($sLink, 1)

; If the download size is 0 then don't divide by 0.
	If $nDlSize = 0 Then $nDlSize = -1

; Initiate the download.
	$hDownHandle = InetGet($sLink, $sLocation, 1, 1)

; This begins the loop that queries the download and may be defined in the main loop.

	local $nDataLast

	While Not(InetGetInfo($hDownHandle, 2))

		$nNumerator = InetGetInfo($hDownHandle, 0)
		$nDataThis = $nNumerator

		$nRoundedFinal = ((Round(($nNumerator / $nDlSize), 4))*100)

		$nDataPerSecond = $nNumerator - $nDataLast

		if $nDlSize = -1 then $nRoundedFinal = "[?]"
		GUICtrlSetData($hDownloaderLabel, "Downloading " & $sDownName & "..." & @CRLF & @CRLF & "Percent Completed:  " & @TAB & $nRoundedfinal & "%" & @CRLF & "Current Speed: " & @TAB & round($nDataPerSecond*10/(1024), 1) & "KB/S")
		if not($nDlSize = -1) then GUICtrlSetData($hDownloaderProgress, $nRoundedfinal)

		$nDataLast = $nDataThis
		Sleep(100)

	WEnd

; If the download failed display the results and return false...
	if InetGetinfo($hDownHandle, 4) <> 0 Then
	; If the window is shown display the results and sleep for three seconds, then close the download, hide the window, and return false.

		GUICtrlSetData($hDownloaderLabel, "Download Failed! Code: " & InetGetInfo($hDownHandle, 4))

		if $fShowWin then
			sleep(3000)
		EndIf
		InetClose($hDownHandle)
		GUISetState(@SW_HIDE, $hDownloaderMainWin)

		return False
	Else
		GUICtrlSetData($hDownloaderLabel, "Downloaded " & $sDownName & "." & @CRLF & @CRLF & "Percent Completed:  " & "100.00%")
		GUICtrlSetData($hDownloaderProgress, 100)
	EndIf

; Close the download and hide the window.
; Return true: Successful download.
	InetClose($hDownHandle)

	if $fShowWin then GUIDelete($hDownloaderMainWin)

	return true


EndFunc
;==>Download