$90Days = (get-date).adddays(-90)
#get list of users inactive for 90 days
$list = Get-ADUser -properties * -filter {(lastlogondate -notlike "*" -OR lastlogondate -le $90days) -AND (passwordlastset -le $90days) -AND (enabled -eq $True) -and (PasswordNeverExpires -eq $false) -and (whencreated -le $90days)} | select-object name,lastlogondate
#Disable accounts innactive for 90 days
$disable = Get-ADUser -properties * -filter {(lastlogondate -notlike "*" -OR lastlogondate -le $90days) -AND (passwordlastset -le $90days) -AND (enabled -eq $True) -and (PasswordNeverExpires -eq $false) -and (whencreated -le $90days)} |select -expandproperty samaccountname
#$disable | %{Get-ADUser -Identity $_ | Disable-ADAccount}
#send email containing inactive accounts
if(@($list | select -ExpandProperty name).Length -gt 0){
email()
}