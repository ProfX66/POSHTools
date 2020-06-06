Function Get-PowerEvents([String]$Computer = $env:COMPUTERNAME, [String]$Path = $null, [TimeSpan]$TimeMask = [TimeSpan]::Zero, [Switch]$Descending)
{
	[Int]$Private:id = 1074
	[String]$Private:source = $Computer
	if (($Path) -and (Test-Path -Path $Path))
	{
		$Private:source = $Path
		$Private:powerEvents = Get-WinEvent -FilterHashtable @{ Path=$Path; id=$Private:id }
	}
	else { $Private:powerEvents = Get-WinEvent -ComputerName $Computer -FilterHashtable @{ logname='System'; id=$Private:id } }

	$Private:powerEvents | Sort-Object -Property TimeCreated -Descending:$Descending | ForEach-Object `
	{
		[PSCustomObject]@{
			Location = $Private:source;
            ID = $Private:id;
			Date = $_.TimeCreated.Add($TimeMask); 
			User = $_.Properties[6].Value; 
			Process = $_.Properties[0].Value; 
			Action = $_.Properties[4].Value; 
			Reason = $_.Properties[2].Value; 
			ReasonCode = $_.Properties[3].Value;
			Comment = $_.Properties[5].Value;
		}
	}
}