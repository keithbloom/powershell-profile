#See http://msdn.microsoft.com/en-us/library/cc281962.aspx

PowerShell -NoExit -Command "$HOME\Documents\WindowsPowerShell\InitializeSQLProvider.ps1"

cd SQLSERVER:\sql\`(local`)\SQLSERVER2008\Databases\StudyGlobal\Tables

$opts = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
$opts.ScriptDrops = $true
$tables = ls | where {$_.Schema -eq "SG"}
$tables | foreach {$_.ForeignKeys} |  foreach {$_.Script()} >> C:\Temp\CreateKeysScript.sql
$tables | foreach {$_.ForeignKeys} |  foreach {$_.Script($opts)} >> C:\Temp\DropKeysScript.sql