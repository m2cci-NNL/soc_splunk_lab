# SOC Lab Splunk App + CI/CD

This repo contains the Splunk app and a GitHub Actions workflow that deploys to a remote Splunk server on every push to `main` and restarts Splunk.

## Structure
- `soc_lab_app/` — your Splunk app tree
- `.github/workflows/deploy.yml` — CI pipeline
- `scripts/remote_install.sh` — remote install + restart

## Prereqs on the Splunk server
- Linux host reachable by SSH
- Splunk installed at `${REMOTE_SPLUNK_HOME}`
- User with SSH key access
- That user can either:
  - `sudo systemctl restart splunk` without password, or
  - run `${REMOTE_SPLUNK_HOME}/bin/splunk restart` (will require Splunk auth)

To allow service restart without password, add a sudoers entry (secure this):
```
youruser ALL=NOPASSWD: /bin/systemctl restart splunk, /bin/systemctl restart Splunkd
```

## GitHub Secrets to set
- `SSH_HOST` — IP or DNS of Splunk server
- `SSH_USER` — SSH user
- `SSH_KEY` — private key (PEM) for the user
- `SSH_PORT` — optional, default 22
- `REMOTE_SPLUNK_HOME` — e.g. `/opt/splunk`
- `REMOTE_APP_NAME` — default `soc_lab`
- `USE_SYSTEMCTL` — `1` to use systemctl, `0` to use Splunk CLI

## Deploy flow
1. Push to `main`
2. Workflow creates `soc_lab_app.tgz`
3. Workflow uploads artifact and installer to `/tmp` on remote
4. Remote script copies app into `$SPLUNK_HOME/etc/apps/${REMOTE_APP_NAME}`
5. Remote script restarts Splunk

## Local testing
- Package:
  ```bash
  tar -czf soc_lab_app.tgz soc_lab_app
  ```
- Copy and run the script manually over SSH to validate before wiring the action.

## Notes
- App content resides under `soc_lab_app/etc/apps/soc_lab/`.
- Extend later sprints by committing new `.conf`, dashboards, and saved searches into this tree.
