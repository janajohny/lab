provider "azurerm"{
    features{}
}
#Resource Group Creation
resource "azurerm_resource_group" "myLinuxRg"{
    name=var.rgname
    location=var.location
}

#Vnet creation
resource "azurerm_virtual_network" "myLinuxVnet" {
    name                = var.vnetName
    address_space       = var.vnet_address_space
    location            = var.location
    resource_group_name = azurerm_resource_group.myLinuxRg.name
}

#subnet Creation
resource "azurerm_subnet" "myLinuxsubnet" {
    name                 = var.subnetName
    resource_group_name  = azurerm_resource_group.myLinuxRg.name
    virtual_network_name = azurerm_virtual_network.myLinuxVnet.name
    address_prefixes     = var.subnet_address_space
}

#NSG Creation with rule
resource "azurerm_network_security_group" "myNSG" {
    name                = var.NSGName
    location            = var.location
    resource_group_name = azurerm_resource_group.myLinuxRg.name

    security_rule {
        name                       = "SSH"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

}
resource "azurerm_subnet_network_security_group_association" "MyNSG-Subnet-association" {
  subnet_id                 = azurerm_subnet.myLinuxsubnet.id
  network_security_group_id = azurerm_network_security_group.myNSG.id
}

#Create Public IP 1
resource "azurerm_public_ip" "myPublicIP1" {
  name                = var.VM1PublicIPName
  resource_group_name = azurerm_resource_group.myLinuxRg.name
  location            = azurerm_resource_group.myLinuxRg.location
  allocation_method   = "Static"

}

#
# Create network interface 1
resource "azurerm_network_interface" "myLinuxNIC1" {
    name                      = var.linux1NICName
    location                  = var.location
    resource_group_name       = azurerm_resource_group.myLinuxRg.name

    ip_configuration {
        name                          = "myNicConfiguration1"
        subnet_id                     = azurerm_subnet.myLinuxsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myPublicIP1.id
    }

 
}


#create Virtual machine 1
resource "azurerm_linux_virtual_machine" "myLinuxVm1" {
    name                  = var.vm1Name
    location              = var.location
    resource_group_name   = azurerm_resource_group.myLinuxRg.name
    network_interface_ids = [azurerm_network_interface.myLinuxNIC1.id]
    size                  = "Standard_B2ms"

    os_disk {
        name              = "myOsDisk1"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    admin_username = var.admin_username
    admin_password = var.admin_password
    disable_password_authentication = false
    
    provisioner "remote-exec" {
        inline =   [
            "sudo apt-get update",
            "sudo apt-get install ansible -y",
            "sudo apt-get update"
        ]
        connection {
            host = self.public_ip_address
            user =  self.admin_username
            password =  self.admin_password
        }
    }
}


  
