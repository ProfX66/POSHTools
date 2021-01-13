Function Find-Images()
{
    [CmdletBinding()]
    Param
	(
		[Parameter(Mandatory=$True)]
		[String[]]$SearchPaths,
		[Parameter(Mandatory=$False)]
		[String]$CopyPath = "I:\P\Temp1",
		[Parameter(Mandatory=$False)]
		[ValidateSet("Landscape", "Portrait", "Square", "Unknown")]
		[String]$Type = "Landscape",
		[Parameter(Mandatory=$False)]
		[Int]$Width = 1024,
		[Parameter(Mandatory=$False)]
		[Switch]$OneLevel
    )

    [Bool]$Recurse = $True
    if ($OneLevel) { $Recurse = $False }

    foreach ($sp in $SearchPaths)
    {
        Write-Warning ("Searching: {0}" -F $sp)
        $files = Get-ChildItem -Path $sp -Recurse:$Recurse -File -Force | ForEach-Object { Get-ImageInfo -Path $_.FullName -Verbose | Where-Object { ($_.Type -match $Type) -and ($_.Width -gt $Width) } }
        $files | ForEach-Object { Copy-Item -Path $_.FullName -Destination $copyPath -Force -Verbose }
    }
}