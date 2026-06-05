# İTÜ Tez Şablonu (Typst) · `itu-thesis`

İstanbul Teknik Üniversitesi (İTÜ) lisansüstü tezleri için Typst şablonu.
Resmi LaTeX şablonu (`itutez.cls` v1.7.1, Ocak 2025) temel alınarak yeniden
yazılmıştır.

> Thesis template for graduate theses at Istanbul Technical University, ported
> from the official LaTeX class to Typst.

> ⚠️ **Gayriresmî / topluluk uyarlaması.** Bu paket İstanbul Teknik
> Üniversitesi tarafından resmî olarak onaylanmamıştır; resmî LaTeX şablonundan
> bağımsız bir gönüllü uyarlamasıdır. Teziniz teslim edilmeden önce çıktının
> güncel İTÜ tez yazım kurallarına uyduğunu mutlaka kendiniz doğrulayın.
>
> *Unofficial community port — not officially endorsed by ITU. Verify the
> output against the current official thesis guidelines before submission.*

## Hızlı başlangıç

```bash
typst init @preview/itu-thesis:0.1.0 benim-tezim
cd benim-tezim
typst watch main.typ
```

Bu komut çalışan bir örnek proje oluşturur. `main.typ` içindeki bilgileri kendi
tezinize göre düzenleyin.

## Özellikler

- Dış kapak + Türkçe iç kapak + İngilizce iç kapak
- Jüri onay / imza sayfası
- İthaf, Önsöz, İçindekiler, Kısaltmalar, Semboller
- Çizelge Listesi ve Şekil Listesi (otomatik)
- Özet / Summary
- Ön materyalde roma (i, ii, …), gövdede arabik (1, 2, …) sayfa numarası
- Numaralı bölümler (“BÖLÜM 1. …”) + numarasız ön/arka materyal başlıkları
- Ekler (EKLER kapağı ile) ve Özgeçmiş
- NUM (sayılı/IEEE) ve APA atıf stilleri — bkz. `main.typ` ve `main-apa.typ`
- Türkçe ve İngilizce dil desteği (`dil: "tr"` / `dil: "en"`)

## Kullanım

`#show: thesis.with(...)` çağrısındaki başlıca parametreler:

| Parametre | Açıklama |
|---|---|
| `ad`, `soyad`, `ogrenci-no` | Öğrenci bilgileri |
| `tez-basligi`, `thesis-title` | TR/EN başlık (en çok 3 satır, dizi) |
| `anabilim-dali-tr/-en`, `program-tr/-en` | Akademik birim |
| `enstitu` | `"lisansustu"`, `"bilisim"`, `"fenbilimleri"`, `"sosyalbilimler"`, `"enerji"`, `"avrasya"` |
| `danisman`, `danisman-en`, `es-danisman*` | Danışman / eş danışman (TR & EN) |
| `juri` | `(ad: "...", univ: "...")` sözlüklerinden dizi |
| `dil` | `"tr"` veya `"en"` |
| `derece` | `"yukseklisans"` veya `"doktora"` |
| `cilt` | `"bez"` veya `"karton"` |
| `ithaf`, `onsoz`, `kisaltmalar`, `semboller`, `ozet`, `summary`, `ekler`, `ozgecmis` | Ön/arka materyal içerikleri |
| `kaynakca` | `bibliography("refs.bib", style: "ieee", title: "Kaynaklar")` |

Gövde bölümleri (`= Giriş`, `== Alt başlık`, …) `#show` çağrısından sonra
normal Typst başlıkları olarak yazılır; otomatik olarak numaralanır.

### Atıf ve kaynakça

`refs.bib` dosyasına BibTeX kayıtları ekleyin, metin içinde `@anahtar` ile atıf
yapın. Stil için `kaynakca` parametresinde `style: "ieee"` (sayılı) veya
`style: "apa"` kullanın.

## Notlar

- Şablon `Times New Roman` fontunu hedefler; sistemde yoksa `TeX Gyre Termes` /
  `Libertinus Serif` gibi alternatiflere düşer. Birebir görünüm için Times New
  Roman fontunun kurulu olması önerilir.
- Typst, EPS desteklemez; şekilleri PNG/PDF/SVG olarak ekleyin.

## Lisans

MIT — bkz. [LICENSE](LICENSE).

Bu şablon, İTÜ Bilişim Enstitüsü tarafından hazırlanan resmi LaTeX şablonundan
uyarlanmıştır.
