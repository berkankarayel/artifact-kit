#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/lib/common.sh"

UBUNTU_IMAGE="ubuntu:24.04"

if [[ $# -lt 1 ]]; then
  echo "Kullanim: $0 <liste-dosyasi>"
  exit 1
fi

LIST_FILE="$1"
require_file "$LIST_FILE"
load_config
require_nexus_password

# Cikti klasoru: liste adina gore (base-node.txt -> debs/base-node/)
LIST_NAME="$(basename "$LIST_FILE" .txt)"
OUT_DIR="$ARTIFACT_DIR/debs/$LIST_NAME"

mapfile -t PACKAGES < <(read_list "$LIST_FILE")
log_info "${#PACKAGES[@]} paket istendi: ${PACKAGES[*]}"

# Gecici calisma klasoru; script nasil biterse bitsin silinir
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

NEXUS_URL="http://${NEXUS_HOST}:${NEXUS_HTTP_PORT}/repository"

# 1) Container'in apt kaynaklari: Nexus proxy
cat > "$WORK_DIR/ubuntu.sources" <<EOF
Types: deb
URIs: ${NEXUS_URL}/ubuntu-proxy/
Suites: noble noble-updates
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: ${NEXUS_URL}/ubuntu-security-proxy/
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

# 2) Container'in Nexus giris bilgisi
cat > "$WORK_DIR/nexus.conf" <<EOF
machine http://${NEXUS_HOST}:${NEXUS_HTTP_PORT}
login ${NEXUS_USER}
password ${NEXUS_PASSWORD}
EOF
chmod 600 "$WORK_DIR/nexus.conf"

# 3) Container icinde calisacak komutlar
cat > "$WORK_DIR/inside.sh" <<'EOF'
set -euo pipefail
rm -f /etc/apt/sources.list.d/*
cp /work/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources
cp /work/nexus.conf /etc/apt/auth.conf.d/nexus.conf
apt-get update -qq
apt-get install --download-only -y -qq "$@"
cp /var/cache/apt/archives/*.deb /out/
chown -R "$HOST_UID:$HOST_GID" /out
EOF

# Eski indirmeleri temizle, yenilerini al
mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/*.deb

log_info "Temiz $UBUNTU_IMAGE container'inda indiriliyor..."
docker run --rm \
  -v "$WORK_DIR:/work:ro" \
  -v "$OUT_DIR:/out" \
  -e HOST_UID="$(id -u)" \
  -e HOST_GID="$(id -g)" \
  "$UBUNTU_IMAGE" bash /work/inside.sh "${PACKAGES[@]}"

# Manifest: ne, ne zaman, nereden
DEB_COUNT="$(find "$OUT_DIR" -maxdepth 1 -name '*.deb' | wc -l)"
{
  echo "Liste:            $LIST_FILE"
  echo "Tarih:            $(date '+%Y-%m-%d %H:%M:%S')"
  echo "Kaynak image:     $UBUNTU_IMAGE"
  echo "Istenen paketler: ${PACKAGES[*]}"
  echo "Indirilen .deb:   $DEB_COUNT"
} > "$OUT_DIR/manifest.txt"

write_checksums "$OUT_DIR"
log_info "Tamamlandi: $DEB_COUNT paket -> $OUT_DIR"