#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/lib/common.sh"

if [[ $# -lt 1 ]]; then
  echo "Kullanim: $0 <liste-dosyasi>"
  exit 1
fi

LIST_FILE="$1"
require_file "$LIST_FILE"
load_config
require_nexus_password
nexus_login

mapfile -t IMAGES < <(read_list "$LIST_FILE")
log_info "${#IMAGES[@]} image islenecek"

for image in "${IMAGES[@]}"; do
  validate_image_ref "$image"

  if image_exists_in_nexus "$image"; then
    log_info "Zaten var, atlaniyor: $(nexus_image "$image")"
    continue
  fi

  pull_image "$image"
  push_image "$image"
done

log_info "Tamamlandi"