


<#$servers = Get-ADcomputer -Filter * | where{$_.distinguishedName -like "*Servers*" -and $_.enabled -eq "True"} | select -ExpandProperty name

#query active directory for a list of servers

$servers | %{

#for each server

$server = $_
Get-ScheduledTask -CimSession $server | select taskname,taskpath | Export-Clixml -LiteralPath ('')

#grab scheduled tasks and export them to the network drive.  The tasks are saved as powershell objects in xml format, the only reliable way to access them is through "import-clixml"

}
#>
#------------------------------------------------------------------------------------------------------------------
$servers = ()
$body = "Unidentified Tasks:`n`nserver,taskname `n"
$servers | %{
    $server = $_.basename
    Get-ScheduledTask -CimSession $server | select taskname,taskpath | Export-Clixml -LiteralPath ("\\vfps01\I\Department\IT\Public\ServerTasksTemp\$server.xml")
    }

$servers | %{
    $SERVER = $_

    $reference = Import-Clixml -LiteralPath 
    $difference = Import-Clixml -LiteralPath

    $result = Compare-Object -ReferenceObject $reference -DifferenceObject $difference -Property taskname

    $result | select -expandproperty taskname | %{$body += (($server -replace ".xml","") + "," + $_ + "`n")}
    }
    email($body)