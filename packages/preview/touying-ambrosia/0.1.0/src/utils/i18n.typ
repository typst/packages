/// i18n Outline Title
///
/// -> content
#let i18n-outline-title = context {
  let mapping = (
    ar: "المحتويات",
    ca: "Índex",
    cs: "Obsah",
    da: "Indhold",
    en: "Outline",
    es: "Índice",
    et: "Sisukord",
    fi: "Sisällys",
    fr: "Sommaire",
    ja: "目次",
    ru: "Содержание",
    zh-TW: "目錄",
    zh: "目录",
    vn: "Nội Dung",
  )
  mapping.at(text.lang, default: mapping.en)
}


/// i18n Bibliography Title
///
/// -> content
#let i18n-bibliography-title = context {
  let mapping = (
    ar: "المراجع",
    ca: "Bibliografia",
    cs: "Literatura",
    da: "Litteraturliste",
    en: "Bibliography",
    es: "Bibliografía",
    et: "Bibliograafia",
    fi: "Kirjallisuusluettelo",
    fr: "Bibliographie",
    ja: "参考文献",
    ru: "Список литературы",
    zh-TW: "參考文獻",
    zh: "参考文献",
    vn: "Tài Liệu Tham Khảo",
  )
  mapping.at(text.lang, default: mapping.en)
}
