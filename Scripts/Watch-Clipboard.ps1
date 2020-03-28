Function Watch-Clipboard()
{
    [CmdletBinding()]
    Param
	(
        [Parameter(Mandatory=$False)]
		[Switch]$Export,
        [Parameter(Mandatory=$False)]
		[String]$ExportPath = "G:\Temp",
        [Parameter(Mandatory=$False)]
		[String]$ExportName = "TempClip",
        [Parameter(Mandatory=$False)]
		[String]$Interval = "1s",
        [Parameter(Mandatory=$False)]
		[String]$ExitString = "StopLoop",
        [Parameter(Mandatory=$False)]
		[Switch]$Clear
    )

    if ($Clear) { Write-Warning -Message "Clearing clipboard!"; Set-Clipboard -Value $null }

    [Bool]$Loop = $true
    [String]$currentClip = $null
    [String]$exportFile = Join-Path -Path $ExportPath -ChildPath ("{0}-{1}.txt" -f (Get-Date).ToString("yyyyMMdd-HHmmss"), $ExportName)
    [TimeSpan]$tsInterval = Get-TimeSpan -Interval $Interval

    if ($Export)
    {
        Write-Warning -Message ("Saving output to [ {0} ]" -f $exportFile)
        if (!(Test-Path -Path $ExportPath)) { New-Item -Path $ExportPath -ItemType Directory -Force | Out-Null }
        if (!(Test-Path -Path $exportFile)) { New-Item -Path $exportFile -ItemType File -Force | Out-Null }
    } 

    Write-Warning -Message ("Monitoring Clipboard - [ {0} ] interval" -f $Interval)

    do
    {
        Write-Verbose -Message "Loop"
        [String]$tempClip = Get-Clipboard -Format Text -TextFormatType Text
        if ($tempClip)
        {
            if ($tempClip -ne $currentClip)
            {
                $currentClip = $tempClip
                Write-Host ("New Clip: {0}" -f $currentClip)
                if ($currentClip -match "^$ExitString$") { $Loop = $False; Write-Warning -Message "Aborting!"; return }
                if ($Export -and $Loop)
                {
                    try
			        {
				        $Private:StreamWriter = New-Object -TypeName System.IO.StreamWriter($exportFile, $true)
				        $Private:StreamWriter.WriteLine($currentClip)
				        $Private:StreamWriter.Close()
			        }
			        catch { }
                }
            }
        }
        Start-Sleep -Seconds $tsInterval.TotalSeconds
    } While ($Loop)
}