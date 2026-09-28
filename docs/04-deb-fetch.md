# Deb Paketlerini Çekme

[← Ana sayfa](../README.md)

Listedeki paketleri **tüm bağımlılıklarıyla** birlikte `.deb` olarak indirir.

**Script:** [`bin/deb-fetch.sh`](../bin/deb-fetch.sh)

## Çalışma Mantığı

İndirme, temiz bir `ubuntu:24.04` container'ı içinde yapılır. Temiz sistemde hiçbir paket kurulu olmadığı için bağımlılık listesi eksiksiz çıkar. Container'ın apt kaynakları Nexus apt proxy'ye yönlendirildiğinden, indirilen paketler Nexus önbelleğine de alınır.

```
liste → ubuntu:24.04 container → apt (Nexus proxy) → .deb → ARTIFACT_DIR/debs/<liste-adi>/
```

## Kullanım

```bash
./bin/deb-fetch.sh <liste-dosyasi>
./bin/deb-fetch.sh lists/debs/base-node.txt
```

## Çıktı

`ARTIFACT_DIR/debs/<liste-adi>/` klasörü (liste adı `.txt` olmadan):

| Dosya | İçerik |
|---|---|
| `*.deb` | İstenen paketler ve tüm bağımlılıkları |
| `manifest.txt` | Liste, tarih, kaynak image, istenen paketler, indirilen paket sayısı |
| `SHA256SUMS` | Tüm dosyaların sha256 özetleri |

Script her çalıştığında klasördeki eski `.deb` dosyalarını silip yeniden indirir.

## Nexus Ön Koşulları

- `ubuntu-proxy`: apt (proxy), distribution `noble`, `http://archive.ubuntu.com/ubuntu/`
- `ubuntu-security-proxy`: apt (proxy), distribution `noble-security`, `http://security.ubuntu.com/ubuntu/`

## Doğrulama

```bash
cat <cikti-klasoru>/manifest.txt
cd <cikti-klasoru> && sha256sum -c SHA256SUMS
```

## Tek Arşiv Haline Getirme (Manuel)

```bash
cd /srv/artifacts/debs
tar -czf /srv/artifacts/bundles/base-node-<tarih>.tar.gz base-node/
cd /srv/artifacts/bundles
sha256sum base-node-<tarih>.tar.gz > base-node-<tarih>.tar.gz.sha256
```

## İzole Makinede Kurulum

```bash
sha256sum -c base-node-<tarih>.tar.gz.sha256
tar -xzf base-node-<tarih>.tar.gz
cd base-node && sha256sum -c SHA256SUMS
sudo apt install ./*.deb
```

`apt install ./*.deb` bağımlılık sırasını kendisi çözer.

## Paket Listeleri

| Liste | İçerik |
|---|---|
| [`lists/debs/base-node.txt`](../lists/debs/base-node.txt) | İzole node'lar için temel OS paketleri (chrony, nfs-common, open-iscsi, jq, fio, tcpdump, strace vb.) |