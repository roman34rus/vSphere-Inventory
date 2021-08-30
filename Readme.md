# vSphere Inventory

Набор скриптов для сбора данных с одного или нескольких серверов vCenter.
Собранные данные записываются в файлы в формате CSV в каталог DataStore.
Лог выполнения: Scripts\lastrun.log.
Тестировалось на серверах vCenter 5.0-7.02.

# Собираемые данные

Кластеры хостов
* vCenter
* Datacenter
* Cluster
* HAEnabled
* DRSEnabled
* DRSAutomationLevel
* HostCount
* PhysCores
* PhysRAMGB
* VMCount
* VirtCores
* VirtRAMGB
* V2PCoresRatio
* VirtRAMPercent

Хосты
* vCenter
* Datacenter
* Parent
* Host
* ESXiVersion
* ESXiBuild
* LicenseKey
* Manufacturer
* Model 
* CPUType
* CPUCount
* PhysCores
* LogicCores
* PhysRAMGB
* VMCount
* VirtCores
* VirtRAMGB
* V2PCoresRatio
* RAMOverprovisionGB

Аплинки хостов
* vCenter
* Datacenter
* Parent
* Host
* Uplink
* Device
* Address
* Port

Снапшоты
* vCenter
* Datacenter
* VM
* Name
* Description
* Created
* SizeGB

Хранилища
* vCenter
* Datacenter
* Parent
* Storage
* Type
* MultipleHostAccess
* SIOCEnabled
* CapacityGB
* ProvisionedGB
* UncommittedGB
* FreeSpaceGB
* OverprovisionGB

Серверы vCenter
* vCenter
* Version
* Build

Виртуальные машины
* vCenter* Datacenter* VM Path* VM Name* CPU Count* RAM GB* Provisioned Space GB* Used Space GB* DNS Name* IP* OS* Power State* Notes* CustomFields

# Требования

* PowerShell 5.0.
* VMware vSphere PowerCli 6.5.
* Учетная запись, от имени которой будут запускаться скрипты, должна иметь права ReadOnly на серверах vCenter и права записи в каталоги DataStore, Scripts.

# Использование

1. Скопировать каталоги DataStore и Scripts на компьютер, имеющий доступ к серверам vCenter. Они должны находиться в одном каталоге.
2. Скопировать файл Scripts\Settings.ps1.example в Scripts\Settings.ps1.
3. Задать в файле Scripts\Settings.ps1 имена/адреса серверов vCenter.
4. Запустить скрипт Scripts\Run-Inventory.cmd вручную или настроить периодический запуск средствами планировщика задач.

# История изменений

v1.9
Исправлены ошибки, обновлено описание.

v1.8
Исправлены ошибки.

v1.7
Добавлен сбор информации о кластерах ESXi.
Небольшие изменения в коде и CSV-файлах.

v1.6
Добавлен сбор лицензионных ключей ESXi.

v1.5
Добавлена поддержка Powershell 5.0 и PowerCLI 6.5.
Добавлено логирование выполнения скрипта в файл lastrun.log.

v1.4
Добавлен расчет переподписки (overprovision) на ресурсы (CPU, RAM, storage).

v1.3
Добавлен сбор информации о виртуальных машинах (имена, адреса, выделенные ресурсы, аннотации и атрибуты).

v1.2
Добавлен сбор информации о статусе Storage IO Control.
Путь к каталогу DataStore убран из параметров, генерируется автоматически.

v1.1 
Добавлен сбор информации о снапшотах виртуальных машин.

v1.0
Исходная версия.