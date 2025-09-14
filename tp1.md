# 1. Prérequis

## 🌞 Déterminer quel algorithme de chiffrement utiliser pour vos clés:

- OpenSSH a déclaré ssh-rsa obsolète.
- L'entreprise SSH dérière le protocol SSH préconise d'utiliser ed25519 étant le dernier algo mis en place et Azure n'authorise uniquement RSA ou Ed25519.

<br>

## 🌞 Générer une paire de clés pour ce TP:

```shell
ssh-keygen -f ~/cloud_tp1_key -t ed25519
```

- Utilisation d'une passphrase

<br>

## 🌞 Configurer un agent SSH sur votre poste:

- Utilisation de l'agent SSH directement dans le PowerShell

<br>
<br>
<br>

# 2. Spawn des VMs

## 🌞 Connectez-vous en SSH à la VM pour preuve:

- `.ssh\cloud_tp1_key.pub`
- Création d'une VM:
    - **Subscription:** Subscription
    - **Resource group:** Main
    - **Virtual machine name:** TP1
    - **Region:** (Europe) France Central
    - **Availability options:** No infrastructure redundancy required
    - **Image:** Ubuntu Server 24.04 LTS
    - **Authentication type:** SSH public key
    - **Username:** azureuser
    - **SSH public key source:** Use existing public key
    - **SSH public key:** ssh-ed25519...
    - **Public inbound ports:** Allow selected ports
    - **Select inbound ports:** SSH (22)

```shell
ssh -i .ssh/cloud_tp1_key azureuser@4.211.156.221
```

<br>

## 🌞 Créez une VM depuis le Azure CLI:

- Installation de Azure CLI

```shell
az login
az group create --name TP1 --location francecentral
az vm create -g TP1 -n TP1vm --image Ubuntu2204 --admin-username azureuser --ssh-key-values ~/.ssh/cloud_tp1_key.pub --size Standard_D2s_v3
```

- Résultat:

```json
{
  "fqdns": "",
  "id": "/subscriptions/...",
  "location": "francecentral",
  "macAddress": "00-0D-3A-E7-AE-FC",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.4",
  "publicIpAddress": "4.251.118.152",
  "resourceGroup": "TP1"
}
```

<br>

## 🌞 Assurez-vous que vous pouvez vous connecter à la VM en SSH sur son IP publique:

```shell
ssh -i .ssh/cloud_tp1_key azureuser@4.251.118.152
```

<br>

## 🌞 Une fois connecté, prouvez la présence...:

```shell
sudo systemctl status walinuxagent.service
sudo systemctl status cloud-init.service
```

<br>

# 3. Terraforming planets infrastructures

## 🌞 Utilisez Terraform pour créer une VM dans Azure:

- Création des fichier `main.tf`, `variables.tf` et `terraform.tfvars`

```shell
az account show --query id
terraform init
terraform plan -out=tfplan
terraform apply
```

- logs:

```shell
azurerm_resource_group.rg: Creating...
azurerm_resource_group.rg: Still creating... [00m10s elapsed]
azurerm_resource_group.rg: Still creating... [00m20s elapsed]
azurerm_resource_group.rg: Creation complete after 29s [id=/subscriptions/a1f37475-cbc7-47b3-8b51-0b9b3029c847/resourceGroups/TP1]
azurerm_virtual_network.vnet: Creating...
azurerm_virtual_network.vnet: Still creating... [00m10s elapsed]
azurerm_virtual_network.vnet: Creation complete after 18s [id=/subscriptions/a1f37475-cbc7-47b3-8b51-0b9b3029c847/resourceGroups/TP1/providers/Microsoft.Network/virtualNetworks/TP1-vnet]
azurerm_subnet.subnet: Creating...
azurerm_subnet.subnet: Still creating... [00m10s elapsed]
azurerm_subnet.subnet: Creation complete after 13s [id=/subscriptions/a1f37475-cbc7-47b3-8b51-0b9b3029c847/resourceGroups/TP1/providers/Microsoft.Network/virtualNetworks/TP1-vnet/subnets/TP1-subnet]
azurerm_network_interface.nic: Creating...
azurerm_network_interface.nic: Still creating... [00m10s elapsed]
azurerm_network_interface.nic: Creation complete after 12s [id=/subscriptions/a1f37475-cbc7-47b3-8b51-0b9b3029c847/resourceGroups/TP1/providers/Microsoft.Network/networkInterfaces/TP1-nic]
azurerm_linux_virtual_machine.vm: Creating...
azurerm_linux_virtual_machine.vm: Still creating... [00m10s elapsed]
azurerm_linux_virtual_machine.vm: Still creating... [00m20s elapsed]
azurerm_linux_virtual_machine.vm: Still creating... [00m30s elapsed]
azurerm_linux_virtual_machine.vm: Still creating... [00m40s elapsed]
azurerm_linux_virtual_machine.vm: Creation complete after 49s [id=/subscriptions/a1f37475-cbc7-47b3-8b51-0b9b3029c847/resourceGroups/TP1/providers/Microsoft.Compute/virtualMachines/TP1-vm]
```

```shell
ssh -i .ssh/cloud_tp1_key azureuser@4.211.132.107
```


---
