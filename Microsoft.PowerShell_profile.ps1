Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Install posh-git
pushd
cd posh-git
Import-Module .\posh-git
Enable-GitColors
popd

. ./configurePrompt.ps1
. ./ssh-agent-utils.ps1

. (Resolve-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")

function Start-Explorer{
	if(!$args) { explorer . }
	else { explorer $args }
}
Set-Alias e Start-Explorer

function Start-Notepad{
	& 'C:\Users\K_Bloom\AppData\Local\Microsoft\AppV\Client\Integration\C8126E61-371E-4C27-8589-AACC8D6E34A0\Root\notepad++.exe' $args
}
set-alias n Start-Notepad

function Start-gVim {
	& 'C:\Program Files (x86)\Vim\vim73\gvim.exe' $args
}
set-alias v Start-gVim

function Set-Location-Dev{
	param([string]$location = "")
	Push-Location

	if($folder -ne ""){
		cd $location
		return
	}

	cd $location
}


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

function CheckStatus {
	git status -s
}
set-alias gs CheckStatus

function Clone {
	param([string]$repository = "", [string]$folder ="")
	
	git clone $repository
	
	cd $folder
	
	git submodule update --init
	
}

function CheckoutRemote {
	param([string]$branch = "")
	
	git checkout -b $branch --track origin/$branch
}
set-alias gitbranch CheckoutRemote

function NuGetClean {
	git status --porcelain | select-string -pattern "\.dll|\.xml" | foreach-object { $_ -replace "\?\? "} | rm
}

set-alias sql ssms.exe

function wcfclient { 
	& "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\WcfTestClient.exe" 
}

. ./environment.ps1
