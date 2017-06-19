' Commence RM -- Report Category / Report Form
' Copyright © 2001 Commence Corporation. All Rights Reserved
 
Option Explicit
 
Const InitialTab = "Initial Tab"
Const fName = "reportKey"
 
Const xlCategory = 1
Const xlPrimary = 1
Const xlValue = 2
Const xlThin = 2


Const CHART_CATEGORY = "CHART_CATEGORY"
Const CHART_KEY_FIELD = "CHART_KEY_FIELD"
Const CHART_DATE_FIELD = "CHART_DATE_FIELD"
Const CHART_DATE_START = "CHART_DATE_START"
Const CHART_DATE_END = "CHART_DATE_END"
'(1=COUNT, 2=SUM, 3=AVERAGE)
Const CHART_CALCULATION = "CHART_CALCULATION"
'FIELD USED BY CHART_CALCULATION (NOT USED BY CHART_CALCULATION=0)
Const CHART_CALCULATION_FIELD = "CHART_CALCULATION_FIELD"
Const CHART_TYPE = "CHART_TYPE"
'Calendar mode month/week
Const CHART_TIMESCALE = "CHART_TIMESCALE"
Const CHART_CALCULATION_FORMAT = "CHART_CALCULATION_FORMAT"

'Employee category information
Const EMPLOYEE_CATEGORY = "EMPLOYEE_CATEGORY"
Const EMPLOYEE_KEY_FIELD = "EMPLOYEE_KEY_FIELD"
Const EMPLOYEE_CONNECTION_NAME = "EMPLOYEE_CONNECTION_NAME"
Const EMPLOYEE_KEY_VALUE = "EMPLOYEE_KEY_VALUE"


'Type category information
Const TYPE_CATEGORY = "TYPE_CATEGORY"
Const TYPE_KEY_FIELD = "TYPE_KEY_FIELD"
Const TYPE_CONNECTION_NAME = "TYPE_CONNECTION_NAME"
Const TYPE_KEY_VALUE = "TYPE_KEY_VALUE"

Const FILTER_CONNECTION_NAME = "FILTER_CONNECTION_NAME"
Const FILTER_CATEGORY = "FILTER_CATEGORY"
Const FILTER_KEY_FIELD = "FILTER_KEY_FIELD"
Const FILTER_KEY_VALUE = "FILTER_KEY_VALUE"


'User defined filters if any
Const USER_DEFINED_FILTER1 = "USER_DEFINED_FILTER1"
Const USER_DEFINED_FILTER2 = "USER_DEFINED_FILTER2"
Const USER_DEFINED_FILTER3 = "USER_DEFINED_FILTER3"

'Excel Parameters
Const EXCEL_TITLE = "EXCEL_TITLE"
Const EXCEL_SHEET_TITLE = "EXCEL_SHEET_TITLE"
Const EXCEL_XAXIS_TITLE = "EXCEL_XAXIS_TITLE"
Const EXCEL_YAXIS_TITLE = "EXCEL_YAXIS_TITLE"
Const EXCEL_CHART_TYPE = "EXCEL_CHART_TYPE"
Const EXCEL_CHART_LEGEND = "EXCEL_CHART_LEGEND"

 
Dim CommenceDB          ' commence database object
Dim clsScripts          ' Commence excel report library
Dim Conv                                ' commence DDE conversation object
Dim sReportName ' report name
Dim Msg, M
Dim objXLWorkSheet1, objXLWorkSheet2
Dim objXL
Dim x
Dim y
Dim vFormDatumstart
Dim vFormDatumeinde
Dim vMonth
 
Function CreateCommenceObject()
  Dim CMC
  Set CMC = Application.Database 'CreateObject("Commence.DB")
  Set CreateCommenceObject = CMC
End Function
 
 
Sub Form_OnLoad()
    'Set CommenceDB = Application.Database 'CreateObject("Commence.DB")
    Set CommenceDB = CreateCommenceObject
    Set clsScripts = CreateCommenceReportLibrary()
    Set Conv = CommenceDB.GetConversation("Commence", "GetData")
    ' We have to generate another event in order to
    ' handle data. This will initiate the OnEnterTab Event.
    Form.MoveToTab (InitialTab)
