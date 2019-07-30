# LAB 4: Variabler
I den forrige labben så brukte vi variabler fra facts for å fylle ut en template. Facts er en form for variabel som blir generert på hver Ansible run. Disse kan brukes på mange forskjellige måter.

## Variabel-filer
I ```templates/haproxy.cfg.j2``` så har vi en stats-side som har admin/password som påloggingsinformasjon. Vi vil gjerne legge inn et skikkelig passord her i stedet. Det vi kan gjøre, er å legge dette inn i en variabelfil under katalogen ```group_vars```. Filnavnene her vil ha navn på grupper som da vil inneholde variabler som vil gjelde for disse. På denne måten kan man legge inn forskjellige typer informasjon som skal gjelde for grupper av systemer. Man vil f.eks. kunne differensiere mellom test og prod gjennom slike variabler, slik at man kan bruke de samme playbookene, modulene og rollene uansett hvilket miljø man kjører opp, men man vil jo som oftest ha forskjellige passord satt i disse miljøene.

Man har også muligheten for å legge filer i ```hosts_var``` hvor filnavnet vil tilsvare hostnavnet. Her vil man kunne overstyre tidligere variabler, bl.a. fra group_vars. Det er en egen liste over hvilken presedens forskjellige typer variabler får [her](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable). I denne labben vil vi bare se på group_vars.

![oppgave](lab/image/task.png)Bruk kommandoen pwgen for å generere et random-ish passord som vi kan bruke for stats.

```
$ pwgen -cnBs 64 1
W93KU4RJ3iifodHpwVVtTnjiFMs7kepxs9UN4s49NAevEdKRPahkXVMwaouqpzaV
```

Lag deretter katalogen ```group_vars``` og lag en fil som heter ```proxy.yml``` med følgende innhold:

```
---
secret_variable: "W93KU4RJ3iifodHpwVVtTnjiFMs7kepxs9UN4s49NAevEdKRPahkXVMwaouqpzaV"
```

Basert på informasjonen her nå, så vil secret_variable være tilgjengelig kun på servere som ligger i inventory-gruppen proxy. Vi kan dermed bruke ```{{ secret_variable }}``` ellers i Ansible-konfigurasjonen. La oss gjøre en liten modifikasjon i ```haproxy.cfg.j2``` filen. På linje 41 vil det stå ```stats auth admin:password```. Bytt dette ut med ```stats auth admin:{{ secret_variable }}```.

## Vault
Nå har vi definert et passord for tilgang til stats-siden til HAproxy. Hvis du kjører playbooken nå, så vil variablen bli erstattet med passordet som du genererte. Men siden det er et passord, så vil vi gjerne skjerme denne informasjonen. Det gjør også at vi kan dele konfigurasjonen vår med andre, som da kan f.eks. sende pull requests for ting de ønsker å gjøre i miljøet ditt, men du vil ikke at de under noen omstendighet skal ha tilgang til hemmelighetene. Da kan du bruke Ansible Vault.

Ansible Vault kan kryptere hele filer eller bare enkeltvariabler. Det mest fleksible alternativet med tanke på rekeying, modifikasjoner o.l. er å kryptere hele fila, mens fordelen med å kryptere enkeltvariabler er at man kan ha både kryptert og ukryptert informasjon i dem, og til og med variabler kryptert med forskjellige nøkler avhengig av skjermingsnivå.

Først må vi ha en passord-fil som vi skal bruke som nøkkel. Det kan også være et passord, men i de fleste tilfeller så er det bedre å kjøre med passord-filer, siden man da kan tilrettelegge for det i CI/CD pipelines uten å måtte ha en passordfrase som miljøvariabel eller tilsvarende. Når vi kjører playbooks manuelt, slik som i labben, så vil en passord-hemmelighet medføre at du må skrive passordet hver eneste gang du skal kjøre playbooken. Da er det bedre å bare henvise til en passordfil. I eksempelet mellom test og prod, så vil man ha forskjellige nøkler som åpner hemmelighetene for henholdsvis test og prod. Når Ansible kjører i testmiljøet, vil det ha tilgang til nøkkelen som åpner testhemmeligheten, og kun den. Ved å bruke vault-id så kan man angi flere nøkler på en playbook-run, f.eks. `--vault-id=prod@secretkey.txt` og `--vault-id=supersecret@supersecretkey.txt`. Monikeren som er nevnt før alfakrøllen vil også være spesifisert i den krypterte strengen, slik at man lett vil kunne se hvilken nøkkel man trenger for å kjøre eller modifisere hemmeligheten.

