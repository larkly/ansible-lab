# Forberede labmiljøet
## Servere
Det skal være en liste med servernavn [her](servers.txt). Basert på det nummeret du fikk tildelt, copypaste de fire hostnavnene inn i en egen fil slik at du kan bruke dem i neste oppgave. Velg et av systemene som din Ansible-host, og logg inn på det.

Last ned SSH-nøkkelen til labmiljøet https://gitlab.klykken.com/bosse/ansible-lab/raw/master/sshkey.

F.eks.
```
ssh -i ~/Downloads/sshkey -l centos ec2-35-159-40-185.eu-central-1.compute.amazonaws.com
```

Du har altså en privat SSH-nøkkel som du skal kunne bruke for å autentisere deg, og du må også passe på at du legger inn at den skal bruke brukernavn centos for pålogging. Hvordan du eventuelt legger dette inn under PuTTY må nesten bli gruppearbeid om nødvendig.

## Katalog
Inne på systemet, under hjemmekatalogen, lag en katalog som heter ansible, og gå inn i denne. Såfremt oppgaven ikke nevner det spesifikt, så vil de fleste handlinger skje her inne.
```
mkdir ~/ansible
cd ~/ansible
```

[Gå deretter til første laboppgave for å sette igang!](1-inventory.md)