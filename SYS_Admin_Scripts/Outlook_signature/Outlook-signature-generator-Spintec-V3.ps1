<#
.SYNOPSIS
   Outlook signature generator by Cviba
.DESCRIPTION
    Scpipt is writen in PowerShell with HTML elements for generating signature for Outlook in .htm and .txt format.
    Script uses ActiveDirectory properties to genrate personal signature.
    Automation is made by GPO. In the GPO manager there is a UI under users to call .BAT script when users logs in the computer. .BAT script than calls this signature generator.

    For local solution you have to create task in task scheduler and set parameters to run this script when logon and everyday at selected time. NOTE : Do not forget to hardcode user data as commented below.
  

.EXAMPLE
    Example of hardcode user data for local solution. 
    For local solution just move end comment parameter to the end of this line to uncommnt $user and insert the right data to thhe $user. Simple AF

$user = @{
    name="CVIBA"
    title="SYS_ADMIN / QC / SUPPORT"
    mail="cviba.cwiba@spintecgaming.com"
    mobile="+386 41 555 666"
    telephonenumber="+386 8 20 52 000"
    company="Spintec"
    }

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

# Before start, check if current user exists in the AD. If not ERROR
try {
    $user = (([adsisearcher]"(&(objectCategory=User)(samaccountname=$env:username))").FindOne().Properties)
}
catch {
    Write-Host "Error: Unable to query Active Directory for user information. Details: $($_.Exception.Message)"
    exit
}

# -------------------------- Variables ------------------------------------------

# --- variables for images ---
$banner = 'https://www.spintecgaming.com/file/open/72_b542f86a67d22/' 
$logo = 'https://www.spintecgaming.com/file/open/116_9bb47634079c/'
$AAA = 'https://www.spintecgaming.com/file/open/73_2060c44b0c6bc/'
$linkedIn = 'https://www.spintecgaming.com/file/open/69_d221728e88367/'
$facebook = 'https://www.spintecgaming.com/file/open/70_d5bca5bf06c37/'
$youtube = 'https://www.spintecgaming.com/file/open/71_fbc76032c1800/'

# --- variables to urls ---
$url = 'https://www.spintecgaming.com/'
$linkedIn_URL = 'https://www.linkedin.com/company/3001562'
$facebook_URL = 'https://www.facebook.com/spintec.si/'
$youtube_URL = 'https://www.youtube.com/@spintecgamingsolutions2218'

# --- USER DATA VARIABLES ---

# AD data of user 
if ($user.name.count -gt 0) { $displayName = $user.name[0] }    # Display Name
if ($user.title.count -gt 0) { $jobTitle = $user.title[0] }     # Job Title
if ($user.mail.count -gt 0) { $email = $user.mail[0] }          # Email Address

if ($user.mobile.count -gt 0) { $mobileNumber = $user.mobile[0] }                   # Mobile number
if ($user.telephonenumber.count -gt 0) { $telephone = $user.telephonenumber[0] }    # Office number

# Company data of USER in AD
if ($user.company.count -gt 0) { $companyName = $user.company[0] }      # Company name //Spintec //NOE //ARKA

# Group Check 
$Group = [ADSI]"LDAP://cn=IT Staff,OU=Groups,DC=Example,DC=co,DC=uk"
$Group.Member | ForEach-Object {
    if ($user.distinguishedname -match $_) {
        $ItStaff = $true
    }
}

# -------------------------- Small PowerShell backend --------------------------

#Split name to add _ in the middle
$displayFirstname, $displayLastname = $displayName.split(' ')

# Add User name to file name 
# Create signature dir if not exists + file of signature
$folderLocation = Join-Path -Path $Env:appdata -ChildPath 'Microsoft\signatures'
$filename = $displayFirstname + '_' + $displayLastname + '_' + 'Signature'
$file = Join-Path -Path $folderLocation -ChildPath $filename

# Safe check of Signature DIR
# If the directory does not exist create it
# %Appdata%\Microsoft\Signatures
if (-not (Test-Path -Path $folderLocation)) {
    try {
        New-Item -ItemType directory -Path $folderLocation
    }
    catch {
        Write-Host "Error: Unable to create the signatures folder. Details: $($_.Exception.Message)"
        exit
    }
}

# Check if $file exists, remove it to create new friski one later
if (Test-Path "$file" ) {
    Remove-Item -Path "$file.htm" -Recurse -Force -Confirm:$false
    Remove-Item -Path "$file.txt" -Recurse -Force -Confirm:$false
}
else {

}


