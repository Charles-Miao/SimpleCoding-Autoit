#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include "Multimeter.au3"
Global $ConfigINIfile =  @ScriptDir & "\VT158ACC.ini"	
Global $hPort = 0
Global $WinT="FA VT158 ACC 	AutoTEST "
Opt('MustDeclareVars', 1)
Opt("TrayIconHide", 1)
Opt('TrayAutoPause', 0)
FilesCheck(@ScriptDir &"\ng.gif")
FilesCheck($ConfigINIfile)
FilesCheck(@ScriptDir &"\ok.gif")
Global $IniPort,$IniModel,$IniStage,$IniToSfcs,$IniToTest,$StarTime,$EndTime
Global $GuiWinIns,$ScanSN,$GuiBtnOk,$GuiEdtInfo,$TITLE1,$TITLE2
Global $SFCSStage,$SfcResult,$fFunc,$ButtonOK,$sSN,$ComByte,$ComByte2
Global $ACClable1_0,$ACClable2_0,$ACClable3_0,$ACClable4_0
Global $ACClable1_1,$ACClable2_1,$ACClable3_1,$ACClable4_1
Global $ACClable1_3,$ACClable2_3,$ACClable3_3,$ACClable4_3
Global $ACClable1_4,$ACClable2_4,$ACClable3_4,$ACClable4_4
Global $ACClable1_5,$ACClable2_5,$ACClable3_5,$ACClable4_5
Global $PN,$var,$CheckPN,$TestTimes,$PNNum,$TestItem,$TestNum
Global $Low_Voltage,$Over_Voltage,$Normal_Current,$Over_Current
Global $IniStage = "DH"
Global $INStage="IN"
Global $font = "MS Sans Serif"
Global $delaytime=20
Func FilesCheck($files)
	If Not FileExists($files) Then
		MsgBox(16+262144, "ERROR!!", "不能找到文件 " & $files & ", 請檢查文件是否存在!")
		Exit
	EndIf
EndFunc
Global $OPID="KTESTERK"
_Main()
Exit

