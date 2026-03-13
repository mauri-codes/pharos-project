#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/mauri-codes/pharos-project.git"

log() {
  printf '[pharos] %s\n' "$*"
}

fail() {
  printf '[pharos] ERROR: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: ./run.sh <project>

Example:
  ./run.sh NewAccountAdmin
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "Required command '$1' is not available."
  fi
}

detect_arch() {
  local machine
  machine="$(uname -m)"

  case "$machine" in
    x86_64|amd64)
      printf 'amd64\n'
      ;;
    aarch64|arm64)
      printf 'arm64\n'
      ;;
    *)
      fail "Unsupported Linux architecture: $machine"
      ;;
  esac
}

verify_checksum() {
  local file="$1"
  local sums_file="$2"

  if command -v sha256sum >/dev/null 2>&1; then
    (cd "$(dirname "$file")" && sha256sum -c "$sums_file" --ignore-missing)
    return
  fi

  if command -v shasum >/dev/null 2>&1; then
    local expected actual
    expected="$(awk "/$(basename "$file")/ { print \$1 }" "$sums_file")"
    actual="$(shasum -a 256 "$file" | awk '{ print $1 }')"
    [[ -n "$expected" ]] || fail "Could not find checksum for $(basename "$file")"
    [[ "$expected" == "$actual" ]] || fail "Checksum verification failed for $(basename "$file")"
    return
  fi

  fail "Neither sha256sum nor shasum is available for checksum verification."
}

install_terraform() {
  if command -v terraform >/dev/null 2>&1; then
    log "Terraform already installed: $(terraform version -json 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin).get(\"terraform_version\", \"unknown\"))' || terraform version | head -n 1)"
    return
  fi

  require_cmd curl
  require_cmd unzip
  require_cmd python3

  local arch version base_url tmp_dir zip_file sums_file install_dir
  arch="$(detect_arch)"
  version="$(curl -fsSL https://checkpoint-api.hashicorp.com/v1/check/terraform | python3 -c 'import json,sys; print(json.load(sys.stdin)["current_version"])')"
  base_url="https://releases.hashicorp.com/terraform/${version}"
  tmp_dir="$(mktemp -d)"
  zip_file="${tmp_dir}/terraform_${version}_linux_${arch}.zip"
  sums_file="${tmp_dir}/terraform_${version}_SHA256SUMS"
  install_dir="${HOME}/.local/bin"

  trap 'rm -rf "${tmp_dir}"' RETURN

  log "Installing Terraform ${version} for linux_${arch}"
  mkdir -p "$install_dir"
  curl -fsSL "${base_url}/terraform_${version}_linux_${arch}.zip" -o "$zip_file"
  curl -fsSL "${base_url}/terraform_${version}_SHA256SUMS" -o "$sums_file"
  verify_checksum "$zip_file" "$sums_file"
  unzip -oq "$zip_file" -d "$install_dir"
  chmod +x "${install_dir}/terraform"
  export PATH="${install_dir}:${PATH}"

  if ! command -v terraform >/dev/null 2>&1; then
    fail "Terraform installation completed but terraform is still not in PATH."
  fi

  log "Terraform installed at ${install_dir}/terraform"
}

print_outputs() {
  if ! terraform output -json >/tmp/pharos_terraform_output.json 2>/dev/null; then
    log "No Terraform outputs were produced."
    return
  fi

  python3 - <<'PY'
import json
from pathlib import Path

path = Path("/tmp/pharos_terraform_output.json")
data = json.loads(path.read_text())

if not data:
    print("[pharos] No Terraform outputs were produced.")
else:
    print("[pharos] Terraform outputs:")
    for name, meta in data.items():
        value = meta.get("value")
        if isinstance(value, (dict, list)):
            rendered = json.dumps(value)
        else:
            rendered = str(value)
        print(f"{name}={rendered}")
PY
}

main() {
  if [[ $# -ne 1 ]]; then
    usage
    exit 1
  fi

  local project="$1"
  local tmp_dir repo_dir project_dir

  require_cmd git
  require_cmd bash

  install_terraform

  tmp_dir="$(mktemp -d)"
  repo_dir="${tmp_dir}/pharos-project"
  trap 'rm -rf "${tmp_dir}"' EXIT

  log "Cloning deploy/${project} from ${REPO_URL}"
  git clone --depth 1 --filter=blob:none --sparse "$REPO_URL" "$repo_dir" >/dev/null 2>&1
  git -C "$repo_dir" sparse-checkout set "deploy/${project}"

  project_dir="${repo_dir}/deploy/${project}"
  [[ -d "$project_dir" ]] || fail "Project deploy/${project} does not exist in ${REPO_URL}"

  cd "$project_dir"
  log "Working from $(pwd)"

  if [[ -f "./pre_run.sh" ]]; then
    log "Running pre_run.sh"
    bash "./pre_run.sh"
  fi

  log "Running terraform init"
  terraform init

  log "Running terraform apply -auto-approve"
  terraform apply -auto-approve

  print_outputs

  if [[ -f "./post_run.sh" ]]; then
    log "Running post_run.sh"
    bash "./post_run.sh"
  fi

  log "Deployment finished successfully."
}

main "$@"
