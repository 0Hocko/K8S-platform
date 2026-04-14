<#
.SYNOPSIS
   Rewrite for Spintec. Source code from : https://github.com/captainqwerty/AutomatedOutlookSignature
.DESCRIPTION
  This script uses properties from ActiveDirectory to populate the .htm and .txt file which are then stored in the $folderlocation with the name $filename.htm and $filename.txt. 
  The script can be ran as either a scheduled task at logon or preferably a Group Policy Logon script, more details on this can be found in the ReadMe.txt.
  
.NOTES
    Coffee == Life
    Made by SysAdmin CVIBA

       .---.
      /     \
      \.@-@./
      /`\_/`\
     //  _  \\
    | \     )|_
   /`\_`>  <_/ \
   \__/'---'\__/

#>

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['Get-Content:Encoding'] = 'utf8'

# Get data from AD. If user does not exist script goes to error
try {
    $user = (([adsisearcher]"(&(objectCategory=User)(samaccountname=$env:username))").FindOne().Properties)
}
catch {
    Write-Host "Error: Unable to query Active Directory for user information. Details: $($_.Exception.Message)"
    exit
}

# Logo url found here */*
$logo = 'https://www.spintecgaming.com/file/open/72_b542f86a67d22/banner_470x150.png' 

# AD data of user 
if ($user.name.count -gt 0) { $displayName = $user.name[0] }    # Display Name
if ($user.title.count -gt 0) { $jobTitle = $user.title[0] }     # Job Title
if ($user.mail.count -gt 0) { $email = $user.mail[0] }          # Email Address

if ($user.mobile.count -gt 0) { $mobileNumber = $user.mobile[0] }                   # Mobile number
if ($user.telephonenumber.count -gt 0) { $telephone = $user.telephonenumber[0] }    # Office number

# Company data of USER in AD
if ($user.company.count -gt 0) { $companyName = $user.company[0] }      # Company name //Spintec //NOE //ARKA

# Extended attributes for special purpeses
if ($user.extensionAttribute1.count -gt 0) { $attribute1 = $user.extensionAttribute1[0] } # Custom attribute 1
if ($user.extensionAttribute2.count -gt 0) { $attribute2 = $user.extensionAttribute2[0] } # Custom attribute 2

# Group Check Example
$Group = [ADSI]"LDAP://cn=IT Staff,OU=Groups,DC=Example,DC=co,DC=uk"
$Group.Member | ForEach-Object {
    if ($user.distinguishedname -match $_) {
        $ItStaff = $true
    }
}

#Split name to add _ in the middle
$displayFirstname, $displayLastname = $displayName.split(' ')

# Add User name to file name 
# Create signature dir if not exists + file of signature
$folderLocation = Join-Path -Path $Env:appdata -ChildPath 'Microsoft\signatures'
$filename = $displayFirstname + '_' + $displayLastname + '_' + 'Signature'
$file = Join-Path -Path $folderLocation -ChildPath $filename

# If the directory does not exist create it
if (-not (Test-Path -Path $folderLocation)) {
    try {
        New-Item -ItemType directory -Path $folderLocation
    }
    catch {
        Write-Host "Error: Unable to create the signatures folder. Details: $($_.Exception.Message)"
        exit
    }
}

# {~~~~~~~~~~~TIMESTEMP QUERY~~~~~~~~~~~~~~~} #
# Better safe than sorry. TimeStemp gets date in format "HHMMSSddmmyyyy" just to be safe in the terms of cache in outlook.
$TimeStemp = ((Get-Date).ToString('HHMMssddMMyyyy'))


#############################################
#                                           #
#   Signature template in HTML with CSS     #
#                                           #
#############################################
$style = 
@"
<style>
p {
    font-family:Colibri,sans-serif;
    color:#666666;font-size:15px;
    font-weight:700;
    margin-bottom:15px;
}

table {
    border:0;
    border-collapse:collapse;
    border-spacing:0;
}

