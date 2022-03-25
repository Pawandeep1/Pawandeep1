Get-Ciminstance -ClassName Win32_networkadapterconfiguration | Where-Object { $_.ipenabled -eq "true"} | ft -AutoSize Description, Index, IPAddress, IPSubnet, DNSDomain,
DNSServerSearchOrder