Func _Main()
	_GetIniSet()
	Local $ComByte
	Local $chCom	
	_CreateWin()
	GUICtrlSetData($GuiEdtInfo, "請刷條碼")
	GUICtrlSetBkColor($GuiEdtInfo,0xFFFF00)
	Sleep(100)		
	$fFunc = False	
	$var = IniReadSectionNames($ConfigINIfile)
	If @error Then 
		MsgBox(4096+262144, "", "发生错误,可能目标文件并非标准的INI文件.")
		Exit
	EndIf
	If $IniPort <> "" And Multimeter_LoadDll() Then
		$hPort = Multimeter_InitPort("\\.\" & $IniPort)
		If $hPort <> 0 Then
			Local $StrCheck=Multimeter_GetData($hPort)
			Local $StrCheck=Multimeter_GetData($hPort)
			ConsoleWrite($StrCheck&@CRLF)
			If not StringInStr(Multimeter_GetData($hPort),"DCV")  then 
				GUISetState(@SW_HIDE, $GuiWinIns)
				Multimeter_ClosePort($hPort)
				$hPort = 0	
				Multimeter_UnloadDll()	
				MsgBox(16,"电流表档位错误","请先把电流表档位调节至 +~【V】")
				Exit
			EndIf	
			GUISetState(@SW_SHOW, $GuiWinIns)
			While True
				_LoopFunc()			
				Sleep(500)
			WEnd
		Else
			GUISetState(@SW_HIDE, $GuiWinIns)
			MsgBox(16,"COM口错误","请先打开电流表")
			Exit
		EndIf
	EndIf		
EndFunc

Func _GetIniSet() ;獲取設定函數 ;Get Setting Function 
	$IniPort = IniRead($ConfigINIfile, "PORT", "CTRL_PORT", "COM3") ;控制串口設定
	$IniModel = IniRead($ConfigINIfile, "SFCS", "MODEL", "") ;機種名設定
	$IniToSfcs = IniRead($ConfigINIfile, "SFCS", "TOSFCS", "") ;RRR,BBB檔案存放路徑
	$IniToTest = IniRead($ConfigINIfile, "SFCS", "TOTEST", "") ;AAA,CCC檔案讀取路徑
	Local $sErr	
	;RunWait(@ComSpec & " /c " & "share.bat","", @SW_HIDE)
	If Not FileExists($IniToSfcs) Then
		MsgBox(16+262144,"TOSFCS錯誤","無法找到目錄:"&$IniToSfcs&"請確認盤符是否設定正確,10秒後自動退出",10)
		Exit
	ElseIf Not FileExists($IniToTest) Then
		MsgBox(16+262144,"TOTEST錯誤","無法找到目錄:"&$IniToTest&"請確認盤符是否設定正確,10秒後自動退出",10)
		Exit
	EndIf
EndFunc

Func _CreateWin() ;主窗口生成函數
	$GuiWinIns = GUICreate($WinT, 500, 530, -1, -1, -1, BitOR($WS_EX_APPWINDOW, $WS_EX_TOPMOST))
	GUICtrlCreateLabel("版本:1.0.0.1       2014-04-24        ACC 信息: ", 15, 10)
	GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
	$GuiEdtInfo = GUICtrlCreateEdit("", 10, 80, 466, 60, BitOR($ES_READONLY, $ES_MULTILINE, $ES_AUTOVSCROLL, $ES_AUTOHSCROLL,$ES_CENTER))
	GUICtrlSetFont(-1, 15, 400, 0, "MS Sans Serif")
	GUICtrlCreateInput("S N:", 10, 40, 60, 30,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0x00FF00)
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")
	GUICtrlCreateInput("站別：", 240, 5, 60, 30,$WS_DISABLED)
	GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")	
	GUICtrlCreateInput($IniStage, 310, 5, 35, 30,$WS_DISABLED)
	GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")	
	GUICtrlCreateInput("端口:"&$IniPort, 356, 5, 115, 30,$WS_DISABLED)
	GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")
	Global $ScanSN = GUICtrlCreateInput("", 80, 40, 280, 30,$ES_UPPERCASE)
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")
	GUICtrlSetLimit($ScanSN,15)
	$ButtonOK=	GUICtrlCreateButton ("确定",  402, 38, 75,42, BitOR($BS_CENTER, $BS_DEFPUSHBUTTON, $BS_VCENTER))
	GUICtrlCreateInput("測試項:", 10, 145, 87, 34,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0x00FF00) 
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")
	GUICtrlCreateInput("測試值", 111, 145, 81, 34,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0x00FF00)
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")	
	GUICtrlCreateInput("最大值", 206, 145, 81, 34,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0x00FF00)
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")	
	GUICtrlCreateInput("最小值", 301, 145, 81, 34,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0x00FF00)
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")	
	GUICtrlCreateInput(" 結   果", 396, 145, 81, 34,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0x00FF00)
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")
	
	$ACClable1_0 = GUICtrlCreateInput("第1項", 10, 190, 87, 34,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0x00FFFF)
	GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")	
	$ACClable1_1 = GUICtrlCreateInput("", 111, 190, 81, 34,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1,14, 400, 0, "MS Sans Serif")
	$ACClable1_3 = GUICtrlCreateInput("", 206, 190, 81,34,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")
	$ACClable1_4 = GUICtrlCreateInput("", 301, 190, 81,34,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")
	$ACClable1_5 = GUICtrlCreateInput("", 396, 190, 81,34,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")

	$ACClable2_0 = GUICtrlCreateInput("第2項", 10, 235, 87, 34,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0x00FFFF)
	GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")
	$ACClable2_1 = GUICtrlCreateInput("", 111, 235, 81, 34,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")	
	$ACClable2_3 = GUICtrlCreateInput("", 206, 235, 81, 34,$WS_DISABLED)	
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")
	$ACClable2_4 = GUICtrlCreateInput("", 301, 235, 81, 34,$WS_DISABLED)	
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")
	$ACClable2_5 = GUICtrlCreateInput("", 396, 235, 81, 34,$WS_DISABLED)	
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")	
	
	$ACClable3_0 = GUICtrlCreateInput("第3項", 10, 280, 87, 34,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0x00FFFF)
	GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")
	$ACClable3_1 = GUICtrlCreateInput("", 111, 280, 81, 34,$WS_DISABLED)
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")
	$ACClable3_3 = GUICtrlCreateInput("", 206, 280, 81, 34,$WS_DISABLED)		
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")
	$ACClable3_4 = GUICtrlCreateInput("", 301, 280, 81, 34,$WS_DISABLED)		
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")
	$ACClable3_5 = GUICtrlCreateInput("", 396, 280, 81, 34,$WS_DISABLED)		
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")

	$ACClable4_0 = GUICtrlCreateInput("第4項", 10, 325, 87, 34,$WS_DISABLED)	
	GUICtrlSetBkColor(-1,0x00FFFF)
	GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")
	$ACClable4_1 = GUICtrlCreateInput("", 111, 325, 81, 34,$WS_DISABLED)	
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")	
	$ACClable4_3 = GUICtrlCreateInput("", 206, 325, 81, 34,$WS_DISABLED)	
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")
	$ACClable4_4 = GUICtrlCreateInput("", 301, 325, 81, 34,$WS_DISABLED)	
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")
	$ACClable4_5 = GUICtrlCreateInput("", 396, 325, 81, 34,$WS_DISABLED)	
	GUICtrlSetBkColor(-1,0xFFFFFF)
	GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")		
	Global $GUI_OK=GUICtrlCreatePic(".\ok.gif", 185,370, 150,150)
	GUICtrlSetState(-1,$GUI_HIDE)
	Global $GUI_NG=GUICtrlCreatePic(".\ng.gif", 185,370, 150,150)
	GUICtrlSetState(-1,$GUI_HIDE)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_MsgOnExit")
	GUICtrlSetOnEvent($ButtonOK, "_MsgOnOk")
	Opt("GUIOnEventMode", 1)
	Opt("GUICloseOnESC", 0)
	GUISetState(@SW_HIDE, $GuiWinIns)
EndFunc

Func _MsgOnExit()
	If $hPort <> 0 Then
		Multimeter_ClosePort($hPort)
		$hPort = 0
	EndIf	
	Multimeter_UnloadDll()	
	Exit
EndFunc

Func _MsgOnOk()
	;Value=5.13/5.67
	_TestPic_Disable()
	$PN=""
	$ComByte=""
	GUICtrlSetState($ScanSN, $GUI_DISABLE)
	$sSN = GUICtrlRead($ScanSN)	
	GUICtrlSetState($ButtonOK, $GUI_disABLE)
	If $sSN <> "" Then
		If StringLen($sSN) <> 15 Or StringLeft($sSN, 1) <> "S" Then
			If StringLen($sSN) <> 15  Then
				GUICtrlSetData($GuiEdtInfo, "SN長度錯誤")
				GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)
				Sleep(500)
				GUICtrlSetData($GuiEdtInfo, "SN長度錯誤，請重新刷條碼")
			Else
				GUICtrlSetData($GuiEdtInfo, "SN開頭規則錯誤錯誤")
				GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)
				Sleep(500)
				GUICtrlSetData($GuiEdtInfo, "SN開頭規則錯誤錯誤,必須為S，請重新刷條碼")
			EndIf			
			GUICtrlSetBkColor($GuiEdtInfo,0xFF00FF)
			_Enable()
		Else	
			GUICtrlSetData($GuiEdtInfo, "SN 條碼OK,正在發送RRR文件")
			GUICtrlSetBkColor($GuiEdtInfo,0xFFFF00)	
			If _SendRRR() Then
				If _RecvAAA() Then		
					$PN = IniRead($INITOTEST & "\" & $sSN & ".AAA","SFC","PN","") 
					$SFCSStage=IniRead($INITOTEST & "\" & $sSN & ".AAA","SFC","Stage","") 
					Sleep(10)
					GUICtrlSetData($GuiEdtInfo, "AAA文件OK")
					FileDelete($INITOTEST & "\" & $sSN & ".AAA")
					RunWait(@ComSpec & " /c " & "TestUpdate.bat","", @SW_MAXIMIZE)
					If $PN ="" or $SFCSStage="" Then						
						_Enable()
						GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)
						If $PN="" And $SFCSStage="" Then
							GUICtrlSetData($GuiEdtInfo,"PN與Stage為空,請重新測試")
						ElseIf $PN="" and $SFCSStage<>"" Then
							GUICtrlSetData($GuiEdtInfo,"PN為空,請重新測試")
						ElseIf  $PN<>"" and $SFCSStage="" Then
							GUICtrlSetData($GuiEdtInfo,"Stage為空,請重新測試")
						EndIf
					Else
						If $SFCSStage=$IniStage Or $SFCSStage=$INStage Then
							Local $TestItem_=IniRead($ConfigINIfile,"PN",$PN,0)
							$TestTimes=StringSplit($TestItem_,"/")
							If $TestTimes[0]<>3  Then				;至少有2組測試Item
								_Enable()
								GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)
								GUICtrlSetData($GuiEdtInfo,"當前測試項目設定格式PN=4/5.13/5.67")
								Return 
							EndIf
							If $TestTimes[1] >4 Or $TestTimes[1] <1 then  
								_Enable()
								GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)
								GUICtrlSetData($GuiEdtInfo,"當前測試項目只能1~4次，請找TE設定")
								Return 
							EndIf	
							If Not StringIsFloat($TestTimes[2]) Then 
								_Enable()
								GUICtrlSetData($GuiEdtInfo,"測試spec必須為浮點數格式,當前測試spec為:"&$TestTimes[2])
								GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)	
								Return False
							EndIf		
							If Not StringIsFloat($TestTimes[3]) Then 
								_Enable()
								GUICtrlSetData($GuiEdtInfo,"測試spec必須為浮點數格式,當前測試spec為:"&$TestTimes[3])
								GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)	
								Return False
							EndIf
							If $TestTimes[1]=1 Then
								_ACCLable1()
							ElseIf $TestTimes[1]=2 Then
								_ACCLable1()
								_ACCLable2()
							ElseIf	$TestTimes[1]=3 Then
								_ACCLable1()
								_ACCLable2()								
								_ACCLable3()
							ElseIf	$TestTimes[1]=4 Then
								_ACCLable1()
								_ACCLable2()								
								_ACCLable3()
								_ACCLable4()
							EndIf							
							$fFunc=True
						Else
							_Enable()
							GUICtrlSetData($GuiEdtInfo,"站別不正確,當前測試站別為:"&$INIStage &@CRLF&"當前機台站別:"&$Sfcsstage& "    請刷一下台進行測試")
							GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)		
						EndIf						
					EndIf		
				Else
					_Enable()
					GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)
					GUICtrlSetData($GuiEdtInfo,"AAA Time Out ! "&"請檢查網絡是否連接成功")
				EndIf								
			Else
				_Enable()
				GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)
				GUICtrlSetData($GuiEdtInfo,"RRR Time Out ! "&"請檢查網絡是否連接成功")
			EndIf							
		EndIf
	Else		
		_Enable()
		GUICtrlSetData($GuiEdtInfo, "SN條碼為空，請重新刷條碼")
		GUICtrlSetBkColor($GuiEdtInfo,0xFF00FF)
	EndIf
