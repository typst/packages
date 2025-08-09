#import "@preview/codly:1.2.0": *
#import "/lib.typ": *
#show: codly-init
#codly(languages: codly-languages)
#for (key, entry) in codly-languages{
  raw(lang: key, block: true,  key)
}
