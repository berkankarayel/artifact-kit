# Airgap Artifact Kit

İnternete kapalı ortamlar için container image, paket ve dosyaları çekip Nexus'a taşıyan bash scriptleri.

Neyin çekileceği `lists/` altındaki metin dosyalarında tanımlanır; scriptlere dokunmadan sadece listeler değiştirilir.

## Dokümanlar

| # | Konu | Durum |
|---|---|---|
| 1 | [Kurulum ve Yapılandırma](docs/01-kurulum.md) | ✅ |
| 2 | [Image Çekme (image-pull)](docs/02-image-pull.md) | ✅ |
| 3 | [Image'ı Nexus'a Gönderme (image-push)](docs/03-image-push.md) | ✅ |

## Hızlı Başlangıç

```bash
cp config/config.env.example config/config.env
./bin/image-push.sh lists/images/base.txt
```

## Yapı

```
├── bin/        # Çalıştırılan scriptler
├── lib/        # Ortak fonksiyonlar (common.sh)
├── config/     # Ayarlar
└── lists/      # Çekilecek öğelerin listeleri
```