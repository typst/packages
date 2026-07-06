//============================================================================================//
//                                          Imports                                           //
//============================================================================================//

#import "./books.typ": iboo


//============================================================================================//
//                                   blindex Languages File                                   //
//============================================================================================//

// Declaration and structuring of the {ldict} language dictionary
#let ldict = (:)

// Populate ldict with book keys
#for K in iboo.keys() { ldict.insert(K, (:)) }

#let lang-paths = (
  "lang/en/en-USX.typ",       // English, Unified Scripture XML (USX), "en-USX", language
  "lang/en/en-3.typ",         // English, 3-char English, "en-3", language
  "lang/en/en-logos.typ",     // English, Logos bible, "en-logos", language
  "lang/pt/pt-ARC-1911.typ",  // Portuguese, Almeida Revista e Corrigida, 1911
  "lang/pt/br-pro.typ",       // Brazilian Portuguese, Protestant, "br-pro", language
  "lang/pt/br-cat.typ",       // Brazilian Portuguese, Catholic, "br-cat", language
  "lang/fr/fr-TOB.typ",       // Français, Œcuménique, "fr-TOB", language
)

// Language-tradition imports
#for path-to-file in lang-paths {
  let path-parts = path-to-file.split("/")
  let iso-639-2-lang = path-parts.at(1)
  let lang-file-name = path-parts.at(2)
  let lang-name = lang-file-name.split(".").at(0)
  import path-to-file: lang-dict
  for key in iboo.keys() {
    ldict.at(key).insert(lang-name, lang-dict.at(key))
  }
}

