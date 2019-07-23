# Source: https://docs.microsoft.com/en-us/sharepoint/administration/sharepoint-server-2016-dev-test-environment-in-azure

$cred = Get-StoredCredential -Target "szuinside"
Connect-AzAccount -Credential $cred

$subscrName = Get-AzSubscription | Sort Name | Select Name

$subscr = $subscrName.Name
Select-AzSubscription -SubscriptionName $subscr

Get-AzResourceGroup | Sort ResourceGroupName | Select ResourceGroupName

$rgName="kbo-dev-sharepoint"
$locName="West Europe"
New-AzResourceGroup -Name $rgName -Location $locName

# create network
$locName=(Get-AzResourceGroup -Name $rgName).Location
$spSubnet=New-AzVirtualNetworkSubnetConfig -Name SP2016Subnet -AddressPrefix 10.0.0.0/24
New-AzVirtualNetwork -Name SP2016Vnet -ResourceGroupName $rgName -Location $locName -AddressPrefix 10.0.0.0/16 -Subnet $spSubnet -DNSServer 10.0.0.4
$rule1=New-AzNetworkSecurityRuleConfig -Name "RDPTraffic" -Description "Allow RDP to all VMs on the subnet" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$rule2 = New-AzNetworkSecurityRuleConfig -Name "WebTraffic" -Description "Allow HTTP to the SharePoint server" -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix "10.0.0.6/32" -DestinationPortRange 80
New-AzNetworkSecurityGroup -Name SP2016Subnet -ResourceGroupName $rgName -Location $locName -SecurityRules $rule1, $rule2
$vnet=Get-AzVirtualNetwork -ResourceGroupName $rgName -Name SP2016Vnet
$nsg=Get-AzNetworkSecurityGroup -Name SP2016Subnet -ResourceGroupName $rgName
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name SP2016Subnet -AddressPrefix "10.0.0.0/24" -NetworkSecurityGroup $nsg
$vnet | Set-AzVirtualNetwork

# Create the adVM virtual machine
$vmName="adVM"
$vmSize="Standard_D1_v2"
$vnet=Get-AzVirtualNetwork -Name SP2016Vnet -ResourceGroupName $rgName
$pip = New-AzPublicIpAddress -Name ($vmName + "-PIP") -ResourceGroupName $rgName -Location $locName -AllocationMethod Dynamic
$nic = New-AzNetworkInterface -Name ($vmName + "-NIC") -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -PrivateIpAddress 10.0.0.4
$vm=New-AzVMConfig -VMName $vmName -VMSize $vmSize
$vm=Set-AzVMOSDisk -VM $vm -Name ($vmName +"-OS") -DiskSizeInGB 128 -CreateOption FromImage -StorageAccountType "Standard_LRS"
$diskConfig=New-AzDiskConfig -AccountType "Standard_LRS" -Location $locName -CreateOption Empty -DiskSizeGB 20
$dataDisk1=New-AzDisk -DiskName ($vmName + "-DataDisk1") -Disk $diskConfig -ResourceGroupName $rgName
$vm=Add-AzVMDataDisk -VM $vm -Name ($vmName + "-DataDisk1") -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 1
$cred=Get-Credential -Message "Type the name and password of the local administrator account for adVM."
$vm=Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName adVM -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm=Set-AzVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
$vm=Add-AzVMNetworkInterface -VM $vm -Id $nic.Id
New-AzVM -ResourceGroupName $rgName -Location $locName -VM $vm

# Do this inside of azVM
Get-Disk | Where PartitionStyle -eq "RAW" | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "WSAD Data"
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName brew.szuinside.com -DatabasePath "F:\NTDS" -SysvolPath "F:\SYSVOL" -LogPath "F:\Logs"
Restart server
Add-WindowsFeature RSAT-ADDS-Tools
New-ADUser -SamAccountName sp_farm_db -AccountPassword (read-host "Set user password" -assecurestring) -name "sp_farm_db" -enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false