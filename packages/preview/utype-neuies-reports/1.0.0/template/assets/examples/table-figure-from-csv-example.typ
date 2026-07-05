// CSV dosyaının yolu `csv`fonksiyonuna girilerek veri okunur.
#let csv-table-data = csv("/template/assets/csv-files/csv-table-data.csv")

// CSV dosyasından tablo figürü örneği.
#figure(
  // Figürün başlığı yazılır.
  caption: [CSV dosyasıyla tablo örneği.],
  // Figürün içeriği eklenir. Tablo eklenir.
  table(
    columns: csv-table-data.first().len(),
    table.header(
      table.cell(rowspan: 2)[Soru],
      table.cell(colspan: 2)[Doğru],
      table.cell(colspan: 2)[Yanlış],
      table.cell(colspan: 2)[Fikrim Yok],
      table.cell(colspan: 2)[Toplam],
      table.hline(start: 1, stroke: 1pt),
      ..([*f*], [*%*]) * 3,
      [*N*],
      [*%*],
    ),
    ..csv-table-data.flatten(),
    table.footer(
      table.cell(
        colspan: csv-table-data.first().len(),
        stroke: none,
        align(left)[\* Tablo açıklaması varsa tablonun hemen altına yazınız.\ \* İkinci satır örneği.],
      ),
    ),
  ),
) <figür-tablo-csv-dosyasıyla-tablo-örneği> // Figüre atıf yapılırken kullanılacak etiket belirtilir. Bütün figürler 'figür' kelimesi ve türü de (şekilse 'şekil'; tabloysa 'tablo'; kodsa 'kod' vb.) şeklinde sistemli yazılırsa istenen figür aranırken bulması kolaylaşır.