![oppgave](lab/image/task.png)Lag først en passordfil:

```
$ uuidgen > vault-password-file
```

Nå har vi en helt fin passordfil. Du kan også bruke ``dd if=/dev/urandom of=vault-password-file bs=1 count=1M`` hvis du vil. Opp til deg!

*For sikkerhets-nerder, vi venter ikke på at du får nok entropi til å kunne lage en 1GB nøkkel med /dev/random*

### Opsjon 1: Kryptere hele fila
![oppgave](lab/image/task.png)Man krypterer hele fila med ```ansible-vault encrypt --vault-id=lab@vault-password-file group_vars/proxy.yml```

Resultatet blir noe som:
```
$ cat group_vars/proxy.yml
$ANSIBLE_VAULT;1.2;AES256;lab
65636233363436303133346530626532613639653838326637346631383933313566373863346663
6565396566666436653964643966333030653035316633300a386263303231366635643332366261
63306662363639616137633639613339383131613636383563353166306631646130386433643961
3065353563636631610a383533313466313563646566313935613533343562366238633466666532
63326531663363373131646231373065613837323637653762656166613864336532313339636237
34643665393432363636313335346432346633646635303838666330336265303163346436656336
326439393364333134323862353735376535
```

Man kan bytte ut ```encrypt``` parameteret til ansible-vault med ```view```, ```edit```, ```decrypt``` og ```rekey```.

Når man krypterer hele fila så bør alt innholdet i den alltid være av en slik type som gjør at de som har tilgang på nøkkelen er de eneste som kan tenkes å ville bruke den. Hvis det er andre som kan tenkes å ville legge ikke-hemmelige variabler inn der, og som ikke skal ha tilgang til nøkkelen, så kan det hende at det er bedre å se på om man kan legge inn hemmeligheten som en variabel i stedet. Det skal vi se på nå i opsjon 2.

### Opsjon 2: Kryptere selve variablen
![info](lab/image/info.png)Man kan velge om man vil pipe innholdet inn fra en annen kommando, eller bli promptet for innholdet.

```
$ ansible-vault encrypt_string --vault-id=lab@vault-password-file --stdin-name="secret_variable"
Reading plaintext input from stdin. (ctrl-d to end input)
567CC2EA-81D1-4583-9877-2A692C51E9EA
```

eller

```
echo "567CC2EA-81D1-4583-9877-2A692C51E9EA" | ansible-vault encrypt_string --vault-id=lab@vault-password-file --stdin-name="secret_variable"
```

eller

```
pwgen -cnBs 128 1 | ansible-vault encrypt_string --vault-id=lab@vault-password-file --stdin-name="secret_variable"
```

Output vil se nogenlunde slik ut:
```
secret_variable: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          39343736323762323563303930626338383937666563303339613264633762376165653133376163
          6631353161383337383631353234333464333737666465310a353436323935393230373734323961
          36646538306231643232386139336635303563383332346133313563303231323839383263386663
          3666623537316634380a656162303239396364656566626565366464313436343365313738656236
          33653137336263666365363934313135336430306639643966646637636237646238363264383232
          6434333332336439333535306462666335663266623530343364
```

Dette kan man enten cutpaste eller redirecte inn i group_vars/proxy.yml. Man kan dermed ha vanlige og krypterte variabler om hverandre, alt etter bruksbehovet.

Når man bruker vault på enkeltvariabler på denne måten, så kan man ikke bruke ```ansible-vault``` parametrene ```edit```, ```view``` og så videre, siden de kommandoene forholder seg kun til helkrypterte filer.

Skal man dekryptere en enkeltvariabel, må man sakse ut den krypterte strengen og pipe det inn til `ansible-vault` slik:
```
echo '$ANSIBLE_VAULT;1.1;AES256
39343736323762323563303930626338383937666563303339613264633762376165653133376163
6631353161383337383631353234333464333737666465310a353436323935393230373734323961
36646538306231643232386139336635303563383332346133313563303231323839383263386663
3666623537316634380a656162303239396364656566626565366464313436343365313738656236
33653137336263666365363934313135336430306639643966646637636237646238363264383232
6434333332336439333535306462666335663266623530343364' | ansible-vault decrypt --vault-id=lab@vault-password-file /dev/stdin --output=/dev/stderr
```

