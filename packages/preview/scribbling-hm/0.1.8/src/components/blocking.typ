#let blocking-notice(
  gender: none,
  thesis-type: "Bachelorarbeit"
) = {

  let author = if gender == "w" [der Verfasserin] else if gender == "m" [des Verfassers] else [des Verfassenden]

  v(1fr)

  [
    Die vorliegende #thesis-type beinhaltet vertrauliche Informationen und darf durch Dritte, mit Ausnahme der Gutachter und berechtigten Beteiligten im Prüfungsverfahren, ohne ausdrückliche schriftliche Zustimmung #author nicht eingesehen werden.

    Insbesondere ist eine Vervielfältigung, weitere Verwendung und eine Veröffentlichung der #thesis-type ohne ausdrückliche schriftliche Genehmigung #author, auch auszugsweise, untersagt.

  ]

  v(1fr)
}
