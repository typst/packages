// Translated with: https://www.deepl.com
#let get-declaration-on-the-final-thesis(
  lang: "de",
  legal-reference: none,
  thesis-name: none,
  consent-to-publication-in-the-library: none, // true, false
  genitive-of-university: none
) = [
  #import "utils.typ": *
  #import "dictionary.typ": txt-declaration-on-the-final-thesis, txt-declaration-on-the-final-thesis-first-part

  #let get-placeholder(it) = { text(fill: red)[#todo(it)] }
    
  #set text(size: 10pt)
  #set heading(numbering: none)
  #heading(outlined: false, txt-declaration-on-the-final-thesis)

  #txt-declaration-on-the-final-thesis-first-part

  #v(1fr)

  #if lang == "de" [
    Mir ist bewusst, dass Täuschungen nach der für mich gültigen Studien- und Prüfungsordnung / nach
    #if is-not-none-or-empty(legal-reference) [ #legal-reference ] else [ #get-placeholder[Rechtsbezug] ]
    geahndet werden.
  ] else if lang == "en" [
    I am aware that cheating will be penalised according to the study and examination regulations applicable to me / according to
    #if is-not-none-or-empty(legal-reference) [ #legal-reference. ] else [ #get-placeholder[legal reference]. ]
  ]

  #v(1fr)

  #if lang == "de" [
    Die Zustimmung zur elektronischen Plagiatsprüfung wird erteilt.
  ] else if lang == "en" [
    Consent to the electronic plagiarism check is granted.
  ]
    
  #signing()

  #v(2fr)

  #if lang == "de" [
    Der Veröffentlichung der
    #if is-not-none-or-empty(thesis-name) [ #thesis-name ] else [ #get-placeholder[Art der Abschlussarbeit] ]
    in der Bibliothek der
    #if is-not-none-or-empty(genitive-of-university) [ #genitive-of-university ] else [ #get-placeholder[Genitiv der Universität] ]
    wird
    #if is-not-none-or-empty(consent-to-publication-in-the-library) {
      if consent-to-publication-in-the-library [] else [nicht]
    } else [ #get-placeholder[nicht] ]
    zugestimmt.
  ] else if lang == "en" [
    The publication of the
    #if is-not-none-or-empty(thesis-name) [ #thesis-name ] else [ #get-placeholder[thesis name] ]
    in the library of
    #if is-not-none-or-empty(genitive-of-university) [ #genitive-of-university ] else [ #get-placeholder[genitive of university] ]
    is
    #if is-not-none-or-empty(consent-to-publication-in-the-library) {
      if consent-to-publication-in-the-library [] else [nicht]
    } else [ #get-placeholder[not] ]
    approved.
  ] 

  #signing()
]