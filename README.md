# soc_splunk_lab
Reproduire les fondations de Splunk ES avec Splunk Enterprise et démontrer une maîtrise complète du SOC cycle.

1. Objectif général

Construire un SOC Lab complet sous Splunk Enterprise capable de :

Normaliser les données (CIM).

Implémenter des use cases clés (AD, Firewall, Cloud).

Utiliser les briques Splunk ES manuellement : macros, data models, correlation searches, risk-based alerting, threat intelligence.

Livrer le tout en sprints Agile (documentation + tableaux de bord + notables).

2. Architecture minimale

1x Search Head

1x Indexer

1x Heavy Forwarder (optionnel pour parsing)

1x Universal Forwarder (Windows AD logs, Sysmon)

Sources :

Windows AD : EventCode 4624, 4625, 4720, 4726, 4768, 4769

Firewall : pfSense, Cisco ASA, Fortinet (syslog)

Cloud : AWS CloudTrail ou Azure Activity logs

Sysmon : T1059, T1071 simulation

3. Sprint plan (Agile)

🟩 Sprint 1 : Base Splunk SOC

But : mettre en place l’infrastructure + indexation normalisée

Créer les index : main, wineventlog, firewall, cloud, risk

Créer le mapping CIM :

CIM_Authentication, CIM_Network_Traffic, CIM_Endpoint

Normaliser avec props.conf et transforms.conf

Créer les macros :

authentication

network_traffic

endpoint_process

🟧 Sprint 2 : Correlation + Use Cases de base

But : construire les détections SIEM

Brute force (AD)

Account creation / deletion

Suspicious RDP connection

Unauthorised DNS traffic

Firewall port scanning

AWS console login outside region
→ Chaque use case = savedsearches.conf avec action notable (table notable_events)

🟥 Sprint 3 : Risk-Based Alerting

But : introduire la logique RBA manuellement

Créer risk_object_user, risk_object_host

Définir risk_add macro :

eval risk_score = risk_score + <value>


Détecter cumul de score sur 24h → notable si > seuil

Tableau de bord “Risk Center”

🟦 Sprint 4 : Threat Intelligence

But : enrichir avec IOC

Intégrer une liste IOC (file lookup .csv avec IP, domain, hash)

Commande lookup pour enrichir logs

Détection :

| lookup threatintel_lookup domain AS dest OUTPUTNEW threat_type
| where isnotnull(threat_type)

🟪 Sprint 5 : Dashboard & Storytelling SOC

But : visualiser la couverture et la corrélation

Dashboard global par catégorie MITRE ATT&CK

KPI : nb d’alertes, top users, top sources, heatmap MITRE

Documentation du sprint (rétrospective, next backlog)

4. Structure du projet
$SPLUNK_HOME/etc/apps/soc_lab/
 ├── default/
 │    ├── props.conf
 │    ├── transforms.conf
 │    ├── savedsearches.conf
 │    ├── macros.conf
 │    ├── datamodels.conf
 │    └── eventtypes.conf
 ├── lookups/
 │    └── threatintel_lookup.csv
 ├── dashboards/
 │    └── soc_overview.xml
 ├── README/
 │    └── sprints_plan.md

5. Deliverables finaux

1 Dashboard global SOC (overview + KPIs)

1 Dashboard RBA (risk evolution)

1 Tableau Threat Intel

Documentation Agile (sprints + objectifs)

Portfolio démonstratif : “SOC Splunk Enterprise sans ES”