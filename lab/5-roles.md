# LAB 5: Roles
Roller hjelper oss med å "modularisere" oppgaver, og baserer seg på en viss struktur av variabelfiler, oppgaver, handlers og slike ting.

En rolle har gjerne denne filstrukturen, i vårt tilfelle under `~/ansible` ser det nogenlunde slik ut nå, pluss roller:

```
playbook.yml
inventory
group_vars/
   proxy.yml
roles/
   example/
      tasks/
      handlers/
      files/
      templates/
      vars/
      defaults/
      meta/
   anotherrole/
      tasks/
      templates/
      defaults/
```

Her kan vi f.eks. legge en fil under `roles/rolename/tasks/main.yml` som inneholder noe slikt:

```
- name: installere Apache
  import_tasks: redhat.yml
  when: ansible_facts['os_family']|lower == 'redhat'
- import_tasks: debian.yml
  when: ansible_facts['os_family']|lower == 'debian'
```

Basert på denne kan vi importere forskjellige måter å gjennomføre oppgaven på, basert på hvilken distro som kjøres:
```
# roles/example/tasks/redhat.yml
- yum:
    name: "httpd"
    state: present

# roles/example/tasks/debian.yml
- apt:
    name: "apache2"
    state: present
```

Hvis det finnes en fil som heter `main.yml` inne i noen av de katalogene over, så vil innholdet i dem gjelde. Dette kan vi bruke som i eksempelet over, til å kalle inn andre task-filer basert på gitte forutsetninger.

## Galaxy
Man kan bruke eksterne roller for å gjøre morsomme ting på en lett måte. Det kan refereres til spesifikke git-repoer med interne roller, eller man kan peke på roller som er lagt opp på [Ansible Galaxy](https://galaxy.ansible.com).

![oppgave](lab/image/task.png)Ved hjelp av en Ansible Galaxy rolle skal vi installere PostgreSQL på serverne i gruppe `sql`.

```
mkdir ~/ansible/roles
ansible-galaxy install geerlingguy.postgresql -p roles
```

Dersom man ikke angir `-p` parameteret, så vil rollen installeres som en systemrolle eller der Ansible defaulter til å legge roller. For synlighetens skyld så sier vi at vi vil ha rollen i vår underkatalog `~/ansible/roles/`.

Legg til følgende på slutten av `playbook.yml`:

```
- hosts: sql
  become: true
  vars:
    postgresql_databases:
      - name: some_database
    postgresql_users:
      - name: some_user
        password: secret
  roles:
  - geerlingguy.postgresql
```

Kjør Ansible playbooken igjen. Legg merke til at det er en hel del ekstra tasks som nå foregår, som vi ikke har hatt noe forhold til før vi nå tok inn denne rollen. Man kan gå inn i `~/ansible/roles/postgreql/` for å undersøke nærmere hva denne rollen gjør. Man bør passe på hva man importerer når man skal bruke eksterne roller f.eks. i produksjon. I stedet for å referere til en Galaxy-rolle med username.rolename, kan man gi en referanse til et Git-repo, f.eks. lokalt. Dette kan enten være en kopi av en ekstern rolle som har gjennomgått en audit, eller en rolle produsert for intern bruk.

* [Eksempelfil](workdir/playbook.yml)
* [Neste lab](lab/6-modules.md)