End Sub
 
Sub Form_OnSave()
End Sub
 
Sub Form_OnCancel()
End Sub
 
Sub Form_OnEnterTab(ByVal TabName)
On Error Resume Next

Dim sView
Dim MyArray
Dim u

        If Not IsAdd() Then

                ' Find out if we're in a subsidiary view via DDE
                sView = Conv.Request("[GetActiveViewInfo(|)]")  ' grabs a bunch of view related information
                MyArray = Split(sView, "|")             ' sticks view info into an array
                sView = MyArray(0)                              ' this grabs the view name from the array

                Select Case sView

                Case "Admin - Reports"
                ' edit the item if using the admin view.
                Case Else
                        ' User opens form. We capture the report name, open it and close this form
'                        If TabName = InitialTab Then
'                                sReportName = Form.Field(fName).Value
 '                               Conv.Execute ("[ShowView(""" + sReportName + """, 1)]")
  '                              If Err.Number < 1 Then
   '                                     Form.Cancel
    '                                    ' If we generate an error it's because the report name doesn't exist
     '                           ElseIf Err.Number > 0 Then
      '                                  Msg = "This report does not exist. Would you like to fix this?"
       '                                 M = MsgBox(Msg, vbYesNo, "Commence")
        '                                If M = vbNo Then
         '                                       Form.Cancel
          '                              ElseIf M = vbYes Then
           '                             End If
            '                    End If
             '           End If
                End Select
        End If

        Call Link
End Sub
 
Sub Form_OnLeaveTab(ByVal TabName)
End Sub
 
Sub Form_OnEnterField(ByVal FieldName)
End Sub
 
Sub Form_OnLeaveField(ByVal FieldName)
End Sub
 
Sub Link()
On Error Resume Next
Dim sView
Dim MyArray
Dim u
Dim cAccount, nAccount, rAccount, iAccount, iClarify, vAccount, vClarify
Dim CommenceDB
Set CommenceDB = CreateObject("Commence.DB") 'Application.Database 'CreateObject("Commence.DB")
Dim Conv
Set Conv = CommenceDB.GetConversation("Commence", "GetData")
Dim s
s = Conv.Request("[ClarifyItemNames(True)]")

Dim oxType
Set oxType = Form.Connection("Relates to", "reportType")
Set cAccount = CommenceDB.GetCursor(0, "Account", 0)


        If TabName = InitialTab Then
                ' Find out if we're in a subsidiary view via DDE
                sView = Conv.Request("[GetActiveViewInfo(|)]")  ' grabs a bunch of view related information
                MyArray = Split(sView, "|")             ' sticks view info into an array
                sView = MyArray(0)                              ' this grabs the view name from the array

                If IsAdd() Then
                        Select Case sView
                                Case "Report List Rep"
                                        u = CreateLink("Reports (Sales Rep)")
                                        oxType.SetConnection u(0), ""

                                Case "Report List Mgr"
                                        u = CreateLink("Reports (Sales Mgr)")
                                        oxType.SetConnection u(0), ""

                                Case "Report List Supp Mgr"
                                        u = CreateLink("Reports (Support Mgr)")
                                        oxType.SetConnection u(0), ""

                        End Select
                Else


                End If
        End If
Set Conv = Nothing
Set CommenceDB = Nothing

End Sub
 

