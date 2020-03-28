Function Get-TwitterNames()
{
    [CmdletBinding()]
    Param
	(
        [Parameter(Mandatory=$True)]
		[String]$Path
    )

    if (!(Test-Path -Path $Path)) { Write-Warning -Message ("File [ {0} ] could not be found!" -f $Path); return $null }
    $con = Get-Content -Path $Path -Force

    if ($con)
    {
        foreach ($line in $con)
        {
            if ($line -match 'twitter\.com')
            {
                $tPatt = [RegEx]'(?<=\/\/twitter\.com\/).*'
                $m = $tPatt.Matches($line) | Select-Object -First 1 -ExpandProperty Value
                if ($m -match "/")
                {
                    $s = $m -split "/"
                    $m = $s | Select-Object -First 1
                }
                [PSCustomObject]@{ FullName = $line; Name = $m }
            }
        }
    }
}

#Get-TwitterNames -Path "G:\Temp\20200121-195348-Twitter.txt" | Select-Object -ExpandProperty Name -Unique