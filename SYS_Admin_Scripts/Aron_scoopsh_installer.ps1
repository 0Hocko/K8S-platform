#1. Install scoop
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

#2. Update scoop
scoop install git
scoop update

#3. Add buckets to scoop 
scoop bucket add extras
scoop bucket add versions
scoop bucket add main
scoop bucket add nonportable

#4. Install software
scoop install main/7zip
scoop install extras/android-studio
scoop install extras/azuredatastudio
scoop install versions/azuredatastudio-insiders
scoop install extras/filezilla
scoop install main/git
scoop install extras/scribus
scoop install extras/greenshot
scoop install nonportable/k-lite-codec-pack-mega-np
scoop install extras/firefox
scoop install extras/notepadplusplus
scoop install extras/openvpn-connect
scoop install nonportable/pdf24-creator-np
scoop install extras/putty
scoop install extras/teamviewer
scoop install extras/vlc
scoop install extras/winmerge
scoop install extras/winscp
scoop install extras/googlechrome
scoop install extras/vscode