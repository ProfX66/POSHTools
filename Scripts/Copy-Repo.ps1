Function Copy-Repo()
{
    [CmdletBinding()]
    Param
	(
		[Parameter(Mandatory=$True)]
		[String]$URI,
		[Parameter(Mandatory=$False)]
		[String]$RootPath = "G:\Repos",
		[Parameter(Mandatory=$False)]
		[String]$UserName = "ProfX",
		[Parameter(Mandatory=$False)]
		[String]$UserEmail = "prof@pxcnet.com",
		[Parameter(Mandatory=$False)]
		[String]$Branch,
		[Parameter(Mandatory=$False)]
		[Switch]$ConfigOnly,
		[Parameter(Mandatory=$False)]
		[Switch]$Force
    )

    if ($RepoPath -and !($PSBoundParameters.ContainsKey('RootPath'))) { $RootPath = $RepoPath }

    [String]$Private:repoName = (Split-Path -Path $URI -Leaf) -replace '\.git$'
    if ($Branch) { $Private:repoName = [String]::Concat($Private:repoName, ".", $Branch) }

    [String]$Private:repoPath = Join-Path -Path $RootPath -ChildPath $Private:repoName
    [String]$Private:repoConfig = Join-Path -Path $Private:repoPath -ChildPath ".git/config"

    Write-Verbose -Message ("      URI: {0}" -f $URI)
    Write-Verbose -Message ("   Branch: {0}" -f $Branch)
    Write-Verbose -Message ("     Name: {0}" -f $Private:repoName)
    Write-Verbose -Message ("     Path: {0}" -f $Private:repoPath)
    Write-Verbose -Message ("   Config: {0}" -f $Private:repoConfig)
    Write-Verbose -Message (" UserName: {0}" -f $UserName)
    Write-Verbose -Message ("UserEmail: {0}" -f $UserEmail)

    if (Test-Path -Path $Private:repoPath)
    {
        if ($Force)
        {
            Write-Host ("Removing local path [ {0} ] as Force is [ True ]" -f $Private:repoPath)
            Get-ChildItem -Path $Private:repoPath -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $Private:repoPath -Force -Recurse -ErrorAction SilentlyContinue
        }
        else
        {
            if ($ConfigOnly) { Write-Host ("Local path [ {0} ] already exists - Updating config only..." -f $Private:repoPath) }
            else { Write-Warning -Message ("Local path [ {0} ] already exists - Aborting clone (Override with '-Force')" -f $Private:repoPath); return }
        }
    }

    if (!($ConfigOnly))
    {
        if ($Branch)
        {
            Write-Host ("Cloning repo [ {0} ] branch [ {1} ] into [ {2} ]..." -f $URI, $Branch, $Private:repoPath)
            git clone -b $Branch $URI $Private:repoPath
        }
        else
        {
            Write-Host ("Cloning repo [ {0} ] into [ {1} ]..." -f $URI, $Private:repoPath)
            git clone $URI $Private:repoPath
        }
    }

    Write-Host ("Setting [ user.name ] to [ {0} ] in [ {1} ]..." -f $UserName, $Private:repoConfig)
    git config --file "$Private:repoConfig" user.name "$UserName"

    Write-Host ("Setting [ user.email ] to [ {0} ] in [ {1} ]..." -f $UserEmail, $Private:repoConfig)
    git config --file "$Private:repoConfig" user.email "$UserEmail"

    Write-Host "Completed!`n" -ForegroundColor Green
}