##
# ICAP PowerShell Utils module
#
# Read more here http://confluence.icaptools.com/display/CoreTools/Getting+started+with+the+ALM+framework
#
function _Get-LatestPackageUrl {
    param(
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]
        [string] $nugetUrl,
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]
        [string] $packName
    )

	[xml]$hsg = Invoke-WebRequest $nugetUrl -UseBasicParsing
    $entries += _Get-PackageEntries $nugetUrl $packName
    $entry = $entries |  Sort-Object {[System.DateTime]::Parse($_.updated)} -Descending | select-object -First 1
    
    if(!$entry) {
        throw "Package $packName not found in nuget respository"
    }
    else {
        return $entry.content.src
    }
}

function _Get-PackageEntries {
    param(
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]
        [string] $nugetUrl,
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]
        [string] $packName
    )

	[xml]$hsg = Invoke-WebRequest $nugetUrl -UseBasicParsing
    $entries = $hsg.feed.entry | ? { $_.title.'#text' -eq $packName }
    
    $nextPageLink = $hsg.feed.link | ? { $_.rel -ieq "next" } | Select-Object -ExpandProperty href
    if($nextPageLink) {
        $entries += _Get-PackageEntries $nextPageLink $packName
    }

    Write-Output $entries
}

function _Get-PackageByUrl {
    param(
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]
        [string] $packageUrl,
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]
        [string] $dest
    )

    $packageName = split-path $packageUrl | split-path -Leaf
    $version = split-path $packageUrl -Leaf

    $packageNameAndVersion = "$packageName.$version"
    $extractDir = join-path $dest -child $packageNameAndVersion

    Write-Debug "downloading to: $extractDir"
    Write-Debug "package: $packageName"
    Write-Debug "version: $version"
    
    $zipDownload = $packageNameAndVersion + ".zip"

    if (-Not (Test-Path $extractDir)) {
        New-Item -ItemType directory -Path $extractDir | Out-Null
    } 
    
    $nupkgPath = join-path $extractDir -child $zipDownload

    if(Test-Path $nupkgPath) {
        Write-Debug "nuget package $packageNameAndVersion already download.  Not download.  Remove package to initiate download."
        $downloaded = $false
    }
    else {   
        Write-Debug "Downloading package $packageNameAndVersion..."
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($packageUrl, $nupkgPath )
        Write-Debug "Package downloaded."
        $downloaded = $true
    }

    $result = New-Object PSObject
    $result  | Add-Member -NotePropertyName "Downloaded" -NotePropertyValue $downloaded
    $result  | Add-Member -NotePropertyName "Path" -NotePropertyValue $nupkgPath
    $result  | Add-Member -NotePropertyName "Name" -NotePropertyValue $packageName
    $result  | Add-Member -NotePropertyName "Version" -NotePropertyValue $version
    
    Write-Output $result
}


function _Install-Package {
    param(
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]
        [string] $packageFullPath,
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]
        [string] $packageDestinationFolder
    )

    Write-Debug "Unpacking package ..."

    $shell = new-object -com shell.application

    $zip = $shell.NameSpace($packageFullPath)

    $items = $zip.items() | ? { `
            $_.Path -notmatch "^.+\\\[Content_Types\]\.xml$" `
            -and $_.Path -notmatch "^.+\\package$" `
            -and $_.Path -notmatch "^.+\\_rels$" `
            } 
    
    foreach($item in $items)
    {
        $shell.Namespace($packageDestinationFolder).Copyhere($item)
    }

    Write-Debug "Package unpacked."

}

function _Create-Junction {
    param(
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]
        [string] $rootDir
    )

    $target = "$rootDir\..\..\..\framework"
    $source = "$rootDir\root"

	$junction =  join-path $source -child "tools\junction.exe"
	
	if(-not (test-path $junction)) {
		throw "junction.exe expected but not found at path $junction"
	}
	
    if(Test-Path $target) {
        if(-not (gi $target).Attributes.ToString().Contains("ReparsePoint")) {
            "Junction target $target already exists but is not a junction.  Delete directory and rerun script."
        }
        else {
            write-debug "existing junction found Deleting junction..."
            $result = & $junction $target /d /accepteula 
			if($LASTEXITCODE -ne 0) {
				throw $result
			}			
            write-debug "Junction deleted"
        }

    }
    
    Write-Debug "Creating junction ..."
    $result = & $junction $target $source /accepteula
	if($LASTEXITCODE -ne 0) {
		throw $result
	}			
    Write-Debug "Junction created"
    
}