Function CreateLink(pMultiViewName)
' this function will build help build a link to the parent record of a multiview
' when the user uses the add item click menu

        Const sDelim = "!"              ' GetActiveView Delimiter
        Const cDelim = " | "              ' Clarify Delimiter - this can change for each category
        Dim sView
        Dim MyArray
        Dim sItem
        Dim sClarify
        Dim CommenceDB
                Set CommenceDB = Application.Database 'CreateObject("Commence.DB")
        Dim Conv
                Set Conv = CommenceDB.GetConversation("Commence", "GetData")
        Dim s
                s = Conv.Request("[ClarifyItemNames(True)]")

                                ' this will make the header view the active view even though we're referencing the multiview
                                Conv.Execute "[ShowView(""" + pMultiViewName + """, 0)]"
                                sView = Conv.Request("[GetActiveViewInfo(""" + sDelim + """)]")
                                MyArray = Split(sView, sDelim)
                                sView = MyArray(3)

                                ' we need to parse out the results
                                ' get the item name first
                                MyArray = Split(sView, cDelim)
                                MyArray(0) = RTrim(MyArray(0))
                                MyArray(1) = RTrim(MyArray(1))
        CreateLink = MyArray
End Function
 

Sub Form_OnClick(ByVal ControlID)
        Dim f
        Dim timeScale
        If ControlID = "CommandButton3" Then
                Select Case Form.Field("reportKey").Value
                
'Type 1 graph
                'Monthly
                Case "Opportunity Graph"
                        timeScale = 1
                        f = CreateExcelReportForOpportunity(timeScale)
                Case "Revenue Graph"
                        timeScale = 1
                        f = CreateExcelReportForOpportunityRevenue(timeScale)
                Case "Ticket Graph"
                        timeScale = 1
                        f = CreateExcelReportForTicket(timeScale)
                'Weekly
                Case "Ticket Graph Weekly"
                        timeScale = 2
                        f = CreateExcelReportForTicket(timeScale)
        
'Type 2 graph
                Case "All Opportunity Graph"
                        f = AllOpportunityExcelReport()
                Case "All Revenue Graph"
                        f = AllOpportunityExcelReportRevenue()
                Case "All Ticket Graph"
                        f = AllTicketsExcelReport()
                        
'Type 3 graph
                Case "Opportunity Count Graph"
                        timeScale = 1
                        f = EmployeeOppReport(timeScale)
                Case "Revenue Based on Employees"
                        timeScale = 1
                        f = EmployeeOppRevenueReport(timeScale)
                Case "Ticket Count Graph"
                        timeScale = 1
                        f = EmployeeTicketReport(timeScale)
                ' Weekly
                Case "Ticket Count Graph Weekly"
                        timeScale = 2
                        f = EmployeeTicketReport(timeScale)
                End Select
        End If
End Sub


Function CreateCommenceReportLibrary()
    Dim clsScripts2
    Set clsScripts2 = CreateObject("CmcExcelReportLib.CmcChart")
    Set CreateCommenceReportLibrary = clsScripts2
End Function

Function CreateDictionary()
  Dim objDictionary
  Set objDictionary = CreateObject("Scripting.Dictionary")
  Set CreateDictionary = objDictionary
End Function

Function GetFormData(objDictionary)
  objDictionary.Add EXCEL_SHEET_TITLE, Form.Field("reportKey").Value
  objDictionary.Add CHART_DATE_START, CStr(Form.Field("StartDate").Value)
  objDictionary.Add CHART_DATE_END, CStr(Form.Field("EndDate").Value)
  Set GetFormData = objDictionary
End Function

Function BuildConnectionFilterString(conName, conCategory, nameField)
    Dim Employee
    Dim strEmployee
    Dim strFilterString
    Dim i
    'MsgBox ( "Connection name: " & conName & " Connection Cateogry: " & conCategory)
    Set Employee = Connection(conName, conCategory)
      For i = 1 To Employee.ConnectedItemCount
        Employee.CurrentSelection = i
        If i = 1 Then
          strEmployee = Employee.FieldValue(nameField)
        Else
          strEmployee = strEmployee & ".OR." & Employee.FieldValue(nameField)
        End If
      Next
    'strEmployee = "Employee.Support"
    strFilterString = strEmployee
    BuildConnectionFilterString = strFilterString
End Function


Function BuildFilterString4(deptment)
  Dim vFilterEmployee, FILEmployee
  vFilterEmployee = dquote(deptment)
  FILEmployee = "[ViewFilter(4, CTCF,, Relates to, Department, departmentKey, Equal to, " + vFilterEmployee + ")]"
  BuildFilterString4 = FILEmployee
End Function


'Refactored methods
' type 1 graphs
Function CreateExcelReportForOpportunity(timeScale)
  Dim nRtn
  Dim strReturn
 
  Dim objDictionary
  Set objDictionary = CreateDictionary()
  
  Dim calcType
  calcType = 1
 
  ' create dictionary
  Set objDictionary = SetDictionaryObjectsForType1Graph(objDictionary, calcType, timeScale)
  SetDicObjForOpportunity (objDictionary)
  SetDicObjForOpportunityCount (objDictionary)

  strReturn = clsScripts.MapParameters(CommenceDB, objDictionary)
  If strReturn <> "" Then
    MsgBox (strReturn)
  End If
  
  Set objDictionary = Nothing
End Function


' Type 1 graph
Function CreateExcelReportForOpportunityRevenue(timeScale)
  Dim nRtn
  Dim strReturn
  Dim calcType
  calcType = 2
    
  Dim objDictionary
  Set objDictionary = CreateDictionary()
  
  ' create dictionary
  Set objDictionary = SetDictionaryObjectsForType1Graph(objDictionary, calcType, timeScale)
  SetDicObjForOpportunity (objDictionary)
  SetDicObjForOpportunityRevenue (objDictionary)

  strReturn = clsScripts.MapParameters(CommenceDB, objDictionary)
  If strReturn <> "" Then
    MsgBox (strReturn)
  End If
  
  Set objDictionary = Nothing
End Function

Function CreateExcelReportForTicket(timeScale)
  Dim nRtn
  Dim strReturn
 
  Dim objDictionary
  Set objDictionary = CreateDictionary()
  
  Dim calcType
  calcType = 1
  
  ' create dictionary
  Set objDictionary = SetDictionaryObjectsForType1Graph(objDictionary, calcType, timeScale)
  SetDicObjForTicket (objDictionary)
  
  If timeScale = 1 Then ' monthly graph
        SetDicObjForTicketCount (objDictionary)
  Else
    SetDicObjTicketWeeklyCount (objDictionary)
  End If
  

  strReturn = clsScripts.MapParameters(CommenceDB, objDictionary)
  If strReturn <> "" Then
    MsgBox (strReturn)
  End If
  
  Set objDictionary = Nothing
End Function

Sub SetDicObjForOpportunity(objDictionary)
  objDictionary.Add CHART_CATEGORY, "Opportunity"
  objDictionary.Add CHART_DATE_FIELD, "enterDate"
  objDictionary.Add CHART_KEY_FIELD, "opportunityKey"
End Sub

Sub SetDicObjForOpportunityCount(objDictionary)
  objDictionary.Add EXCEL_TITLE, "Opportunities Per Month"
  objDictionary.Add EXCEL_YAXIS_TITLE, "Number of Opportunities"
  objDictionary.Add EXCEL_XAXIS_TITLE, "Month"
End Sub

Sub SetDicObjForOpportunityRevenue(objDictionary)
  objDictionary.Add CHART_CALCULATION_FORMAT, 2
  objDictionary.Add EXCEL_TITLE, "Revenue Per Month"
  objDictionary.Add EXCEL_YAXIS_TITLE, "Revenue"
  objDictionary.Add EXCEL_XAXIS_TITLE, "Month"
End Sub

Sub SetDicObjForTicket(objDictionary)
  objDictionary.Add CHART_CATEGORY, "Ticket"
  objDictionary.Add CHART_DATE_FIELD, "DateNew"
  objDictionary.Add CHART_KEY_FIELD, "ticketKey"
End Sub

Sub SetDicObjForTicketCount(objDictionary)
  objDictionary.Add EXCEL_TITLE, "Support Tickets Per Month"
  objDictionary.Add EXCEL_YAXIS_TITLE, "Number of Tickets"
  objDictionary.Add EXCEL_XAXIS_TITLE, "Month"
End Sub

Sub SetDicObjTicketWeeklyCount(objDictionary)
  objDictionary.Add EXCEL_TITLE, "Support Tickets Per Week"
  objDictionary.Add EXCEL_YAXIS_TITLE, "Number of Tickets"
  objDictionary.Add EXCEL_XAXIS_TITLE, "Week"
End Sub

Function SetDictionaryObjectsForType1Graph(objDictionary, calcType, timeScale)
  'Add dictionary structure and data
  Set objDictionary = GetFormData(objDictionary)
  objDictionary.Add CHART_TIMESCALE, timeScale ' MONTH, WEEK OR DATA
  
  If calcType = 2 Then
        objDictionary.Add CHART_CALCULATION, 2
        objDictionary.Add CHART_CALCULATION_FIELD, "potentialDollars"
  Else
        objDictionary.Add CHART_CALCULATION, 1
  End If

  objDictionary.Add CHART_TYPE, 1
  
  objDictionary.Add FILTER_CONNECTION_NAME, "Relates to"
  objDictionary.Add FILTER_CATEGORY, "Employee"
  objDictionary.Add FILTER_KEY_FIELD, "employeeKey"
   
  Dim filtString
  Dim conName, conCategory, conNameField
  conName = objDictionary.Item(FILTER_CONNECTION_NAME)
  conCategory = objDictionary.Item(FILTER_CATEGORY)
  conNameField = objDictionary.Item(FILTER_KEY_FIELD)
  filtString = BuildConnectionFilterString(conName, conCategory, conNameField)
  objDictionary.Add FILTER_KEY_VALUE, filtString
  
  Set SetDictionaryObjectsForType1Graph = objDictionary
End Function

' Refactored code
' Type 2 graph

Function AllOpportunityExcelReport()
  Dim nRtn
  Dim strReturn
 
  Dim objDictionary
  Set objDictionary = CreateDictionary()
  
  Dim department
  department = "Sales"
  
  Dim calcType
  calcType = 1
  
  Set objDictionary = SetDictionaryObjectsForType2Graph(objDictionary, calcType, department)
  SetDicObjForOpportunity (objDictionary)
  SetDicObjForYAxisOpportunity (objDictionary)
  SetDicObjForExcelOpportunityCount (objDictionary)
  
  strReturn = clsScripts.MapParameters(CommenceDB, objDictionary)
  If strReturn <> "" Then
    MsgBox (strReturn)
  End If
  
  Set objDictionary = Nothing
End Function

Function AllOpportunityExcelReportRevenue()
  Dim nRtn
  Dim strReturn
 
  Dim objDictionary
  Set objDictionary = CreateDictionary()

  Dim department
  department = "Sales"
  
  Dim calcType
  calcType = 2
   
  'Set objDictionary = SetDictionaryObjectsForAllOpportunitiesRevenue(objDictionary)
  Set objDictionary = SetDictionaryObjectsForType2Graph(objDictionary, calcType, department)
  SetDicObjForOpportunity (objDictionary)
  SetDicObjForYAxisOpportunity (objDictionary)
  SetDicObjForExcelOpportunitySum (objDictionary)
  
  strReturn = clsScripts.MapParameters(CommenceDB, objDictionary)
  If strReturn <> "" Then
    MsgBox (strReturn)
  End If
  
  Set objDictionary = Nothing

End Function

Function AllTicketsExcelReport()
  Dim nRtn
  Dim strReturn
 
  Dim objDictionary
  Set objDictionary = CreateDictionary()
  
  Dim department
  department = "Support"
  
  Dim calcType
  calcType = 1
    
  'Set objDictionary = SetDictionaryObjectsForAllTickets(objDictionary)
  Set objDictionary = SetDictionaryObjectsForType2Graph(objDictionary, calcType, department)
  SetDicObjForTicket (objDictionary)
  SetDicObjForYAxisTicket (objDictionary)
  SetDicObjForExcelTicketCount (objDictionary)
  
  strReturn = clsScripts.MapParameters(CommenceDB, objDictionary)
  If strReturn <> "" Then
    MsgBox (strReturn)
  End If
  
  Set objDictionary = Nothing
End Function


Function SetDictionaryObjectsForType2Graph(objDictionary, calcType, department)
  Set objDictionary = GetFormData(objDictionary)
   'Add dictionary structure and data
  ' Category and Field Details
  objDictionary.Add CHART_TYPE, 2
  
  If calcType = 2 Then
        objDictionary.Add CHART_CALCULATION, 2
        objDictionary.Add CHART_CALCULATION_FIELD, "potentialDollars"
  Else
        objDictionary.Add CHART_CALCULATION, 1
  End If
  
  objDictionary.Add EMPLOYEE_CONNECTION_NAME, "Relates to"
  objDictionary.Add EMPLOYEE_CATEGORY, "Employee"
  objDictionary.Add EMPLOYEE_KEY_FIELD, "employeeKey"
  Dim xaxisvalue
  
  'Reusing this values because both the connection names
  '( report as well as opportunity connection names to employee) are same
  Dim conName1, conCategory1, conNameField1
  conName1 = objDictionary.Item(EMPLOYEE_CONNECTION_NAME)
  conCategory1 = objDictionary.Item(EMPLOYEE_CATEGORY)
  conNameField1 = objDictionary.Item(EMPLOYEE_KEY_FIELD)
  xaxisvalue = BuildConnectionFilterString(conName1, conCategory1, conNameField1)

  objDictionary.Add EMPLOYEE_KEY_VALUE, xaxisvalue
     
  Set SetDictionaryObjectsForType2Graph = objDictionary
End Function

Sub SetDicObjForYAxisOpportunity(objDictionary)
  objDictionary.Add TYPE_CONNECTION_NAME, "Relates to"
  objDictionary.Add TYPE_CATEGORY, "oppType"
  objDictionary.Add TYPE_KEY_FIELD, "opptypeKey"
  
  Dim conName2, conCategory2, conNameField2, yaxisvalue
  conName2 = objDictionary.Item(TYPE_CONNECTION_NAME)
  conCategory2 = objDictionary.Item(TYPE_CATEGORY)
  conNameField2 = objDictionary.Item(TYPE_KEY_FIELD)
  yaxisvalue = BuildConnectionFilterString(conName2, conCategory2, conNameField2)

  objDictionary.Add TYPE_KEY_VALUE, yaxisvalue
End Sub

Sub SetDicObjForExcelOpportunityCount(objDictionary)
  objDictionary.Add EXCEL_TITLE, "Graph of Opportunity count"
  objDictionary.Add EXCEL_YAXIS_TITLE, "Number of Opportunities"
  objDictionary.Add EXCEL_XAXIS_TITLE, "Employees"
End Sub

Sub SetDicObjForExcelOpportunitySum(objDictionary)
  objDictionary.Add CHART_CALCULATION_FORMAT, 2
  objDictionary.Add EXCEL_TITLE, "Graph of Opportunity Revenue"
  objDictionary.Add EXCEL_YAXIS_TITLE, "Revenue"
  objDictionary.Add EXCEL_XAXIS_TITLE, "Employees"
End Sub

Sub SetDicObjForYAxisTicket(objDictionary)
  objDictionary.Add TYPE_CONNECTION_NAME, "Relates to"
  objDictionary.Add TYPE_CATEGORY, "TicketType"
  objDictionary.Add TYPE_KEY_FIELD, "ticketTypeKey"
  'objDictionary.Add TYPE_KEY_VALUE, ""
  
  Dim conName2, conCategory2, conNameField2, yaxisvalue
  conName2 = objDictionary.Item(TYPE_CONNECTION_NAME)
  conCategory2 = objDictionary.Item(TYPE_CATEGORY)
  conNameField2 = objDictionary.Item(TYPE_KEY_FIELD)
  yaxisvalue = BuildConnectionFilterString(conName2, conCategory2, conNameField2)
  objDictionary.Add TYPE_KEY_VALUE, yaxisvalue
End Sub

Sub SetDicObjForExcelTicketCount(objDictionary)
  objDictionary.Add EXCEL_TITLE, "Graphs for Ticket count"
  objDictionary.Add EXCEL_YAXIS_TITLE, "Number of Tickets"
  objDictionary.Add EXCEL_XAXIS_TITLE, "Employees"
End Sub


' Refactored Code
' Type 3 graph

Function EmployeeOppReport(timeScale)
  Dim nRtn
  Dim strReturn
  Dim objDictionary
  
  Dim department
  department = "Sales"
  
  Dim calcType
  calcType = 1
  
  Set objDictionary = CreateDictionary()
  'Set objDictionary = SetDictionaryObjectsForOpportunitiesEmployees(objDictionary)
  Set objDictionary = SetDictionaryObjectsForType3Graph(objDictionary, calcType, department, timeScale)
  SetDicObjForOpportunity (objDictionary)
  SetDicObjForOpportunityCount (objDictionary)

  strReturn = clsScripts.MapParameters(CommenceDB, objDictionary)
  If strReturn <> "" Then
    MsgBox (strReturn)
  End If

  Set objDictionary = Nothing

End Function

Function EmployeeOppRevenueReport(timeScale)
  Dim nRtn
  Dim strReturn

  Dim objDictionary
  Set objDictionary = CreateDictionary()
  
  Dim department
  department = "Sales"
  
  Dim calcType
  calcType = 2
     
  'Set objDictionary = SetDictionaryObjectsForOppRevenueEmployees(objDictionary)
  Set objDictionary = SetDictionaryObjectsForType3Graph(objDictionary, calcType, department, timeScale)
  SetDicObjForOpportunity (objDictionary)
  SetDicObjForOpportunityRevenue (objDictionary)
    
  strReturn = clsScripts.MapParameters(CommenceDB, objDictionary)
  If strReturn <> "" Then
    MsgBox (strReturn)
  End If
  
  Set objDictionary = Nothing
End Function

Function EmployeeTicketReport(timeScale)
  Dim nRtn
  Dim strReturn
 
  Dim objDictionary
  Set objDictionary = CreateDictionary()
  
  Dim department
  department = "Support"
  
  Dim calcType
  calcType = 1
    
  'Set objDictionary = SetDictionaryObjectsForTicketsEmployees(objDictionary)
  Set objDictionary = SetDictionaryObjectsForType3Graph(objDictionary, calcType, department, timeScale)
  SetDicObjForTicket (objDictionary)
  
  If timeScale = 1 Then ' monthly graph
        SetDicObjForTicketCount (objDictionary)
  Else
    SetDicObjTicketWeeklyCount (objDictionary)
  End If
  strReturn = clsScripts.MapParameters(CommenceDB, objDictionary)
  
  If strReturn <> "" Then
    MsgBox (strReturn)
  End If
  
  Set objDictionary = Nothing
End Function


Function SetDictionaryObjectsForType3Graph(objDictionary, calcType, department, timeScale)
   'Add dictionary structure and data
  Set objDictionary = GetFormData(objDictionary)
  objDictionary.Add CHART_TYPE, 3
  objDictionary.Add CHART_TIMESCALE, timeScale ' MONTH, WEEK OR DATA
  
  If calcType = 2 Then
        objDictionary.Add CHART_CALCULATION, 2
        objDictionary.Add CHART_CALCULATION_FIELD, "potentialDollars"
  Else
        objDictionary.Add CHART_CALCULATION, 1
  End If
    
  objDictionary.Add TYPE_CONNECTION_NAME, "Relates to"
  objDictionary.Add TYPE_CATEGORY, "Employee"
  objDictionary.Add TYPE_KEY_FIELD, "employeeKey"
  objDictionary.Add TYPE_KEY_VALUE, ""
    
  objDictionary.Add FILTER_CONNECTION_NAME, "Relates to"
  objDictionary.Add FILTER_CATEGORY, "Employee"
  objDictionary.Add FILTER_KEY_FIELD, "employeeKey"
  
  Dim filterValue
  'filterValue = BuildFilterString4(department)
  Dim conName, conCategory, conNameField
  conName = objDictionary.Item(FILTER_CONNECTION_NAME)
  conCategory = objDictionary.Item(FILTER_CATEGORY)
  conNameField = objDictionary.Item(FILTER_KEY_FIELD)
  filterValue = BuildConnectionFilterString(conName, conCategory, conNameField)
  objDictionary.Add FILTER_KEY_VALUE, filterValue
  
  Set SetDictionaryObjectsForType3Graph = objDictionary
End Function


' utility function to add "" around values used in filter strings
Function dquote(val)
  Dim squote
  squote = """"
  dquote = squote & val & squote
End Function

