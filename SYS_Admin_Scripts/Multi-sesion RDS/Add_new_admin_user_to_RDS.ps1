<#
.SYNOPSIS
    ** Automated sync Domian-Admins from AD to use RDS. **

.DESCRIPTION
    This script auto syncs users from AD in Domain-Admins OU to use RDS on Test windows VM

.NOTES
    Use PWSH automation for easier life

.BY
       .---.
      /     \
      \.@-@./
      /`\_/`\
     //  _  \\
    | \     )|_
   /`\_`>  <_/ \
   \__/'---'\__/
   CVIBA ADMIN
#>

# ===========================================
# SYNC ALL USERS FROM OU TO LOCAL RDP GROUP #
# ===========================================

# Domain parameters
$Domain = "k8s.local"
$OU = "OU=Domain-Admins,DC=k8s,DC=local"  

Write-Host "Retrieving all users from OU: $OU..."
Import-Module ActiveDirectory

try {
    $ouUsers = Get-ADUser -SearchBase $OU -Filter * | Select-Object -ExpandProperty SamAccountName
} catch {
    Write-Error "Failed to retrieve users. Check AD module and OU DN."
    exit
}

foreach ($username in $ouUsers) {
    $userPrincipal = "$Domain\$username"
    Write-Host "Adding $userPrincipal to local Remote Desktop Users group..."
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member $userPrincipal -ErrorAction SilentlyContinue
}

Write-Host "============================================================="
Write-Host "#  DONE! All users from $OU synced to local RDP users group.#"
Write-Host "#  RDP access ready for new members.                        #"
Write-Host "============================================================="