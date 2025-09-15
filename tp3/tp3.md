# 1. Continuité autour de AZ-104

## Les technologies utilisées:

- OS des serveurs: Ubuntu
- Coding languages: Python, HTML, CSS, TailwindCSS and JS
- Backend: Django
- Frontend: Django
- BD: PostgreSQL
- uWSGI: Gunicorn
- Proxy: Nginx

## La logique:

- Création de 3 VMs:
    - Une VM pour le backend/frontend
    - Une VM pour la BD
    - Une VM pour le proxy

## Au moins deux machines:

- Pour me connecter en SSH à la website-vm via la proxy-vm:

```shell
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/cloud_tp3_key 
ssh -A -i ~/.ssh/cloud_tp3_key azureuser@4.251.111.233 (vers la proxy-vm)
ssh azureuser@10.0.1.6 (vers la website-vm)
```

<br>