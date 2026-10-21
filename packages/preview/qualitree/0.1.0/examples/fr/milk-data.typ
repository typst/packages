// Traduire les libellés conserve les identifiants, les relations et les poids
// du modèle pédagogique commun. Les données numériques ne sont pas dupliquées.
#import "@preview/qualitree:0.1.0": qfd-diff
#import "../milk-options.typ": baseline, manual, automatic, baseline-components, manual-components, automatic-components
#let labels-fr = (
  whats: [Besoins], hows: [Fonctions], importance: [Poids],
  relation: [Relation], strong: [Forte (9)], medium: [Moyenne (3)], weak: [Faible (1)],
  changes: [Modifications], added: [Ajout], removed: [Suppression], changed: [Modification],
  absolute: [Σ abs.], relative: [Rel. %], target: [Cible],
)
#let needs = (
  taste: [Savourer un bon café], clean: [Nettoyer facilement],
  space: [Occuper peu de place], safe: [Utiliser sans danger à la maison],
  milk: [Savourer un lait chaud et texturé], ready: [Disposer de lait entre les utilisations],
)
#let functions-before = (coffee: [Préparer le café], clean: [Nettoyer les circuits], protect: [Contenir les dangers])
#let functions-after = functions-before + (
  clean: [Nettoyer les circuits café et lait], protect: [Contenir les dangers du café et de la vapeur],
  heat-milk: [Chauffer le lait], texture: [Texturer le lait],
  cold: [Stocker le lait au froid], meter: [Doser le lait automatiquement],
)
#let parts-before = (coffee: [Module de préparation du café], control: [Commande et interface], housing: [Boîtier et protection])
#let parts-manual = parts-before + (
  control: [Commande avec mode vapeur], housing: [Boîtier et protection vapeur],
  steam: [Générateur de vapeur], wand: [Buse vapeur et pichet amovible],
)
#let parts-automatic = parts-before + (
  control: [Commande du cycle lait automatique], housing: [Boîtier et protection de puissance],
  steam: [Générateur de vapeur], mixer: [Mélangeur vapeur–lait],
  cold: [Réservoir réfrigéré], circuit: [Pompe, vannes et tuyaux de lait],
)
#let translate(stage, rows, columns, components: false) = stage + (
  whats: stage.row-ids.map(id => rows.at(id)),
  hows: stage.column-ids.map(id => columns.at(id)),
  labels: labels-fr + if components {
    (whats: [Fonctions · priorités transmises], hows: [Composants], importance: [Rel. %])
  } else { (:) },
)
#let manual-diff = qfd-diff(translate(baseline, needs, functions-before), translate(manual, needs, functions-after))
#let automatic-diff = qfd-diff(translate(baseline, needs, functions-before), translate(automatic, needs, functions-after))
#let manual-component-diff = qfd-diff(
  translate(baseline-components, functions-before, parts-before, components: true),
  translate(manual-components, functions-after, parts-manual, components: true),
)
#let automatic-component-diff = qfd-diff(
  translate(baseline-components, functions-before, parts-before, components: true),
  translate(automatic-components, functions-after, parts-automatic, components: true),
)
