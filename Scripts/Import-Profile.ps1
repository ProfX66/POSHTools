[String]$Private:skipPattern = '(Import-Profile|Microsoft\.PowerShell_profile)\.ps1'

[String[]]$Modules = (
    "G:\Repos\POSH-Git\src\posh-git.psd1"
)

$Modules | ForEach-Object {
    Write-Host ("Importing external module: '{0}'" -f $_) -ForegroundColor Yellow
    Import-Module $_ -Force -Scope Global
}

[String[]]$ScriptFolders = (
    "G:\Repos\POSHTools",
    "G:\Repos\POSHToolsPrivate",
    "G:\Repos\POSHToolsWork"
)

$ScriptFolders | ForEach-Object {
    if (Test-Path -Path $_)
    {
        Write-Host ("Importing PowerShell functions from directory: '{0}'" -f $_) -ForegroundColor Yellow
        Get-ChildItem -Path $_ -Filter *.ps1 -Recurse | Where-Object { $_.Name -notmatch $Private:skipPattern } | ForEach-Object {
            Write-Host ("-> Loading file: {0}" -f $_.Name)
            Import-Module $_.FullName -Force -Scope Global
        }
    }
    else { Write-Warning -Message ("Path [ {0} ] not found - Skipping..." -f $_) }
}

Write-Host "`nCompleted!`n" -ForegroundColor Green