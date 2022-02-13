<#
.SYNOPSIS
  This script will create new userprofiles and groups based on a .csv file and add them into those groups if needed.
.DESCRIPTION
  First this script will create userprofiles with name, fullname, description and password. It won't overwrite existing users but instead display a warning message.
  After that it will try to add them into their respective groups but if a group doesn't exist yet, it will create it first.
.PARAMETER Param1
  -UserCsvPath
    Optional.
    Specify the path to the folder the .csv file is in using "". Only give the path to the folder without the name of the .csv file!
  -UserCsvName
    Optional.
    Specify the exact name (without the path) of the .csv file with the extension included using "".
.INPUTS
  The script will ask for the name and the path of the .csv file seperately based on if parameters were given.
.OUTPUTS
  This script doesn't create a logfile
.NOTES
  Version:        1.0
  Author:         Kovacs Gergo Viktor
  Creation Date:  2021.10.23
  Purpose/Change: Creation of a new script to help create new users.
.EXAMPLE
------- Example: Run the script giving the path and the name for the .csv file using parameters. --------
  UserMakerFull -UserCsvPath "D:\example\newusers\" -UserCsvName "NewUsersExample.csv"
#>

#requires -version 5.1

#-----------------------------------------------------------[Parameters]-----------------------------------------------------------
[CmdletBinding()]
param (
    [Parameter()]
    [string]$UserCsvPath,
    [Parameter()]
    [string]$UserCsvName
)
#---------------------------------------------------------[Initialisations]--------------------------------------------------------
$CompInfo = Get-ComputerInfo
#----------------------------------------------------------[Declarations]----------------------------------------------------------

if ($UserCsvPath -eq "") {
    $UserCsvPath = Read-Host "Please provide the path to the folder containing the .csv file with the user-list!"
}
if ($UserCsvName -eq "") {
    $UserCsvName = Read-Host "Please provide the name of the .csv file containing the user-list!"
}
#-----------------------------------------------------------[Functions]------------------------------------------------------------
if (Test-path $UserCsvPath) {
    if (Test-path (Join-Path $UserCsvPath $UserCsvName)) {        
        $choice = @('&no', '&yes')
        $warn1 = $host.UI.PromptForChoice("Create users from provided .csv file", "Are you sure?", $choice, 0)
        if ($warn1 -eq $true) {
            $usercsv = Import-Csv -path (Join-Path $UserCsvPath $UserCsvName)
#-----------------------------------------------------------[Execution]------------------------------------------------------------
            foreach ($user in $usercsv) {
                if ((Get-LocalUser -Name * | Select-Object name).name.contains($user.name)) {
                    Write-Host "The user -$($user.name)- already exists!"
                }
                else {                    
                    New-LocalUser -Name $user.Name -FullName $user.FullName -Description $user.Description -Password (ConvertTo-SecureString $user.Password -AsPlainText -force) 
                    Write-host "User profile -$($user.name)- created succesfully"     
                }
            }
            foreach ($user in $usercsv) {
                if ((Get-LocalGroup | Select-Object Name).name.contains($user.group) -eq $false) {
                    New-LocalGroup -name $user.Group 
                    Write-Host "-$($user.group)- group created succesfully!"
                    Add-LocalGroupMember -Group $user.Group -Member $user.Name
                    Write-host "The user -$($user.name)- became a member of -$($user.Group)-"
                }
                else {
                    if ((Get-LocalGroupMember -Group $user.group).Name.contains($CompInfo.CsName + '\' + $user.name)) {
                        Write-Host "The user -$($user.name)- is already a member of -$($user.Group)-"
                    }
                    else {
                        Add-LocalGroupMember -Group $user.Group -Member $user.Name
                        Write-host "The user -$($user.name)- became a member of -$($user.Group)-" 
#-----------------------------------------------------------[Finish up]------------------------------------------------------------
                    }
                }
            }                              
        }
        else {
            Write-Host "User creation aborted!"
        }
    }
    else {
        Write-Host ".csv file not found!"
        Write-Host "Please make sure that you have given the correct filename and path!"
    }
}
else {
    Write-Host "The path specified does not exist!"
}


