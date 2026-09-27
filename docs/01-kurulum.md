# Kurulum ve Yapılandırma

[← Ana sayfa](../README.md)

## Gereksinimler

- Bash 4+
- Docker
- curl
- Nexus Repository (image-push için)

## Yapılandırma

```bash
cp config/config.env.example config/config.env
```

| Değişken | Açıklama |
|---|---|
| `NEXUS_HOST` | Nexus adresi (IP veya DNS adı) |
| `NEXUS_HTTP_PORT` | Nexus arayüz ve API portu |
| `NEXUS_DOCKER_PORT` | Nexus Docker registry portu |
| `NEXUS_USER` | Nexus kullanıcı adı |
| `ARTIFACT_DIR` | İndirilen dosyaların kaydedileceği klasör |

`config/config.env` Git'e dahil edilmez.

## Şifre

Şifre dosyada tutulmaz. Script çalışırken sorar veya ortam değişkeninden okur:

```bash
export NEXUS_PASSWORD='...'
```

## Liste Formatı

- Her satıra bir öğe yazılır
- `#` ile başlayan satırlar ve satır sonu yorumları atlanır
- Boş satırlar atlanır

```
# Temel image'lar
nginx:1.27.2
mcr.microsoft.com/dotnet/aspnet:8.0   # uygulama calisma ortami
```