#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
Global $HHSnINIfile = "CurrentSFCS.ini"
Global	$SoftWareName = IniRead($HHSnINIfile,"Main","SName","UnKnow")
Global $TOSFCS = IniRead($HHSnINIfile,"SFCS","ToSFCS","error")
Global $TOTEST = IniRead($HHSnINIfile,"SFCS","ToTest","error")
Global $TOStage = IniRead($HHSnINIfile,"SFCS","Stage","error")
Global $delaytime = IniRead($HHSnINIfile,"Time","delaytime","error")
Global Const $ErrFlag   = 0 + 16 + 0 + 4096 + 262144
Global $SN,$WinTitle, $WinCtrl,$WinCtrlsn,$WinCtrlid
Global $WinTitle = IniRead($HHSnINIfile, "CONFIG", "WINTITLE", "")
Global $WinCtrl=IniRead($HHSnINIfile,"Config","WinCtrl","error")
Global $WinCtrlsn=IniRead($HHSnINIfile,"Config","WinCtrlsn","error")
Global $WinCtrlid=IniRead($HHSnINIfile,"Config","WinCtrlid","error")
Global $USEID=IniRead($HHSnINIfile,"Config","USEID","error")
Global $SNlength=IniRead($HHSnINIfile,"Main","SNlength","error")

