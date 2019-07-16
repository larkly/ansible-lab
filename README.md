# Ansible-lab

## Provisjonering av labmiljø
Under katalogen ```terraform``` ligger det Terraform- og Ansible-konfigurasjon for å sette opp et labmiljø i AWS. Kjøring av disse betinger at AWS-credentials er satt opp riktig i environment eller i ~/.aws/credentials.
Sett variablen count= under instance i ```ansible-kurs.tf``` slik at hver deltaker får 4-5 systemer til å boltre seg på. Kjør deretter ```terraform apply``` og godkjenn planen som blir satt opp dersom den ser OK ut.
State blir satt lokalt, så hold kontroll på tfstate-filen, ellers vil du ikke enkelt kunne kjøre en destroy senere.

### CI/CD - automatisk provisjonering
Det er satt opp en automatisk CI-pipeline mot dette repoet på https://gitlab.klykken.com. Ved push mot feature branch vil det kjøres en ```terraform plan``` mot branchens terraform-setup. Det vil bli synlig i en merge request hvorvidt testen var vellykket eller ikke. En forutsetning for å merge mot master er at testen er vellykket. Ved merge mot master vil ```terraform apply``` kjøres, og planen eksekveres. State vil synkroniseres mot AWS S3.

## Laboppgaver
### Forutsetninger
Det er noen forutsetninger for vedkommende som skal gjennomføre disse laboppgavene.

* Tilgang på egen laptop med ssh eller PuTTY
* Tilstrekkelig kunnskap til å kunne koble seg på angitte serversystemer med ssh eller PuTTY
* Tilstrekkelig kunnskap med Linux til å kunne skrive og modifisere filer

### SSH
Når systemene er provisjonert, spytter Terraform ut en liste over systemer. Disse fordeles blant dem som skal ta laboppgavene. Innlogging til disse kan gjøres med SSH-nøkkelen på https://gitlab.klykken.com/bosse/ansible-lab/blob/master/sshkey, enten som parameter til ssh på Linux og Mac, eller som en opsjon i PuTTY-profilen i Windows.

Ut ifra listen av systemer man blir allokert, velger man én av dem som "master" og logger inn på denne for å gjennomføre oppgavene.

### Ansible install
### Inventory
### Playbooks
#### Plays
#### Tasks
#### Import
### Roles
### Modules
#### Ansible Galaxy
### Variables
#### Ansible Vault
