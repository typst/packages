// ORCID'leri tıklanabilir bağlantı haline getirmek için oluşturulmuş bir bileşen fonksiyonudur. [Create a clickable link component for ORCID.]\
// Örnek [Example]: [https://orcid.org/1234-1234-1234-1234]
#let orcid-link-component(orcid: none) = link("https://orcid.org/" + orcid, orcid)
