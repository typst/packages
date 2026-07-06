// APPENDICES content — the "EKLER" cover heading is added by the template.
// Each appendix starts with a level-1 heading (=); these are printed unnumbered.

= EK A: İlave Çalışmalar

Bu ek bölümde tez içinde detaylı olarak yer alamayan ancak araştırmanın
bütünlüğü için önemli olan ek çalışmalar sunulmuştur.

== A.1 Ek İstatistikler

Aşağıdaki tablo, ana metinde sunulandan daha ayrıntılı veriler içermektedir.

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    [Deneme], [Ortalama], [Standart Sapma],
    [1], [45.2], [2.3],
    [2], [47.8], [1.9],
    [3], [46.5], [2.1],
    [4], [48.1], [1.8],
  ),
  caption: [Ek istatistikler],
)

== A.2 Kod Örnekleri

```python
def calculate_mean(data):
    """Veri setinin ortalamasını hesaplar."""
    return sum(data) / len(data)

result = calculate_mean([1, 2, 3, 4, 5])
print(f"Ortalama: {result}")
```

= EK B: Detaylı Formüller

Işık hızı ile ilgili Einstein formülü:

$ E = m c^2 $

burada $E$ enerji, $m$ kütle ve $c$ ışık hızıdır. Genel görelilik denklemi:

$ G_(mu nu) + Lambda g_(mu nu) = 8 pi G T_(mu nu) $
