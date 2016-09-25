& git submodule update --init --recursive
$profileDir = Split-Path -parent $profile
$poshGitDir = Join-Path $profileDir "posh-git"
if (![System.IO.Directory]::Exists($profileDir)) {[System.IO.Directory]::CreateDirectory($profileDir)}
if (![System.IO.Directory]::Exists($profileDir)) {[System.IO.Directory]::CreateDirectory($poshGitDir)}
Copy-Item -Path ./*.ps1 -Destination $profileDir -Force -Exclude "bootstrap.ps1"
Copy-Item -Path ./posh-git/** -Destination $poshGitDir -Force -Include **
Copy-Item -Path ./homeFiles/** -Destination $home -Include **
Remove-Variable profileDir
Remove-Variable poshGitDir
