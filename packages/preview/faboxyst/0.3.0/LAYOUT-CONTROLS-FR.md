# Paramétrage de la mise en page des boîtes

Les boîtes conservent leurs paramètres de dimensions et de style existants (`width`, `height`, `padding`, `inset`, `gap`, etc.). Le passage ajoute des réglages de placement indépendants aux composants publics de contenu dont le titre, le texte, le numéro ou l’icône sont positionnés séparément.

## Réglages de placement communs

Selon les éléments présents dans le composant, les fonctions acceptent maintenant :

- `title-offset-x`, `title-offset-y`
- `body-offset-x`, `body-offset-y`
- `icon-offset-x`, `icon-offset-y`
- `number-offset-x`, `number-offset-y`

Chaque réglage est une longueur Typst (`0.1cm`, `2pt`, etc.). Les valeurs positives déplacent l’élément vers la droite ou le bas; les valeurs négatives, vers la gauche ou le haut. Les défauts `0pt` préservent le rendu antérieur. Ces contrôles ont été ajoutés aux éléments effectivement placés dans **82 fonctions publiques**, réparties dans **79 modules source**; les helpers sans contenu et les composants dont la mise en page est entièrement composée en flux ne reçoivent pas de paramètres sans effet.

```typ
#simple-rounded-text-box(
  title: [Titre],
  body: [Texte de détail],
  title-offset-y: -0.05cm,
  body-offset-x: 0.08cm,
  icon-offset-y: 0.04cm,
)
```

## Largeurs et écarts indépendants

Les composants qui ont besoin d’un réglage plus fin exposent aussi des largeurs de colonnes et des écarts dédiés. `auto` conserve les proportions de référence.

| Composant | Réglages spécifiques |
|---|---|
| `horizontal-chevron-block` | `body-width`, offsets du texte et de l’icône |
| `three-color-infographic-card` et `three-color-infographic-stack` | `title-width`, `body-width`, offsets distincts et `title-gap` |
| `neumorphic-text-panel` | `content-width`, `title-body-gap`, offsets distincts du titre, du corps et de l’icône |
| `vertical-chevron-list-item` | `title-width`, `body-width`, écart horizontal, `number-size` et offsets du titre, du corps et du numéro |
| `stacked-banner-row` | `content-width`, `title-body-gap`, offsets du titre, du corps et de l’icône; `padding` règle désormais l’inset horizontal |
| `text-box-display-card` | `title-width`, `body-width`, `body-title-gap` et offsets séparés |
| `quad-step-card` | Largeurs/écart du texte, taille du numéro et offsets du titre, du corps, de l’icône, du numéro et des médaillons |
| `looped-chevron-callout` | `body-width`, offsets texte/icône et réglages de position/espacement des chevrons |
| `kinds-text-box-1/2/3` | `title-width`, `body-width`, `title-body-gap` et offsets du titre, du corps et du numéro |

## Contrôle et rendu

- `auto` conserve les proportions ou les écarts déjà utilisés par le composant.
- Les offsets sont additifs : ils déplacent l’élément depuis son emplacement d’origine sans modifier le panneau.
- Un décalage important peut faire sortir le texte du panneau; adapter alors `width`, `height`, la largeur de texte ou les paramètres d’inset existants.
- Les options sont ajoutées en fin de signature pour ne pas casser les appels existants.
- `examples/component-layout-controls-demo.typ` et `examples/kinds-text-box-layout-controls.typ` contiennent des appels personnalisés. Les tests et exemples du paquet ont été recompilés avec les modifications.
