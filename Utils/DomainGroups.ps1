$wi = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$wi.groups |% {$_.Translate([System.Security.Principal.ntaccount])} |                                             
   select @{n='Domain';e={$_.value.split('\')[-2]}},                                                                  
   @{n='Account';e={$_.value.split('\')[-1]}} |                                                                
   Sort domain | ft account -GroupBy domain   