/*
********** settings, variable declarations **********
*/

#SingleInstance Force
#NoEnv
#NoTrayIcon
OnExit, quit

programName = TinyLog
programVersion = 0.2
programFullName = %programName% v%programVersion%
programAuthor = OC

configFile = TinyLog.ini

/*
********** auto-execute section **********
*/

; getSettings
GoSub, getSettings
; process command line parameters
GoSub, getParams
; get current time
GoSub, getTime
; write to log file
GoSub, writeLog
; terminate script
GoSub, quit
Return

/*
********** subroutines **********
*/

; process command line parameters
getParams:
	If 0 = 1 ; check if there is a single parameter
	{
		desc = %1%
	}
	Else
	{
		GoSub, quit
	}
Return

; write to log file
writeLog:
   ; check for invalid chars
   checkValidity(desc, "Description")
   
   ; create log file with column headings if it doesn't exist already
   If (addSpace = True)
   {
      separator := " " . separator . " "
   }
   
   IfNotExist, %logFile%
      FileAppend
         , % timestampHeading . separator . descHeading . "`n"
         , %lfModifier%%logFile%
		 
   ; write to file
   FileAppend
      , % timestamp . separator . desc . "`n"
      , %lfModifier%%logFile%
Return

; get current time
getTime:
   If (useUTC = True)
   {
      FormatTime, timestamp, %A_NowUTC%, %timeFormat%
   }
   Else
   {
      FormatTime, timestamp, %A_Now%, %timeFormat%
   }
Return

; read user settings
getSettings:
   ; create config file if it does not exist yet
   IfNotExist, %configFile%
      GoSub, writeSettings
	  
   ; read settings from file
   IniRead, logFileBase, %configFile%, logFiles, logFileBase
   IniRead, logFileExt, %configFile%, logFiles, logFileExt
   IniRead, unixMode, %configFile%, CsvFormat, unixMode
   IniRead, useUTC, %configFile%, CsvFormat, useUTC
   IniRead, timeFormat, %configFile%, CsvFormat, timeFormat
   IniRead, separator, %configFile%, CsvFormat, separator
   IniRead, addSpace, %configFile%, CsvFormat, addSpace
   IniRead, timestampHeading, %configFile%, columnHeadings, timestamp
   IniRead, descHeading, %configFile%, columnHeadings, desc
   
   ; convert True/False strings to actual boolean values
   stringToBoolean(skipTimestamp)
   stringToBoolean(unixMode)
   stringToBoolean(useUTC)
   stringToBoolean(addSpace)
   
   ; process settings
   logFile = %logFileBase%.%logFileExt%
   If (unixMode = True)
      lfModifier = * ; use Unix mode for linefeeds (LF)
   Else
      lfModifier = ; use Windows mode for linefeeds (CR+LF)
Return

; write user settings
writeSettings:
   IniWrite, TinyLog, %configFile%, logFiles, logFileBase
   IniWrite, txt, %configFile%, logFiles, logFileExt
   IniWrite, False, %configFile%, csvFormat, unixMode
   IniWrite, False, %configFile%, csvFormat, useUTC
   IniWrite, dd/MM/yyyy HH:mm, %configFile%, csvFormat, timeFormat
   IniWrite, |, %configFile%, csvFormat, separator
   IniWrite, True, %configFile%, csvFormat, addSpace
   
   ; log file format
   IniWrite, Timestamp, %configFile%, columnHeadings, timestamp
   IniWrite, Description, %configFile%, columnHeadings, desc
Return

; check for invalid chars
checkValidity(ByRef var, varTitle)
{
   Global separator
   Global programName
   
   If var Contains %separator%
   {
      MsgBox, 0, %programName%,
         ( LTrim
            Error: %varTitle% contains column separator.
            Respective characters will be removed automatically.
         )
      cleanse(var, "")
   }
}

; remove potentially problematic chars
cleanse(ByRef string, cleanChar)
{
   ; remove column separators
   Global separator
   StringReplace, string, string, %separator%, %cleanChar%, All
}

; convert True/False strings to actual boolean values
stringToBoolean(ByRef var)
{
   If var = True
      var := True
   Else
      var := False
}

; terminate script
quit:
   ExitApp
Return
