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

function services { Start-Project -hash @{Path='APMG.Services.WCF';Solution='.\APMG.Services.WCF.sln'}}
function portal { Start-Project -hash @{Path='APMG.Portal.WCF';Solution='.\APMG.Portal.WCF.sln'}}
function admin { Start-Project -hash @{Path='APMG.Admn.WCF';Solution='.\APMG.Admin.WCF.sln'}}
function booking { Start-Project -hash @{Path='APMG.Services.WCF\APMG.Services.WCF.Booking';Solution='.\APMG.Services.WCF.Booking.sln'}}

function  work { Set-Location-Dev $work }
function  dev { Set-Location-Dev $dev }