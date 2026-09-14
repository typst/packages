// Rapor Başlığı yazısı bileşeni. [Report Title text component.]\
// Örnek [Example]: [*TEZ BAŞLIĞI*]
#let report-title-text-component(report-title: none) = text(weight: "bold", upper(report-title.upper-case))
