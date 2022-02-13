# UsermakerPS
version 1.0  
Author: Gergo Viktor Kovacs  
Creation Date:  2021.10.23  

Run this script in a PowerShell v5.1 capable CLI.  
This .ps1 file will create users in Windows based on a .csv file.  
The columns in the .csv file must be built as follows: "Name","Fullname","Description","Password","Group"  
Details:  
  "Name" - the desired username. (Mandatory)  
  "Fullname" - The full name of the user. (Optional - leave as "" if not used)  
  "Description" - Any description deemed necessary. (Optional - leave as "" if not used)  
  "Password" - (Mandatory)  
  "Group" - Provide one group to add the user into, if it doesn't exist, one will be created. (Mandatory)
