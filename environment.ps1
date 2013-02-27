$dev = 'E:\Code'
$work = 'C:\APMG\Marlin'
$services = @{Path='APMG.Services.WCF';Solution='.\APMG.Services.WCF.sln'}
$portal = 'APMG.Portal.sln'
$admin = 'APMG.Admin.sln'

function Start-Project {
	Param ($hash)
	
	Set-Location-Dev $work
	
	cd $hash.Path
	Start-VisualStudio $hash.Solution
	
	cd $work\'LocalBuild'
}

function services { Start-Project -hash @{Path='APMG.Services';Solution='.\APMG.Services.sln'}}
function portal { Start-Project -hash @{Path='APMG.Portal';Solution='.\APMG.Portal.sln'}}
function admin { Start-Project -hash @{Path='APMG.Admin';Solution='.\APMG.Admin.sln'}}
function booking { Start-Project -hash @{Path='APMG.Services\APMG.Services.WCF.Booking';Solution='.\APMG.Services.WCF.Booking.sln'}}

function  work { Set-Location-Dev $work }
function  dev { Set-Location-Dev $dev }