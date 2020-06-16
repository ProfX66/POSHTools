[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$False)]
    [String]$RepoPath = "G:\Repos"
)

[String]$Private:skipPattern = '(Import-Profile|Microsoft\.PowerShell_profile)\.ps1'

[String[]]$Modules = (
    "%RepoPath%\POSH-Git\src\posh-git.psd1"
)

$Modules | ForEach-Object {
    [String]$Private:mPath = $_ -replace "%RepoPath%", $RepoPath
    Write-Host ("Importing external module: '{0}'" -f $Private:mPath) -ForegroundColor Yellow
    Import-Module $Private:mPath -Force -Scope Global
}

[String[]]$ScriptFolders = (
    "%RepoPath%\POSHTools",
    "%RepoPath%\POSHToolsPrivate",
    "%RepoPath%\POSHToolsWork"
)

$ScriptFolders | ForEach-Object {
    [String]$Private:mPath = $_ -replace "%RepoPath%", $RepoPath
    if (Test-Path -Path $Private:mPath)
    {
        Write-Host ("Importing PowerShell functions from directory: '{0}'" -f $Private:mPath) -ForegroundColor Yellow
        Get-ChildItem -Path $Private:mPath -Filter *.ps1 -Recurse | Where-Object { $_.Name -notmatch $Private:skipPattern } | ForEach-Object {
            Write-Host ("-> Loading file: {0}" -f $_.Name)
            Import-Module $_.FullName -Force -Scope Global
        }
    }
    else { Write-Warning -Message ("Path [ {0} ] not found - Skipping..." -f $Private:mPath) }
}

Write-Host "`nCompleted!`n" -ForegroundColor Green