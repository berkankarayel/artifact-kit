# Image'ı Nexus'a Gönderme

[← Ana sayfa](../README.md)

Listedeki image'ları çeker, Nexus adıyla etiketler ve Nexus'a gönderir. Nexus'ta zaten bulunan image'lar atlanır.

**Script:** [`bin/image-push.sh`](../bin/image-push.sh)

## Kullanım

```bash
./bin/image-push.sh <liste-dosyasi>
./bin/image-push.sh lists/images/base.txt
```

## İsimlendirme

Kaynak registry adresi atılır, orijinal yol korunur:

| Kaynak | Nexus'taki adı |
|---|---|
| `nginx:1.27.2` | `<nexus>/library/nginx:1.27.2` |
| `rancher/k3s:v1.31.1-k3s1` | `<nexus>/rancher/k3s:v1.31.1-k3s1` |
| `mcr.microsoft.com/dotnet/aspnet:8.0` | `<nexus>/dotnet/aspnet:8.0` |

## Nexus Ön Koşulları

1. **Docker (hosted)** deposu, HTTP connector portu tanımlı (örn. `8082`)
2. **Security → Realms** altında **Docker Bearer Token Realm** aktif
3. Nexus HTTP kullanıyorsa, Docker'da `/etc/docker/daemon.json`:

```json
{
  "insecure-registries": ["<nexus-adresi>:8082"]
}
```

Docker, registry'leri **isimle** eşleştirir. IP ve DNS adı ayrı kayıtlar gerektirir (hem `insecure-registries` hem `docker login`).

## Nexus'tan Çekme

```bash
docker login <nexus-adresi>:8082 -u admin
docker pull <nexus-adresi>:8082/library/nginx:1.27.2
```