# Функция для получения информации о снапшотах.
# Параметры: Datacenter, имя vCenter.
#
# Любимов Роман, 2015

function Get-SnapshotInfo
{
	Param(
		[Parameter(Mandatory = $True)]
		[VMware.VimAutomation.Types.Datacenter] $dc,
		
		[Parameter(Mandatory = $True)]
		[string] $vcName
	)
	
	$report = @()

	Get-VM | Get-Snapshot | % { 
		$SizeGB = [Math]::Round($_.SizeGB, 3)
		
		$reportLine = New-Object psobject
		$reportLine | Add-Member -Type noteproperty -Name vCenter -Value $vcName
		$reportLine | Add-Member -Type noteproperty -Name Datacenter -Value $dc.Name
		$reportLine | Add-Member -Type noteproperty -Name VM -Value $_.VM
		$reportLine | Add-Member -type noteproperty -name Name -Value $_.Name
		$reportLine | Add-Member -type noteproperty -name Description -Value $_.Description
		$reportLine | Add-Member -type noteproperty -name Created -Value $_.Created
		$reportLine | Add-Member -type noteproperty -name SizeGB -Value $SizeGB
		
		$report += $reportLine
	}
	
	return $report | sort VM, Created
}