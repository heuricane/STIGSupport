<#
.SYNOPSIS
    Attempts to convert a checklist in 1.x version to a compatible 2.6 version checklist

.DESCRIPTION
    Attempts to convert a checklist in 1.x version to a compatible 2.6 version checklist

.PARAMETER Source
    Full path to the CKL file to convert

.PARAMETER Destination
    Full path to the save location for the upgraded ckl
  
.EXAMPLE
    "Convert-ToNewCKLVersion.ps1" -Source 'C:\CKLs\MyChecklist.ckl' -Destination 'C:\CKLs\UpgradedMyChecklist.ckl'
#>
Param($Source, $Destination)
if ((Get-Module|Where-Object -FilterScript {$_.Name -eq "StigSupport"}).Count -le 0)
{
    #End if not
    Write-Error "Please import StigSupport.psm1 before running this script"
    return
}
$Content = Get-Content -Path $Source -Raw
$Content = $Content.Replace("<STIG_INFO>","<STIGS><iSTIG><STIG_INFO>").Replace("</CHECKLIST>","</iSTIG></STIGS></CHECKLIST>")
$Content = $Content -replace "<SV_VERSION>DISA STIG Viewer : .*</SV_VERSION>",""
$Content | Out-File $Destination
Repair-StigCKL -Path $Destination