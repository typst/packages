// Rapport de laboratoire HES-SO
//
// 📋 Configuration: src/settings/name.typ
// 📝 Sections: examples/1_intro.typ, examples/20_conclusion.typ, etc.

#import "@preview/rapport-labo-hes-so:0.1.0": *
#import "src/settings/name.typ": config
#set math.equation(numbering: if config.afficher-numéros-équations { "(1)" } else { none })
#show: rapport()
#show lq.selector(lq.diagram): set text(.9em)
#show: lq.set-tick(outset: 3pt, inset: 0pt)
#show: lq.set-diagram(
  xaxis: (mirror: (ticks: false)),
  yaxis: (mirror: (ticks: false)),
)
#register-glossary(mes-acronymes)
#let exemple_content = read("src/assets/code/exemple.py")

//EDITION
= Introduction

Ce modèle démontre les principales fonctionnalités disponibles pour créer un rapport de laboratoire professionnel avec HES-SO.

== Objectif

L'objectif est d'étudier le comportement des composants électriques en régime alternatif et de valider les résultats avec les théories établies.

== Méthodologie

Nous avons utilisé une approche expérimentale combinée à une @rust pour validation théorique.

// ============================================================================
// 2. BOÎTES UTILITAIRES
// ============================================================================

#pagebreak()
= Exemples de boîtes utilitaires

Les boîtes utilitaires vous permettent de mettre en avant des informations importantes.

== Boîte d'information
#info-box[Ceci est une boîte d'information. Elle contient des détails importants et des conseils pratiques.]

== Boîte d'attention
#danger-box[⚠️ Attention ! Cette zone contient un risque identifié. Respectez les consignes de sécurité.]

== Boîte de validation
#valid-box[✅ La validation des résultats a réussi avec une précision de 98%.]

== Boîte d'erreur
#feu-box[🔥 Erreur critique détectée dans le circuit à 14h30. Calibrer les instruments.]

== Boîte d'idée
#idea-box[💡 Suggestion : utiliser une meilleure source de signal pour améliorer la précision des mesures.]

== Boîte TODO
#todo-box[
  - Collecter les données finales
  - Vérifier les calculs
  - Rédiger la conclusion
]

// ============================================================================
// 3. CONTENU TECHNIQUE - ÉQUATIONS
// ============================================================================

#pagebreak()
= Contenu technique

== Équations numérotées

La réactance inductive est donnée par :
$ X_L = 2 pi f L $ <eq:reactance>

On peut également exprimer l'impédance totale comme :
$ Z = sqrt(R^2 + X_L^2) $ <eq:impedance>

D'après l'équation @eq:reactance, on constate que la réactance varie linéairement avec la fréquence. En utilisant l'équation @eq:impedance, on peut calculer l'impédance totale du circuit.

== Tables et figures

#figure(
  table(
    columns: (auto, 20%, 1fr, 25%),
    inset: 8pt,
    align: horizon,
    stroke: 0.5pt + luma(150),
    fill: (x, y) => {
      if y == 0 { green.lighten(80%) } else if x == 0 { blue.lighten(80%) } else { none }
    },
    [*Fréquence*], [*Intensité (mA)*], [*Réactance (Ω)*], [*Inductance (mH)*],
    [1 kHz], [267.33], [13.96], [2.2],
    [1.5 kHz], [178.02], [21.46], [2.2],
    [2 kHz], [133.65], [28.92], [2.2],
  ),
  caption: [Mesures de l'inductance de la bobine en fonction de la fréquence],
)

Ce rapport utilise notamment @hei et @rust.

== Texte avec surbrillance

Ce texte contient des éléments #stabilo(couleur: yellow)[surbrillancés en jaune], #stabilo(couleur: rgb("#FF6B6B"), opacite: 70%)[en rouge], et #stabilo(couleur: green, opacite: 50%)[en vert].

== Photo avec légende

#danger-box[Attention à  la qualité des images, si le fichiers est trop volumineux lorsque l'on va convertir le code Typst en PDF cela va créer un fichier PDF ultra lourd. Il est possible de passer après par #link("https://www.ilovepdf.com/fr/compresser_pdf", "I-love PDF") pour réduire la taille du fichier.]


#figure(
  image("src/assets/picture/logo Hes.png", width: 20%),
  caption: [nom image],
) <fig:cursor_schema1>
#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,

    // Image de gauche
    image("src/assets/picture/logo Hes.png", width: 30%),

    // Image de droite
    image("src/assets/picture/logo Hes.png", width: 30%),
  ),
  caption: [comment intégrer 2 images],
) <fig:double_image1>

la fonction \#photo permet d'intégrer provisoirement une autre image
#photo(largeur: 50pt, nom: "le nom ")

== Code source

La section ici explique comment importer directement du code en faisant :

*Contrôle + C Contrôle V* ou en important seulement des lignes de code
#figure(
  caption: [Exemple en Python],
  supplement: "Figure",

  code(
    ```python //mettre ici cpp, ou vhdl  et copier coller le code ensuite
    def verifier_moteur():
        vitesse = 100
        if vitesse > 50:
            print("Attention")
        return True
    ```,
  ),
)<code:code_c_>

#figure(
  caption: [Extrait du fichier],
  supplement: "Figure",
  kind: image,
  code-fichier(
    exemple_content,
    debut: 7,
    fin: 11,
    lang: "python",
  ),
)

#figure(
  caption: [Extrait du fichier],
  supplement: "Figure",
  kind: image,
  code-fichier(
    exemple_content,
    debut: 1,
    fin: 11,
    lang: "python",
  ),
)


#pagebreak()
== Graphiques

Les graphiques permettent de visualiser l'évolution des données expérimentales.

#info-box[Les graphiques sont créés avec la librairie *lilaq*, qui offre une flexibilité maximale pour créer des courbes et des diagrammes scientifiques.]

Voici un exemple de graphique montrant l'évolution de la réactance inductive en fonction de la fréquence :

#figure(
  lq.diagram(
    lq.plot(
      (1, 1.5, 2),
      (13.96, 21.46, 28.92),
      yerr: 0,
      mark: "o",
      stroke: (dash: "dashed"),
      label: [Réactance],
    ),
    height: 4cm,
    xlabel: [Fréquence (kHz)],
    xlim: (0.5, 2.5),
    ylabel: [Réactance [Ω]],
    ylim: (13, 30),
  ),
  caption: [Réactance inductive en fonction de la fréquence],
) <fig:reactance>

Comme le montre la figure @fig:reactance, l'évolution de la réactance inductive est linéaire et proportionnelle à la fréquence, conformément à l'équation @eq:reactance.

// ============================================================================
// 4. GLOSSAIRE
// ============================================================================

#pagebreak()
= Glossaire

Le glossaire contient les définitions des termes techniques utilisés dans ce rapport.

*Termes utilisés :*

Ce rapport utilise notamment @hei et @rust.

Pour plus de détails, consultez la section "Glossaire" à la fin du document.

// ============================================================================
// 5. CONCLUSION
// ============================================================================

#pagebreak()
= Conclusion

Ce rapport a démontré l'utilisation complète du modèle HES-SO pour Typst, incluant :

✅ Mise en page professionnelle et automatisée
✅ Boîtes utilitaires colorées et personnalisables
✅ Tableaux et figures avec légendes
✅ Code source numéroté
✅ Équations numérotées avec références
✅ Glossaire avec acronymes
✅ Gestion complète des auteurs et professeurs
✅ Pages de signature automatiques

Le modèle est entièrement personnalisable via le fichier `src/settings/name.typ`.



