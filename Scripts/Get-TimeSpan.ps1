Function Get-TimeSpan([String]$Interval = "5s")
{
	[TimeSpan]$Private:outTimespan = 0
	try
	{
        $ExSplat = @{ ErrorAction = 'SilentlyContinue'; ErrorVariable = 'tsErrors'; WarningAction = 'SilentlyContinue'; WarningVariable = 'tsWarnings' }
		$Private:duration = Select-String -InputObject $Interval -Pattern "^*[A-Za-z]\z" | ForEach-Object {$_.Matches} | Select Value -First 1
		switch -Regex ($Private:duration)
		{
			"s" { $Private:outTimespan = New-TimeSpan @ExSplat -Seconds (($Interval -replace "^*[A-Za-z]\z","") -as [Int]) }
			"m" { $Private:outTimespan = New-TimeSpan @ExSplat -Minutes (($Interval -replace "^*[A-Za-z]\z","") -as [Int]) }
			"h" { $Private:outTimespan = New-TimeSpan @ExSplat -Hours (($Interval -replace "^*[A-Za-z]\z","") -as [Int]) }
			"d" { $Private:outTimespan = New-TimeSpan @ExSplat -Days (($Interval -replace "^*[A-Za-z]\z","") -as [Int]) }
			default { $Private:outTimespan = New-TimeSpan @ExSplat -Hours (($Interval -replace "^*[A-Za-z]\z","") -as [Int]) }
		}
		Write-Verbose -Message ("TimeSpan data for [ {0} ] is [ {1} ]" -f $Interval, $Private:outTimespan.ToString())
	}
	catch [Exception] { Write-Warning -Message ($Error[0]) }

	if ($tsErrors -ne $null) { $tsErrors | ForEach-Object { Write-Warning -Message ($_) } }
	if ($tsWarnings -ne $null) { $tsWarnings | ForEach-Object { Write-Warning -Message ($_) } }

	return $Private:outTimespan
}

#Get-TimeSpan
#Get-TimeSpan -Interval 5m