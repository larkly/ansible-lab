# LAB 3: Templates
I forrige playbook så ble proxyen satt opp med default settings, siden vi ikke hadde gjort noe for å konfigurere HAproxy. Vi ønsker at HAproxy skal bruke våre servere i gruppen ```app``` som backend. Vi kan derfor ikke bare kopiere inn en statisk fil slik vi gjorde i forrige lab, siden backendet må defineres.

![oppgave](lab/image/task.png)Lag en katalog som heter ```templates``` og i denne legger vi følgende fil som vi kaller ```haproxy.cfg.j2```. Dette er standardkonfigurasjonen til HAproxy med noen modifikasjoner.

```
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    stats socket /var/lib/haproxy/stats

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

listen  stats   127.0.0.1:1936
        mode            http
        log             global
        maxconn 10
        clitimeout      100s
        srvtimeout      100s
        contimeout      100s
        timeout queue   100s
        stats enable
        stats hide-version
        stats refresh 30s
        stats show-node
        stats auth admin:password
        stats uri  /haproxy?stats

frontend  main *:80
    default_backend             app
    acl has_stats_uri path_beg -i /haproxy
    use_backend statsb if has_stats_uri

backend statsb
    server localhost 127.0.0.1:1936 check

backend app
    balance     roundrobin
{% for h in groups['app'] -%}
{% if h != inventory_hostname %}
    server {{ h }} {{ hostvars[h]['ansible_default_ipv4']['address'] }}:80 check
{% endif %}
{% endfor %}
```

Endringene i forhold til standardkonfigurasjonen ligger i ```listen stats``` delen, at ```frontend``` skal peke på riktig backend, og at requests skal gå mot stats-interfacet dersom URI begynner med /haproxy.

Vi legger også til noen variabler og template-kommandoer under ```backend app``` siden vi ønsker å populere dette med de instansene som vi i Ansible inventory har definert som ```[app]```. Generelt sett så blir ```h``` noe vi kan bruke for å få en datatype vi kan bruke for å trekke ut facts, bl.a. IP-adresser. Kaller vi kun på ```h``` så får vi en variabel som inneholder hostnavnet slik det står i inventory, så vi kan bruke den med ```hostvars[h]``` slik at vi kan trekke ut facts om hvert aktuelle system. I dette tilfellet er vi interessert i å få frem IP-adressen på hvert system, og utenfor variabel-klammene definerer vi den statiske informasjonen, slik som at den skal gå mot port 80, og at den skal kjøre en generell helsesjekk.

![oppgave](lab/image/task.png)Vi legger deretter til følgende i playbook.yml *etter* bolken som omhandler ```haproxy | service enabled and started```:

```
  - name: haproxy | configure
    template:
      src: haproxy.cfg.j2
      dest: /etc/haproxy/haproxy.cfg
      owner: root
      group: root
      mode: 0644
    notify:
    - haproxy | restarting
```

Sist vi definerte en fil så brukte vi modulen ```copy```. Her bruker vi modulen ```template```. Den forventer at ```src``` ligger i katalogen ```templates``` under der playbooken kjører (samt et par andre steder). Med ```template``` som modul så blir j2-filen kopiert ut, slik som med ```copy``` men blir deretter også parset gjennom en av Pythons template-engines - [Jinja2](http://jinja.pocoo.org).

* [Eksempelfil](workdir/templates/haproxy.cfg.j2)
* [Neste lab](lab/4-variables.md)