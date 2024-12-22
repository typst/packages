#import "/lib.typ":*

#show: init-glossary.with(yaml("glossary.yml"))

@first, @second, @third, @fourth, @fifth, @sixth

#glossary(ignore-case: false, sort: true)
#line(length: 20em)
#glossary(ignore-case: true, sort: true)
#line(length: 20em)
#glossary(ignore-case: false, sort: false)
#line(length: 20em)
#glossary(ignore-case: true, sort: false)
