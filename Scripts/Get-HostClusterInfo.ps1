# Функция для получения информации о кластерах ESXi
# Параметры: кластер ESXi, имя vCenter, имя Datacenter, массив данных о хостах ESXi кластера
#
# Любимов Роман, 2020

function Get-HostClusterInfo
{
	Param(
		[Parameter(Mandatory = $True)]
		[VMware.VimAutomation.Types.Cluster] $cluster,
		
		[Parameter(Mandatory = $True)]
		[string] $vcName,
		
		[Parameter(Mandatory = $True)]
		[string] $dcName,

		[Parameter(Mandatory = $True)]
		[array] $HostInfoArr
	)

	$report = New-Object psobject
		
	$report | Add-Member -type noteproperty -name vCenter -Value $vcName
	$report | Add-Member -type noteproperty -name Datacenter -Value $dcName
	$report | Add-Member -type noteproperty -name Cluster -Value $cluster.Name
	$report | Add-Member -type noteproperty -name HAEnabled -Value $cluster.HAEnabled
	$report | Add-Member -type noteproperty -name DRSEnabled -Value $cluster.DrsEnabled
	$report | Add-Member -type noteproperty -name DRSAutomationLevel -Value $cluster.DrsAutomationLevel
	$report | Add-Member -type noteproperty -name HostCount -Value $HostInfoArr.Count

	$report | Add-Member -type noteproperty -name PhysCores -Value ($HostInfoArr | Measure-Object -Property PhysCores -Sum).Sum
	$report | Add-Member -type noteproperty -name PhysRAMGB -Value ($HostInfoArr | Measure-Object -Property PhysRAMGB -Sum).Sum
	$report | Add-Member -type noteproperty -name VMCount -Value ($HostInfoArr | Measure-Object -Property VMCount -Sum).Sum
	$report | Add-Member -type noteproperty -name VirtCores -Value ($HostInfoArr | Measure-Object -Property VirtCores -Sum).Sum
	$report | Add-Member -type noteproperty -name VirtRAMGB -Value ($HostInfoArr | Measure-Object -Property VirtRAMGB -Sum).Sum
	
	$v2pCoresRatio = "Error"
	if ($report.PhysCores -gt 0) {
		$v2pCoresRatio = [Math]::Round($report.VirtCores / $report.PhysCores, 1)
	}
	$report | Add-Member -type noteproperty -name V2PCoresRatio -Value $v2pCoresRatio
	
	$virtRAMPercent = "Error"
	if ($report.PhysRAMGB -gt 0) {
		$virtRAMPercent = [Math]::Round($report.VirtRAMGB / $report.PhysRAMGB * 100)
	}
	$report | Add-Member -type noteproperty -name VirtRAMPercent -Value $virtRAMPercent

	return $report
}