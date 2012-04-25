Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Install posh-git
pushd
cd posh-git
Import-Module .\posh-git
Enable-GitColors
popd

. ./configurePrompt.ps1

. ./ssh-agent-utils.ps1

function Start-Explorer{
	if(!$args) { explorer . }
	else { explorer $args }
}
Set-Alias e Start-Explorer

function Start-Notepad{
	notepad++ $args
}
set-alias n Start-Notepad

function Start-VisualStudio{
	param([string]$projFile = "")

	if($projFile -eq ""){
		ls *.sln | select -first 1 | %{
			$projFile = $_
		}
	}

	if(($projFile -eq "") -and (Test-Path src)){
		ls src\*.sln | select -first 1 | %{
			$projFile = $_
		}
	}

	if($projFile -eq ""){
		echo "No project file found"
		return
	}

	echo "Starting visual studio with $projFile"
	. $projFile
}
set-alias vs Start-VisualStudio