#Region ### START Koda GUI section ### Form=
$Name = GUICreate($SoftWareName, 480, 260, 880, 20)
$SNNametxt = GUICtrlCreateLabel("SN:",13, 30, 40, 32) 
GUICtrlSetFont($SNNametxt,18,400,0,"MS Sans Serif")
$ScanSN = GUICtrlCreateInput("", 80, 30, 350, 24,$ES_UPPERCASE)
$MessageTXT = GUICtrlCreateLabel("結果:", 10, 121, 99, 33)
GUICtrlSetFont($MessageTXT,18,400,0,"MS Sans Serif")
$Message = GUICtrlCreateLabel("Pls Scan SN:", 80, 80, 352, 102,BitOR($SS_CENTER,$SS_NOPREFIX,$SS_CENTERIMAGE),$WS_EX_STATICEDGE)
GUICtrlSetFont($Message, 18, 400, 0, "MS Sans Serif")
GUICtrlSetBkColor($Message, 0x00FF00)
$Version = GUICtrlCreateLabel("Version:0.3  2014-06-26", 263, 209, 132, 21,BitOR($SS_CENTER,$SS_NOPREFIX,$SS_CENTERIMAGE),$WS_EX_STATICEDGE) 
GUICtrlSetBkColor($Version, 0x00FFF0)
$StageShow = GUICtrlCreateLabel("站別:", 10, 202, 144, 44) 
GUICtrlSetFont($StageShow,18,400,0,"MS Sans Serif")
$StageShowTxt = GUICtrlCreateLabel($TOStage, 84, 208, 132, 21,BitOR($SS_CENTER,$SS_NOPREFIX,$SS_CENTERIMAGE),$WS_EX_STATICEDGE) 
GUICtrlSetBkColor($StageShowTxt, 0xFFFF00)
GUICtrlSetLimit($ScanSN,15)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	Global $StageIN="IN"
	WinActivate($Name)
	GUICtrlSetState($ScanSN,$GUI_FOCUS)
	GUICtrlSetData($ScanSN,"")
	if WinExists($WinTitle) Then
			WinClose($WinTitle)
			WinClose("Loading","")
	EndIf
	GUICtrlSetData($Message,"Pls Scan SN:")
	GUICtrlSetBkColor($Message, 0x00FF00)
	If Not ReadINI($HHSnINIfile) Then
		Exit
	EndIf
	WinClose("Loading","")
	SCAN()
	GUICtrlSetBkColor($Message,0xFFFF00)
	GUICtrlSetData($Message,"Pls Wait test program...")
	$SN = GUICtrlRead($ScanSN)
	if SendRRR() then 
		If (WaitAAA()) Then
			$PN = IniRead($TOTEST & "\" & $SN & ".AAA","SFC","PN","error")        
			$SFCSStage = IniRead($TOTEST & "\" & $SN & ".AAA","SFC","Stage","error")
			$Runfiles = IniRead($HHSnINIfile,"PN",$PN,"Unknow")
			Sleep(100)
			if $RunFiles = "Unknow" Then ;Can't Find Run Files.
				GUICtrlSetBkColor($Message,0xFF0000)
				GUICtrlSetData($Message,"No Set PN Pls Call TE.")
				FileDelete($TOTEST & "\" & $SN & ".AAA") 
				MsgBox(0+16+262144,"Message","Not Set PN in INI files" & chr(10) & "Please Check SN in SFCS")
				Exit
			EndIf
			FileDelete($TOTEST & "\" & $SN & ".AAA")  
			if $SFCSStage=$StageIN Then  ;Stage iS  IN
					if SendBBB() Then 
						GUICtrlSetData($Message,"Pls Wait CCC Files")
						if (recvccc()) Then
							$TEMPSTAGE = IniRead($TOTEST & "\" & $SN & ".CCC","SFC","Stage","error")
							$resultCCC = IniRead($TOTEST &"\" & $SN & ".CCC","SFC","Result","error")
							FileDelete($TOTEST & "\" & $SN & ".CCC") 
							if $TEMPSTAGE = $StageIN  and $ResultCCC = "OK" then 
									if SendRRR() then 	;add other rrr
										If (WaitAAA()) Then
											$SFCSStage = IniRead($TOTEST & "\" & $SN & ".AAA","SFC","Stage","error")
											FileDelete($TOTEST & "\" & $SN & ".AAA") 
										Else
											GUICtrlSetBkColor($Message,0xFF0000)
											GUICtrlSetData($Message,"Time Out ! ")
											MsgBox(0+16+262144,"Message","請檢查網絡是否連接成功" & chr(10) & "AAA Failed Please call TE or MIS...")
										EndIf		
									Else;RRR Files Failed.
										GUICtrlSetBkColor($Message,0xFF0000)
										GUICtrlSetData($Message,"Time Out ! ")
										MsgBox(0+16+262144,"Message","請檢查網絡是否連接成功" & Chr(10) & "Something error in sendRRR file...")
									EndIf

							ElseIF $TOStage <> $TEMPSTAGE Then
								GUICtrlSetData($Message,"Pls GO To " & $ToStage)
								GUICtrlSetBkColor($Message,0xFF0000)
								MsgBox($ErrFlag,"Error","Stage error,pls Check!")
							ElseIf $ResultCCC <> "OK" Then
								GUICtrlSetData($Message,"Error:" & $ResultCCC)
								GUICtrlSetBkColor($Message,0xFF0000)
								MsgBox(0+16+262144,"Message","Please Chick to Test Next")															
							EndIf
						Else;CCC File Failed.
							GUICtrlSetData($Message,"Time Out ! ")
							GUICtrlSetBkColor($Message,0xFF0000)													
							MsgBox(0+16+262144,"Message","請檢查網絡是否連接成功" & chr(10) & "CCC Failed Please call TE or MIS...")
						EndIf									
					Else;BBB File Failed.
						GUICtrlSetData($Message,"Time Out ! ")
						GUICtrlSetBkColor($Message,0xFF0000)													
						MsgBox(0+16+262144,"Message","請檢查網絡是否連接成功" & chr(10) & "BBB Failed Please call TE or MIS...")
					EndIf	
			EndIf
			if $SFCSStage=$TOStage Then	;Stage is Test
				GUICtrlSetData($Message,"Update program... ")
				Sleep(500)
				$a=RunWait(@ComSpec & " /c " & "S_Update.bat", "C:\VT208ACC\Station\Update_program", @SW_HIDE)
				ConsoleWrite("$a="&$a&@CRLF)
				
				if FileExists($Runfiles) then 	
					RUN($Runfiles)
				Else
					GUICtrlSetBkColor($Message,0xFF0000)
					GUICtrlSetData($Message,"Can't Find Run Files")
					MsgBox(0+16+262144,"error","Can't find run files!"&Chr(10)&"Please Check Files")	
					Exit
				EndIf
				while True
					if WinExists($wintitle) Then
						GUICtrlSetBkColor($Message,0xFFFF00)
						GUICtrlSetData($Message,"Test Start:")
						ExitLoop
					else 
						Sleep(1000)
					EndIf
				WEnd	
				$DF=WinExists($WinTitle)
				If $DF Then
					WinActivate($WinTitle)
					$ConID=ControlSetText($WinTitle, "", $WinCtrlID,$USEID)
					WinActivate($WinTitle)
					ControlClick($WinTitle, "", $WinCtrlID)
					send("{ENTER}")	
					$ConSN=ControlSetText($WinTitle, "", $WinCtrlSN, $SN)
					WinActivate($WinTitle)
					ControlClick($WinTitle, "", $WinCtrlSN)
					send("{ENTER}")							
					if $ConID and $ConSN Then
							While True
								Switch WinExists($wintitle)
								case  1
									if WaitResult()="PASS" Then
										WinClose($WinTitle)
										WinClose("Loading","")
												if SendBBB() Then 
													GUICtrlSetData($Message,"Pls Wait CCC Files")
													if (recvccc()) Then
														$TEMPSTAGE = IniRead($TOTEST & "\" & $SN & ".CCC","SFC","Stage","error")
														$resultCCC = IniRead($TOTEST &"\" & $SN & ".CCC","SFC","Result","error")
														FileDelete($TOTEST & "\" & $SN & ".CCC") 
														if $TOStage = $TEMPSTAGE  and $ResultCCC = "OK" then 
															GUICtrlSetBkColor($Message, 0x00FF00)
															GUICtrlSetData($Message," PASS")
															MsgBox(0+262144,"Message","Please Chick to Test Next",1)	
														elseIF $TOStage <> $TEMPSTAGE Then
															GUICtrlSetData($Message,"Pls GO To " & $ToStage)
															GUICtrlSetBkColor($Message,0xFF0000)
															MsgBox($ErrFlag,"Error","Stage error,pls Check!")
														ElseIf $ResultCCC <> "OK" Then
															GUICtrlSetData($Message,"Error:" & $ResultCCC)
															GUICtrlSetBkColor($Message,0xFF0000)
															MsgBox(0+16+262144,"Message","Please Chick to Test Next")															
														Else
															Sleep(100)														
														EndIf
													Else
														GUICtrlSetData($Message,"Time Out ! ")
														GUICtrlSetBkColor($Message,0xFF0000)													
														MsgBox(0+16+262144,"Message","請檢查網絡是否連接成功" & chr(10) & "CCC Failed Please call TE or MIS...")
													EndIf					
												Else
													GUICtrlSetData($Message,"Time Out ! ")
													GUICtrlSetBkColor($Message,0xFF0000)													
													MsgBox(0+16+262144,"Message","請檢查網絡是否連接成功" & chr(10) & "上拋SFCS失敗")
												EndIf
												ExitLoop
									Elseif WaitResult()="FAIL" Then
										ControlClick("Erro", "Test FAIL!!", "Button1")
										GUICtrlSetBkColor($Message,0xFF0000)
										GUICtrlSetData($Message,"Test Fail")
										MsgBox(0+16+262144,"Message","Please Chick to Test Next")	
										WinClose($WinTitle)
										WinClose("Loading","")
										ExitLoop
									Else
										GUICtrlSetBkColor($Message,0xFFFF00)
										GUICtrlSetData($Message,"Pls Wait Test Result")
										Sleep(100)
									EndIf
								Case else 
									ExitLoop
								EndSwitch
							WEnd
					Else
						GUICtrlSetData($Message,"Error")
					EndIf					
				EndIf				
			EndIf
			if $SFCSStage <>$TOStage Then
				GUICtrlSetBkColor($Message,0xFF0000)
				GUICtrlSetData($Message,"Stage:   "&$SFCSStage)
				MsgBox($ErrFlag,"Stage Error!","站別不正確，當前站別為："& $SFCSStage)
			EndIf
			
		Else;AAA File Failed.
			GUICtrlSetBkColor($Message,0xFF0000)
			GUICtrlSetData($Message,"Time Out ! ")
			MsgBox(0+16+262144,"Message","請檢查網絡是否連接成功" & chr(10) & "AAA Failed Please call TE or MIS...")
		EndIf
	Else;RRR File Failed.
		GUICtrlSetBkColor($Message,0xFF0000)
		GUICtrlSetData($Message,"Time Out ! ")
		MsgBox(0+16+262144,"Message","請檢查網絡是否連接成功" & Chr(10) & "Something error in sendRRR file...")
	EndIf
	GUICtrlSetState($ScanSN,$GUI_enABLE)
	GUICtrlSetState($ScanSN,$GUI_FOCUS)
	GUICtrlSetData($ScanSN,"")
	WinClose($WinTitle)
	WinClose("Loading","")
	$nMsg = GUIGetMsg()
	Switch $nMsg
			Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
WEnd

Func ReadINI($HHSnINIfile)
		RunWait(@ComSpec & " /c " & @ScriptDir &"\share.bat",@ScriptDir, @SW_HIDE)
		sleep(1000)
	If $ToSfcs == "" Or Not FileExists($ToSfcs) Then
		$TempStr = "TOSFCS key is wrong in INI file: " & $HHSnINIfile
		MsgBox($ErrFlag, "ERROR", $TempStr)
		Return False
	EndIf
	
	If $ToTest == "" Or Not FileExists($ToTest) Then
		$TempStr = "TOTEST key is wrong in INI file: " & $HHSnINIfile
		MsgBox($ErrFlag, "ERROR", $TempStr)
		Return False
	EndIf
	
	If $WinTitle == "" Then
		$TempStr = "Can not find WINTITLE key in INI file: " & $HHSnINIfile
		MsgBox($ErrFlag, "ERROR", $TempStr)
		Return False
	EndIf
	
	$WinCtrl = IniRead($HHSnINIfile, "CONFIG", "WINCTRL", "")
	If $WinCtrl == "" Then
		$TempStr = "Can not find WINCTRL key in INI file: " & $HHSnINIfile
		MsgBox($ErrFlag, "ERROR", $TempStr)
		Return False
	EndIf
	If $TOStage == "" Then
		$TempStr = "Can not find STAGE key in INI file: " & $HHSnINIfile
		MsgBox($ErrFlag, "ERROR", $TempStr)
		Return False
	EndIf
	Return True
	
EndFunc
Func SendBBB()
	Local $objFile, $strFile
		$objFile = FileOpen($ToSfcs & "\" & $SN & ".BB_", 2)
	If $objFile = -1 Then
		Return False
	EndIf
		$strFile = "[SFC]" & @CRLF & "SN=" & $SN & @CRLF & "STAGE=" & $SFCSStage & @CRLF & "TIME=" & @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & @CRLF & "RESULT=OK"
	FileWrite($objFile, $strFile)
		FileClose($objFile)
	Sleep(500)
		If FileMove($ToSfcs & "\" & $SN & ".BB_", $ToSfcs & "\" & $SN & ".BBB", 1) Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func RecvCCC()
	$loop = 0
	while True
		If (FileExists($TOTEST & "\" & $SN & ".CCC")) Then
			ExitLoop
		Else
			$loop = $loop+1
			Sleep(1000)
			If $loop == $delaytime Then
				Return False
				ExitLoop
			EndIf
		EndIf
	WEnd
	If $loop <> $delaytime Then                              ;we have 20 mins to wait for .AAA file ....
		Return True                                          ;so you can modify the time from INI file...
	EndIf
	
EndFunc
Func SCAN()
	While 1
		$msg=GUIGetMsg()
		if $msg=$ScanSN Then
			$MBSN1=GUICtrlRead($ScanSN)
			IF stringlen($MBSN1)<>$SNlength Then
				GUICtrlSetState($ScanSN,$GUI_DISABLE)
				$ans = MsgBox(0+16+262144, "Error!", "SN is not exist !! Retry Again?",2)
				GUICtrlSetData($ScanSN,"")
				WinActivate($Name)
				GUICtrlSetState($ScanSN,$GUI_ENABLE)
				GUICtrlSetState($ScanSN,$GUI_FOCUS)
			Else
				ExitLoop
			EndIf
		EndIf
    WEnd
	GUICtrlSetState($ScanSN,$GUI_DISABLE)
EndFunc


Func SendRRR()                                              ;establish a .RRR file let SFCS to give back a .AAA file...
	$content = "[SFC]" & @CRLF & "SN=" & $SN &  @CRLF & "TIME=" & @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & @CRLF 
		$objFile = FileOpen($TOSFCS & "\" & $SN & ".BB_", 2)
		If $objFile = -1 Then
			MsgBox(0+16+262144,"error","Open file error!")
		EndIf
		FileWrite($objFile, $content)
		FileClose($objFile)	
		If FileMove($TOSFCS & "\" & $SN & ".BB_", $TOSFCS & "\" & $SN & ".RRR", 1) Then
			Return True
		Else
			Return False
		EndIf
	EndFunc
	
Func WaitAAA()                                     ;wait for .AAA file from SFCS...
	$loop = 0
	while True
		If (FileExists($TOTEST & "\" & $SN & ".AAA")) Then
			ExitLoop
		Else
			$loop = $loop+1
			Sleep(1000)
			If $loop == $delaytime Then
				Return False
				ExitLoop
			EndIf
		EndIf
	WEnd
	If $loop <> $delaytime Then                              ;we have 20 mins to wait for .AAA file ....
		Return True                                          ;so you can modify the time from INI file...
	EndIf
EndFunc


Func WaitResult()
	If WinExists($WinTitle) And ControlGetText($WinTitle, "", $WinCtrl) == "PASS" Then
		Return "PASS"
	ElseIf WinExists($WinTitle) And ControlGetText($WinTitle, "", $WinCtrl) == "FAIL" Then
		Return "FAIL"
	Else
		return "wait"
	EndIf
EndFunc

