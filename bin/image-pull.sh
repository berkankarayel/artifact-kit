#!/usr/bin/env bash
set -euo pipefail

# Scriptin bulundugu yerden projenin kok dizinini bul
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/lib/common.sh"

if [[ $# -lt 1 ]]; then
  echo "Kullanim: $0 <liste-dosyasi>"
  exit 1
fi

LIST_FILE="$1"
require_file "$LIST_FILE"
load_config

mapfile -t IMAGES < <(read_list "$LIST_FILE")
log_info "${#IMAGES[@]} image islenecek"

for image in "${IMAGES[@]}"; do
  validate_image_ref "$image"
  pull_image "$image"
done

log_info "Tamamlandi"