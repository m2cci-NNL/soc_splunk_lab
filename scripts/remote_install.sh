#!/usr/bin/env bash
set -euo pipefail

: "${REMOTE_SPLUNK_HOME:?Need REMOTE_SPLUNK_HOME}"
: "${REMOTE_APP_NAME:?Need REMOTE_APP_NAME}"
: "${REMOTE_STAGING_DIR:=/tmp/soc_lab_staging}"
: "${REMOTE_OWNER:=splunk}"
: "${REMOTE_GROUP:=splunk}"
: "${USE_SYSTEMCTL:=1}"
: "${HEALTH_TIMEOUT:=120}"
: "${SPLUNK_USERNAME:=}"
: "${SPLUNK_PASSWORD:=}"

echo "[remote] Preparing staging dir ${REMOTE_STAGING_DIR}"
rm -rf "${REMOTE_STAGING_DIR}"
mkdir -p "${REMOTE_STAGING_DIR}"

echo "[remote] Unpacking artifact"
tar -xzf /tmp/soc_lab_app.tgz -C "${REMOTE_STAGING_DIR}"

SRC_APP_DIR="${REMOTE_STAGING_DIR}/soc_lab_app/etc/apps/${REMOTE_APP_NAME}"
PREFLIGHT_APP="${REMOTE_SPLUNK_HOME}/etc/apps/${REMOTE_APP_NAME}__preflight"
LIVE_APP="${REMOTE_SPLUNK_HOME}/etc/apps/${REMOTE_APP_NAME}"

echo "[remote] Preflight copy to ${PREFLIGHT_APP}"
rm -rf "${PREFLIGHT_APP}"
mkdir -p "$(dirname "${PREFLIGHT_APP}")"
cp -a "${SRC_APP_DIR}" "${PREFLIGHT_APP}"
chown -R "${REMOTE_OWNER}:${REMOTE_GROUP}" "${PREFLIGHT_APP}"

echo "[remote] Running btool check"
set +e
"${REMOTE_SPLUNK_HOME}/bin/splunk" cmd btool check --app="${REMOTE_APP_NAME}__preflight"
BT=$?
set -e
if [[ $BT -ne 0 ]]; then
  echo "[remote] btool check FAILED (${BT}). Aborting deploy."
  exit 1
fi
echo "[remote] btool check OK"

echo "[remote] Deploying live app to ${LIVE_APP}"
rm -rf "${LIVE_APP}"
cp -a "${SRC_APP_DIR}" "${LIVE_APP}"
chown -R "${REMOTE_OWNER}:${REMOTE_GROUP}" "${LIVE_APP}"

if [[ "${USE_SYSTEMCTL}" == "1" ]]; then
  echo "[remote] Restarting Splunk service via systemctl"
  sudo systemctl restart splunk || sudo systemctl restart Splunkd
else
  echo "[remote] Restarting Splunk via CLI"
  "${REMOTE_SPLUNK_HOME}/bin/splunk" restart --answer-yes --no-prompt
fi

echo "[remote] Waiting for Splunk to become healthy (timeout ${HEALTH_TIMEOUT}s)"
SECS=0
until [[ $SECS -ge $HEALTH_TIMEOUT ]]; do
  if systemctl is-active --quiet splunk || systemctl is-active --quiet Splunkd; then
    # Optional REST health check if creds provided
    if [[ -n "${SPLUNK_USERNAME}" && -n "${SPLUNK_PASSWORD}" ]]; then
      if curl -sku "${SPLUNK_USERNAME}:${SPLUNK_PASSWORD}" https://localhost:8089/services/server/info?output_mode=json | grep -q '"serverName"'; then
        echo "[remote] REST health check OK"
        exit 0
      fi
    else
      echo "[remote] Service appears active"
      exit 0
    fi
  fi
  sleep 3
  SECS=$((SECS+3))
done

echo "[remote] Health check FAILED after ${HEALTH_TIMEOUT}s"
exit 2
