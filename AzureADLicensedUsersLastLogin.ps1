<# The purpose of this script is to query AzureAD for licensed user accounts and pull the last logon time.
If a multi-factored account is being used, the 'AzureADPreview\Connect-AzureAD' command must be run in the PowerShell session prior to the script being run, otherwise uncomment line 15.
The credentials provided must be an Azure AD administrator account.

The following are dependencies that should be installed prior to running the script.
	Install-Module -Name Msonline
	Install-Module -Name AzureAD
		Ensure version 2.0.2.130 or highger by using "Get-InstalledModule -name Azure*"
	Install-Module -AllowClobber -Name AzureADPreview #>


Import-Module -Name Msonline
Import-Module -Name AzureAD
Import-Module -Name AzureADPreview

# AzureADPreview\Connect-AzureAD
Connect-MsolService

$Users = Get-MsolUser -All | where {$_.isLicensed -eq $true}
$Headers = "DisplayName`tUserPrincipalName`tLicense`tLastLogon" >> C:\Temp\Users.tsv
ForEach ($User in $Users)
    {
    $UPN = $User.UserPrincipalName.ToLower()
    $LoginTime = Get-AzureADAuditSignInLogs -top 1 -filter "userprincipalname eq '$UPN'" | select CreatedDateTime
   	$NewLine = $User.DisplayName + "`t" + $User.UserPrincipalName + "`t" + $User.Licenses.AccountSkuId + "`t" + $LoginTime.CreatedDateTime
   	$NewLine >> C:\Temp\Users.tsv
    }