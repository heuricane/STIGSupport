# General Usage Information
All the scripts assume your powershell session has the module imported. Ensure you import it first!

## Import the module
```
Import-Module "<PathtoPSM1>"
```

## Folder Structure
- Module: Module required for all scripts
- Utility: Misc. utilities to facilitate work with CKL files.

## Utilities
### Convert-XCCDFtoCKL.ps1
Converts an XCCDF file (Output from SCAP) to a CKL file for further processing
Use the STIG viewer application to create a blank CKL file. That will be used for the TemplateCKLPath
```
&"Convert-XCCDFtoCKL.ps1" -TemplateCKLPath "<Path to blank ckl>" -STIGName "<STIG name to filter XCCDF files to like U_Windows_2012_and_2012_R2_MS_V2R7_STIG>" -SaveDirectory "<A direcotry to save the results to>" [-XCCFPath "<Optional path to XCCF files directory. If not set, will auto set to %USERPROFILE%\SCC\RESULTS\SCAP The default directory>"]
```

### Report on Open checks
Saves a CSV file containing more detailed information on open checks
```
&"Export-OpenStigData.ps1" -CKLDirectory <Path to a folder containing all your CKL files> -SavePath <Path to a csv file to save>
```

### Set-NRtoOpen.ps1
This script will set any checks for a CKL file from Not_Reviewed to Open
```
&"Set-NRtoOpen.ps1" -CKLPath <Path to the CKL file to edit>
```

### Export-MetricsReport.ps1
This script will output several CSV files containing general metrics on stig progress. Note that the directory tree that your CKL files are in, must be in a certain format!
```
&"Export-MetricsReport.ps1" -CKLDirectoryPath <Path to parent of CKL folders> -SavePath <Path to save CSV reports>
```
#### Directory Tree
```
Parent
   |-IIS
   |  |-IIS Server 1.ckl
   |  |-IIS Server 2.ckl
   |
   |-DNS
      |-DNS Server 1.ckl
```
Running the script against that directory for the Parent folder, would output 2 csv files. One named "IIS.csv" and the other named "DNS.csv".

### Export-POAMData.ps1
Script will run through a target directory and build a collection of CKL files. From there it will parse them and find all checks that are set to Open or Not Reviewed and add each to an object. End result is a CSV file that can be used to copy and pasted bulk POA&M data into a provided template.
```
"Export-POAMData.ps1" -CKLDirectory <path to desired CKLs> -SavePath <Desired path and filename.csv>
```

### Convert-ToNewCKLVersion.ps1
Attempts to convert a checklist in 1.x version to a compatible 2.6 version checklist. This has had limited testing and may not work, but is worth a shot.
```
"Convert-ToNewCKLVersion.ps1" -Source 'C:\CKLs\MyChecklist.ckl' -Destination 'C:\CKLs\UpgradedMyChecklist.ckl'
```

# Module Functions

## Export-StigCKL 
 Saves a loaded CKL file to disk
```
Export-StigCKL -CKLData $CKLData -Path "C:\CKLs\MyCKL.ckl" Export-StigCKL -CKLData $CKLData -Path "C:\CKLs\MyCKL.ckl" -AddHostData
```

## Get-CKLHostData 
 Gets the host information from the CKLData
```
Get-CKLHostData -CKLData $CKLData
```

## Get-StigInfoAttribute 
Gets a stig info attribute, literally value of a "SI_DATA" under the "STIG_INFO" elements from the XML data of the CKL. This contains general information on the STIG file itself. (Version, Date, Name)
```
Get-StigInfoAttribute -CKLData $CKLData -Attribute "Version"
```

## Get-StigMetrics 
 Returns a complex object of metrics on the statuses of the checks in the specified directory.
```
Get-StigMetrics -CKLDirectory "C:\CKLS\"
```
### Return object format
```
This is an example showing the format of this function's output. This function will display different views of the same data.
@{
   IndividualVulnScores=@(
      [PSCustomObject]@{NotAFinding=1;Open=0;NotReviewed=0;NotApplicable=0;VulnID="V-00000"},
      [PSCustomObject]@{NotAFinding=0;Open=1;NotReviewed=0;NotApplicable=0;VulnID="V-00001"},
      [PSCustomObject]@{NotAFinding=0;Open=0;NotReviewed=0;NotApplicable=1;VulnID="V-00002"}
   );
   CategoryScores=@{
      Cat1=[PSCustomObject]@{Total=200; NotApplicable=50; NotReviewed=50; Open=50; NotAFinding=50;UniqueTotal=200};
      Cat2=[PSCustomObject]@{Total=200; NotApplicable=50; NotReviewed=50; Open=50; NotAFinding=50;UniqueTotal=200};
      Cat3=[PSCustomObject]@{Total=200; NotApplicable=50; NotReviewed=50; Open=50; NotAFinding=50;UniqueTotal=200};
   };
   TotalFindingScores=[PSCustomObject]@{Total=200; NotApplicable=50; NotReviewed=50; Open=50; NotAFinding=50}
}
```

