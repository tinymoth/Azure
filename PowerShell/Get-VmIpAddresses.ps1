# Get a list of VMs, their IP addresses and power status
# it may break if the vm has more than one nic
# it won't list vm's without a nic
# it may break if a vm has more than one power state

$vms = get-azurermvm
$nics = get-azurermnetworkinterface | where VirtualMachine -NE $null #skip Nics with no VM

$nicTable = foreach($nic in $nics)
{
    $vm = $vms | where-object -Property Id -EQ $nic.VirtualMachine.id
    $powerStatus = (((Get-AzureRmVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status).Statuses).code -like "PowerState/*").split('/')[1]
    $prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
    $alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
    $nicObject = @{
        ResourceGroupName = $vm.ResourceGroupName
        VmName = $($vm.Name)
        IpAddress = $prv
        Allocation = $alloc
        PowerStatus = $($powerStatus)
    }
    New-Object psobject -Property $nicObject
}
$nicTable | ft #| ?{$_.PowerStatus -like "*running"}

# Get-AzureRmVm | Get-AzureRmVm -Status | select ResourceGroupName, Name, @{n="Status"; e={$_.Statuses[1].DisplayStatus}}
# Get-AzureRmResource `
# | ?{$_.ResourceType -eq "Microsoft.Compute/virtualMachines"} `
# | foreach {get-azurermvm -ResourceGroupName $_.ResourceGroupName -Name $_.ResourceName -Status `
# | ?{$_.Statuses[1].DisplayStatus -match "VM Running"} `
# | select Name, ResourceGroupName, @{Label='VMStatus';Expression={"Running"}}}