Function Export-ModernAppData([String]$Path, [String]$Id = (Get-Date).ToString("yyyyMMdd-HHmmss"))
{
    if (!($Path)) { Write-Warning "Path is empty..."; return }
    if (!(Test-Path -Path $Path)) { New-Item -Path $Path -ItemType Directory -Force | Out-Null }

    Function Get-AppPackages()
    {
        Get-ChildItem -Path "C:\Users\$env:USERNAME\AppData\Local\Packages" -Directory | ForEach-Object {
            $Private:package = $_
            Get-ChildItem -Path $_.FullName -Recurse -File | ForEach-Object {
                [PSCustomObject]@{
                    PackageName = $Private:package.Name;
                    Files = $_.FullName -replace ([RegEx]::Escape($Private:package.FullName))
                }
            }
        }
    }

    Function Get-StartAppsEx {
        (New-Object -ComObject Shell.Application).
            NameSpace("shell:::{4234d49b-0245-4df3-b780-3893943456e1}").
                Items() | ForEach-Object {
                        $Private:item = $_
                        $_.Verbs() | ForEach-Object {
                            [PSCustomObject]@{
                                ApplicationName = $Private:item.Name;
                                ApplicationID = $Private:item.Path;
                                AvailableVerbs = $_.Name -replace '&'
                            }
                        }
            }
    }

    Write-Host "Gathering: ProvisionedAppXPackage"
    Get-ProvisionedAppXPackage -Online | Export-Csv -Path (Join-Path -Path $Path -ChildPath ("ProvisionedAppXPackage-{0}.csv" -F $Id)) -NoTypeInformation -Force

    Write-Host "Gathering: AppxPackage"
    Get-AppxPackage | Export-Csv -Path (Join-Path -Path $Path -ChildPath ("AppXPackage-{0}.csv" -F $Id)) -NoTypeInformation -Force
    Get-AppPackages | Export-Csv -Path (Join-Path -Path $Path -ChildPath ("AppXPackageLocalAppData-{0}.csv" -F $Id)) -NoTypeInformation -Force

    Write-Host "Gathering: Start Applications"
    Get-StartAppsEx | Export-Csv -Path (Join-Path -Path $Path -ChildPath ("StartApps-{0}.csv" -F $Id)) -NoTypeInformation -Force

    Write-Host "Gathering: Start Shortcuts"
    Get-ChildItem -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs" -Recurse | ForEach-Object { $_.FullName } | Out-File -PSPath (Join-Path -Path $Path -ChildPath ("StartMenu-{0}.txt" -F $Id))
    Get-ChildItem -Path "C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" -Recurse | ForEach-Object { $_.FullName } | Out-File -PSPath (Join-Path -Path $Path -ChildPath ("StartMenuUser-{0}.txt" -F $Id))
}

#Export-AppInfo -Path "C:\Temp"