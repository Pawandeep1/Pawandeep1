Param ([switch]$System, 
       [switch]$Disks, [switch]$Network)

import-module pawandeep

if ($System -eq $false -and $Disks -eq $false -and $Network -eq $false) {
	echo "Uses functions in previous labs as a module for this perticular lab."
	echo "Add Param arguments to get more specific results."
     pawandeep-System;
     pawandeep-Disks;pawandeep-Network;
} else{
     if ($System) {
         pawandeep-System;
     }
     if ($Disks) {
         pawandeep-Disks;
     }
     if ($Network) {
         pawandeep-Network;
     }
}