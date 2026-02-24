#let language-terms = state("language-terms", (:))

#let get-terms(language) = {
  if language == "en" {
    (
      "and": "and",
      "Author Note": "Author Note",
      "Abstract": "Abstract",
      "Keywords": "Keywords",
      "Appendix": "Appendix",
      "Annex": "Annex",
      "Addendum": "Addendum",
      "Note": "Note",
    )
  } else if language == "es" {
    (
      "and": "y",
      "Author Note": "Nota del autor",
      "Abstract": "Resumen",
      "Keywords": "Palabras clave",
      "Appendix": "Apéndice",
      "Annex": "Anexo",
      "Addendum": "Adenda",
      "Note": "Nota",
    )
  } else if language == "de" {
    (
      "and": "und",
      "Author Note": "Autorennotiz",
      "Abstract": "Zusammenfassung",
      "Keywords": "Schlüsselwörter",
      "Appendix": "Anhang",
      "Annex": "Anhang",
      "Addendum": "Nachtrag",
      "Note": "Hinweis",
    )
  } else if language == "pt" {
    (
      "and": "e",
      "Author Note": "Nota do autor",
      "Abstract": "Resumo",
      "Keywords": "Palavras-chave",
      "Appendix": "Apêndice",
      "Annex": "Anexo",
      "Addendum": "Adendo",
      "Note": "Nota",
    )
  } else if language == "fr" {
    (
      "and": "et",
      "Author Note": "Note de l'auteur",
      "Abstract": "Résumé",
      "Keywords": "Mots-clés",
      "Appendix": "Annexe",
      "Annex": "Annexe",
      "Addendum": "Addendum",
      "Note": "Note",
    )
  } else if language == "it" {
    (
      "and": "e",
      "Author Note": "Nota dell'autore",
      "Abstract": "Sommario",
      "Keywords": "Parole chiave",
      "Appendix": "Appendice",
      "Annex": "Allegato",
      "Addendum": "Addendum",
      "Note": "Nota",
    )
  } else if language == "nl" {
    (
      "and": "en",
      "Author Note": "Auteursopmerking",
      "Abstract": "Samenvatting",
      "Keywords": "Trefwoorden",
      "Appendix": "Bijlage",
      "Annex": "Bijlage",
      "Addendum": "Addendum",
      "Note": "Notitie",
    )
  } else if language in ("sr_Latn", "sr") {
    (
      "and": "i",
      "Author Note": "Napomena autora",
      "Abstract": "Apstrakt",
      "Keywords": "Ključne reči",
      "Appendix": "Dodatak",
      "Annex": "Prilog",
      "Addendum": "Dopuna",
      "Note": "Napomena",
    )
  } else if language == "sr_Cyrl" {
    (
      "and": "и",
      "Author Note": "Напомена аутора",
      "Abstract": "Апстракт",
      "Keywords": "Кључне речи",
      "Appendix": "Додатак",
      "Annex": "Прилог",
      "Addendum": "Допуна",
      "Note": "Напомена",
    )
  } else {
    language-terms.get()
  }
}
