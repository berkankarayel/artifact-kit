#!/usr/bin/env bash
# Ortak fonksiyonlar.
# Bu dosya dogrudan calistirilmaz; scriptler tarafindan 'source' ile yuklenir.

# ---------- Log ----------
log_info() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO]  $*"
}

log_error() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" >&2
}

# ---------- Kontroller ----------
require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    log_error "Dosya bulunamadi: $file"
    exit 1
  fi
}

# ---------- Ayarlar ----------
load_config() {
  local config_file="$ROOT_DIR/config/config.env"
  require_file "$config_file"
  source "$config_file"
}

# ---------- Liste ----------
# Liste dosyasini okur, yorum ve bos satirlari atar, temiz satirlari basar.
read_list() {
  local file="$1"
  local line
  while IFS= read -r line; do
    line="${line%%#*}"
    line="$(echo "$line" | xargs)"
    [[ -z "$line" ]] && continue
    echo "$line"
  done < "$file"
}

# ---------- Image ----------
# Image adinda surum etiketi var mi ve latest degil mi kontrol eder.
validate_image_ref() {
  local image="$1"
  local name="${image##*/}"
  if [[ "$name" != *:* || "$name" == *:latest ]]; then
    log_error "'$image' icin surum belirtilmeli (latest kullanilamaz)"
    return 1
  fi
}

pull_image() {
  local image="$1"
  log_info "Cekiliyor: $image"
  docker pull --quiet "$image"
}

# ---------- Nexus ----------
# Sifre ortam degiskeninde yoksa gizli olarak sorar.
require_nexus_password() {
  if [[ -z "${NEXUS_PASSWORD:-}" ]]; then
    read -r -s -p "Nexus sifresi ($NEXUS_USER): " NEXUS_PASSWORD
    echo
  fi
}

# Docker'i Nexus registry'sine giris yaptirir.
nexus_login() {
  echo "$NEXUS_PASSWORD" | docker login "${NEXUS_HOST}:${NEXUS_DOCKER_PORT}" \
    -u "$NEXUS_USER" --password-stdin > /dev/null
  log_info "Nexus girisi basarili: ${NEXUS_HOST}:${NEXUS_DOCKER_PORT}"
}

# Image adindan kaynak registry'yi atip Nexus'taki yolu uretir.
#   nginx:1.27.2                        -> library/nginx:1.27.2
#   rancher/k3s:v1.31.1-k3s1            -> rancher/k3s:v1.31.1-k3s1
#   mcr.microsoft.com/dotnet/aspnet:8.0 -> dotnet/aspnet:8.0
image_path() {
  local image="$1"
  local first="${image%%/*}"
  if [[ "$image" == */* && ( "$first" == *.* || "$first" == *:* ) ]]; then
    image="${image#*/}"
  fi
  if [[ "$image" != */* ]]; then
    image="library/$image"
  fi
  echo "$image"
}

# Image'in Nexus'taki tam adi.
nexus_image() {
  echo "${NEXUS_HOST}:${NEXUS_DOCKER_PORT}/$(image_path "$1")"
}

# Image Nexus'ta var mi? Varsa 0 (basarili), yoksa 1 doner.
image_exists_in_nexus() {
  local path name tag code
  path="$(image_path "$1")"
  name="${path%:*}"
  tag="${path##*:}"
  code="$(curl -s -I -o /dev/null -w '%{http_code}' \
    -u "${NEXUS_USER}:${NEXUS_PASSWORD}" \
    -H "Accept: application/vnd.oci.image.index.v1+json" \
    -H "Accept: application/vnd.docker.distribution.manifest.list.v2+json" \
    -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    "http://${NEXUS_HOST}:${NEXUS_DOCKER_PORT}/v2/${name}/manifests/${tag}")"
  [[ "$code" == "200" ]]
}

# Image'i Nexus adiyla etiketler ve gonderir.
push_image() {
  local image="$1"
  local target
  target="$(nexus_image "$image")"
  log_info "Etiketleniyor: $image -> $target"
  docker tag "$image" "$target"
  log_info "Gonderiliyor: $target"
  docker push --quiet "$target"
}