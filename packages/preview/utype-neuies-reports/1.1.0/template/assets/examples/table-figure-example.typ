// Tablo figürü örneği.
#figure(
  // Figürün başlığı yazılır.
  caption: [Fiziksel ve kimyasal olaylar sorularının frekans analizi.],
  // Figürün içeriği eklenir. Tablo eklenir.
  table(
    columns: 9,
    table.header(
      table.cell(rowspan: 2)[Soru],
      table.cell(colspan: 2)[Doğru],
      table.cell(colspan: 2)[Yanlış],
      table.cell(colspan: 2)[Fikrim Yok],
      table.cell(colspan: 2)[Toplam],
      table.hline(start: 1, stroke: 1pt),
      [*f*],
      [*%*],
      [*f*],
      [*%*],
      [*f*],
      [*%*],
      [*N*],
      [*%*],
    ),

    [S77], [152], [58,5], [86], [33,1], [22], [8,5], [260], [100],
    [S78], [121], [46,5], [122], [46,9], [17], [6,5], [260], [100],
    [S79], [169], [65], [67], [25,8], [24], [9,2], [260], [100],
    [S80], [208], [80], [21], [8,1], [31], [11,9], [260], [100],
    [S81], [246], [94,6], [11], [4,2], [3], [1,2], [260], [100],
    [S82], [233], [89,6], [23], [8,8], [4], [1,5], [260], [100],
    [S83], [220], [84,6], [38], [14,6], [2], [0,8], [260], [100],
    table.footer(
      table.cell(
        colspan: 9,
        stroke: none,
        align(left)[Tablo açıklaması varsa tablonun hemen altına yazınız.],
      ),
    ),
  ),
) <figür-tablo-fiziksel-ve-kimyasal-olaylar-sorularının-frekans-analizi> // Figüre atıf yapılırken kullanılacak etiket belirtilir. Bütün figürler 'figür' kelimesi ve türü de (şekilse 'şekil'; tabloysa 'tablo'; kodsa 'kod' vb.) şeklinde sistemli yazılırsa istenen figür aranırken bulması kolaylaşır.
