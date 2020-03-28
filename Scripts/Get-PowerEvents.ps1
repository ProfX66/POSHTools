Function Get-PowerEvents()
{
	Get-WinEvent -FilterHashtable @{ logname='System'; id=1074 } | ForEach-Object `
	{
		[PSCustomObject]@{
            ID = 1074;
			Date = $_.TimeCreated; 
			User = $_.Properties[6].Value; 
			Process = $_.Properties[0].Value; 
			Action = $_.Properties[4].Value; 
			Reason = $_.Properties[2].Value; 
			ReasonCode = $_.Properties[3].Value;
			Comment = $_.Properties[5].Value;
		}
	}
}