### Kjøre Ansible med Vault
![oppgave](lab/image/task.png)Når du nå har lagt inn vault-filer eller variabler, og skal kjøre enten `ansible` eller `ansible-playbook`, så vil Ansible trenge å vite hvilen nøkkel den skal bruke til å dekryptere innholdet. Legg til parameteret `--vault-id=id@passordfil` slik at den får låst opp hemmeligheten. Du kan gjerne bruke flere `--vault-id` på kommandolinjen dersom du har flere forskjellige nøkler som brukes.

Ansible vil som regel klage over at du har en fullkryptert fil som den ikke får tilgang til, f.eks. under `group_vars`. Dette er fordi Ansible leser alle disse filene i forbindelse med en kjøring. Dersom du har kryptert enkeltvariabler så er det større sjans for at Ansible ikke merker at den er kryptert, siden den mest sannsynlig ikke har noen referanser til den aktuelle variablen.

## Facts
Noe av det første Ansible gjør under en playbook run, er at den henter inn informasjon om hostene. Dette er informasjon som vi kan bruke f.eks. med `when` conditionals, slik som vi allerede har satte i playbooken vår i lab 2, hvor vi kun ville sette en SELinux boolean dersom SELinux faktisk var enablet på det systemet. Vi kan også bruke dem i templates, så dette er svært nyttig. Men hvordan vet jeg hva slags facts jeg kan forholde meg til? Dette avhenger litt av hvordan systemet du snakker med er satt opp. Du har noen standardfacts som Ansible finner selv, du kan ha installert noen tredjeparts facts-kilder som `facter` og `ohai`, eller du kan ha laget dine egne facts. I vårt labmiljø er `facter` allerede installert.

*[Facter](https://github.com/puppetlabs/facter) er en frittstående del av Puppet. [Ohai](https://github.com/chef/ohai) er en frittstående del av Chef.*

![oppgave](lab/image/task.png)Ta en nærmere titt på hvilke facts som gjelder for dine systemer ved å orkestrere med setup-modulen i Ansible.

```
ansible -b -i inventory -m setup proxy
```

Output er et JSON-dokument som viser de forskjellige facts som du kan treffe beslutninger på i playbooks, templates og andre steder i Ansible, f.eks. der man ønsker å bruke `when:` i en playbook task for bare å trigge oppgaven dersom en viss tilstand gjelder, f.eks. `when: ansible_facts['selinux']['config_mode'] == 'enforcing'` dersom man kun vil kjøre en kommando på systemer som er satt opp for å kjøre SELinux. Dette er ganske likt måten man ville forholde seg til en `dict()` i Python.

### Lokale facts
Hva om du trenger å ha en spesiell fact som forteller noe om systemet du kjører på? Kanskje du har en spesiell applikasjon som skal rapportere om tilstand, versjonsnummer og annen informasjon? Du kan legge inn filer i `/etc/ansible/facts.d/` som slutter på `.fact`, og som er enten JSON eller INI. De kan også være eksekverbare, så lenge de returnerer JSON.

![oppgave](lab/image/task.png)La oss lage en slik facts-fil. Vi legger den i `~/ansible/files/preferences.fact`:

```
[blatti]
herp=ja
derp=nei
```

La oss lage en play nederst i playbooken vår som dytter denne facts-filen ut på alle systemene:

```
- hosts: all
  gather_facts: false
  become: true
  tasks:
  - name: preferences.fact | create dir
    file:
      path: /etc/ansible/facts.d
      state: directory
      mode: '0755'
  - name: preferences.fact | copy
    copy:
      src: preferences.fact
      dest: /etc/ansible/facts.d/preferences.fact
      owner: root
      group: root
      mode: 0644
```

Etter at vi har kjørt playbooken vår igjen, la oss sjekke setup-kommanduen vi kjørte i forrige avsnitt igjen. Har vi fått en blatti der? Den vil ligge under `ansible_local`.

* [Eksempelfil](workdir/group_vars/proxy.yml)
* [Neste lab](lab/5-roles.md)