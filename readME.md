# extract-mssql-result-by-time-to-csv-and-then-scp

A window batch file that query a local Microsoft SQL Server 2017 using SQL authentication. 
The results of the query will then be truncated into a .CSV format file and then send to a ssh enabled machine over SSH connection by utilizing PSCP.exe.
* This batch script is for interaction with MSSQL Only *
* This batch script is for timestamp only *

# Table of contents

- [Project Title](#project-title)
- [Table of contents](#table-of-contents)
- [Tested Environment](#tested-environment)
- [Installation](#installation)
	- [Initial Configuration](#initial-configuration)
- [License](#license)

# Tested Environment
[(Back to top)](#table-of-contents)

* Windows Server 2016	10.0.14393 Build 14393
* Microsoft SQL Server Express (64-bit) 13.0.4001.0

# Installation
[(Back to top)](#table-of-contents)

Download the required program

* PSCP.exe https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

Setting up required setting on windows to automate the script

1) Open up "Task Scheduler"
2) Right click on "Task Scheduler Library"
3) Create Task
4) Add a Task Name
5) Add a New Trigger
6) Select One Time or Daily
7) Add a New Action
8) Select "Start a program"
9) Select the .bat script file from [Browse...]						example: "C:\Users\Username\Desktop\MSScript\mssql.bat"
10) *Important* Add the folder location under [Start in(optional):]	example: C:\Users\Username\Desktop\MSScript\
11) Select "OK" to save the new task
12) Right click on the newly created task
13) "Enable" the new task
14) Right click on the newly created task again
15) "Run" the new task

Check to see if the script is running
1) Open up "Event Viewer"
2) Windows Logs > Application
3) Filter Current Log ...
4) Insert event id of "999"
5) The logs should contains Information Level with description of "Starting Script...", "PSCP Successful" & "Updated Last ID".


## Initial Configuration
[(Back to top)](#table-of-contents)

### Config.txt
The Configuration can be listed in any order, 

SQL_MACHINE=     	//Name of the machine that contains the SQL Server                                                                                               
SQL_USER=			//SQL account Username                                                                                                        
SQL_PASS=			//SQL account Password
SQL_DB=				//SQL database name
COUNTER_ID=			//The variable used to count
QUERY_FROM=         //Database Table Name              
QUERY_SELECT=		//Query Selected Columns
DELIMS=				//Delimiter used for CSV
SCPPORT=			//SSH PORT                                  
SCPPASS=			//User Password
URL=				//<username>@<ipaddress>:<Folder>

#### Example of the config.txt
```
SQL_MACHINE=WIN-LQTXXXXXXXV
SQL_USER=test
SQL_PASS=P@ssw0rd
SQL_DB=TEST
COUNTER_ID=AUDIT_EVENTS_ID
QUERY_FROM=[TEST].[dbo].[AUDIT_EVENTS]
QUERY_SELECT=AUDIT_EVENTS_ID,EVENT_TIMESTAMP,ACTOR,ACTOR_HOST,
DELIMS=,
SCPPORT=22
SCPPASS=P@ssw0rd
URL=test@192.168.1.116:Documents
```

### Counter.txt
*Check this .txt first if logs results is empty*

LASTID=YYYY-MM-DD HH:MM:SS.000     	//Contain the last timestamp that was successfully extracted and successfully SCP

#### Example of the Counter.txt
```
LASTID=2021-03-04 15:10:00.000		
```

### PSCP.txt //Can be ignore
```
logs.csv                  | 0 kB |   0.1 kB/s | ETA: 00:00:00 | 100%		//Contain the result of PSCP
```

# License
[(Back to top)](#table-of-contents)
GNU General Public License v3.0
kwtan@outlook.sg