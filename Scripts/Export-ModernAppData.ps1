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

    Function Expand-AppxPackage()
    {
        Function Resolve-SID([String]$SID)
	    {
		    [String]$Private:return = $null
		    try
		    {
			    $Private:uSid = New-Object -TypeName System.Security.Principal.SecurityIdentifier($SID)
			    $Private:sUser = $Private:uSid.Translate([System.Security.Principal.NTAccount])
			    $Private:return = $Private:sUser.Value
		    }
		    catch [Exception] { }
		    $Private:return
	    }

        Get-AppxPackage -AllUsers | ForEach-Object {
            [Object[]]$arr = @()
            [PSCustomObject]$Private:objData = New-Object -TypeName PSObject
            $Private:item = $_

            $Private:item | Get-Member -MemberType Property | ForEach-Object {

                $Private:n = $_.Name
                $Private:sitem = $Private:item | Select-Object -ExpandProperty $Private:n -ErrorAction SilentlyContinue
                switch -Regex ($Private:n)
                {
                    default { Add-Member -InputObject $Private:objData -NotePropertyName $Private:n -NotePropertyValue ($Private:sitem -join ';') }
                    "PackageUserInformation" {
                        foreach ($puiItem in $Private:sitem)
                        {
                            [PSCustomObject]$Private:pui = New-Object -TypeName PSObject
                            $puiItem | Get-Member -MemberType Property | ForEach-Object {
                                $Private:nn = $_.Name
                                $Private:ssitem = $puiItem | Select-Object -ExpandProperty $Private:nn -ErrorAction SilentlyContinue
                                if ($Private:nn -match 'UserSecurityId')
                                {
                                    Add-Member -InputObject $Private:pui -NotePropertyName "PackageUserInformation-Sid" -NotePropertyValue $Private:ssitem.Sid
                                    if ($Private:ssitem.Username -notmatch '$S-1-5')
                                    {
                                        Add-Member -InputObject $Private:pui -NotePropertyName "PackageUserInformation-Username" -NotePropertyValue $Private:ssitem.Username
                                    }
                                    else { Add-Member -InputObject $Private:pui -NotePropertyName "PackageUserInformation-Username" -NotePropertyValue (Resolve-SID -SID $Private:ssitem.Username) }
                                }
                                else { Add-Member -InputObject $Private:pui -NotePropertyName ([String]::Concat("PackageUserInformation-", $Private:nn)) -NotePropertyValue ($Private:ssitem -join ';') }
                            }
                            $arr += $Private:pui
                        }
                        
                    }
                }
            }

            foreach ($ent in $arr)
            {
                [PSCustomObject]$Private:finalData = New-Object -TypeName PSObject
                $Private:objData | Get-Member -MemberType NoteProperty | ForEach-Object {
                    $Private:apxName = $_.Name
                    $Private:apxData = $Private:objData | Select-Object -ExpandProperty $Private:apxName -ErrorAction SilentlyContinue
                    Add-Member -InputObject $Private:finalData -NotePropertyName $Private:apxName -NotePropertyValue $Private:apxData
                }

                $ent | Get-Member -MemberType NoteProperty | ForEach-Object {
                    $Private:puiName = $_.Name
                    $Private:puiData = $ent | Select-Object -ExpandProperty $Private:puiName -ErrorAction SilentlyContinue
                    Add-Member -InputObject $Private:finalData -NotePropertyName $Private:puiName -NotePropertyValue $Private:puiData
                }
                $Private:finalData
            }
        }
    }

    Write-Host "Gathering: ProvisionedAppXPackage"
    Get-ProvisionedAppXPackage -Online | Export-Csv -Path (Join-Path -Path $Path -ChildPath ("ProvisionedAppXPackage-{0}.csv" -F $Id)) -NoTypeInformation -Force

    Write-Host "Gathering: AppxPackage"
    Expand-AppxPackage | Export-Csv -Path (Join-Path -Path $Path -ChildPath ("AppXPackage-{0}.csv" -F $Id)) -NoTypeInformation -Force
    Get-AppPackages | Export-Csv -Path (Join-Path -Path $Path -ChildPath ("AppXPackageLocalAppData-{0}.csv" -F $Id)) -NoTypeInformation -Force

    Write-Host "Gathering: Start Applications"
    Get-StartAppsEx | Export-Csv -Path (Join-Path -Path $Path -ChildPath ("StartApps-{0}.csv" -F $Id)) -NoTypeInformation -Force

    Write-Host "Gathering: Start Shortcuts"
    Get-ChildItem -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs" -Recurse | ForEach-Object { $_.FullName } | Out-File -PSPath (Join-Path -Path $Path -ChildPath ("StartMenu-{0}.txt" -F $Id))
    Get-ChildItem -Path "C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" -Recurse | ForEach-Object { $_.FullName } | Out-File -PSPath (Join-Path -Path $Path -ChildPath ("StartMenuUser-{0}.txt" -F $Id))
}

#Export-AppInfo -Path "C:\Temp"