#displayname {
    line-height:15px;
    font-family:Verdana,sans-serif;
    color:#cd1719;
    font-size:13px;
    font-weight:900;
}

#jobtitle {
    line-height:15px;
    color:#666666;
    font-size:10px;
    font-family:Verdana,sans-serif;
}

#telephone {
    line-height:15px;
    color:#666666;
    font-size:10px;
    font-family:Verdana,sans-serif;
}

#mobilephone {
    line-height:15px;
    color:#666666;
    font-size:10px;
    font-family:Verdana,sans-serif;
}

#email {
    line-height:15px;
    color:#666666;
    font-size:10px;
    font-family:Verdana,sans-serif;
}
#a1 {
    color:#666666;
}

</style>
"@

$signature = 
@"
<p style="font-family:Colibri,sans-serif;color:#666666;font-size:15px;font-weight:700;margin-bottom:15px;">Lep pozdrav /
    Kind regards,</p>

<table width="470" style="border:0;border-collapse:collapse;border-spacing:0;" border="0" cellpadding="0"
    cellspacing="0">
    <tbody>
        <tr>
            <td width="150" valign="top" style="padding:0;">

                <img src="https://www.spintecgaming.com/file/open/68_df3004ffe7f94/spintec-logo-150x50.png"
                    alt="Spintec" height="50" width="150">
                <br>
                <p style="margin-left:43px;">
                    <a target="_blank" href="https://www.linkedin.com/company/3001562"><img alt="" height="24"
                            width="24"
                            src="https://www.spintecgaming.com/file/open/69_d221728e88367/linkedin.png"></a><span>&nbsp;</span><a
                        target="_blank" href="https://www.facebook.com/spintec.si/"><img alt="" height="24" width="24"
                            src="https://www.spintecgaming.com/file/open/70_d5bca5bf06c37/facebook.png"></a><span>&nbsp;</span><a
                        target="_blank" href="https://www.youtube.com/@spintecgamingsolutions2218"><img alt=""
                            height="24" width="24"
                            src="https://www.spintecgaming.com/file/open/71_fbc76032c1800/youtube.png"></a><span>&nbsp;</span>
                </p>
            </td>
            <td width="320" valign="bottom" style="padding:0 0 2px 32px;">
                <br>

                $(if($displayName){"
                <span id='displayname'>$displayName</span>
                <br>
                "})

                
                <span id='jobtitle'>$jobTitle</span>
                <br>
                <br>
                

                $(if($telephone){"
                <span id='telephone'>
                    <strong>T:</strong>
                    &nbsp;
                    <a id='a1' href='tel:$telephone'>$telephone</a>
                </span>
                <br>
                "})

                $(if($mobileNumber){"
                <span id='mobilephone'>
                    <strong>M:</strong>
                    &nbsp;
                    <a id='a1' href='tel:$mobileNumber'>$mobileNumber</a>
                </span>
                <br>
                "})

                $(if($email){"
                <span id='email'>
                    <strong>M:</strong>
                    &nbsp;
                    <a id='a1' href='mailto:$email'>$email</a>
                </span>
                <br>
                "})
                <br>


        </tr>
        <tr>
            <td colspan="2" style="padding:8px 0;">
                <img src="https://www.spintecgaming.com/file/open/72_b542f86a67d22/banner_470x150.png?$TimeStemp"
                    alt="SpintecBanner" width="470">
            </td>
        </tr>
    </tbody>
</table>
<table width="470" style="border:0;border-collapse:collapse;border-spacing:0;" border="0" cellpadding="0"
    cellspacing="0">
    <tbody>
        <tr>
            <td style="padding:0;">
                <span style="line-height:15px;font-size:10px;font-family:Verdana,sans-serif;"><strong><a target="_blank"
                            href="https://www.spintecgaming.com/games/karma/roulette/automated-roulette-8-playing-stations-dual-side-topper"
                            style="color:#cd1719;">roulette</a></strong></span><span
                    style="line-height:15px;font-size:10px;font-family:Verdana,sans-serif;color:#666666;">&nbsp;|&nbsp;</span><span
                    style="line-height:15px;font-size:10px;font-family:Verdana,sans-serif;"><strong><a target="_blank"
                            href="https://www.spintecgaming.com/"
                            style="color:#cd1719;">www.spintecgaming.com</a></strong></span><span
                    style="line-height:15px;color:#666666;font-size:10px;font-family:Verdana,sans-serif;"><br>SPINTEC
                    d.o.o. Volčja Draga 43 D, SI-5293 Volčja Draga, Slovenia</span>
            </td>
            <td style="padding:0;">
                <img src="https://www.spintecgaming.com/file/open/73_2060c44b0c6bc/AAA_200x160.png" alt="AAA"
                    height="80" width="100">
            </td>
        </tr>
    </tbody>
</table>
<table width="470" style="border:0;border-collapse:collapse;border-spacing:0;" border="0" cellpadding="0"
    cellspacing="0">
    <tbody>
        <tr>
            <td style="padding:0;font-family:Verdana,sans-serif;color:#c4c4c4;font-size:8px;line-height:10px;">
                This message contains confidential information and is intended only for the individual named. If you are
                not the named addressee you should not disseminate, distribute or copy this email. You cannot use or
                forward any attachments in the email. Please notify the sender immediately by email if you have received
                this email by mistake and delete this email from your system.
            </td>
        </tr>
    </tbody>
</table>
<p>&nbsp;</p>
"@



# Save the HTML to the signature file
# Encoding : -Encoding ([System.Text.Encoding]::UTF8) ; -encoding utf8 ; -encoding unicode
#
try {
    $style + $signature | Out-File -FilePath "$file.htm" -encoding unicode
    
}
catch {
    Write-Host "Error: Unable to save the HTML signature file. Details: $($_.Exception.Message)"
    exit
}


# Build the txt version for none rich text emails
$signature = 
@"
Lep pozdrav / Kind regards,

$(if($displayName){ $displayName })
$(if($jobTitle){ $jobTitle })
___________________________________________________________

SPINTECGAMING
$(if($companyName){ $companyName })

$(if($telephone){"T: "+$telephone})
$(if($mobileNumber){"M: "+$mobileNumber})
$(if($email){"E: "+$email})
$(if($website){"W: "+$website})
"@

# Output the text to the signatures folder
try {
    $signature | out-file "$file.txt" -encoding utf8
}
catch {
    Write-Host "Error: Unable to save the text signature file. Details: $($_.Exception.Message)"
    exit
}

#########################
#                       #
#   REG EDIT MASTER     #
#                       #
#########################

# /* uncomment for registry manipulation
# To disable signature settings for user

#   Outlook 2016
<# if (test-path "HKCU:\\Software\\Microsoft\\Office\\16.0\\Common\\General") {
    get-item -path HKCU:\\Software\\Microsoft\\Office\\16.0\\Common\\General | new-Itemproperty -name Signatures -value signatures -propertytype string -force
    get-item -path HKCU:\\Software\\Microsoft\\Office\\16.0\\Common\\MailSettings | new-Itemproperty -name NewSignature -value $filename -propertytype string -force
    get-item -path HKCU:\\Software\\Microsoft\\Office\\16.0\\Common\\MailSettings | new-Itemproperty -name ReplySignature -value $filename -propertytype string -force
    Remove-ItemProperty -Path HKCU:\\Software\\Microsoft\\Office\\16.0\\Outlook\\Setup -Name "First-Run" -ErrorAction silentlycontinue
} #>

# Disable Outlook roaming signature // account signature
# Define the registry path and values
$registryPath = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Setup"
$valueName = "DisableRoamingSignaturesTemporaryToggle"
$valueType = "DWORD"
$valueData = 1

# Check if the registry path exists, if not, create it
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

# Set the registry key value
Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type $valueType

