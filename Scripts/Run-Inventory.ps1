# Сбор данных об инфраструктуре vSphere.
# Данные сохраняются в файлы CSV.
#
# Любимов Роман, 2015

Clear-Host
Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue
Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -DefaultVIServerMode:Single -Confirm:$false -Scope:Session

."$PSScriptRoot\Settings.ps1"
."$PSScriptRoot\Get-vCenterInfo.ps1"
."$PSScriptRoot\Get-HostInfo.ps1"
."$PSScriptRoot\Get-HostUplinkInfo.ps1"
."$PSScriptRoot\Get-StorageInfo.ps1"
."$PSScriptRoot\Get-SnapshotInfo.ps1"
."$PSScriptRoot\Get-VMInfo.ps1"

$DataStorePath = (Get-Item $PSScriptRoot).Parent.FullName + "\DataStore"

$CurrentDateTime = (Get-Date -uformat "%Y%m%d%H%M%S").ToString()

$vCenterInfoArr = @()
$HostInfoArr = @()
$HostUplinkInfoArr = @()
$StorageInfoArr = @()
$SnapshotInfoArr = @()
$VMInfoArr = @()

$vCenterServers | % {
	$vc = Connect-VIServer -Server $_
	
	$vCenterInfoArr += Get-vCenterInfo $vc
	
	Get-Datacenter | % {
		$vcName = $vc.Name
		$dcName = $_.Name
		
		$_ | Get-VMHost | sort Parent, Name | % {
			$HostInfoArr += Get-HostInfo $_ $vcName $dcName
			$HostUplinkInfoArr += Get-HostUplinkInfo $_ $vcName $dcName
		}
				
		$StorageInfoArr += Get-StorageInfo $_ $vcName
		
		$_ | Get-VM | % {
			$SnapshotInfoArr += Get-SnapshotInfo $_ $vcName $dcName
			$VMInfoArr += Get-VMInfo $_ $vcName $dcName
		}
	}
		
	Disconnect-VIServer -Server $vc -Force -Confirm:$false
}

$delimiter = "`t"
$encoding = "Unicode"

$vCenterInfoArr | Export-Csv -Path ($DataStorePath + "\vCenterInfo\" + $CurrentDateTime + ".csv") -Delimiter $delimiter -Encoding $encoding -NoTypeInformation
$HostInfoArr | Export-Csv -Path ($DataStorePath + "\HostInfo\" + $CurrentDateTime + ".csv") -Delimiter $delimiter -Encoding $encoding -NoTypeInformation
$HostUplinkInfoArr | Export-Csv -Path ($DataStorePath + "\HostUplinkInfo\" + $CurrentDateTime + ".csv") -Delimiter $delimiter -Encoding $encoding -NoTypeInformation
$StorageInfoArr | Export-Csv -Path ($DataStorePath + "\StorageInfo\" + $CurrentDateTime + ".csv") -Delimiter $delimiter -Encoding $encoding -NoTypeInformation
$SnapshotInfoArr | sort vCenter, Datacenter, VM, Created | Export-Csv -Path ($DataStorePath + "\SnapshotInfo\" + $CurrentDateTime + ".csv") -Delimiter $delimiter -Encoding $encoding -NoTypeInformation
$VMInfoArr | sort vCenter, Datacenter, "VM Path", "VM Name" | Export-Csv -Path ($DataStorePath + "\VMInfo\" + $CurrentDateTime + ".csv") -Delimiter $delimiter -Encoding $encoding -NoTypeInformation
