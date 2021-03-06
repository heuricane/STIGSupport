<#
.SYNOPSIS
    Sets all NotReviewed in a CKL to Open

.DESCRIPTION
    Loads a CKL, and sets all Not_Reviewed to Open, then saves it

.PARAMETER CKLPath
    Full path to the CKL file
  
.EXAMPLE
    "Set-NRtoOpen.ps1" -CKLPath 'C:\CKLs\MyChecklist.ckl'
#>
Param([Parameter(Mandatory=$true)][ValidateScript({Test-Path -Path $_})][string]$CKLPath)

#Check if module imported
if ((Get-Module|Where-Object -FilterScript {$_.Name -eq "StigSupport"}).Count -le 0)
{
    #End if not
    Write-Error "Please import StigSupport.psm1 before running this script"
    return
}

#If pointing to a single CKL, set children to an array that only contains that one ckl
if ($CKLPath.EndsWith(".ckl"))
{
    $Children = @($CKLPath)
}
else
{
    #Otherwise, load all CKL files from that path and put it into an array
    $Files = Get-ChildItem -Path $CKLPath -Filter "*.CKL"
    $Children = @()
    foreach ($File in $Files)
    {
        $Children += $File.FullName
    }
    if ($Children.Length -eq 0)
    {
        Write-Error "No CKL files found in directory"
        return
    }
}

$I=0
Write-Progress -Activity "Setting CKLs" -PercentComplete (($I*100)/$Children.Length) -Id 1
#Loop through the CKL Files
foreach ($Child in $Children)
{
    $Name = $Child.Split("\")
    $Name = $Name[$Name.Length-1]
    Write-Progress -Activity "Setting CKLs" -PercentComplete (($I*100)/$Children.Length) -Id 1
    #Load the CKL file
    $CKLData = Import-StigCKL -Path $Child
    Write-Progress -Activity "$Name" -Status "Loading Stigs" -PercentComplete 0 -Id 2
    #Load the stig results from the CKL
    $Stigs = Get-VulnCheckResult -XMLData $CKLData
    #For each stig, that is "Not_Reviewed", set it to open
    Write-Progress -Activity "$Name" -Status "Starting Loop" -PercentComplete (($I*100)/$Children.Length) -Id 2
    $S =0
    foreach ($Stig in $Stigs)
    {
        Write-Progress -Activity "$Name" -Status "$($Stig.VulnID)" -PercentComplete (($S*100)/$Stigs.Length) -Id 2
        if ($Stig.Status -eq "Not_Reviewed" -or $Stig.Status -eq "NotReviewed")
        {
            Write-Host "$($Stig.VulnID) is being marked open"
            Set-VulnCheckResult -XMLData $CKLData -VulnID $Stig.VulnID -Result Open
        }
        $S++
    }
    #Save the ckl
    Export-StigCKL -XMLData $CKLData -Path $Child
    Write-Progress -Activity "$Name" -Status "Complete" -PercentComplete 100 -Id 2 -Completed
    $I++
}
Write-Progress -Activity "Setting CKLs" -PercentComplete 100 -Id 1 -Completed