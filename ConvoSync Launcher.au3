#NoTrayIcon
#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=CS Logo.ico
#AutoIt3Wrapper_Outfile=ConvoSync Launcher 0_9.exe
#AutoIt3Wrapper_Res_Description=This is the launcher for the ConvoSync Client.
#AutoIt3Wrapper_Res_Fileversion=0.9.0.0
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Launcher Author|Talkarcabbage
#AutoIt3Wrapper_Res_Field=Program Author|Blir (Random11714)
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <TalkysDownloader.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <progressconstants.au3>

Global $versionNew
Global $versionCurrent

Global $devLink = "http://minepop.servegame.com:8080/job/ConvoSync%20Dev%20Build/lastSuccessfulBuild/artifact/dist/ConvoSyncBundle.jar"
Global $stableLink = "http://api.bukget.org/3/plugins/bukkit/convosync/latest/download"

Opt("GUIOnEventMode", 1)

$CheckingGui = GUICreate("ConvoSync Launcher", 170, 65, -1, -1, $WS_CAPTION)
$CheckingLabel = GUICtrlCreateLabel("Checking for updates to CS...", 15, 13)
$CheckingProgress = GUICtrlCreateProgress(10, 35, 150, 17, $PBS_MARQUEE)
GUICtrlSendMsg($CheckingProgress, $PBM_SETMARQUEE, 100, 18)



$temploc = @AppDataDir & "\ConvoSync\Updates\Temp\ConvoSyncBundle.jar"
$mainloc = @AppDataDir & "\ConvoSync\ConvoSyncBundle.jar"
$ConvoSyncDir = @AppDataDir & "\ConvoSync"

$SaveVersion = ""
$dev = ""

