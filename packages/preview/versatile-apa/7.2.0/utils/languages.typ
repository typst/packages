#let language-terms = state("language-terms", (:))

#let get-terms(language, script) = {
  let overrides = language-terms.get()
  if language == "en" {
    (
      "and": "and",
      "Author Note": "Author Note",
      "Abstract": "Abstract",
      "Keywords": "Keywords",
      "Appendix": "Appendix",
      "Note": "Note",
      ..overrides,
    )
  } else if language == "es" {
    (
      "and": "y",
      "Author Note": "Nota del autor",
      "Abstract": "Resumen",
      "Keywords": "Palabras clave",
      "Appendix": "Apéndice",
      "Note": "Nota",
      ..overrides,
    )
  } else if language == "de" {
    (
      "and": "und",
      "Author Note": "Autorennotiz",
      "Abstract": "Zusammenfassung",
      "Keywords": "Schlüsselwörter",
      "Appendix": "Anhang",
      "Note": "Hinweis",
      ..overrides,
    )
  } else if language == "pt" {
    (
      "and": "e",
      "Author Note": "Nota do autor",
      "Abstract": "Resumo",
      "Keywords": "Palavras-chave",
      "Appendix": "Apêndice",
      "Note": "Nota",
      ..overrides,
    )
  } else if language == "fr" {
    (
      "and": "et",
      "Author Note": "Note de l'auteur",
      "Abstract": "Résumé",
      "Keywords": "Mots-clés",
      "Appendix": "Annexe",
      "Note": "Note",
      ..overrides,
    )
  } else if language == "it" {
    (
      "and": "e",
      "Author Note": "Nota dell'autore",
      "Abstract": "Sommario",
      "Keywords": "Parole chiave",
      "Appendix": "Appendice",
      "Note": "Nota",
      ..overrides,
    )
  } else if language == "nl" {
    (
      "and": "en",
      "Author Note": "Auteursopmerking",
      "Abstract": "Samenvatting",
      "Keywords": "Trefwoorden",
      "Appendix": "Bijlage",
      "Note": "Notitie",
      ..overrides,
    )
  } else if (language == "sr" and script == auto) or (script == "latn" and language == "sr") {
    (
      "and": "i",
      "Author Note": "Napomena autora",
      "Abstract": "Apstrakt",
      "Keywords": "Ključne reči",
      "Appendix": "Dodatak",
      "Note": "Napomena",
      ..overrides,
    )
  } else if language == "sr" and script == "cyrl" {
    (
      "and": "и",
      "Author Note": "Напомена аутора",
      "Abstract": "Апстракт",
      "Keywords": "Кључне речи",
      "Appendix": "Додатак",
      "Note": "Напомена",
      ..overrides,
    )
  } else if language == "id" {
    (
      "and": "dan",
      "Author Note": "Catatan Penulis",
      "Abstract": "Abstrak",
      "Keywords": "Kata Kunci",
      "Appendix": "Lampiran",
      "Note": "Catatan",
      ..overrides,
    )
  } else {
    overrides
    // language-terms.get()
  }
}
