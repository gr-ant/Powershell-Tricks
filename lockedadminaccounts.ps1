

Get-ADGroupMember -Identity "Domain Admins" -Recursive | Get-ADUser -Properties * | %{if($_.lockedout){email("$_.name is locked")}}