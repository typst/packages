// =============================================================================
// OUTILS INTERNES — fonctions d'assistance (fa-*) du modèle, non exportées
// =============================================================================
#import "paquets.typ": *
#import "etats.typ": *

// -------------------------------
// --- FONCTIONS D'ASSISTANCES ---
// -------------------------------
// Utile pour réaliser des tâches spécifiques mais éviter un gros bout de code dans un paramètre

// Fonction pour récupérer et afficher le titre dans l'entête de page
#let fa-afficher-titre() = context {
  // On recupère la page actuelle (avec `context`) :
  let page-num = here().page()
  // On regarde si un titre de niveau 1 s'y trouve :
  let chapters-on-this-page = query(selector(heading.where(level: 1))).filter(h => h.location().page() == page-num)
  // Si non alors :
  if chapters-on-this-page.len() == 0 {
    // Affichage du titre en entête à droite, on utilise le paquet `hydra` pour le faire proprement
    align(right, emph(hydra(1)))
    // Ligne de séparation en header 
    line(length: 100%, stroke: 0.4pt)
  }
}

// Gestion du filigrane de confidentialité et du mode ébauche
// Lit directement les états globaux, aucun paramètre nécessaire
#let fa-fond-de-page() = context [
  // Filigrane CONFIDENTIEL (coin supérieur gauche)
  #if v-confidentiel-global.get() [
    #place(
      // Gestion de l'emplacement du filigrane
      top + left, dx: 5mm, dy: 5mm,
      rect(
        // On l'entoure avec un rectangle rouge
        stroke: rgb(255, 51, 51), inset: 5pt,
        // On change les paramètres du texte à afficher
        text(fill: rgb(255, 51, 51), size: 0.9em, weight: "bold")[
          // Affichage du texte selon la langue choisi dans le modèle
          #v-liste-trad-auto.at("secret").at(v-langue-global.get())
        ]
      )
    )
  ]
  // Filigrane BROUILLON (centre de chaque page)
  #if v-ebauche-global.get() [
    // Gestion de l'emplacement du filigrane
    #place(center + horizon,
      // On le met en diagonale
      rotate(45deg,
        // On change les paramètres du texte à afficher
        text(6.5em, gray.lighten(70%))[
          // Affichage du texte selon la langue choisi dans le modèle
          #v-liste-trad-auto.at("brouillon").at(v-langue-global.get())
        ]
      )
    )
  ]
]

// Applique la couleur de lien correspondant au type de référence
// Lit les couleurs depuis le state v-couleurs-liens-global mis à jour par le modèle
// kind accepte : "glossaire", "bibliographie", "annexe"
#let fa-style-lien(it, kind: "default") = context {
  let couleur = v-couleurs-liens-global.get().at(kind, default: none)
  if couleur != none { text(fill: couleur.darken(45%), it) } else { it }
}

// Vérifie qu'aucun argument inattendu n'a été passé à `fonction` (capturés par un `..autres`).
// `renommes` associe un ancien nom de paramètre à la consigne de migration correspondante,
// pour qu'un document écrit pour une version précédente reçoive un message explicite.
#let fa-verifier-arguments(fonction, autres, renommes: (:)) = {
  for cle in autres.named().keys() {
    if cle in renommes {
      panic(fonction + " : le paramètre `" + cle + "` n'existe plus — " + renommes.at(cle))
    }
    panic(fonction + " : paramètre inconnu `" + cle + "`.")
  }
}

// Complète un paramètre regroupé (dictionnaire) avec ses valeurs par défaut, après avoir
// vérifié que l'utilisateur n'a fourni que des clés connues — ex : `police: (taille: 11pt)`
#let fa-completer(fonction, nom, valeur, defaut) = {
  if type(valeur) != dictionary {
    panic(fonction + " : `" + nom + "` attend un dictionnaire, ex : `" + nom + ": (" + defaut.keys().first() + ": ...)`.")
  }
  for cle in valeur.keys() {
    if cle not in defaut {
      panic(fonction + " : clé inconnue dans `" + nom + "` : `" + cle + "`. Clés possibles : " + defaut.keys().join(", ") + ".")
    }
  }
  defaut + valeur
}

// Ancien nom du paramètre de titre des fonctions `fbc-*`
#let v-renommes-titre = (titre-utilisateur: "renommé en `titre` (`auto` = traduction automatique).")

// Repère invisible signalant qu'une entrée du lexique est citée (voir `v-lexique-cite`)
#let fa-repere-lexique() = [#metadata("lexique-cite")#v-lexique-cite]

// Citation d'une entrée du lexique sous forme de fonction, équivalente à `@cle` : fonctions de
// glossarium, précédées du repère qui déclenche l'affichage de la section lexique
#let gls(..args) = { fa-repere-lexique(); glossarium.gls(..args) }
#let glspl(..args) = { fa-repere-lexique(); glossarium.glspl(..args) }

// Étiquette du repère posé par `fmp-corps-document` au début du corps du document
#let v-debut-corps = <starchy-junia-debut-corps>

// Rang d'une figure dans sa séquence de numérotation : depuis le début du chapitre dans le corps
// du document, depuis le début du document ailleurs (pré-sommaire).
// Les compteurs de figures ne sont jamais remis à zéro : le rang est la différence entre la valeur
// du compteur à la figure et sa valeur au début de la séquence. Cela vaut pour tous les types de
// figures, y compris personnalisés (ex : `figure(kind: "algo", ...)`), sans avoir à les rechercher
// dans le document — une recherche sur toutes les figures inclurait celles du lexique (glossarium),
// dont le contenu change d'une passe à l'autre et empêche la compilation de converger.
// En mode code "figure", images et programmes partagent la même séquence : on additionne leurs compteurs.
#let fa-rang-figure(fig) = {
  let loc = fig.location()
  let partage = v-code-global.at(loc).mode == "figure" and fig.kind in (image, raw)
  let types = if partage { (image, raw) } else { (fig.kind,) }
  // Valeur cumulée des compteurs concernés à un emplacement donné
  let valeur(l) = types.map(t => counter(figure.where(kind: t)).at(l).first()).sum()
  // Début de la séquence dans le corps : dernier titre de niveau 1, ou à défaut le début du corps
  let debut = if v-zone-global.at(loc) == "corps" {
    query(selector(v-debut-corps).or(heading.where(level: 1)).before(loc)).last().location()
  } else { none }
  valeur(loc) - if debut == none { 0 } else { valeur(debut) }
}

// Numéro d'une figure selon la zone où elle se trouve : I, II… en pré-sommaire,
// chapitre.rang dans le corps, rang simple ailleurs. Tout est lu à l'emplacement
// de la figure, le numéro reste donc correct quand elle est citée depuis un autre chapitre.
#let fa-numero-figure(fig) = {
  let loc = fig.location()
  let rang = fa-rang-figure(fig)
  let zone = v-zone-global.at(loc)
  if zone == "corps" { numbering("1.1", counter(heading).at(loc).first(), rang) }
  else if zone == "pre-sommaire" { numbering("I", rang) }
  else { numbering("1", rang) }
}

// Fonction de numérotation commune à toutes les figures, pour `set figure(numbering: ...)`.
// Typst l'évalue avec `here()` placé sur la figure elle-même (légende, listes et références),
// la dernière figure jusqu'à `here()` est donc celle à numéroter — même si elle contient des sous-figures.
#let fa-numerotation-figure(..num) = fa-numero-figure(query(selector(figure).before(here())).last())
