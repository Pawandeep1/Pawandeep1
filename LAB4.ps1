function get-hardwareinfo {
Write-Host "System Hardware Description:"
get-CimInstance win32_computersystem |Format-List
}

function get-osindetail {
Write-Host "System Information:"
get-CimInstance win32_operatingsystem | Format-List name, version
}

function get-processorindetails {
Write-Host "Processor Information:"
gwmi -ClassName win32_processor | fl Description, MaxClockSpeed, NumberOfCores,
@{ n="L1CacheSize"; e={switch($_.L1CacheSize){$Null {$var="data unavailable"; $var}}; 
 if($Null -ne $_.L1CacheSize){ $_.L1CacheSize }}},
@{ n="L2CacheSize"; e={switch($_.L2CacheSize){$Null {$var="data unavailable"; $var}}; 
 if($Null -ne $_.L2CacheSize){ $_.L2CacheSize }}},
@{ n="L3CacheSize"; e={switch($_.L3CacheSize){$Null {$var="data unavailable"; $var}};
 if($Null -ne $_.L3CacheSize){ $_.L3CacheSize }}}
}

function get-memoryindetails {
Write-Host "TOTAL RAM and INFORMATION:"
$cinit = 0
gwmi -ClassName win32_physicalmemory |
foreach {
new-object -TypeName psobject -Property @{
Manufacturer = $_.manufacturer
Description = $_.Description
"Size(GB)" = $_.capacity/1gb
Bank = $_.Banklabel
Slot = $_.devicelocator
}
$cinit += $_.capacity/1gb
} |
format-Table Manufacturer, Description, "Size(GB)", Bank, Slot
"Total RAM: ${cinit}GB"
}

function get-mydisks {
Write-Host "Drive Information:"
Get-WmiObject -ClassNAME Win32_DiskDrive | 
where DeviceID -ne $null |
Foreach-Object {
$drive = $_
$drive.GetRelated("Win32_DiskPartition") |
    foreach {$logicaldisk= $_.GetRelated("win32_LogicalDisk");
    if ($logicaldisk.size) {
        New-Object -TypeName PSobject -Property @{
          Manufacturer = $drive.manufacturer
          DriveLetter = $logicaldisk.DeviceID
          Model = $drive.model
          Size = [string]($logicaldisk.size/1gb -as [int])+"GB"
          Free =[string]((($logicaldisk.freespace / $logicaldisk.size) * 100) -as [int]) +"%"
          FreeSpace= [String]($logicaldisk.freespace / 1gb -as [int])+ "GB"
        } |format-table -AutoS Manufacturer, Model, size, Free, FreeSpace
    }
  }
}}

function get-networkinface {
Write-Host "Network information in detail:"
Get-Ciminstance -ClassName Win32_networkadapterconfiguration |
Where-Object { $_.ipenabled -eq "true"} |
ft -AutoSize Description, Index, IPAddress, IPSubnet,
@{ n="DNSDomain"; e={switch($_.DNSDomain){$Null {$var="data unavailable";$var }}; 
 if($Null -ne $_.DNSdomain){ $_.DNSdomain }}},
@{ n="DNSServersearchorder"; e={switch($_.DNSServersearchorder){$Null {$var="data unavailable"; $var}};
 if($Null -ne $_.DNSServersearchorder){ $_.DNSServersearchorder }}}
}

function get-videoinfor {
Write-Host "GPU details:"
$HD=(get-wmiobject -classname win32_Videocontroller).CurrentHorizontalResolution -as [string]
$VD=(get-wmiobject -class win32_videocontroller).CurrentVerticalResolution -as [String]
$Bit=(get-wmiobject -className Win32_videocontroller).CurrentbitsPerPixel -as [string]
$sum= $HD + " x " + $VD + " and " + $Bit + " bit"
get-wmiobject -classname win32_Videocontroller |
format-List @{n="Video Card Vendor"; e={$_.AdapterCompatibility}}, Description, @{n="Resolution"; e={$sum -as [String] }}
}

get-hardwareinfo
get-osindetail
get-processorindetails
get-memoryindetails
get-mydisks
get-networkinface
get-videoinfor
