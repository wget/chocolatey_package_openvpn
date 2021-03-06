﻿$packageName = 'openvpn'
$fileType = 'exe'
$silentArgs = '/S'
$validExitCodes = @(0)

# If we specify to Uninstall-ChocolateyPackage a silent argument but without
# a path, the command throws an exception. We cannot thus rely on the
# Chocolatey Auto Uninstaller feature. We will need to do manually what the
# PowerShell command does i.e. looking for the right path in the registry
# manually.
[array]$key = Get-UninstallRegistryKey -SoftwareName "OpenVPN*"
if ($key.Count -eq 1) {
    $file = $key.UninstallString

    Uninstall-ChocolateyPackage `
        -PackageName "OpenVPN" `
        -FileType "$fileType" `
        -SilentArgs "$silentArgs" `
        -ValidExitCodes "$validExitCodes" `
        -File "$file" | Out-Null
} elseif ($key.Count -eq 0) {
    Write-Warning "$packageName has already been uninstalled by other means."
} elseif ($key.Count -gt 1) {
    Write-Warning "$key.Count matches found!"
    Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
    Write-Warning "Please alert package maintainer the following keys were matched:"
    $key | % {Write-Warning "- $_.DisplayName"}
}

# This script does not have to take care of removing the gpg4win-vanilla
# dependency as Chocolatey as a built-in function for that. To notify the user
# that a dependency can be removed is unneccessary. If a user wants to
# uninstall a package and its dependencies (as long as no other package depends
# on it) a user can run choco uninstall -x when uninstalling a package.