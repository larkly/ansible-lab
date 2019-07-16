# LAB 1: Inventory
Vi må sette opp en inventory som gjør at Ansible vet hvilke systemer som er relevante for kjøringen. I denne laben skal du ha fått en oversikt over noen systemer. Putt disse inn i en fil, f.eks. inventory.txt og legg til en tagg som beskriver funksjonen slik at vi senere kan gruppere forskjellige plays på dem.

```
[bastion]
ec2-52-57-213-146.eu-central-1.compute.amazonaws.com

[webserver]
ec2-54-93-47-1.eu-central-1.compute.amazonaws.com

[database]
ec2-35-158-94-120.eu-central-1.compute.amazonaws.com

[div]
ec2-54-93-44-234.eu-central-1.compute.amazonaws.com
```

Det er ikke så viktig hvor du legger denne filen. Du vil referere til den senere med filnavn, såfremt du ikke legger den på standardlokasjonen ```/etc/ansible/hosts```. Legger du den der vil du kunne droppe ```-i``` parameteret når du senere skal kjøre ```ansible-playbook```. For labbens del forutsettes det at du legger den i katalogen hvor du vanligvis kommer til å kjøre ansible fra, f.eks. ~/ansible/inventory.txt.

https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html

## Statisk vs dynamisk inventory

[Neste lab](lab/2-playbooks.md)