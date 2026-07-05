#import "@preview/formalettre:0.3.0": lettre

#set text(lang: "fr")

#show: lettre.with(
expediteur: (
  nom: [Étienne #smallcaps[de la Boétie]],
  adresse: [145 avenue de Germignan],
  commune: [33320 Le Taillan-Médoc],
  // Le téléphone et l'adresse email doivent être des chaînes de caractères et
  // non des contenus. Ils seront traités pour en faire des liens cliquables.
  telephone: "01 99 00 67 89",
  email: "etienne@laboetie.example",
  // Coordonnées supplémentaires libres
  coordonnees: (
    link("http://www.laboetie.example/", [www.laboetie.example]),
    [Fédivers : #link(
      "https://mastodon.example/@la_boétie",
      [\@la_boetie\@mastodon.example])],
  )
  // Décommenter la ligne suivante pour utiliser autre chose que le prénom et
  // le nom dans la signature
  // signature: [Étienne],
  // Remplacer par la ligne suivante pour indiquer plusieurs signataires :
  // signature: ([Étienne de la Boétie], [Lambert Daneau]),
  // Décommenter la ligne suivante pour inclure l'image d'une signature
  // numérisée
  // image-signature: image("signature.png"),
),
destinataire: (
  nom: [Michel de Montaigne],
  adresse: [17 butte Farémont],
  commune: [55000 Bar-le-Duc],
),
// Décommenter les lignes suivantes pour indiquer un envoi sous couvert d'un
// intermédiaire hiérarchique.
// intermediaire: (
//   nom: [M. le Président Benoist de Lagebaston],
//   adresse: ([Parlement de Bordeaux], [Palais de l'Ombrière], [Place du Palais]),
//   commune: [33000 Bordeaux],
// ),
lieu: [Camp Germignan],
objet: [Lorem ipsum ?],
date: [le 7 juin 1559],
// Remplacer par la ligne suivante pour utiliser la date du jour
// date: auto,
// Décommenter la ligne suivante pour afficher des informations d'envoi suivi
// ou recommandé
// envoi: [Lettre suivie numéro XXXXXXXX],
ref: [1559/06/0001],    // au besoin, préciser à la place
                        // vref: [<réf. destinataire>]
                        // nref: [<réf. expéditeur>]
appel: [Cher ami,],
salutation: [Veuillez agréer, cher ami, l'assurance de mes chaleureuses salutations.],
ps: [Au fait, notez bien notre prochain rendez-vous !],
// Décommenter la ligne suivante pour préciser des pièces jointes
// pj: ([Photo de famille], [Copie de mon dernier essai]),
// Décommenter la ligne suivante pour indiquer des destinataires en copie
// cc: ([Lambert Daneau], [Jean-Antoine du Baïf]),
marges: (1.5cm, 1cm),   // pour ajouter des marges supplémentaires à gauche
                        // et à droite du corps de la lettre
                        //
marque-pliage: false,   // indiquez true pour imprimer une marque de pliage
                        //
enveloppe: none,        // indiquez un format d'enveloppe, par exemple
                        // "c4", "c5", "c6", "c56" ou "dl"
                        // pour générer une page à imprimer sur enveloppe,
                        //
affranchissement: none, // fournir un code d'affranchissement ou un contenu
                        // d'image de timbre pour qu'il soit imprimé
                        // dans la zone idoine de l'enveloppe
                        //
capitalisation: 0,      // pour passer les adresses en petites capitales ou
                        // en majuscules, indiquer un niveau de capitalisation:
                        // 1, 1.5, 2, 2.5, 3 ou 3.5 (cf. README)
                        //
numerotation: auto,     // auto: afficher automatiquement les numéros de page
                        //       lorsqu'il y a plus d'une page
                        // none: pour jamais afficher de numéro de page
                        // chaîne ou fonction: cf.
                        // <https://typst.app/docs/reference/layout/page/#parameters-numbering>

)

// Le corps du document remplace cette fonction
#lorem(150)