If Not (FileExists($ConvoSyncDir & "\")) Then
	DirCreate(@AppDataDir & "\ConvoSync")
	DirCreate(@AppDataDir & "\ConvoSync\Updates")
	DirCreate(@AppDataDir & "\ConvoSync\Updates\Temp\")
	FirstRun()
EndIf


DirCreate(@AppDataDir & "\ConvoSync")
DirCreate(@AppDataDir & "\ConvoSync\Updates")



If Not (FileExists($ConvoSyncDir & "\ConvoSync.bat")) Then
	FileWrite($ConvoSyncDir & "\ConvoSync.bat", "java -jar ConvoSyncBundle.jar")
EndIf


$mainlink = ""
$Form1 = 0

If FileRead($ConvoSyncDir & "\Updates\promptupdate.txt") = "false" Then
	RunConvoSync()
EndIf

GUISetState(@SW_SHOW, $CheckingGui)

$UpdateAvail = UpdateAvailable()
Sleep(3000)
If Not (FileExists($mainloc)) Then
	UpdateConvoSync()
EndIf

If $UpdateAvail = True Then
	UpdatePrompt()
Else
	RunConvoSync()
EndIf








;Check version + compare to server here. If update available, then return true.
Func UpdateAvailable()
	$verBool = _Download("https://raw.github.com/Blir/ConvoSync/dev/src/version.txt", $ConvoSyncDir & "\Updates\versionNew.txt", "", "", False)
	$versionNew = FileRead($ConvoSyncDir & "\Updates\versionNew.txt")
	$versionCurrent = FileRead($ConvoSyncDir & "\Updates\versionCurrent.txt")
	$StringArray = StringSplit($versionNew, "%%")

	If (FileRead($ConvoSyncDir & "\Updates\DoDev.txt") = "true") Then
		$dev = True
		$mainlink = $devLink
	Else
		$dev = False
		$mainlink = $stableLink
	EndIf

	Local $bool


	If $StringArray[0] = 3 Then ;If the number of elements is three...


		If Not ($dev) Then

			;If the current version does not match the new STABLE version, boolean is true.
			If ($versionCurrent = $StringArray[1]) Then
				$bool = False
			Else
				$bool = True
			EndIf

			$SaveVersion = $StringArray[1]
			;Set the Version-to-be-Saved to the new version.
		EndIf


		If $dev Then

			;If the current version does not match the new DEV version, boolean is true.
			If ($versionCurrent = $StringArray[3]) Then
				$bool = False
			Else
				$bool = True
			EndIf

			$SaveVersion = $StringArray[3]
			;Set the Version-to-be-Saved to the new version.

		EndIf


	EndIf

	;If an update is available/version mismatch, return true.
	Return $bool
EndFunc   ;==>UpdateAvailable



Func UpdateConvoSync()
	GUISetState(@SW_HIDE, $CheckingGui)
	GUISetState(@SW_HIDE, $Form1)

	FileDelete($temploc)
	$didUpdate = _Download($mainlink, $temploc, "ConvoSync", "CS Downloader")

	If $didUpdate = False Then
		MsgBox(16, "ConvoSync Updater", "An error was detected during the update. Please check your Internet connection or try again later.")
	Else
		;filedelete($mainloc)
		FileCopy($temploc, $mainloc, 9)
		FileDelete($ConvoSyncDir & "\Updates\versionCurrent.txt")
		FileWrite($ConvoSyncDir & "\Updates\versionCurrent.txt", $SaveVersion)
	EndIf

	RunConvoSync()

EndFunc   ;==>UpdateConvoSync

Func UpdatePrompt()
	GUISetState(@SW_HIDE, $CheckingGui)
	$Form1 = GUICreate("ConvoSync Launcher", 201, 214)
	$Label1 = GUICtrlCreateLabel("An update is available for ConvoSync! Version: " & $SaveVersion, 8, 16, 187, 27, 0x01)
	$Label2 = GUICtrlCreateLabel("Would you like to update?", 40, 50, 128, 17)
	$Label3 = GUICtrlCreateLabel("Skipping in: 15", 54, 144, 72, 17)
	$Button1 = GUICtrlCreateButton("Yes", 64, 72, 75, 25)
	$Button2 = GUICtrlCreateButton("Not Now", 64, 104, 75, 25)
	$Button3 = GUICtrlCreateButton("No, Don't Ask Again", 40, 168, 123, 25)
	GUISetState(@SW_SHOW, $Form1)
	GUISetOnEvent($GUI_EVENT_CLOSE, "end")
	GUICtrlSetOnEvent($Button1, "UpdateConvoSync")
	GUICtrlSetOnEvent($Button2, "RunConvoSync")
	GUICtrlSetOnEvent($Button3, "NeverUpdate")

	$skip = 0
	While $skip < 15
		Sleep(1000)
		$skip += 1
		GUICtrlSetData($Label3, "Skipping in: " & 15 - $skip)
	WEnd
	RunConvoSync()

EndFunc   ;==>UpdatePrompt

Func RunConvoSync()

	ShellExecute($ConvoSyncDir & "\ConvoSync.bat", "", $ConvoSyncDir, "", @SW_HIDE)
	Sleep(200)
	GUISetState(@SW_HIDE, $CheckingGui)
	Exit
EndFunc   ;==>RunConvoSync

Func NeverUpdate()
	FileWrite($ConvoSyncDir & "\Updates\promptupdate.txt", "false")
	MsgBox(64, "Update Disabled", "You will no longer be notified when an update is available. To change this behavior, delete the 'promptupdate.txt' file in the CS client directory. " & @CRLF & "This directory can be found in Roaming\ConvoSync\updates")
	RunConvoSync()
EndFunc   ;==>NeverUpdate

Func end()
	Exit
EndFunc   ;==>end

Func FirstRun()
	Local $ver = MsgBox(68, "CS Launcher", "This appears to be the first time you've run this program (or you've reset your folder). Your version preference has been set to 'stable'. If you would rather use development versions, please click 'no'. " & @CRLF & @CRLF & "Only choose 'no' if the server you want to connect to has told you to do so.")
	If $ver = 7 Then
		FileWrite($ConvoSyncDir & "\Updates\DoDev.txt", "true")
	EndIf
	Local $1fbool = UpdateAvailable()
EndFunc   ;==>FirstRun