EndFunc

Func _LoopFunc()	
	Local $sTmp
	Local $arrFile
	Local $sFileList	
	If  $fFunc=True Then
		GUICtrlSetData($GuiEdtInfo, "正在测试中"&@CRLF&"请等待...")
		For $L=1 To $TestTimes[1]
			Local $Msg_=MsgBox(262144+1+4096,"提示選擇","第"&$L&"個cradle測試"&@CRLF&"請確認治具是否放好"&@CRLF&"确认:治具放好"&@CRLF&"取消:不测试")
			If $Msg_=2 Then
				GUICtrlSetData($GuiEdtInfo, "第"&$L&"個cradle"&@CRLF&"充電燈NG")
				GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)
				_Enable()
				GUICtrlSetState($GUI_NG,$GUI_Show)
				Return 
			EndIf			
			Local $C=0  ;判断次数如果连续2次pass 那么结果就PASS
			Local $D=0
			GUICtrlSetData($GuiEdtInfo, "正在测试中"&@CRLF&"测试第"&$L&"请等待...")
			For $I=1 To 50; Multimeter_GetData函数大概1s左右
				Local $data = Multimeter_GetData($hPort) 	
				ConsoleWrite($data&@CRLF)
				If $data<>"" then 
					Local $M=StringSplit($data ," ")
					ConsoleWrite($M[0]&@CRLF)
					If $M[1]="DCV" and $M[0]=4 Then				
						;10 ^ (-1) 10的N次方	;DCV -0.0003 E-1 格式
						If $L=1 Then
							GUICtrlSetData ($ACClable1_1,$M[3]*10&" V")
						ElseIf $L=2 Then
							GUICtrlSetData ($ACClable2_1,$M[3]*10&" V")
						ElseIf $L=3 Then
							GUICtrlSetData ($ACClable3_1,$M[3]*10&" V")
						ElseIf $L=4 Then
							GUICtrlSetData ($ACClable4_1,$M[3]*10&" V")
						EndIf
						If $M[4] ="E+1" then 						
							If Number($M[3]*10)>=Number($TestTimes[2]) And Number($M[3]*10)<=Number($TestTimes[3]) Then								
								$C=$C+1		
							Else
								$C=0	
							EndIf
							If $C=2 Then
								$D=1
								ExitLoop
							EndIf			
						Else
							$C=0
						EndIf
					Else
						$C=0
					EndIf
				Else
					$C=0
				EndIf
			Next
			If $D=0 then 
				GUICtrlSetData($GuiEdtInfo, "测试失败"&@CRLF&"请测试下一台...")
				GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)
				If $L=1 Then
					GUICtrlSetData ($ACClable1_5,"NG")
					GUICtrlSetBkColor($ACClable1_5,0xFF0000)
				ElseIf $L=2 Then
					GUICtrlSetData ($ACClable2_5,"NG")
					GUICtrlSetBkColor($ACClable2_5,0xFF0000)
				ElseIf $L=3 Then
					GUICtrlSetData ($ACClable3_5,"NG")
					GUICtrlSetBkColor($ACClable3_5,0xFF0000)
				ElseIf $L=4 Then
					GUICtrlSetData ($ACClable4_5,"NG")
					GUICtrlSetBkColor($ACClable4_5,0xFF0000)
				EndIf				
				_Enable()
				GUICtrlSetState($GUI_NG,$GUI_Show)
				Return					
			EndIf	
			If $L=1 Then
				GUICtrlSetData ($ACClable1_5,"OK")
				GUICtrlSetBkColor($ACClable1_5,0x00FF00)
			ElseIf $L=2 Then
				GUICtrlSetData ($ACClable2_5,"OK")
				GUICtrlSetBkColor($ACClable2_5,0x00FF00)
			ElseIf $L=3 Then
				GUICtrlSetData ($ACClable3_5,"OK")
				GUICtrlSetBkColor($ACClable3_5,0x00FF00)
			ElseIf $L=4 Then
			GUICtrlSetData ($ACClable4_5,"OK")
			GUICtrlSetBkColor($ACClable4_5,0x00FF00)
			EndIf			
		Next
		If _SendBBB() Then
			If _RecvCCC() Then		
				$SfcResult = IniRead($INITOTEST & "\" & $sSN & ".CCC","SFC","Result","") 
				Sleep(10)
				GUICtrlSetData($GuiEdtInfo, "CCC文件OK")
				FileDelete($INITOTEST & "\" & $sSN & ".CCC")
				If $SfcResult <>"OK" Then
					GUICtrlSetState($GUI_NG,$GUI_Show)					
					_Enable()
					GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)
					GUICtrlSetData($GuiEdtInfo,"SFCS Error SFCS 信息為:"&@CRLF &$SfcResult)
				Else
					GUICtrlSetState($GUI_OK,$GUI_Show)
					_Enable()
					GUICtrlSetData($GuiEdtInfo,"PASS    請刷一下台進行測試")
					GUICtrlSetBkColor($GuiEdtInfo,0x00FF00)					
				EndIf		
			Else
				GUICtrlSetState($GUI_NG,$GUI_Show)
				_Enable()
				GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)
				GUICtrlSetData($GuiEdtInfo,"CCC Time Out ! "&"請檢查網絡是否連接成功")
			EndIf								
		Else
			GUICtrlSetState($GUI_NG,$GUI_Show)
			_Enable()
			GUICtrlSetBkColor($GuiEdtInfo,0xFF0000)
			GUICtrlSetData($GuiEdtInfo,"BBB Time Out ! "&"請檢查網絡是否連接成功")
		EndIf	
	EndIf