## Get-VulnCheckResult 
 Gets the status of a single vuln check, or an array of the statys of all vuln checks in a CKL
```
Get-VulnCheckResult -CKLData $CKLData -VulnID "V-11111"
```

## Get-VulnFindingAttribute 
 Gets a vuln's finding attribute (Status, Comments, Details, etc)
```
Get-VulnFindingAttribute -CKLData $CKLData -VulnID "V-1111" -Attribute "COMMENTS"
```

## Get-VulnIDs 
 Returns all VulnIDs contained in the CKL
```
Get-VulnIDs -CKLData $CKLData
```

## Get-VulnInfoAttribute 
 Gets a vuln's informational attribute
```
Get-VulnInfoAttribute -CKLData $CKLData -Attribute "Version"
```

## Get-XCCDFHostData 
 Gets host info from XCCDF
```
Get-XCCDFHostData -XCCDF $XCCDFData
```

## Get-XCCDFResults 
 Returns stig results from an XCCDF file
```
Get-XCCDFResults -XCCDF (Import-XCCDF -Path C:\XCCDF\Results.xml)
```

## Import-StigCKL 
 Load a CKL file as an [XML] element. This can then be passed to other functions in this module.
```
Import-StigCKL -Path "C:\CKLs\MyCKL.ckl"
```

## Import-XCCDF 
Load an XCCDF file into a [xml]
```
Import-XCCDF -Path C:\XCCDF\Results.xml
```

## Merge-CKLData 
 Merges two loaded CKLs
```
Merge-CKLData -SourceCKL $OriginalInfo -DestinationCKL $NewCKL
```

## Merge-CKLs 
 Merges two CKL files and saves it as a new CKL. Largely a wrapper around Merge-CKLData.
```
Merge-CKLs -DestinationCKLFile "C:\CKLS\Blank.ckl" -DestinationCKLFile "C:\CKLS\Answered.ckl" -SaveFilePath "C:\CKLS\Merged.ckl" Merge-CKLs -DestinationCKLFile "C:\CKLS\Blank.ckl" -DestinationCKLFile "C:\CKLS\Answered.ckl" -SaveFilePath "C:\CKLS\Merged.ckl" -IncludeNR
```

## Merge-XCCDFHostDataToCKL 
 Adds XCCDF host info into a loaded CKL data
```
Merge-XCCDFHostDataToCKL -CKLData $CKLData -XCCDF $XCCDFData
```

## Merge-XCCDFToCKL 
 Adds XCCDF results into a loaded CKL data
```
Merge-XCCDFToCKL -CKLData $CKLData -XCCDF $XCCDFData
```

## Repair-StigCKL 
 Opens and resaves a CKL, may fix formatting issues
```
Repair-StigCKL -Path "C:\CKLs\MyCKL.ckl"
```

## Set-CKLHostData 
 Sets host data in CKL. If any parameters are blank, they will be set to running machine
```
Set-CKLHostData -CKLData $CKLData Set-CKLHostData -CKLData $CKLData -Host "SomeMachine" -FQDN "SomeMachine.Some.Domain.com" -Mac "00-00-00-..." -IP "127.0.0.1"
```

## Set-VulnCheckResult 
 Sets the findings information for a single vuln
```
Set-VulnCheckResult -CKLData $CKLData -VulnID "V-11111" -Details "Not set correctly" -Comments "Checked by xyz" -Result Open
```

## Set-VulnCheckResultFromRegistry 
 Sets a vuln status based on a registry check
```
Set-VulnCheckResultFromRegistry -CKLData $CKLData -RegKeyPath "HKLM:\SOFTWARE\COMPANY\DATA" -RequiredKey "PortStatus" -RequiredValue "Closed" -Comments "Checked by asdf"
```

## Set-VulnFindingAttribute 
 Sets a vuln's finding attribute (Status, Comments, Details, etc)
```
Set-VulnFindingAttribute -CKLData $CKLData -VulnID "V-1111" -Attribute "COMMENTS" -Value "This was checked by script"
```
