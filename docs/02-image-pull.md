# Image Çekme

[← Ana sayfa](../README.md)

Listedeki image'ları yerel Docker'a çeker.

**Script:** [`bin/image-pull.sh`](../bin/image-pull.sh)

## Kullanım

```bash
./bin/image-pull.sh <liste-dosyasi>
./bin/image-pull.sh lists/images/base.txt
```

## Kurallar

- Her image için sürüm etiketi zorunludur
- `latest` etiketi ve etiketsiz image'lar reddedilir

## Örnek Çıktı

```
[2026-09-27 12:13:30] [INFO]  4 image islenecek
[2026-09-27 12:13:30] [INFO]  Cekiliyor: nginx:1.27.2
[2026-09-27 12:13:38] [INFO]  Tamamlandi
```