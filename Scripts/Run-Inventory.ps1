# Сбор данных об инфраструктуре vSphere
# Данные сохраняются в файлы CSV
#
# Любимов Роман, 2015-2020

Clear-Host

Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -DefaultVIServerMode:Single -ParticipateInCEIP:$false -Confirm:$false -Scope:Session | Out-Null

."$PSScriptRoot\Settings.ps1"
."$PSScriptRoot\Get-vCenterInfo.ps1"
."$PSScriptRoot\Get-HostInfo.ps1"
."$PSScriptRoot\Get-HostUplinkInfo.ps1"
."$PSScriptRoot\Get-HostClusterInfo.ps1"
."$PSScriptRoot\Get-StorageInfo.ps1"
."$PSScriptRoot\Get-SnapshotInfo.ps1"
."$PSScriptRoot\Get-VMInfo.ps1"

$DataStorePath = (Get-Item $PSScriptRoot).Parent.FullName + "\DataStore"

$CurrentDateTime = (Get-Date -uformat "%Y%m%d%H%M%S").ToString()

$vCenterInfoArr = @()
$HostInfoArr = @()
$HostUplinkInfoArr = @()
$HostClusterInfoArr = @()
$StorageInfoArr = @()
$SnapshotInfoArr = @()
$VMInfoArr = @()

$vCenterServers | ForEach-Object {
	Write-Host "$(Get-Date) Connect-VIServer $_"
	$vc = Connect-VIServer -Server $_
	
	Write-Host "$(Get-Date) Get-vCenterInfo"
	$vCenterInfoArr += Get-vCenterInfo $vc
	
	Write-Host "$(Get-Date) Get-Datacenter"
	Get-Datacenter | ForEach-Object {
		$dc = $_
		$vcName = $vc.Name
		$dcName = $_.Name
		
		Write-Host "$(Get-Date) Get-VMHost"
		$dc | Get-VMHost | Sort-Object Parent, Name | ForEach-Object {
			Write-Host "$(Get-Date) Get-HostInfo $($_.Name)"
			$HostInfoArr += Get-HostInfo $_ $vcName $dcName
			
			Write-Host "$(Get-Date) Get-HostUplinkInfo $($_.Name)"
			$HostUplinkInfoArr += Get-HostUplinkInfo $_ $vcName $dcName
		}
		
		Write-Host "$(Get-Date) Get-Cluster"
		$dc | Get-Cluster | Sort-Object Name | ForEach-Object {
			Write-Host "$(Get-Date) Get-HostClusterInfo"
			$clusterName = $_.Name
			$HostInfoArrFiltered = $HostInfoArr | Where-Object { $_.vCenter -eq $vcName -and $_.Datacenter -eq $dcName -and $_.Parent -eq $clusterName }
			$HostClusterInfoArr += Get-HostClusterInfo $_ $vcName $dcName $HostInfoArrFiltered
		}

		Write-Host "$(Get-Date) Get-StorageInfo"
		$StorageInfoArr += Get-StorageInfo $_ $vcName
		
		Write-Host "$(Get-Date) Get-VM"
		$dc | Get-VM | ForEach-Object {
			Write-Host "$(Get-Date) Get-SnapshotInfo $($_.Name)"
			$SnapshotInfoArr += Get-SnapshotInfo $_ $vcName $dcName
			
			Write-Host "$(Get-Date) Get-VMInfo $($_.Name)"
			$VMInfoArr += Get-VMInfo $_ $vcName $dcName
		}
	}
	
	Write-Host "$(Get-Date) Disconnect-VIServer $_"
	Disconnect-VIServer -Server $vc -Force -Confirm:$false
}

$delimiter = "`t"
$encoding = "Unicode"

$vCenterInfoArr | Export-Csv -Path ($DataStorePath + "\vCenterInfo\" + $CurrentDateTime + ".csv") -Delimiter $delimiter -Encoding $encoding -NoTypeInformation
$HostInfoArr | Export-Csv -Path ($DataStorePath + "\HostInfo\" + $CurrentDateTime + ".csv") -Delimiter $delimiter -Encoding $encoding -NoTypeInformation
$HostUplinkInfoArr | Export-Csv -Path ($DataStorePath + "\HostUplinkInfo\" + $CurrentDateTime + ".csv") -Delimiter $delimiter -Encoding $encoding -NoTypeInformation
$HostClusterInfoArr | Export-Csv -Path ($DataStorePath + "\HostClusterInfo\" + $CurrentDateTime + ".csv") -Delimiter $delimiter -Encoding $encoding -NoTypeInformation
$StorageInfoArr | Export-Csv -Path ($DataStorePath + "\StorageInfo\" + $CurrentDateTime + ".csv") -Delimiter $delimiter -Encoding $encoding -NoTypeInformation
$SnapshotInfoArr | Sort-Object vCenter, Datacenter, VM, Created | Export-Csv -Path ($DataStorePath + "\SnapshotInfo\" + $CurrentDateTime + ".csv") -Delimiter $delimiter -Encoding $encoding -NoTypeInformation
$VMInfoArr | Sort-Object vCenter, Datacenter, "VM Path", "VM Name" | Export-Csv -Path ($DataStorePath + "\VMInfo\" + $CurrentDateTime + ".csv") -Delimiter $delimiter -Encoding $encoding -NoTypeInformation
