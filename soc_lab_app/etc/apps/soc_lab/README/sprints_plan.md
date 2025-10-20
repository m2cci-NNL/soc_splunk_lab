# SOC Lab — Sprint 1

Scope:
- Indexes: wineventlog, firewall, cloud, risk
- CIM alignment for Authentication, Network_Traffic, Endpoint
- Macros to query normalized data
- Sample datasets to ingest

Prereqs:
1) Install Splunk Common Information Model (CIM) app.
2) Create the 4 indexes (or enable from indexes.conf if allowed).
3) Deploy this app under $SPLUNK_HOME/etc/apps and restart Splunk.

Data Ingest:
- Use *Add Data*.
- Set index per file name and choose sourcetype indicated below.
- Files are in ./samples/

Quick tests after ingest:
- `| tstats count from datamodel=Authentication by Authentication.user | head 10`
- `| tstats count from datamodel=Network_Traffic by All_Traffic.src, All_Traffic.dest | head 10`
- `\`authentication\` | stats count by user action`
- `\`network_traffic\` | stats count by src dest protocol`

Next:
- Sprint 2 adds correlation searches.
- Sprint 3 adds RBA with risk index and aggregation.
