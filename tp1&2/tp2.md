# 1. Network Security Group

## 🌞 Ajouter un NSG à votre déploiement Terraform:

- Ajout d'un NSG et de règles SSH dans `network.tf`.

<br>

## 🌞 Prouver que ça fonctionne, rendu attendu:

- la sortie du `terraform apply`:

```shell
azurerm_resource_group.main: Creating...
azurerm_resource_group.main: Still creating... [00m10s elapsed]
azurerm_resource_group.main: Creation complete after 11s [id=/subscriptions/a1f37475-cbc7-47b3-8b51-0b9b3029c847/resourceGroups/TP1]
azurerm_public_ip.main: Creating...
azurerm_virtual_network.main: Creating...
azurerm_network_security_group.main: Creating...
azurerm_public_ip.main: Creation complete after 2s [id=/subscriptions/a1f37475-cbc7-47b3-8b51-0b9b3029c847/resourceGroups/TP1/providers/Microsoft.Network/publicIPAddresses/TP1-public-ip]
azurerm_network_security_group.main: Creation complete after 3s [id=/subscriptions/a1f37475-cbc7-47b3-8b51-0b9b3029c847/resourceGroups/TP1/providers/Microsoft.Network/networkSecurityGroups/TP1-nsg]
azurerm_network_security_rule.ssh_rule: Creating...
azurerm_virtual_network.main: Creation complete after 5s [id=/subscriptions/a1f37475-cbc7-47b3-8b51-0b9b3029c847/resourceGroups/TP1/providers/Microsoft.Network/virtualNetworks/TP1-vnet]
azurerm_subnet.main: Creating...
azurerm_network_security_rule.ssh_rule: Creation complete after 3s [id=/subscriptions/a1f37475-cbc7-47b3-8b51-0b9b3029c847/resourceGroups/TP1/providers/Microsoft.Network/networkSecurityGroups/TP1-nsg/securityRules/SSH_Rule]
azurerm_subnet.main: Creation complete after 5s [id=/subscriptions/a1f37475-cbc7-47b3-8b51-0b9b3029c847/resourceGroups/TP1/providers/Microsoft.Network/virtualNetworks/TP1-vnet/subnets/TP1-subnet]
azurerm_subnet_network_security_group_association.main: Creating...
azurerm_network_interface.main: Creating...
azurerm_subnet_network_security_group_association.main: Creation complete after 4s [id=/subscriptions/a1f37475-cbc7-47b3-8b51-0b9b3029c847/resourceGroups/TP1/providers/Microsoft.Network/virtualNetworks/TP1-vnet/subnets/TP1-subnet]
azurerm_network_interface.main: Still creating... [00m10s elapsed]
azurerm_network_interface.main: Creation complete after 16s [id=/subscriptions/a1f37475-cbc7-47b3-8b51-0b9b3029c847/resourceGroups/TP1/providers/Microsoft.Network/networkInterfaces/TP1-nic]
azurerm_linux_virtual_machine.main: Creating...
azurerm_linux_virtual_machine.main: Still creating... [00m10s elapsed]
azurerm_linux_virtual_machine.main: Creation complete after 18s [id=/subscriptions/a1f37475-cbc7-47b3-8b51-0b9b3029c847/resourceGroups/TP1/providers/Microsoft.Compute/virtualMachines/TP1-vm]

Apply complete! Resources: 9 added, 0 changed, 0 destroyed.
```

- `az vm show --name TP1-vm --resource-group TP1`:

```json
{
  "additionalCapabilities": null,
  ...
  "name": "TP1-vm",
  "networkProfile": {
    "networkApiVersion": null,
    "networkInterfaceConfigurations": null,
    "networkInterfaces": [
      {
        "deleteOption": null,
        "id": "/subscriptions/a1f374.../networkInterfaces/TP1-nic",
        "primary": true,
        "resourceGroup": "TP1"
      }
    ]
  },
  "osProfile": {
    "adminUsername": "azureuser",
    ...
    "linuxConfiguration": {
      "disablePasswordAuthentication": true,
      ...
      "ssh": {
        "publicKeys": [
          {
            "keyData": "ssh-ed25519 ...",
            "path": "/home/azureuser/.ssh/authorized_keys"
          }
        ]
      }
    }
  },
  ...
  "provisioningState": "Succeeded",
  "resourceGroup": "TP1",
  ...
}
```

- Connexion :

```shell
ssh -i .ssh/cloud_tp1_key azureuser@4.211.111.66
```

- Dans la VM :

```shell
sudo nano /etc/ssh/sshd_config
# Ajout de la ligne:
Port 2222
sudo systemctl restart sshd
sudo ss -ltn 'sport = :2222'
```

- Sortie attendue :

```shell
State     Recv-Q Send-Q        Local Address:Port      Peer Address:Port  Process
LISTEN    0      128 0.0.0.0:2222        0.0.0.0:*
LISTEN    0      128    [::]:2222           [::]:*
```

- Test connexion:

```shell
ssh -i .ssh/cloud_tp1_key -p 2222 azureuser@4.211.111.66
# ssh: connect to host 4.211.111.66 port 2222: Connection timed out
```

<br>
<br>
<br>

# 2. Un ptit nom DNS

## 🌞 Donner un nom DNS à votre VM

- Ajout du nom DNS

<br>

## 🌞 Un ptit output nan ?

- À la sortie du `terraform apply`, ce qu'affiche `outputs.tf` :

```hcl
Outputs:

vm_dns_fqdn = "vm-tp1-dns.francecentral.cloudapp.azure.com"
vm_public_ip_address = "4.211.111.66"
```

- Connexion :

