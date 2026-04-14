@echo off
setlocal enabledelayedexpansion

:: Attempt to get the user from Active Directory
set "user="
for /f "tokens=*" %%A in ('powershell -Command "& {try { ([adsisearcher]'(&(objectCategory=User)(samaccountname=%username%))').FindOne().Properties } catch { exit 1 }}"') do (
    set "user=%%A"
)

:: Exit if no user is found or there is an issue
if not defined user (
    echo Error: Unable to query Active Directory for user information.
    exit /b 1
)

:: Create the signatures folder and set the name of the signature file
set "folderLocation=%APPDATA%\Microsoft\signatures"
set "filename=Signature"
set "file=%folderLocation%\%filename%"

:: If the folder does not exist, create it
if not exist "%folderLocation%" (
    mkdir "%folderLocation%" || (
        echo Error: Unable to create the signatures folder.
        exit /b 1
    )
)

:: Logo to be used
set "logo=https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png"

:: Get the user's properties
if defined user.name set "displayName=!user.name[0]!"
if defined user.title set "jobTitle=!user.title[0]!"
if defined user.mail set "email=!user.mail[0]!"
if defined user.mobile set "mobileNumber=!user.mobile[0]!"
if defined user.homephone set "directDial=!user.homephone[0]!"
if defined user.telephonenumber set "telephone=!user.telephonenumber[0]!"
if defined user.company set "companyName=!user.company[0]!"
if defined user.wwwhomepage set "website=!user.wwwhomepage[0]!"
if defined user.postofficebox set "poBox=!user.postofficebox[0]!"
if defined user.physicaldeliveryofficename set "office=!user.physicaldeliveryofficename!"
if defined user.streetaddress set "street=!user.streetaddress[0]!"
if defined user.l set "city=!user.l[0]!"
if defined user.st set "state=!user.st[0]!"
if defined user.postalcode set "zipCode=!user.postalcode[0]!"
if defined user.extensionAttribute1 set "attribute1=!user.extensionAttribute1[0]!"
if defined user.extensionAttribute2 set "attribute2=!user.extensionAttribute2[0]!"
if defined user.extensionAttribute3 set "attribute3=!user.extensionAttribute3[0]!"
if defined user.extensionAttribute4 set "attribute4=!user.extensionAttribute4[0]!"
if defined user.extensionAttribute5 set "attribute5=!user.extensionAttribute5[0]!"

:: Group Check Example
set "ItStaff="
for /f %%G in ('powershell -Command "& {[ADSI]'LDAP://cn=IT Staff,OU=Groups,DC=Example,DC=co,DC=uk'.Member | ForEach-Object { if ('!user.distinguishedname!' -match $_) { exit 1 } }}"') do set "ItStaff=true"

:: Building Style Sheet
set "style=<style>
p, table, td, tr, a, span { 
    font-family: Arial, Helvetica, sans-serif;
    font-size:  12pt;
    color: #28b8ce;
}

span.blue
{
    color: #28b8ce;
}

table {
    margin: 0;
    padding: 0;
}

a { 
text-decoration: none;
}

hr {
border: none;
height: 1px;
background-color: #28b8ce;
color: #28b8ce;
width: 700px;
}

table.main {
    border-top: 1px solid #28b8ce;
}
</style>"

:: Building HTML
set "signature=<p>"

if defined displayName set "signature=!signature!<span><b>!displayName!</b></span><br />"
if defined jobTitle set "signature=!signature!<span>!jobTitle!</span><br /><br />"

set "signature=!signature!<table class='main'><tr><td style='padding-right: 75px;'>"

if defined logo set "signature=!signature!<img src='!logo!' />"

set "signature=!signature!</td><td><table><tr><td colspan='2' style='padding-bottom: 10px;'>"

if defined companyName set "signature=!signature!<b>!companyName!</b><br />"
if defined street set "signature=!signature! !street!, "
if defined city set "signature=!signature! !city!, "
if defined state set "signature=!signature! !state!, "
if defined zipCode set "signature=!signature! !zipCode!"

if defined ItStaff set "signature=!signature!<tr><td td colspan='2'>IT Helpdesk: 0188887 55555 6666</tr></td>"
if defined telephone set "signature=!signature!<tr><td>T: </td><td><a href='tel:!telephone!'>!telephone!</a></td></tr>"
if defined mobileNumber set "signature=!signature!<tr><td>M: </td><td><a href='tel:!mobileNumber!'>!mobileNumber!</a></td></tr>"
if defined email set "signature=!signature!<tr><td>E: </td><td><a href='mailto:!email!'>!email!</a></td></tr>"
if defined website set "signature=!signature!<tr><td>W:</td><td><a href='https://!website!'>!website!</a></td></tr>"

set "signature=!signature!</table></td></tr></table></p><br />"

:: Save the HTML to the signature file
(
    echo !style!
    echo !signature!
) > "%file%.htm"

:: Build the txt version for non-rich text emails
set "signature=!displayName!!jobTitle!___________________________________________________________"
set "signature=!signature!!companyName!!street!, !city!, !state!, !zipCode!"

if defined ItStaff set "signature=!signature!For IT Helpdesk Call 0191231 212313"
if defined telephone set "signature=!signature!T: !telephone!"
if defined mobileNumber set "signature=!signature!M: !mobileNumber!"
if defined email set "signature=!signature!E: !email!"
if defined website set "signature=!signature!W: !website!"

:: Output the text to the signatures folder
echo !signature! > "%file%.txt"

:: Setting the regkeys for Outlook 2016
if exist "HKCU\Software\Microsoft\Office\16.0\Common\General" (
    reg add HKCU\Software\Microsoft\Office\16.0\Common\General /v Signatures /d signatures /f
    reg add HKCU\Software\Microsoft\Office\16.0\Common\MailSettings /v NewSignature /d %filename% /f
    reg add HKCU\Software\Microsoft\Office\16.0\Common\MailSettings /v ReplySignature /d %filename% /f
    reg delete HKCU\Software\Microsoft\Office\16.0\Outlook\Setup /v First-Run /f 2>nul
)

:: Setting the regkeys for Outlook 2010
if exist "HKCU\Software\Microsoft\Office\14.0\Common\General" (
    reg add HKCU\Software\Microsoft\Office\14.0\Common\General /v Signatures /d signatures /f
    reg add HKCU\Software\Microsoft\Office\14.0\Common\MailSettings /v NewSignature /d %filename% /f
    reg add HKCU\Software\Microsoft\Office\14.0\Common\MailSettings /v ReplySignature /d %filename% /f
    reg delete HKCU\Software\Microsoft\Office\14.0\Outlook\Setup /v First-Run /f 2>nul
)