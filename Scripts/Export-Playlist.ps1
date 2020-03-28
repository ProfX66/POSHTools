Function Export-Playlist()
{
    [CmdletBinding()]
    Param
	(
		[Parameter(Mandatory=$True)]
		[String]$Path,
		[Parameter(Mandatory=$False)]
		[String]$OutPath,
		[Parameter(Mandatory=$False)]
		[String]$LibraryPath = "I:\Music\Library",
		[Parameter(Mandatory=$False)]
		[String]$DevicePath = "/storage/external_sd1",
		[Parameter(Mandatory=$False)]
		[Switch]$Force
    )

    If (test-Path -Path $Path)
    {
        $content = Get-Content -Path $Path
        $content | ForEach-Object {
            [String]$line = $_ -replace ([RegEx]::Escape($LibraryPath)),$DevicePath -replace "\\","/"
            Write-Verbose -Message ("{0} => {1}" -f $_, $line)
            [String[]]$newContent += $line
        }

        $OutFile = Join-Path -Path $OutPath -ChildPath (Split-Path -Path $Path -Leaf)
        if (!(test-Path -Path $OutFile)) { New-Item -Path $OutFile -ItemType File -Force | Out-Null }
        else
        {
            if (!($Force)) { $OutFile = Join-Path -Path $OutPath -ChildPath ("{0}-{1}" -f (Get-Date).ToString("yyyyMMddHHmmss"), (Split-Path -Path $Path -Leaf)) }
        }

        Write-Output -Message ("Output File: {0}" -f $OutFile)
        Set-Content -Path $OutFile -Value $newContent -Force
    }
}