

$email = "" #string variable for email draft

$DCs = Get-ADDomainController -Filter *

#Grab the domain controllers


$startDate = (get-date).AddDays(-30)

#Set date variable


foreach ($DC in $DCs){

#for each domain controller

$slogonevents = Get-Eventlog -LogName Security -ComputerName $DC.Hostname -after $startDate | where {$_.eventID -eq 4624 }}

#collect logs for specified date and event ID

$email += "Time, Username, Computername, IP `n"

#create top line of CSV formatted string

$lastday = "" #Define variable to store previous date iteration

  foreach ($e in $slogonevents){write-host $e
  
  #For each event

    if (($e.EventID -eq 4624 ) -and ($e.ReplacementStrings[8] -eq 10)){# -or $e.ReplacementStrings[8] -eq 2
    
    
    #if logon event and login type 10
      
      if ($e.TimeGenerated.TimeOfDay.TotalMinutes -lt 360 -and $e.TimeGenerated.TimeOfDay.TotalMinutes -gt 1200){
      
        #If logon time is before 6 and after 8
        
        if($lastday.ToString() -eq $e.TimeGenerated.Dayofweek.ToString() + $e.TimeGenerated.DayOfYear){
        
        #if the last log is the same day as the current log (This is done so that days are grouped in the final result)
                
        $email += ( ($e.TimeGenerated.ToString()+","+ $e.ReplacementStrings[5].ToString()+","+ $e.ReplacementStrings[11].tostring()+","+$e.ReplacementStrings[18].ToString() + "`n"))}
        
        #Adds a line of event information to the $email string with a `n new line at the end
        
        else{$email += ( ("`n" + $e.TimeGenerated.ToString()+","+ $e.ReplacementStrings[5].ToString()+","+ $e.ReplacementStrings[11].tostring()+","+$e.ReplacementStrings[18].ToString() + "`n"))
        
        #adds a line of event information to the $email string with a `n at the beginning and end
        
        $lastday = $e.TimeGenerated.Dayofweek.ToString() + $e.TimeGenerated.DayOfYear.ToString()
        
        #sets the variable $lastday so it can be referenced in the first part of the statement
        }
        }
    }}

     write-host $email.Length
     if($email.Length -gt 5){email($email)}
   
   #Sends an email with the contents #email (rest of the information can be set in the function