```shell
ssh -i .ssh/cloud_tp1_key azureuser@vm-tp1-dns.francecentral.cloudapp.azure.com
```

<br>
<br>
<br>

# 3. Blob storage

## 🌞 Compléter votre plan Terraform pour déployer du Blob Storage pour votre VM:

- Fichier `storage.tf` créé

<br>

## 🌞 Prouvez que tout est bien configuré, depuis la VM Azure:

```shell
ssh -i .ssh/cloud_tp1_key azureuser@mon-vm-romain-eysines.francecentral.cloudapp.azure.com
wget https://aka.ms/downloadazcopy-v10-linux
tar -xvf downloadazcopy-v10-linux
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/local/bin/
azcopy login --identity
echo "Test Storage Container." > test.txt
azcopy copy 'test.txt' 'https://tp1storageromain.blob.core.windows.net/tp1-data/test.txt'
azcopy copy 'https://tp1storageromain.blob.core.windows.net/tp1-data/test.txt' 'downloaded_test.txt'
cat downloaded_test.txt
```

- Résultat attendu :
    - Test Storage Container

<br>

## 🌞 Déterminez comment azcopy login --identity vous a authentifié:

- Je n'ai pas eu besoin de mot de passe car, avec la commande `azcopy login --identity`, j'ai l'identité de machine virtuelle, que tu avais créée avec Terraform. Cette identité m'a donné la permission d'accéder au stockage.

<br>

## 🌞 Requêtez un JWT d'authentification auprès du service que vous venez d'identifier, manuellement:

```shell
curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fstorage.azure.com%2F' -H Metadata:true -s
```

- Résultat:
    - `{"access_token":"eyJ0eXA...","token_type":"Bearer"}`

<br>

## 🌞 Expliquez comment l'IP 169.254.169.254 peut être joignable:

- L'adresse 169.254.169.254 est joignable car elle fait partie d'une plage d'adresses IP non routables publiquement, mais elle est utilisée par les services de métadonnées d'instance (IMDS) d'Azure. Elle n'est accessible que depuis l'intérieur de la machine virtuelle elle-même.

<br>
<br>
<br>

# 4. Monitoring

## 🌞 Compléter votre plan Terraform et mettez en place une alerte CPU:

- Fichier `monitoring.tf` créé

<br>

## 🌞 Compléter votre plan Terraform et mettez en place une alerte mémoire:

- Fichier `monitoring.tf` créé

<br>

## 🌞 Une commande az qui permet de lister les alertes actuellement configurées:

```shell
az monitor metrics alert list --resource-group MonGroupeDeRessources
```

- Résultat:

```json
[
  {
    "actions": [
      {
        "actionGroupId": "/subscriptions/.../actionGroups/ag-TP1-alerts",
        "webHookProperties": {}
      }
    ],
    "criteria": {
      "allOf": [
        {
          "metricName": "Percentage CPU",
          "operator": "GreaterThan",
          "threshold": 70.0
        }
      ]
    },
    "description": "Alert when CPU usage exceeds 70%",
    "name": "cpu-alert-TP1-vm",
    ...
  },
  {
    "actions": [
      {
        "actionGroupId": "/subscriptions/.../actionGroups/ag-TP1-alerts",
        "webHookProperties": {}
      }
    ],
    "criteria": {
      "allOf": [
        {
          "metricName": "Available Memory Bytes",
          "operator": "LessThan",
          "threshold": 536870912.0
        }
      ]
    },
    "description": "Alert when available RAM drops below 512MiB",
    "name": "ram-alert-TP1-vm",
    ...
  }
]
```

<br>

## 🌞 Stress de la machine:

```shell
stress-ng --cpu 1 --cpu-method all --timeout 120s
stress-ng --vm 1 --vm-bytes 1G --timeout 60s
```

<br>

## 🌞 Vérifier que des alertes ont été fired:

```shell
az monitor metrics alert show --resource-group TP1 --name cpu-alert-TP1-vm --output table
```

- Résultat:

```
AutoMitigate    Description                     Enabled    EvaluationFrequency    Location    Name
--------------  ------------------------------  ---------  --------------------  ----------  ----------------
True            Alert when CPU usage exceeds 70%  True      0:01:00               global      cpu-alert-TP1-vm
```

```shell
az monitor metrics alert show --resource-group TP1 --name ram-alert-TP1-vm --output table
```

- Résultat:

```shell
AutoMitigate    Description                                Enabled    EvaluationFrequency    Location    Name
--------------  -----------------------------------------  ---------  --------------------  ----------  ----------------
True            Alert when available RAM drops below 512MiB  True      0:01:00               global      ram-alert-TP1-vm
```

<br>
<br>
<br>

# 5. Azure Vault

## 🌞 Compléter votre plan Terraform et mettez en place une Azure Key Vault:

- Fichier `keyvault.tf` créé

<br>

## 🌞 Avec une commande az, afficher le secret:
```shell
az keyvault secret show --name "random-secret" --vault-name "kv-TP1-romain"
```

- Résultat:

```shell
{
  "attributes": {
    "created": "2025-09-13T14:00:16+00:00",
    "enabled": true,
    "expires": null,
    "notBefore": null,
    "recoverableDays": 90,
    "recoveryLevel": "Recoverable+Purgeable",
    "updated": "2025-09-13T14:00:16+00:00"
  },
  "contentType": "",
  "id": "https://kv-tp1-romain.vault.azure.net/secrets/random-secret/78186406558a4f53a957c64c18faa457",
  "kid": null,
  "managed": null,
  "name": "random-secret",
  "tags": {},
  "value": "=pY17-FWfhnNsSET"
}
```

<br>

## 🌞 Depuis la VM, afficher le secret:

```shell

```