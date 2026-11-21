#import "@preview/ilkman:0.1.0": *

#show: im-doc.with(
  lang: "tr",
  title: [Ders Notları],
  subtitle: [Bir ilkman başlangıç belgesi],
  author: "Yazar Adı",
  version: "v0.1",
  fonts: "mulish",    // mulish | plex | source | fira
  colors: "okyanus",  // 15 palet: okyanus, fiyort, gece, çelik, okabe, orman, ...
)

#im-cover(style: "waveform", series: "Ders notları", volume: 1)
#im-toc()

= Giriş

Bu belge *ilkman* ile hazırlandı. Paragraflar girintili başlar; bloklar
arasındaki boşluk otomatik ayarlanır. Bir terimi
#im-explain("SIP")[Session Initiation Protocol: çağrı kurma protokolü.]
sol sütundaki bir notla açıklayabilirsiniz.

== Kod

#im-code(title: "merhaba.py", hl: (2,), caption: [İlk program])[```py
def merhaba(ad):
    return f"Merhaba {ad}"

print(merhaba("dünya"))
```]

Satır içi kod: `sip:alice@example.com`.

== Tablo

#im-table(fill: "blue", caption: [Sık kullanılan portlar])[```
Protokol | Port  | Taşıma
SIP      | 5060  | UDP/TCP
SIPS     | 5061  | TLS
RTP      | 10000 | UDP
```]

== Kutular

#im-grid("1/1", fill: ("green", "red"))[
  *Doğru:* önce `REGISTER`.
][
  *Yanlış:* kayıtsız `INVITE`.
]

#im-note(kind: "tip")[Kısayol: #im-kbd("Ctrl+Shift+P")]
