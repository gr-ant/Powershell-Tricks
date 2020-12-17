import-module ActiveDirectory
#imports Active Directory Module

function optionhelp(){
write-host "
Please select any of the following options:
Add User        =  a

Remove User  =  r
"
intro
}
#Help Function

function optionquery(){

$search =(read-host "

Search for a last name") + "*"

write-host "First Last  >  Username"

Get-ADUser -Filter {surname -like $search} | select givenname, surname, samaccountname | foreach-object { 

write-host $_.givenname, $_.surname, "> ",$_.samaccountname
}
#filters AD users by last name and returns possible matches in the format:   First, Last > Username
$returnvalue = (read-host "
Please Enter a username")

#Requests entry from User based on
write-host $returnvalue
return $returnvalue
continue
}
#queries AD users by last name, returns selection

function optioncreate(){

write-host "
Please fill out some user information:
"
$Given = read-host "First Name"
$surname = read-host "Last Name"
$name = "$given $surname"
$accountname = read-host "Username"
$jobtitle = read-host "Job Title"
#Collects User Information

$userprinciplename = $accountname + "@ad.pui.com"
$email = $accountname + "@pui.com"

write-host "

Select One of the following OUs...

"
Get-ADOrganizationalUnit -searchbase "OU=Accounts For Users,DC=ad,DC=pui,DC=com"-filter * -property * | select name | foreach-object {write-host $_.name}
#displays list of department OUs

$OUselection = read-host "What is the OU path.  For example: IT"
$OUPath = "OU=" + $OUselection+"," + "OU=Accounts For Users,DC=AD,DC=PUI,DC=COM"
#constructs OU path

$department = $OUselection.ToString()

New-ADUser -name $name -displayname $name -GivenName $given -Surname $surname -SamAccountName $accountname -UserPrincipalName $userprinciplename -Path $OUpath -AccountPassword( read-host -AsSecureString "What is the starting/default password for this account?") -Department $department -EmailAddress $email -Title $jobtitle -Enabled $true
#creates AD user based on inputed variables.  It allows you to set a starting password

#---> Add Security Groups<---
write-host "
Please select a user to copy permissions from:"
$copy = optionquery
#has operator select a user account for permissions copying

get-ADuser -identity $copy -properties memberof | select-object memberof -expandproperty memberof | Add-AdGroupMember -Members $accountname
#copies permissions to user

$result = get-ADuser -identity $copy -properties memberof | select-object memberof -expandproperty memberof
#displays resullts of security group transfer



$log = "$(Get-date),New-ADUser,$surname $given,$accountname,$(""" + $oupath + """),$copy,$env:username"
#creates log based on data
add-content \\VFPS01\I\Department\IT\Private\Logs\AD.txt $log

}
#creates a new user based on a series of inputs from operator

function optiondelete(){

$select = read-host "Would you like to:
 1 = Delete a user
 2 = Move them to No Longer Employed

 Selection "
 $userselection = optionquery
 #lets operator search for user account through last name

if ($select -eq "2"){
Get-ADUser $userselection | move-adobject -TargetPath "OU=No Longer Employed,OU=Accounts For Users,DC=AD,DC=PUI,DC=COM"
#moves user to No Longer Employed OU

Disable-ADAccount $userselection
#disables AD account
#$log = "Date = $(Get-Date) | Command = move-adobject | Username = $userselection| Target Path = OU=No Longer Employed,OU=Accounts For Users,DC=AD,DC=PUI,DC=COM  | Moved by $env:username"

$log = "$(Get-date),Move-ADObject,$($(get-aduser $userselection).surname) $($(get-aduser $userselection).givenname),$userselection,OU=No Longer Employed,OU=Accounts For Users,DC=AD,DC=PUI,DC=COM,NA,$env:username"
$log = "$(Get-date),Disable-ADAccount,$($(get-aduser $userselection).surname) $($(get-aduser $userselection).givenname),$userselection,OU=No Longer Employed,OU=Accounts For Users,DC=AD,DC=PUI,DC=COM,NA,$env:username"
#creates log for operation
add-content \\VFPS01\I\Department\IT\Private\Logs\AD.txt $log}

if ($select -eq "1"){
remove-aduser $userselection

#removes user from active directory

$log = "$(Get-date),Remove-ADUser,$($(get-aduser $userselection).surname) $($(get-aduser $userselection).givenname),$userselection,OU=No Longer Employed,OU=Accounts For Users,DC=AD,DC=PUI,DC=COM,NA,$env:username"
#creates log for operation

add-content \\VFPS01\I\Department\IT\Private\Logs\AD.txt $log
}}
#supplies options to delete a user, or move them to the No Longer Employed OU}


function intro(){
$selection = read-host -prompt "Please enter a command or type h for help"

if ($selection -eq "h"){optionhelp}
if ($selection -eq "a"){optioncreate}
if($selection -eq "r"){optiondelete}

}
#Requests a command from the User

intro
#calls intro function

<#
Title: Active Directory Powershell Tool
Author:  Grant Miller
Last Edit: 9/6/19
Pluto is a planet
#># Notes