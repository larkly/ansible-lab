# LAB 2: Playbooks
En playbook er en samling av ```plays```, som igjen er en samling av ```tasks``` som er nødvendige for å få konfigurert systemet.
En playbook kan importere andre playbooks, slik at man kan strukturere dem etter oppgavene de skal gjøre.

![oppgave](lab/image/task.png)I labben skal vi lage en `playbook.yml` fil, som du kan legge i samme katalog som du la inventory-filen din.

```
---
- hosts: app
  become: true
```

Vi starter YAML-dokumentet vårt med tre streker ```---```. Deretter indikerer vi hvilken gruppe av hosts som denne playen kommer til å gjelde, i dette tilfellet ```app```. Vi indikerer også at Ansible skal bruke privilegert eskalering for å bli root med ```become: true```.

```
  tasks:
  - name: apache+php | install
    package:
      name: "{{ item }}"
      state: present
    with_items:
    - httpd
    - php
```

![alert](lab/image/alert.png)*Pass på indentering!*

I tasks legger vi inn de oppgavene vi ønsker å gjøre i denne playen. I dette tilfellet ønsker vi å installere både Apache og PHP gjennom det pakkehåndteringssystem som er aktuelt for denne distribusjonen/operativsystemet. I vårt tilfelle er det CentOS 7.6 med yum, men dette håndterer packages-modulen for oss. Det vi må være litt oppmerksomme på er om det er forskjellige navn på pakker i forskjellige distroer/OS. I Debian og Ubuntu heter Apache ```apache``` mens den i RHEL og CentOS heter ```httpd```. Dersom man deployer på tvers av differensierte systemer så må man legge til en ```when``` conditional. Dette kommer vi tilbake til senere.

```
  - name: apache+php | service enabled and started
    service:
      name: httpd
      enabled: yes
      state: started
```

Etter at en pakke er installert så må vi sørge for at den er startet, og at den starter automatisk ved oppstart. Her det også en hjelpermodul som abstraherer bort ```systemd``` og gjør at vi kun trenger å definere tjenestenavnet. Her gjelder den samme problemstillingen som før dog, ved at vi må legge til conditionals dersom vi har flere distroer eller operativsystem hvor pakkenavnene divergerer.

```
  - name: apache+php | index.html
    copy:
      src: index.php
      dest: /var/www/html/index.php
      owner: root
      group: root
      mode: 0644
```

Her ønsker vi å kopiere en fil fra Ansible til en gitt destinasjon. Vi bruker modulen ```copy``` for dette. Innholdet i den filen kommer vi tilbake til.

```
- hosts: proxy
  become: true
  tasks:
  - name: haproxy | install
    package:
      name: haproxy
      state: present
```

Her starter vi en ny play, og vi ønsker nå å jobbe med proxy-serveren. Vi ber Ansible om å sørge for at pakken ```haproxy``` blir installert.

```
  - name: haproxy | set required sebool for stats
    seboolean:
      name: haproxy_connect_any
      state: yes
      persistent: yes
    when: ansible_facts['selinux']['config_mode'] == 'enforcing'
    notify:
    - haproxy | restarting
```

For at HAproxy skal kunne serve oss stats-sider, så må vi sette en SELinux boolean, men bare når SELinux faktisk er konfigurert (when-conditional basert på facts). Vi sørger også for at en handler blir eksekvert på slutten av playet, i dette tilfellet en handler som skal restarte HAproxy.

```
  - name: haproxy | service enabled and started
    service:
      name: haproxy
      enabled: yes
      state: started
```

Vi sørger igjen for at HAproxy startes opp og at den blir startet ved reboots.


```
  handlers:
  - name: haproxy | restarting
    service:
      name: haproxy
      state: restarted
```

Her definerer vi handleren som skal sørge for at HAproxy blir restartet når vi trenger det. Denne kjøres kun når man gjør en ```notify``` mot denne, og kjøres alltid da først etter at playen er gjennomført. Man kan altså ha flere notifies i samme play, som likevel medfører at kommandoen kun kjøres én gang.

## Filen som skal kopieres ut
![oppgave](lab/image/task.png)I playbooken var det en `copy` som skulle legge ut en `index.php` på app-serverne våre. Vi hadde ikke noen nærmere path-angivelse på hvor den skal ligge, så Ansible forventer å finne den i katalogen `files` som skal ligge under samme katalog som Ansible-playbooken vår.

```
mkdir ~/ansible/files
echo "<?php
phpinfo(INFO_VARIABLES);

?>" | tee ~/ansible/files/index.php
```

Modulen `phpinfo()` vil gi oss en fin statusoversikt hvor vi lett kan se at vi går gjennom proxyen (XFF-headers) og at det er forskjellig backend som svarer etter reloads.

## Kjør playbook
![oppgave](lab/image/task.png)Nå som du har definert playbooken, kan du kjøre den. For dette bruker vi `ansible-playbook`, altså ikke den samme `ansible` binaryen som vi brukte til orkestrering.

```
ansible-playbook -u centos --private-key=/path/to/sshkey -i inventory playbook.yml --check
```

Med `--check` vil det kjøres en dry-run. Når du er klar for å la Ansible gjøre det på ordentlig, fjerner du `--check` og kjører på nytt.

* [Eksempelfil](workdir/playbook.yml)
* [Neste lab](lab/3-templates.md)