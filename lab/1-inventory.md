# LAB 1: Inventory
![oppgave](lab/image/task.png)Vi må sette opp en inventory som gjør at Ansible vet hvilke systemer som er relevante for kjøringen. I denne laben skal du ha fått en oversikt over noen systemer. Putt disse inn i en fil, f.eks. inventory.txt og legg til en tagg som beskriver funksjonen slik at vi senere kan gruppere forskjellige plays på dem.

```
ec2-52-57-213-146.eu-central-1.compute.amazonaws.com
ec2-54-93-47-1.eu-central-1.compute.amazonaws.com
ec2-35-158-94-120.eu-central-1.compute.amazonaws.com
ec2-54-93-44-234.eu-central-1.compute.amazonaws.com
```

Vi trenger dog å legge dem inn i grupper, så fordel serverne slik at du får:
- 2 servere i gruppe app
- 1 server i gruppe proxy
- 1 server i gruppe sql

```
[app]
ec2-54-93-47-1.eu-central-1.compute.amazonaws.com
ec2-54-93-44-234.eu-central-1.compute.amazonaws.com

[proxy]
ec2-52-57-213-146.eu-central-1.compute.amazonaws.com

[sql]
ec2-35-158-94-120.eu-central-1.compute.amazonaws.com

```

Det er ikke så viktig hvor du legger denne filen, men jeg anbefaler at du legger den i ~/ansible/inventory. Du vil referere til den senere med filnavn, såfremt du ikke legger den på standardlokasjonen ```/etc/ansible/hosts```. Legger du den der vil du kunne droppe ```-i``` parameteret når du senere skal kjøre ```ansible-playbook```. For labbens del forutsettes det at du legger den i katalogen hvor du vanligvis kommer til å kjøre ansible fra, f.eks. ~/ansible/inventory.txt.

https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html

## Statisk vs dynamisk inventory

![info](lab/image/info.png)Hvis inventory-filen man kaller er et eksekverbart (+x) script, så vil Ansible eksekvere denne, og vil da bruke STDOUT fra dette scriptet som inventory. Man kan dermed bruke Bash, Perl, Go eller hva man vil for å gjøre oppslag i eksterne databaser for å produsere denne inventory-filen og gruppeinndelingen. Vi prøver ikke på dette i denne labben, men det er greit å vite.

## Opsjoner i inventory
![info](lab/image/info.png)Man kan legge inn opsjoner i denne filen. For eksempel så forventer disse EC2-instansene at man logger inn som bruker ```centos```. Man kan dermed legge til parameteret ```ansible_user=centos``` på hver av host-linjene, f.eks.:
```
ec2-52-57-213-146.eu-central-1.compute.amazonaws.com ansible_user=centos
```

Det er opp til deg om du vil gjøre dette nå. Vi vil i senere eksempler angi dette på kommandolinjen når vi kjører playbooks. Hvis du legger inn dette parameteret i inventory-filen, så kan du droppe den opsjonen når vi senere skal kjøre playbooks.

## Test at det fungerer
![oppgave](lab/image/task.png)For å teste at inventory fungerer, uten å ha noen playbook eller noe annet å kjøre, kan vi bruke Ansibles *orkestrering*. Kjør denne kommandoen:

```
ansible -u centos --private-key=/path/to/sshkey -i ~/ansible/inventory all -m ping
```

Dette vil kjøre Ansible-modulen ping direkte mot alle enheter i inventory-filen. Ping er en helt vanlig Ansible-modul. Du kan altså kjøre andre typer moduler direkte fra kommandolinjen, slik som f.eks. yum. Ved å bruke parameteret `-a` så vil man kunne gi opsjoner til modulen. La oss prøve et eksempel til:

```
ansible -u centos --private-key=/path/to/sshkey -b -i ~/ansible/inventory all -m yum -a 'name=sysstat state=present'
```

Prøv å kjøre kommandoen på nytt, og se hva som skjer. Prøv også å bytte ut `state=present` med `state=absent`. Tilbakemeldingen du får avhenger av om det er forskjell mellom Ansibles *forventede* og *faktiske* tilstand.

Legg merke til at vi la til `-b` som et parameter her. Det er fordi yum krever at man bruker sudo, og -b tilsvarer become_root som man ville brukt i playbooks, som vi ser på i neste lab.

* [Eksempelfil](workdir/inventory)
* [Neste lab](lab/2-playbooks.md)
