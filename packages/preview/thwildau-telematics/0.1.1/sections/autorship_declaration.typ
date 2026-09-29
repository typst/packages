#import "../utils/translation.typ": translation

#let make-autorship-declaration() = {
  pagebreak(weak: true)

  // Declaration of independence
  heading(level: 1, numbering: none, translation("Declaration of authenticity"))
  //[Ich erkläre hiermit, dass ich den vorliegenden Praktikumsbericht eigenständig angefertigt und nur die angegeben Quellen und Hilfsmittel verwendet habe.]
  translation("Hereby, I declare that I have composed the presented paper independently on my own and without any other resources than the ones indicated. All thoughts taken directly or indirectly from external sources are properly denoted as such.")

  v(3cm)
  line(length: 100%)

  translation("Date") + ", " + translation("Signature")

  v(3cm)
}
