Function Find-UnicodeFilePaths()
{
    <#
    .SYNOPSIS

    Finds files which include unicode characters in their path

    .DESCRIPTION

    Enumerates the provided path for files which include any unicode characters in their path name.

    .INPUTS

    Path: Parent path String to search in
    Extensions: String array of extensions
    Recurse: Switch to enable recursive enumeration

    .OUTPUTS

    Ordered list with file and match details

    .EXAMPLE

    PS> Find-UnicodeFilePaths -Path "Directory"
    Ordered object with found file details

    .EXAMPLE

    PS> Find-UnicodeFilePaths -Path "Directory" -Recurse
    Ordered object with found file details

    .EXAMPLE

    PS> Find-UnicodeFilePaths -Path "Directory" -Recurse -Extensions MP3,FLAC
    Ordered object with found file details
    #>

    [CmdletBinding()]
    Param (
      [Parameter(Mandatory=$True)]
      [String]$Path,
      [String[]]$Extensions,
      [Switch]$Recurse
    )

    [DateTime]$StartTime = Get-Date
    [Object[]]$UnicodePaths = @()
    [String]$ExtensionPattern = "."
    [String]$UnicodePattern = '[^\u0000-\u007F]'
    [Int]$Count = 0

    if ($Extensions) { $ExtensionPattern = $Extensions -join '|' }
    Write-Verbose -Message ([String]::Format("Extension RegEx Pattern [ {0} ]", $ExtensionPattern))

    Write-Verbose -Message ([String]::Format("Searching paths in [ {0} ]", $Path))
    Get-ChildItem -Path $Path -Recurse:$Recurse | Where-Object { $_.Extension -match $ExtensionPattern } | ForEach-Object `
    {
        $Count++
        Write-Verbose -Message ([String]::Format("[{0}] {1}", $count, $_.FullName))
        if ($_.FullName -match $UnicodePattern)
        {
            Write-Warning -Message ([String]::Format("Unicode Path: {0}", $_.FullName))
            [String]$MatchType = "FileName"
            if ($_.Directory -match $UnicodePattern) { $MatchType = "ParentPath" }

            $FileProperties = [Ordered]@{
                "MatchType" = $MatchType
			    "Directory" = $_.Directory
			    "Name" = $_.Name
			    "Extension" = $_.Extension
                "FullName" = $_.FullName
                "Size" = [String]::Format("{0:N2} MB", ($_.Length /1MB))
                "CreationTime" = $_.CreationTime
                "LastWriteTime" = $_.LastWriteTime
		    }
            $UnicodePaths += New-Object -TypeName PSObject -Property $FileProperties
        }
    }

    if ($UnicodePaths)
    {
        [DateTime]$EndTime = Get-Date
        [TimeSpan]$Duration = $EndTime - $StartTime
        Write-Verbose -Message ([String]::Format("Finished in [ {0} ] Minutes", $duration.TotalMinutes))
        Write-Verbose -Message ([String]::Format("Total of [ {0}/{1} ] files with unicode in their path name", $UnicodePaths.Count, $Count))
    }
    else { Write-Verbose -Message "Zero unicode file paths found!" }
    $UnicodePaths
}