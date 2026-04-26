// this is an example. Check https://typst.app/universe/package/glossarium

#let glossary = (
  // minimal term
  (key: "jku", short: "Johannes Kepler University"),
  // a term with a long form
  (key: "goat", short: "GOAT", long: "greatest of all time"),
  // no long form here
  (key: "kdecom", short: "KDE Community", desc:"An international team developing and distributing Open Source software."),
  // a full term with description containing markup
  (
    key: "oidc", 
    short: "OIDC", 
    long: "OpenID Connect", 
    desc: [OpenID is an open standard and decentralized authentication protocol promoted by the non-profit
     #link("https://en.wikipedia.org/wiki/OpenID#OpenID_Foundation")[OpenID Foundation].]),
)