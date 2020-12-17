#list of approved admin accounts
$approved = @()

#gets domain admin accounts and compares approved list to actual list
get-adgroupmember 'domain admins' | select -ExpandProperty name | %{ 
if ( $approved -contains $_ ){}

else{

#retrieves active directory user information for unnaproved account
$data = Get-ADUser -Filter ('name -eq '+"'"+ $_+"'")|Out-String


