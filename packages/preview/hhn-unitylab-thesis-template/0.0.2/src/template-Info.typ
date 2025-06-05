#let template-version = version(0, 0, 2)
#let template-date = datetime.today().display("[day]. [month repr:long] [year]")
#let template-info = [*Template Version #template-version from #template-date*]

#let template-license = link("https://opensource.org/license/mit")[MIT]
#let template-copyright-year = "2024"
#let template-copyright-holder = "Ferdinand Burkhardt"

#let print-template-info() = {

  let font = context text.font
  let font-size = context text.size
  let font-leading = context par.leading
  let lang = context text.lang
  
  [
    #pagebreak()
    
    = Template Information
    Version: #template-info \
    License: #template-license \
    Copyright Year: #template-copyright-year \
    Copyright Holder: #template-copyright-holder 
    
    Font: #font \
    Size: #font-size \
    Leading: #font-leading \
    Language Settings: #lang 
    
    #link("https://typst.app/universe/package/hhn-unitylab-thesis-template")[Typst Universe Package]
  ]
}