function Install-CoreAlm {
    <#

        .SYNOPSIS

        Installs the latest version of the ALM Nuget package from Nexus.

        .DESCRIPTION

        Read more here http://confluence.icaptools.com/display/CoreTools/Install-CoreALM+cmdlet

        .PARAMETER packagesFolder

        The destination folder that the nuget pacakge will be downloaded and unpacked to.  Can be relative to the current directory

        .EXAMPLE

        Install the latest version of the framework using the default package location.

        Install-CoreAlm

        .EXAMPLE

        Install the latest version of the framework and specify a different package location

        Install-CoreAlm -packagesFolder "c:\myPackageCache"

    #>
	Param(	
		[Parameter(Mandatory=$false)]
        [string]$packagesFolder = '.\solutions\packages'
    )
	
    $nugetUrl = "https://nexus.icaptools.com/nexus/service/local/nuget/fusion-core-nuget-release"
	$almPackageName = "Fusion.Core.ALM"

    Write-Host "Installing latest $almPackageName nuget package ..." -ForegroundColor Green

    $currentDir = (Get-Item -Path ".\" -Verbose).FullName
	Write-Debug "Current working directory is $currentDir"

	if(-not [System.IO.Path]::IsPathRooted($packagesFolder)) {
		$packagesFolder = Join-Path $currentDir -child $packagesFolder
	}
	    
    if (-Not (Test-Path $packagesFolder)) {
		Write-Debug "Packages folder not found.  Creating packages folder."
        New-Item -ItemType directory -Path $packagesFolder | out-null
    } 

	$packagesFolder = Resolve-Path $packagesFolder
	
    $latestPackageUrl = _Get-LatestPackageUrl "$nugetUrl/Packages" $almPackageName

    $result = _Get-PackageByUrl $latestPackageUrl $packagesFolder

    $packageRoot = (split-path $result.Path)

    if($result.Downloaded) {
        $packageFolder = _Install-Package $result.Path $packageRoot
        Write-Host "Successfully installed '$($result.Name) $($result.Version)'."
    }
    else {
        Write-Host "'$($result.Name) $($result.Version)' already installed."
    }

    _Create-Junction $packageRoot


    # finalise
    Write-Host
    Write-Host "Fusion.Core.Alm package installed and ready to use" -Foreground Green
    Write-Host
    Write-Host @"
Run the following command to load the ALM framework:

    Import-Module -Name .\framework\modules\Core.Alm -Force -DisableNameChecking

Once run, the following commands will be available:
    Invoke-Build
    Invoke-Deploy

    ... plus many others

Run the following command for a full list of commands 
    PS> Get-Command -Module Core.Alm | select Name

Run the Get-Help <cmdlet name>  -detailed command for help about each cmdlet.
    e.g. PS> get-help Invoke-Build -detailed
"@

    Write-Host
    Write-Host "Complete" -ForegroundColor Green

}

function Update-IcapPoshUtils {
     <#

        .SYNOPSIS

        Installs the latest version of the ICAP PowerShell utilities.

        .DESCRIPTION

        Read more here http://confluence.icaptools.com/display/CoreTools/Getting+started+with+the+ALM+framework

        .EXAMPLE

        Install the latest version of the ICAP PowerShell utilities

        Update-IcapPoshUtils

    #>

    (new-object Net.WebClient).DownloadString("https://nexus.icaptools.com/nexus/service/local/repositories/icap-poshutils-release/content/ICAP.PoshUtils.Bootstrap/latest/ICAP.PoshUtils.Bootstrap-latest.psm1") | iex
}


Export-ModuleMember -function @("Install-CoreAlm", "Update-IcapPoshUtils")
