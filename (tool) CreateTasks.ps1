function convert-day($day){

#converts string to system.dayofweek seemingly easier than other methods online :)

$list = @(([System.DayOfWeek].DeclaredFields | select -expandproperty name))

return [System.DayOfWeek]:: ($list[$list.IndexOf($day)])

}

function new-task($config){

$config | %{

$dayofweek = convert-day -day $_.day

    $time = [System.DateTime]$_.time
    
    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-file $_.path"

    $trigger = New-ScheduledTaskTrigger -weekly -WeeksInterval $_.freq -DaysOfWeek $dayofweek -At $time

    Register-ScheduledTask -Action $action  -Trigger $trigger  -TaskName $_.name -Description $_.desc.tostring()

}}

$config = import-csv -LiteralPath $psscriptroot\taskconfig.csv

new-task -config $config


