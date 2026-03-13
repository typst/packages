#let georgia = ("Georgia", "New Computer Modern")

#let make-copyright-page(author) = {
  page(numbering: none, header: none, footer: none, {
    set text(font: georgia, size: 10pt)
    set par(justify: true, spacing: 0.65em, first-line-indent: 0pt)

    v(2cm + 26pt)

    text(font: "New Computer Modern", size: 11.7pt, weight: "bold", "Upphovsrätt")
    v(0.6em)

    [Detta dokument hålls tillgängligt på Internet - eller dess framtida ersättare - under 25 år från publiceringsdatum under förutsättning att inga extraordinära omständigheter uppstår.]

    par(first-line-indent: 1.5em)[Tillgång till dokumentet innebär tillstånd för var och en att läsa, ladda ner, skriva ut enstaka kopior för enskilt bruk och att använda det oförändrat för ickekommersiell forskning och för undervisning. Överföring av upphovsrätten vid en senare tidpunkt kan inte upphäva detta tillstånd. All annan användning av dokumentet kräver upphovsmannens medgivande. För att garantera äktheten, säkerheten och tillgängligheten finns lösningar av teknisk och administrativ art.]

    par(first-line-indent: 1.5em)[Upphovsmannens ideella rätt innefattar rätt att bli nämnd som upphovsman i den omfattning som god sed kräver vid användning av dokumentet på ovan beskrivna sätt samt skydd mot att dokumentet ändras eller presenteras i sådan form eller i sådant sammanhang som är kränkande för upphovsmannens litterära eller konstnärliga anseende eller egenart.]

    par(first-line-indent: 1.5em)[För ytterligare information om Linköping University Electronic Press se förlagets hemsida #raw("http://www.ep.liu.se/").]

    v(2cm + 14pt)

    text(font: "New Computer Modern", size: 11.7pt, weight: "bold", "Copyright")
    v(0.6em)

    [The publishers will keep this document online on the Internet - or its possible replacement - for a period of 25 years starting from the date of publication barring exceptional circumstances.]

    par(first-line-indent: 1.5em)[The online availability of the document implies permanent permission for anyone to read, to download, or to print out single copies for his/hers own use and to use it unchanged for non-commercial research and educational purpose. Subsequent transfers of copyright cannot revoke this permission. All other uses of the document are conditional upon the consent of the copyright owner. The publisher has taken technical and administrative measures to assure authenticity, security and accessibility.]

    par(first-line-indent: 1.5em)[According to intellectual property law the author has the right to be mentioned when his/her work is accessed as described above and to be protected against infringement.]

    par(first-line-indent: 1.5em)[For additional information about the Linköping University Electronic Press and its procedures for publication and for assurance of document integrity, please refer to its www home page: #raw("http://www.ep.liu.se/").]

    v(1fr)

    h(1.5em)
    [© #author]

    v(1fr)
  })
}
