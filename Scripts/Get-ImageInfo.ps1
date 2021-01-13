Function Get-ImageInfo([String]$Path, [Int]$Padding = 200, [Switch]$Excel, [Switch]$Verbose)
{
    $item = Get-Item -Path $Path
    if ($Verbose) { Write-Host ("Processing: {0}" -F $item.FullName) }
    try { $details = [Drawing.Image]::FromFile($item.FullName) }
    catch {}
    if ($details)
    {
        $ratio = Get-Ratio -x $details.Width -y $details.Height
        $ratioOut = $ratio.Ratio
        if ($Excel) { $ratioOut = " {0}" -F $ratio.Ratio }

        $type = "Unknown"
        if ([Math]::Abs(($details.Height - $details.Width)) -le $Padding) { $type = "Square" }
        else
        {
            if ($details.Height -gt $details.Width) { $type = "Portrait" }
            else { $type = "Landscape" }
        }

        Add-Member -InputObject $details -NotePropertyName "FullName" -NotePropertyValue $item.FullName
        Add-Member -InputObject $details -NotePropertyName "Extension" -NotePropertyValue $item.Extension
        Add-Member -InputObject $details -NotePropertyName "AspectRatio" -NotePropertyValue $ratioOut
        Add-Member -InputObject $details -NotePropertyName "Type" -NotePropertyValue $type
        $details
        $details.Dispose()
    }
}

Function Get-Divisors($n)
{
    $div = @();
    foreach ($i in 1 .. ($n/3))
    {
        $d = $n/$i;
        if (($d -eq [System.Math]::Floor($d)) -and -not ($div -contains $i))
        {
            $div += $i;
            $div += $d;
        }
    };
    $div | Sort-Object;
}

Function Get-CommonDivisors($x, $y)
{
    $xd = Get-Divisors $x;
    $yd = Get-Divisors $y;
    $div = @();
    foreach ($i in $xd) { if ($yd -contains $i) { $div += $i; } }
    $div | Sort-Object;
}

Function Get-GreatestCommonDivisor($x, $y)
{
    $d = Get-CommonDivisors $x $y;
    $d[$d.Length-1];
}

Function Get-Ratio($x, $y)
{
    $d = Get-GreatestCommonDivisor $x $y;
    New-Object PSObject -Property @{
        X = $x;
        Y = $y;
        Divisor = $d;
        XRatio = $x/$d;
        YRatio = $y/$d;
        Ratio = "$($x/$d):$($y/$d)";
    };
}