EndFunc

Func _SendRRR() 
	FileDelete($INITOTEST & "\" & $sSN & ".AAA")
	GUICtrlSetData($GuiEdtInfo, "Send RRR")	
	GUICtrlSetBkColor ($GuiEdtInfo,0xFFFF00)
	Local	$content = "[SFC]" & @CRLF & "SN=" & $sSN &  @CRLF & "TIME=" & @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & @CRLF 
	Local	$objFile = FileOpen($INITOSFCS & "\" & $sSN & ".BB_", 2)
	If $objFile = -1 Then
		MsgBox(0+16+262144,"error","Open file error!")
	EndIf
	FileWrite($objFile, $content)
	FileClose($objFile)	
	If FileMove($INITOSFCS & "\" & $sSN & ".BB_", $INITOSFCS & "\" & $sSN & ".RRR", 1) Then
		Return True
	Else
		Return False
	EndIf
EndFunc
	
Func _RecvAAA()
	GUICtrlSetData($GuiEdtInfo, "正在讀取AAA文件")	
	GUICtrlSetBkColor ($GuiEdtInfo,0xFFFF00)
	Local $loop = 0
	while True
		If (FileExists($INITOTEST & "\" & $sSN & ".AAA")) Then
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
	If $loop <> $delaytime Then                              
		Return True                                          
	EndIf
EndFunc

Func _SendBBB()
	FileDelete($INITOTEST & "\" & $sSN & ".CCC")
	GUICtrlSetData($GuiEdtInfo, "Send BBB")	
	GUICtrlSetBkColor ($GuiEdtInfo,0xFFFF00)
	Local $objFile, $strFile
		$objFile = FileOpen($INIToSfcs & "\" & $sSN & ".BB_", 2)
	If $objFile = -1 Then
		Return False
	EndIf
	$StrFile = "[SFC]" & @CRLF & "SN=" & $sSN & @CRLF & "STAGE=" & $IniStage & @CRLF & "TIME=" & @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & @CRLF & "RESULT=OK"
	FileWrite($objFile, $strFile)
	FileClose($objFile)
	Sleep(500)
	If FileMove($INIToSfcs & "\" & $sSN & ".BB_", $INIToSfcs & "\" & $sSN & ".BBB", 1) Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func _RecvCCC()
	GUICtrlSetData($GuiEdtInfo, "正在讀取CCC文件")	
	GUICtrlSetBkColor ($GuiEdtInfo,0xFFFF00)
	Local $loop = 0
	while True	
		If (FileExists($INITOTEST & "\" & $sSN & ".CCC")) Then
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
	If $loop <> $delaytime Then                             
		Return True                                         
	EndIf
EndFunc

Func _Enable()
	GUICtrlSetState($ScanSN, $GUI_ENABLE)
	GUICtrlSetState($ButtonOK, $GUI_ENABLE)
	GUICtrlSetData($ScanSN, "")
	GUICtrlSetState($ScanSN, $GUI_FOCUS)	
	$fFunc = False	
EndFunc

Func _TestPic_Disable()
	GUICtrlSetState($ACClable1_0,$GUI_HIDE)
	GUICtrlSetState($ACClable1_1,$GUI_HIDE)
	GUICtrlSetState($ACClable1_3,$GUI_HIDE)
	GUICtrlSetState($ACClable1_4,$GUI_HIDE)
	GUICtrlSetState($ACClable1_5,$GUI_HIDE)
	GUICtrlSetState($ACClable2_0,$GUI_HIDE)
	GUICtrlSetState($ACClable2_1,$GUI_HIDE)
	GUICtrlSetState($ACClable2_3,$GUI_HIDE)
	GUICtrlSetState($ACClable2_4,$GUI_HIDE)
	GUICtrlSetState($ACClable2_5,$GUI_HIDE)
	GUICtrlSetState($ACClable3_0,$GUI_HIDE)
	GUICtrlSetState($ACClable3_1,$GUI_HIDE)
	GUICtrlSetState($ACClable3_3,$GUI_HIDE)
	GUICtrlSetState($ACClable3_4,$GUI_HIDE)
	GUICtrlSetState($ACClable3_5,$GUI_HIDE)
	GUICtrlSetState($ACClable4_0,$GUI_HIDE)
	GUICtrlSetState($ACClable4_1,$GUI_HIDE)
	GUICtrlSetState($ACClable4_3,$GUI_HIDE)
	GUICtrlSetState($ACClable4_4,$GUI_HIDE)
	GUICtrlSetState($ACClable4_5,$GUI_HIDE)	
	GUICtrlSetState($GUI_NG,$GUI_HIDE)
	GUICtrlSetState($GUI_OK,$GUI_HIDE)
	GUICtrlSetBkColor($ACClable1_5,0xFFFFFF)
	GUICtrlSetBkColor($ACClable2_5,0xFFFFFF)
	GUICtrlSetBkColor($ACClable3_5,0xFFFFFF)
	GUICtrlSetBkColor($ACClable4_5,0xFFFFFF)
EndFunc

Func _ACCLable1()
	GUICtrlSetState($ACClable1_0,$GUI_SHOW)
	GUICtrlSetState($ACClable1_1,$GUI_SHOW)
	GUICtrlSetData ($ACClable1_1,"")
	GUICtrlSetState($ACClable1_3,$GUI_SHOW)
	GUICtrlSetData ($ACClable1_3,$TestTimes[2]&" V")
	GUICtrlSetState($ACClable1_4,$GUI_SHOW)
	GUICtrlSetData ($ACClable1_4,$TestTimes[3]&" V")
	GUICtrlSetState($ACClable1_5,$GUI_SHOW)	
	GUICtrlSetData ($ACClable1_5,"")
EndFunc

Func _ACCLable2()
	GUICtrlSetState($ACClable2_0,$GUI_SHOW)
	GUICtrlSetState($ACClable2_1,$GUI_SHOW)
	GUICtrlSetData ($ACClable2_1,"")
	GUICtrlSetState($ACClable2_3,$GUI_SHOW)
	GUICtrlSetData ($ACClable2_3,$TestTimes[2]&" V")
	GUICtrlSetState($ACClable2_4,$GUI_SHOW)
	GUICtrlSetData ($ACClable2_4,$TestTimes[3]&" V")
	GUICtrlSetState($ACClable2_5,$GUI_SHOW)	
	GUICtrlSetData ($ACClable2_5,"")
EndFunc

Func _ACCLable3()
	GUICtrlSetState($ACClable3_0,$GUI_SHOW)
	GUICtrlSetState($ACClable3_1,$GUI_SHOW)
	GUICtrlSetData ($ACClable3_1,"")
	GUICtrlSetState($ACClable3_3,$GUI_SHOW)
	GUICtrlSetData ($ACClable3_3,$TestTimes[2]&" V")
	GUICtrlSetState($ACClable3_4,$GUI_SHOW)
	GUICtrlSetData ($ACClable3_4,$TestTimes[3]&" V")
	GUICtrlSetState($ACClable3_5,$GUI_SHOW)	
	GUICtrlSetData ($ACClable3_5,"")
EndFunc

Func _ACCLable4()
	GUICtrlSetState($ACClable4_0,$GUI_SHOW)
	GUICtrlSetState($ACClable4_1,$GUI_SHOW)
	GUICtrlSetData ($ACClable4_1,"")
	GUICtrlSetState($ACClable4_3,$GUI_SHOW)
	GUICtrlSetData ($ACClable4_3,$TestTimes[2]&" V")
	GUICtrlSetState($ACClable4_4,$GUI_SHOW)
	GUICtrlSetData ($ACClable4_4,$TestTimes[3]&" V")
	GUICtrlSetState($ACClable4_5,$GUI_SHOW)	
	GUICtrlSetData ($ACClable4_5,"")
EndFunc