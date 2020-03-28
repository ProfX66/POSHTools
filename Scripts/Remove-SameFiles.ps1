Function Remove-SameFiles()
{
    [CmdletBinding()]
    Param
	(
		[Parameter(Mandatory=$True)]
		[String[]]$Paths,
		[Parameter(Mandatory=$False)]
		[Switch]$Recurse,
		[Parameter(Mandatory=$False)]
		[Switch]$Remove,
		[Parameter(Mandatory=$False)]
		[Switch]$Summary
    )

    Function Get-FileData()
    {
        [CmdletBinding()]
        Param
	    (
		    [Parameter(Mandatory=$True)]
		    [String]$Path,
		    [Parameter(Mandatory=$False)]
		    [Switch]$Recurse
        )

        [String]$Head = "Gathering all files from path [ {0} ]"
        if ($Recurse) { $Head = "Recursively gathering all files from path [ {0} ]" }
        Write-Host (Format-String -Items $Head, $Path)

        $files = Get-ChildItem -Path $Path -Recurse:$Recurse -Force
        foreach ($file in $files)
        {
            [String]$Hash = (Get-FileHash -Path $file.FullName -Algorithm MD5).Hash
            if ($Hash)
            {
                Write-Verbose (Format-String -Items "{0} => {1}", $Hash, $file.FullName)
                [PSCustomObject]@{ Name = $file.Name; FileInfo = $file; Hash = $Hash }
            }
        }
    }

    Function Join-FileList()
    {
        [CmdletBinding()]
        Param
	    (
		    [Parameter(Mandatory=$True)]
		    [String[]]$Paths,
		    [Parameter(Mandatory=$False)]
		    [Switch]$Recurse
        )

        foreach ($Path in $Paths)
        {
            Get-FileData -Path $Path -Recurse:$Recurse
        }
    }

    Function Get-UniqueList()
    {
        [CmdletBinding()]
        Param
	    (
		    [Parameter(Mandatory=$True)]
		    [PSCustomObject]$InputObject
        )

        $UniqueItems = $InputObject | Sort-Object -Property Hash -Unique
        foreach ($UniqueItem in $UniqueItems)
        {
            Write-Verbose (Format-String -Items "{0} => {1}", $UniqueItem.Hash, $UniqueItem.FileInfo.FullName)
            [PSCustomObject]@{ Name = $UniqueItem.Name; FileInfo = $UniqueItem.FileInfo; Hash = $UniqueItem.Hash }
        }
    }

    Function Get-Differential()
    {
        [CmdletBinding()]
        Param
	    (
		    [Parameter(Mandatory=$True)]
		    [PSCustomObject]$ReferenceObject
        )

        $UniqeObj = @{}
        $UniqeObj.Clear()
        foreach ($item in $ReferenceObject)
        {
            try { $UniqeObj.Add($item.Hash, $null) }
            catch { [PSCustomObject]@{ Name = $item.Name; FileInfo = $item.FileInfo; Hash = $item.Hash } }
        }
    }

    Function Format-String([Object[]]$Items)
    {
	    [Object[]]$Private:realItems = @()
	    $Items | ForEach-Object { $Private:realItems += (Get-FriendlyNull -Check $_) }
	    [String]$Private:pattern = $Private:realItems | Select-Object -First 1
	    [Object[]]$Private:vars = $Private:realItems | Select-Object -Skip 1
	    [String]$Private:replacePattern = [String]::Format("\{{{0}\}}", $Private:vars.Count)
	    [String]$Private:newReplacePattern = [String]::Format("({0})", $Private:vars.Count)
	    $Private:pattern = $Private:pattern -replace $Private:replacePattern,$Private:newReplacePattern
	    return ([String]::Format($Private:pattern, $Private:vars))
    }

    Function Get-FriendlyNull([String]$Check)
	{
		if (Test-NullOrEmpty -Check $Check) { return "Null" }
		else { return $Check }
	}

    Function Test-NullOrEmpty([String]$Check)
	{
		return [String]::IsNullOrEmpty($Check)
	}

    $AllFiles = Join-FileList -Paths $Paths -Recurse:$Recurse
    Write-Host (Format-String -Items "Found [ {0} ] files", $AllFiles.Count)
    Write-Host "Finding all unique files based on MD5 checksum..."
    $UniqueFiles = Get-UniqueList -InputObject $AllFiles
    Write-Host (Format-String -Items "Found [ {0} ] unique files", $UniqueFiles.Count)
    Write-Host "Determining differential file list..."
    $DiffFiles = Get-Differential -ReferenceObject $AllFiles
    Write-Host (Format-String -Items "Found [ {0} ] differential files", $DiffFiles.Count)

    if ($Remove)
    {
        $DiffFiles | ForEach-Object `
        {
            if ($_.Hash)
            {
                Write-Verbose (Format-String -Items "Removing file => {0} ({1})", $_.FileInfo.FullName, $_.Hash)
                Remove-Item -Path $_.FileInfo.FullName -Force
            }
        }
    }
    else
    {
        $DiffFiles | ForEach-Object `
        {
            if ($_.Hash) { Write-Verbose (Format-String -Items "[WhatIf] Removing file => {0} ({1})", $_.FileInfo.FullName, $_.Hash) }
        }
    }

    if ($Summary)
    {
        Write-Host "========================================================================"
        Write-Host (Format-String -Items "==   Total files     `t=>`t {0}", $AllFiles.Count)
        Write-Host (Format-String -Items "==   Total unique    `t=>`t {0}", $UniqueFiles.Count)
        if ($Remove) { Write-Host (Format-String -Items "==   Total removed   `t=>`t {0}", $DiffFiles.Count) }
        else { Write-Host (Format-String -Items "==   Total to remove `t=>`t {0}", $DiffFiles.Count) }
        Write-Host (Format-String -Items "==   Total remaining `t=>`t {0}", ($AllFiles.Count - $DiffFiles.Count))
        Write-Host "========================================================================"
    }
}

#Get-EventLog -LogName 'Security' -InstanceId 4634 -newest 1