// rd.typ — les boîtes de cours et d'activités du paquet rdboites.
//
// Ce fichier est un MODULE : lib.typ l'exporte sous le nom `rd`, et on écrit
//   #rd.zone[Objectif de la séance][Savoir reconnaître un triangle rectangle.]
//   #rd.attention[On ne peut pas diviser par zéro.]
//
// Les noms de boîtes sont courts et parlants (`encadreOB`, `tornpage`, `ggbentrainer`…). Rangées sous `rd.`,
// elles ne heurtent aucun nom des autres paquets (`methode`, `exemple`, `encadrer`…) et l'autocomplétion de
// Tinymist les propose toutes après le point.
//
// Les CLÉS sont celles de tcolorbox quand la boîte les prend en option : `colframe`, `colback`, `coltitle`,
// `colbacktitle`, `coltext`, `arc`, `boxrule`, `leftrule`, `width`, `height`, `halign`, `valign`… (tirets à la
// place des espaces). Les valeurs viennent, par priorité décroissante : de la clé locale, d'un style nommé
// (`style:`), du réglage de la boîte, du réglage global (`setrdboites`), du défaut. Voir `reglages.typ`.
//
// Les fichiers `rd-*.typ` sont internes ; seuls les noms importés ci-dessous sont publics.

// Outils communs : ombre floue, icône d'avertissement, compteurs
#import "rd-outils.typ": icone-alerte, ombre-floue, reinitialiser-compteur
#import "rd-outils.typ": reinitialiser-scratch as _reinitialiser-scratch

// Boîtes de complexité faible
#import "rd-simples.typ": (
  alignbox, attention, blankbox, boiteprog, casio, centragebox, domino, encadre, encadregrille, encadreOB, entete, etiquette,
  exem, exemplerealisation, ficheno, figbox, formula, miniexemple, mydoc, myformule, rappelbox, regularcell,
  regulartcbitemize, schemamainlevee, scratchuse, tcalignbox, tcencadre, tcwhite, zone,
)

// Boîtes de complexité moyenne
#import "rd-moyennes.typ": (
  acocher, boxpointlignesrep, casesvf, cinema, coinpli, corrdembox, cours, dottedbox, dottedleftbox, dottedrightbox,
  ernum, exemple, exemplereduit, helpblock, jourleague, leftpoint, listecocher, ltitlebox, mylink, mytcbitembox,
  mytcbitemize, opbox, parchemin, partieDNB, progbox, rightpoint, sans-coin, scratchblock, scratchblockenv,
  scratchcapture, scratchfig, scratchfigbox, tccoinpli, thermobox, tornpage, vf,
)

// Boîtes de complexité forte
#import "rd-fortes.typ": designbox, ggbentrainer, ggbqr, ggbqrenv, icone-tablette, methode, tache

/// Remet à zéro les trois compteurs Scratch (`scratchblock`, `scratchfig`, `scratchcapture`) :
/// pour que la numérotation recommence à 1.
///
/// ```typ
/// #rd.resetScratchCounters()
/// ```
///
/// -> content
#let resetScratchCounters() = _reinitialiser-scratch()
