# Ansible-lab

## Provisjonering av labmiljø
Under ```terraform``` ligger det Terraform- og Ansible-konfigurasjon for å sette opp et labmiljø i AWS. Kjøring av disse betinger at AWS-credentials er satt opp riktig i environment eller i ~/.aws/credentials.
Sett variablen count= under instance i ```ansible-kurs.tf``` slik at hver deltaker får 4-5 systemer til å boltre seg på. Kjør deretter ```terraform apply``` og godkjenn planen som blir satt opp dersom den ser OK ut.
State blir satt lokalt, så hold kontroll på tfstate-filen, ellers vil du ikke enkelt kunne kjøre en destroy senere.