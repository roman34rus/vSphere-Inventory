# Функция для получения информации о виртуальных машинах
# Параметры: ВМ, имя vCenter, имя Datacenter
#
# Любимов Роман, 2015-2021

function Get-VMInfo
{
	Param(
		[Parameter(Mandatory = $True)]
		[VMware.VimAutomation.Types.VirtualMachine] $vm,
		
		[Parameter(Mandatory = $True)]
		[string] $vcName,
		
		[Parameter(Mandatory = $True)]
		[string] $dcName
	)
	
	# Получаем путь к ВМ в VMs and Templates
	$path = $vm.Folder.Name
	$currentFolder = $vm.Folder
	while ($currentFolder.Name -ne $null) {
		$currentFolder = $currentFolder.Parent
		$path = $currentFolder.Name + "/" + $path
	}
	
	# Выбираем адреса IPv4, объединяем в строку
	$ip = ""
	$vm.Guest.IPAddress | ForEach-Object {
		if ($_ -Match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}") {
			$ip += $_ + " "
		}
	}
		
	# Удаляем из аннотации переносы строк и табуляцию
	$notes = $vm.Notes -replace "`r"," " -replace "`n"," " -replace "`t"," "
	
	# Названия Сustom Fields
	$cfKeys = "Дата вывода из эксплуатации", "Дата создания", "Заказчик", "Исполнитель", "Кем создана", "Куратор ДИТ", "Проект"
	
	$report = New-Object psobject
	$report | Add-Member -type noteproperty -name vCenter -Value $vcName
	$report | Add-Member -type noteproperty -name Datacenter -Value $dcName
	$report | Add-Member -Type NoteProperty -Name "VM Path" -Value $path
	$report | Add-Member -Type NoteProperty -Name "VM Name" -Value $vm.Name
	$report | Add-Member -Type NoteProperty -Name "CPU Count" -Value $vm.NumCpu
	$report | Add-Member -Type NoteProperty -Name "RAM GB" -Value $vm.MemoryGB
	$report | Add-Member -Type NoteProperty -Name "Provisioned Space GB" -Value ([Math]::Round($vm.ProvisionedSpaceGB))
	$report | Add-Member -Type NoteProperty -Name "Used Space GB" -Value ([Math]::Round($vm.UsedSpaceGB))
	$report | Add-Member -Type NoteProperty -Name "DNS Name" -Value $vm.Guest.HostName
	$report | Add-Member -Type NoteProperty -Name "IP" -Value $ip
	$report | Add-Member -Type NoteProperty -Name "OS" -Value $vm.Guest.OSFullName
	$report | Add-Member -Type NoteProperty -Name "Power State" -Value $vm.PowerState
	$report | Add-Member -Type NoteProperty -Name "Notes" -Value $notes
	$cfKeys | ForEach-Object {
		$report | Add-Member -Type NoteProperty -Name $_ -Value $vm.CustomFields[$_]
	}
		
	return $report
}