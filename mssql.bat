@ECHO OFF
EVENTCREATE /T INFORMATION /ID 999 /L APPLICATION /D "Starting Script ..."

REM set configurations from config.txt & counter.txt
for /f "delims=" %%x in (config.txt) do ( SET "%%x" )
for /f "delims=" %%y in (counter.txt) do ( SET "%%y" )

REM fetch the latest ID
SET QUERY1="set nocount on;select TOP 1 %COUNTER_ID% FROM %QUERY_FROM% WHERE %COUNTER_ID% < CURRENT_TIMESTAMP ORDER BY %COUNTER_ID% DESC"
for /f "tokens=*" %%c in ('SQLCMD -b -W -S %SQL_MACHINE% -U %SQL_USER% -P %SQL_PASS% -d %SQL_DB% -Q %QUERY1% -h -1') do ( SET LATEST=%%c )

REM fetch results between the last fetched Id and the latest ID
SET UNLIMITED="set nocount on;select %QUERY_SELECT% FROM %QUERY_FROM% WHERE %COUNTER_ID% > '%LASTID%' AND %COUNTER_ID% <= '%LATEST%' ORDER BY %COUNTER_ID% ASC"
SQLCMD -s%delims% -b -W -S %SQL_MACHINE% -U %SQL_USER% -P %SQL_PASS% -d %SQL_DB% -Q %UNLIMITED% | findstr /v /c:"-" /b > "logs.csv"
if ERRORLEVEL 1 ( goto err_handler ) else ( goto pscp )
goto Exit

REM Attempt to PSCP
:pscp
pscp -P %SCPPORT% -pw %SCPPASS% logs.csv %URL% > "PSCP.txt"
FIND "100%%" PSCP.txt >Nul && ( goto updateConfigFile ) || ( goto pscp_handler )
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
ECHO LASTID=%LATEST% > "counter.txt"
EVENTCREATE /T INFORMATION /ID 999 /L APPLICATION /D "Updated last ID"
goto Exit

:Exit
EXIT