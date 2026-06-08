// SEMBOLLER içeriği — "SEMBOLLER" başlığı şablon tarafından eklenir.
// LaTeX şablonundaki gibi: kalın sembol, ardından " : " ve açıklama (başlık satırı yok).

#grid(
  columns: (auto, auto, 1fr),
  column-gutter: (1.5em, 0.6em),
  row-gutter: 0.7em,
  [$alpha$], [:], [Açı, alfa açısı],
  [$beta$], [:], [Açı, beta açısı],
  [$gamma$], [:], [Açı, gama açısı],
  [$Delta E$], [:], [Enerji farkı],
  [$sigma$], [:], [Standart sapma],
  [$theta$], [:], [Sıcaklık],
  [$lambda$], [:], [Dalga boyu],
  [$mu$], [:], [Ortalama, mikro],
  [$pi$], [:], [Pi sayısı],
  [$rho$], [:], [Yoğunluk],
)
