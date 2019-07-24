# LAB 6: Modules
Ansible kommer med en drøss forskjellige moduler. Disse omtales også som "task plugins" eller "library plugins". En oversikt og doumentasjon over disse er å finne på [Ansibles dokumentasjonssider](https://docs.ansible.com/ansible/latest/modules/modules_by_category.html) på web, eller lokalt med `ansible-doc -l` eller `ansible-doc <modulnavn>`.

![oppgave](lab/image/task.png)Vi har allerede vært borti moduler som `ping`, `setup`, `yum`, `copy` og `template`. Andre interessante moduler er `command` som gjør at vi kan kjøre hvilken som helst kommando på systemet. La oss prøve:

```
ansible -i /path/to/inventory all -m command -a '/usr/bin/uptime'
```

I en playbook ville denne sett slik ut:
```
- name: Uptime
  command: /usr/bin/uptime
```

## Egne moduler
Det er når man vil lage sine egne moduler at man faktisk må begynne å programmere litt i Python. Man bør dog først spørre seg om det virkelig er behov for å lage en helt ny modul, eller om kanskje en rolle som kombinerer forskjellige eksisterende moduler ville være en bedre løsning.

Man kan se nærmere på Ansibles eksisterende moduler på [Github](https://github.com/ansible/ansible/tree/devel/lib/ansible/modules) dersom man vil se nærmere på hvordan de er bygd opp.

* [Tilbakemeldinger](lab/7-feedback.md)