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
	& 'C:\Users\K_Bloom\AppData\Local\Microsoft\AppV\Client\Integration\DD4431E1-7233-4187-9384-2C3E1D4D62B8\Root\notepad++.exe' $args
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


function elevate-process{
	$file, [string]$arguments = $args;
	$psi = new-object System.Diagnostics.ProcessStartInfo $file;
	$psi.Arguments = $arguments;
	$psi.Verb = "runas";
	$psi.WorkingDirectory = get-location;
	[System.Diagnostics.Process]::Start($psi) >> $null
}
set-alias sudo elevate-process

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
	sudo "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe" $projFile
}
set-alias vs Start-VisualStudio

function Start-Project {
	Param ($hash)
	
	Set-Location-Dev $hash.Root
	
	cd $hash.Path
	Start-VisualStudio $hash.Solution
	
}

function Service-Path {

 Param ($name)
 (gwmi win32_service|?{$_.name -like "$name*"}).pathname
}

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
