$packageName = 'openvpn'
$fileType = 'exe'
$silentArgs = '/S'
$validExitCodes = @(0)

# If we specify to Uninstall-ChocolateyPackage a silent argument but without
# a path, the command throws an exception. We cannot thus rely on the
# Chocolatey Auto Uninstaller feature. We will need to do manually what the
# PowerShell command does i.e. looking for the right path in the registry
# manually.

$regUninstallDir = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
# No value in the 32 bits SysWoW64 subsystem on 64 bits. No string in that
# registry node.
#$regUninstallDirWow64 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'

$uninstallPaths = $(Get-ChildItem $regUninstallDir).Name
$uninstallPath = $uninstallPaths -match "OpenVPN" | Select -First 1

$openvpnKey = ($uninstallPath.replace('HKEY_LOCAL_MACHINE\','HKLM:\'))

$file = (Get-ItemProperty -Path ($openvpnKey)).UninstallString 

# Let's remove the certificate we inserted
Start-ChocolateyProcessAsAdmin "certutil -delstore 'TrustedPublisher' 'OpenVPN Technologies, Inc.'"

Uninstall-ChocolateyPackage `
    -PackageName "$packageName" `
    -FileType "$fileType" `
    -SilentArgs "$silentArgs" `
    -ValidExitCodes "$validExitCodes" `
    -File "$file"

# After the uninstall has performed, choco checks if there are uninstall
# registry keys left and decides to launch or not its auto uninstaller feature.
# However, here, we have a race condition. When choco checks if the following
# registry key is still present, it's already gone.
# SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenVPN
# A fix for this issue is already present in choco 0.10.4
# https://github.com/chocolatey/choco/issues/1035
if ($Env:CHOCOLATEY_VERSION -lt "0.10.4") {
    # Let's sleep. 2 secs is not enough. 5 is too long.
    Start-Sleep -s 3
}

# The uninstaller changes the PATH, apply these changes in the current PowerShell
# session.
Update-SessionEnvironment
