Const fDate = "Date"
Dim oDate
Set oDate = Form.field(fDate)

Const fValue = "Valeur"
Dim oValue
Set oValue = Form.field(fValue)

Sub Form_OnClick(ByVal ControlID)
        If ControlID = "CommandButton1" Then
'			pythonFile = "D:\Users\Jean-Pierre\OneDrive\Documents\Commence\VBScript\downloadRates.py"

			'Writing input args for the python file
			Set fso  = CreateObject("Scripting.FileSystemObject")
			Set file = fso.CreateTextFile("c:\temp\input.txt", 1)
			file.write(oDate.Value)
			file.Close

			'executing python file to collect data
			strCommand = "D:\Users\Jean-Pierre\OneDrive\Documents\Commence\VBScript\downl.bat" 
			Set WshShell = CreateObject("WScript.Shell") 
			WshShell.Run strCommand,0,True
'			WshShell.Run """D:\Users\Jean-Pierre\OneDrive\Documents\Commence\VBScript\python"" " & pythonFile, 0, True
			Set WshShell = Nothing

			'reading data collected by the python file
			Set fso  = CreateObject("Scripting.FileSystemObject")
			Set file = fso.OpenTextFile("c:\temp\output.txt", 1)
			btcRate = file.ReadAll
			file.Close
			oValue.Value = btcRate
		End If
End Sub
