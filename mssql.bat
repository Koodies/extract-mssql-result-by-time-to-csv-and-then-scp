@ECHO OFF
EVENTCREATE /T INFORMATION /ID 999 /L APPLICATION /D "Starting Script ..."

REM set configurations from config.txt & counter.txt
for /f "delims=" %%x in (config.txt) do (SET "%%x")
for /f "delims=" %%y in (counter.txt) do (SET "%%y")

REM fetch the latest ID
SET QUERY1="set nocount on;select TOP 1 %COUNTER_ID% FROM %QUERY_FROM% ORDER BY %COUNTER_ID% DESC"
for /f %%a in ('sqlcmd -b -W -S %SQL_MACHINE% -U %SQL_USER% -P %SQL_PASS% -d %SQL_DB% -Q %QUERY1% -h -1') do SET LATESTID=%%a

if %ROWS% EQU 0 (goto fetch_unlimited) else (goto fetch_with_limit)
goto Exit


:fetch_unlimited

SET UNTIL=%LATESTID%

REM fetch results between the last fetched Id and the latest ID
SET UNLIMITED="set nocount on;select %QUERY_SELECT% FROM %QUERY_FROM% WHERE %COUNTER_ID% > %LASTID% AND %COUNTER_ID% <= %UNTIL% ORDER BY %COUNTER_ID% ASC"
SQLCMD -s%delims% -b -W -S %SQL_MACHINE% -U %SQL_USER% -P %SQL_PASS% -d %SQL_DB% -Q %UNLIMITED% | findstr /v /c:"-" /b > "logs.csv"
if ERRORLEVEL 1 ( goto err_handler ) else ( goto pscp )
goto Exit

:fetch_with_limit

REM Check for differences of 1000 between the last ID and latest ID
SET /a DIFF= %LATESTID% - %LASTID%
if %DIFF% LSS %ROWS% (set UNTIL=%LATESTID%) else (set /a UNTIL=%LASTID%+%ROWS%)

REM fetch results between the last fetched Id and the latest ID
SET LIMITED="set nocount on;select TOP %ROWS% %QUERY_SELECT% FROM %QUERY_FROM% WHERE %COUNTER_ID% > %LASTID% AND %COUNTER_ID% <= %UNTIL% ORDER BY %COUNTER_ID% ASC"
SQLCMD -s%delims% -b -W -S %SQL_MACHINE% -U %SQL_USER% -P %SQL_PASS% -d %SQL_DB% -Q %LIMITED%  | findstr /v /c:"-" /b > "logs.csv"
if ERRORLEVEL 1 ( goto err_handler ) else ( goto pscp )
goto Exit

REM Attempt to PSCP
:pscp
for /f "tokens=5* delims=|" %%b in ('pscp -P %SCPPORT% -pw %SCPPASS% logs.csv %URL%') do SET PSCP=%%b
ECHO %PSCP% | FIND /I "100%%">Nul && ( goto updateConfigFile ) || ( goto pscp_handler )
goto Exit

REM Logging SQL Error into event log
:err_handler
EVENTCREATE /T ERROR /ID 999 /L APPLICATION /D "Error on SQL Query"
goto Exit

REM Log fail to PSCP into event log
:pscp_handler
EVENTCREATE /T ERROR /ID 999 /L APPLICATION /D "Error on PSCP"
goto Exit

REM update and overwrite last id in counter.txt
:updateConfigFile
EVENTCREATE /T INFORMATION /ID 999 /L APPLICATION /D "PSCP Successful"
ECHO LASTID=%UNTIL% > "counter.txt"
EVENTCREATE /T INFORMATION /ID 999 /L APPLICATION /D "Updated last ID"
goto Exit

:Exit
EXIT