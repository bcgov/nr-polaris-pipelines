#!/usr/bin/env bash
# Manually runs the Broker and Vault steps of the Polaris pipeline smoke test,
# without Jenkins. Use it to check the Broker JWT and the intention file.
#
# Usage: BROKER_JWT=<jwt> scripts/test-polaris-pipeline-smoke-test.sh [preflight]
#
# With "preflight", only validates the intention (nothing is opened). Otherwise
# runs the full sequence the Jenkinsfile does. Requires curl and jq. The JWT,
# action token and Vault tokens are never printed.
set -euo pipefail

: "${BROKER_JWT:?Set BROKER_JWT to the Broker JWT of the smoke test account}"
BROKER_URL="${BROKER_URL:-https://broker.io.nrs.gov.bc.ca/v1}"
KNOX_URL="${KNOX_URL:-https://knox.io.nrs.gov.bc.ca/v1}"
INTENTION_FILE="$(dirname "$0")/intention-polaris-pipeline-smoke-test.json"
VAULT_PATH="apps/data/dev/oscar/polaris-pipeline-smoke-test/development"
EXPECTED_KEY=smoke_test_value
EXPECTED_VALUE=not-a-secret
SCHEME=Bearer
AUTH_HEADER="Authorization: ${SCHEME} ${BROKER_JWT}"

# Prints the response body and fails on a non-2xx status.
call() {
  local out status
  out=$(mktemp)
  status=$(curl -sS -o "${out}" -w '%{http_code}' --connect-timeout 10 --max-time 30 "$@")
  if [[ ! "${status}" =~ ^2 ]]; then
    echo "HTTP ${status}" >&2
    cat "${out}" >&2; echo >&2
    rm -f "${out}"
    return 1
  fi
  cat "${out}"; rm -f "${out}"
}

INTENTION=$(jq \
  --arg id "manual-$(date +%s)" \
  '.event.provider = "polaris-pipeline-smoke-test"
   | .event.url = "https://github.com/bcgov/nr-polaris-pipelines"
   | .event.trigger.id = $id
   | .event.trigger.url = "https://github.com/bcgov/nr-polaris-pipelines"' "${INTENTION_FILE}")

if [[ "${1:-}" == "preflight" ]]; then
  echo "Preflight: validating the intention with Broker"
  call -X POST -H "Authorization: Bearer ${BROKER_JWT}" -H 'Content-Type: application/json' \
    -d "${INTENTION}" "${BROKER_URL}/intention/preflight" >/dev/null
  echo "Preflight OK"
  exit 0
fi

INTENTION_TOKEN=
close_failed() {
  if [[ -n "${INTENTION_TOKEN}" ]]; then
    echo "Closing the intention as failed"
    curl -sS -o /dev/null -X POST -H "X-Broker-Token: ${INTENTION_TOKEN}" \
      "${BROKER_URL}/intention/close?outcome=failure" || true
  fi
}
trap 'rc=$?; [[ ${rc} -ne 0 ]] && close_failed; exit ${rc}' EXIT

echo "1. Open intention"
OPEN=$(call -X POST -H "Authorization: Bearer ${BROKER_JWT}" -H 'Content-Type: application/json' \
  -d "${INTENTION}" "${BROKER_URL}/intention/open")
INTENTION_TOKEN=$(jq -r '.token' <<<"${OPEN}")
ACTION_TOKEN=$(jq -r '.actions.configure.token' <<<"${OPEN}")

echo "2. Start action"
call -X POST -H "X-Broker-Token: ${ACTION_TOKEN}" "${BROKER_URL}/intention/action/start" >/dev/null

echo "3. Provision a Vault token (no role id)"
WRAPPED=$(call -X POST -H "X-Broker-Token: ${ACTION_TOKEN}" "${BROKER_URL}/provision/token/self" \
  | jq -r '.wrap_info.token // empty')
[[ -n "${WRAPPED}" ]] || { echo "Broker response had no wrap_info.token" >&2; exit 1; }

echo "4. Unwrap it with Knox"
VAULT_TOKEN=$(call -X POST -H "X-Vault-Token: ${WRAPPED}" "${KNOX_URL}/sys/wrapping/unwrap" \
  | jq -r '.auth.client_token // empty')
[[ -n "${VAULT_TOKEN}" ]] || { echo "Knox response had no client_token" >&2; exit 1; }

echo "5. Read ${VAULT_PATH}"
SECRET=$(call -H "X-Vault-Token: ${VAULT_TOKEN}" "${KNOX_URL}/${VAULT_PATH}")
curl -sS -o /dev/null -X POST -H "X-Vault-Token: ${VAULT_TOKEN}" "${KNOX_URL}/auth/token/revoke-self" || true
ACTUAL=$(jq -r --arg k "${EXPECTED_KEY}" '.data.data[$k] // empty' <<<"${SECRET}")
if [[ "${ACTUAL}" != "${EXPECTED_VALUE}" ]]; then
  echo "${EXPECTED_KEY} was missing or did not match" >&2
  exit 1
fi

echo "6. End action and close intention"
call -X POST -H "X-Broker-Token: ${ACTION_TOKEN}" "${BROKER_URL}/intention/action/end" >/dev/null
call -X POST -H "X-Broker-Token: ${INTENTION_TOKEN}" "${BROKER_URL}/intention/close?outcome=success" | jq -r '.audit // .message'
INTENTION_TOKEN=
echo "Smoke test passed"