# --- TIMESTEMP QUERY ---
# Better safe than sorry. TimeStemp gets date in format "HHMMSSddmmyyyy" just to be safe in the terms of cache in outlook.
$TimeStemp = ((Get-Date).ToString('HHMMssddMMyyyy'))

# -------------------------- SIGNATURE PART / PS TO HTM PART ------------------------------------------


# --- Signature template in HTML ---
$metadata =
@"
<!doctype html>
<html>
<head>
	<meta charset="utf-8">
	<title>SpintecGaming</title>
</head>
"@

$signature = 
@"
<body style="background-color:#FFFFFF;">

<table cellspacing="0" cellpadding="0" border="0" style="border-collapse:separate;table-layout:fixed;overflow-wrap:break-word;word-wrap:break-word;word-break:break-word;max-width:470px;">
	<tbody>
		<tr>
			<td colspan="2" style="padding:0 0 20px 0;font-family:Calibri,sans-serif;">
				<span style="color:#666666;font-size:10pt;font-weight:700;">Lep pozdrav / Kind regards,</span>
			</td>
		</tr>		
		<tr>
			<td width="150" valign="top" style="padding:0 0 20px 0;text-align:center;">
				<a target="_blank" href="$url"><img alt="Spintec logo" width="100" align="center" src="$logo"></a><br>
			</td>
			<td width="320" valign="bottom" style="padding:0 0 25px 32px;line-height:12px;font-family:Verdana,sans-serif;">
            <span style="color:#EC0000;font-size:10pt;font-weight:900;">
                $displayName
            </span>
            <br>	
            <span style="color:#666666;font-size:7.5pt;">
               $jobTitle
            </span>
            </td>
		</tr>
		<tr>
			<td width="150" valign="bottom" style="padding:0;text-align:center;">
				<a target="_blank" href="$linkedIn_URL"><img alt="Linkedin" height="24" width="24" src="$linkedIn"></a>&nbsp;<a target="_blank" href="$facebook_URL"><img alt="Facebook" height="24" width="24" src="$facebook"></a>&nbsp;<a target="_blank" href="$youtube_URL"><img alt="YouTube" height="24" width="24" src="$youtube"></a>
			</td>
			<td width="320" valign="bottom" style="padding:0 0 4px 32px;font-family:Verdana,sans-serif;line-height:12px;color:#666666;font-size:7.5pt;">
			
            $(if($telephone){"
                <strong>T:</strong>
                &nbsp;
                <a target='_blank' style='color:#666666;' href='tel:$telephone'>$telephone</a>
                "})

            $(if($mobileNumber){"
                <strong>M:</strong>
                &nbsp;
                <a target='_blank' style='color:#666666;' href='tel:$mobileNumber'>$mobileNumber</a>
                "})
            <br>
            
            $(if($email){"
            <strong>E:</strong>
            &nbsp;
            <a target='_blank' style='color:#666666;' href='mailto:$email'>$email</a>
            "})

			</td>
		</tr>
		<tr>
			<td colspan="2" style="padding:20px 0 5px 0;">
				<a target="_blank" href="$url"><img alt="" src="$banner$TimeStemp width="470"></a>
			</td>
		</tr>
	</tbody>
</table>

<table cellspacing="0" cellpadding="0" border="0" style="border-collapse:separate;table-layout:fixed;overflow-wrap:break-word;word-wrap:break-word;word-break:break-word;max-width:470px;">
	<tbody>
		<tr>
			<td width="370" style="padding:0;line-height:12px;font-size:7.5pt;font-family:Verdana,sans-serif;color:#666666;">
				SPINTEC d.o.o., Volčja Draga 43 D, SI-5293 Volčja Draga, Slovenija<br>
				<strong><a target="_blank" href="$url" style="color:#EC0000;">www.spintecgaming.com</a></strong>
			</td>
			<td width="100" style="padding:0;">
				<a target="_blank" href="$url"><img alt="AAA" width="100" src="$AAA"></a>
            </td>
        </tr>
	</tbody>
</table>

<table cellspacing="0" cellpadding="0" border="0" style="border-collapse:separate;table-layout:fixed;overflow-wrap:break-word;word-wrap:break-word;word-break:break-word;max-width:470px;">
	<tbody>
		<tr>
			<td style="padding:0;font-family:Verdana,sans-serif;color:#c4c4c4;font-size:8px;line-height:9px;">
				This message contains confidential information and is intended only for the individual named. If you are not the named addressee you should not disseminate, distribute or copy this email. You cannot use or forward any attachments in the email. Please notify the sender immediately by email if you have received this email by mistake and delete this email from your system.
			</td>
		</tr>
	</tbody>
</table>
	
</body>
</html>
"@

# --- Save the HTML to the signature file ---

#vvvvvvvvvvvvvvvvvv JEBA vvvvvvvvvvvvvvvvvvvv
# --- Function to Write UTF-8 without BOM using StreamWriter ---
# Save HTML signature
function Write-UTF8File-StreamWriter {
    param (
        [string]$filePath,
        [string]$content
    )

    $streamWriter = [System.IO.StreamWriter]::new($filePath, $false, [System.Text.Encoding]::UTF8)
    try {
        $streamWriter.Write($content)
    }
    finally {
        $streamWriter.Close()
    }
}

# Combine the metadata and signature
$fullHtmlContent = $metadata + $signature

# Save HTML signature using UTF-8 encoding
Write-UTF8File-StreamWriter -filePath "$file.htm" -content $fullHtmlContent



# Build the txt version for non-rich text emails
$signature = 
@"
Lep pozdrav / Kind regards,

$(if($displayName){ $displayName })
$(if($jobTitle){ $jobTitle })
___________________________________________________________

SPINTECGAMING
$(if($companyName){ $companyName })
Volčja Draga 43D

$(if($telephone){"T: "+$telephone})
$(if($mobileNumber){"M: "+$mobileNumber})
$(if($email){"E: "+$email})
$(if($website){"W: "+$website})
"@

# Output the text to the signatures folder with UTF-8 encoding
try {
    $signature | Out-File -FilePath "$file.txt" -Encoding utf8
}
catch {
    Write-Host "Error: Unable to save the text signature file. Details: $($_.Exception.Message)"
    exit
}

# -------------------------- HARDCORE PART ------------------------------------------
#                       --- AT YOUR OWN RISK ---


                      #~~~~~~~~~~~~~~~~~~~~~~~#
                      #\                     /#
                      # >--REG EDIT MASTER--< #
                      #/                     \#
                      #~~~~~~~~~~~~~~~~~~~~~~~#

<# COMMENT OUT REGISTRY ! 

# Set default New Mail signature
if (-not (Test-Path "HKCU:\\Software\\Microsoft\\Office\\16.0\\Common\\MailSettings\\NewSignature")) {
    get-item -path HKCU:\\Software\\Microsoft\\Office\\16.0\\Common\\MailSettings | new-Itemproperty -name NewSignature -value $filename -propertytype string -force
} else { 

}

#Set default Replay mail signature
if (-not (Test-Path "HKCU:\\Software\\Microsoft\\Office\\16.0\\Common\\MailSettings\\ReplySignature")) {
    get-item -path HKCU:\\Software\\Microsoft\\Office\\16.0\\Common\\MailSettings | new-Itemproperty -name ReplySignature -value $filename -propertytype string -force
} else { 

}

#Delete First-Run value to re-enable editing signature
if (Test-Path "HKCU:\\Software\\Microsoft\\Office\\16.0\\Outlook\\Setup\\First-Run"){
    Remove-ItemProperty -Path HKCU:\\Software\\Microsoft\\Office\\16.0\\Outlook\\Setup -Name "First-Run" -ErrorAction silentlycontinue
}

#                  ! --- DANGER --- !                #

# Disables signature edit setting in outlook

if (-not (Test-Path "HKCU:\\Software\\Microsoft\\Office\\16.0\\Common\\General\\Signatures")) {
    get-item -path HKCU:\\Software\\Microsoft\\Office\\16.0\\Common\\General | new-Itemproperty -name Signatures -value signatures -propertytype string -force
} else {

}

#>


# --- ROAMING SIGNATURE ACCOUNT SIGNATURE ---

# Disable Outlook roaming signature // account signature
if (-not (Test-Path "HKCU:\\Software\\Microsoft\\Office\\16.0\\Outlook\\Setup\\DisableRoamingSignaturesTemporaryToggle")) {
    get-item -Path HKCU:\\Software\\Microsoft\\Office\\16.0\\Outlook\\Setup | new-Itemproperty -name DisableRoamingSignaturesTemporaryToggle -value 1 -Type DWORD -Force
}
else { }
