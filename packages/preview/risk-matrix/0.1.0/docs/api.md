# API 0.1.0

Toutes les fonctions sont exportées par `lib.typ`. Les fonctions de rendu
renvoient du contenu Typst ; les validateurs renvoient `none` ou interrompent
la compilation avec un message. Aucun fichier n'est lu par la bibliothèque.
Vous pouvez charger vos propres données avec `json()` ou `yaml()` côté document
puis transmettre leurs tableaux/dictionnaires aux composants.

## Matrices

`risk-matrix(risks, severity: severity-scale, likelihood: likelihood-scale,
policy: none, stage: "initial", title: none, cell-height: 16mm)`

- `risks` : tableau de dictionnaires au format décrit ci-dessous.
- `severity`, `likelihood` : tableaux non vides de libellés, du niveau 1 au niveau N.
  Les échelles par défaut ont quatre niveaux. Des échelles à cinq niveaux sont possibles.
- `policy` : `none`, ou tableau de lignes G1 à GN, chaque ligne contenant les
  classes des colonnes V1 à VN. Valeurs autorisées : `"low"`, `"medium"`, `"high"`.
  Les dimensions doivent correspondre aux échelles. Les couleurs sont doublées
  de libellés « Faible », « Moyen », « Élevé » ; aucune classe n'est produite sans politique.
- `stage` : `"initial"` ou `"residual"`. Les éléments sans résiduel sont signalés
  sous la matrice. C = `target` ; E = `assessed`.
- `title` : chaîne ou contenu facultatif.
- `cell-height` : hauteur minimale du contenu des cases ; les lignes s'agrandissent
  pour éviter le chevauchement des identifiants. Utiliser des identifiants courts.

La matrice forme un bloc indivisible. Pour des centaines de risques, filtrer par
source, valeur métier ou scénario et produire plusieurs matrices. Une matrice
trop grande pour une page doit être divisée par l'auteur du document.

`risk-comparison(risks, severity: severity-scale, likelihood: likelihood-scale,
policy: none)` produit deux matrices successives, initiale puis cible/résiduelle.

`risk-register(risks, severity: severity-scale, likelihood: likelihood-scale,
policy: none)` affiche cotations, statut, justification, propriétaire et décision.

`risk-level(gravity, likelihood, policy)` renvoie une des trois clés de classe.
La politique est un argument positionnel obligatoire. Cette fonction ne
multiplie jamais les deux indices et ne décide jamais de l'acceptation.

`severity-scale`, `likelihood-scale` et `example-policy` sont des constantes.
La politique d'exemple ne doit pas être attribuée à l'ANSSI.

## Risques

`risk(id, title, gravity, likelihood, owner: "", strategic: none,
operational: none, feared-events: (), residual: none, decision: "À décider")`
construit un dictionnaire. Les contrôles sont réalisés lors de sa validation
ou de son rendu, ce qui permet des échelles personnalisées.

| Champ | Type / convention |
| --- | --- |
| `id` | Chaîne non vide, unique dans le tableau de risques |
| `title` | Chaîne ou contenu |
| `gravity`, `likelihood` | Entiers de 1 à la taille de l'échelle correspondante |
| `owner` | Propriétaire, chaîne ou contenu |
| `strategic`, `operational` | Identifiants SS/SO ; facultatifs en usage autonome, obligatoires pour `validate-study` |
| `feared-events` | Tableau d'identifiants ER ; obligatoire et non vide dans une étude validée |
| `decision` | Décision d'autorité et modalités de suivi ; texte libre |
| `residual` | `none` ou dictionnaire décrit ci-dessous |

Un `residual` contient `gravity`, `likelihood`, `status` et `rationale`.
`status` vaut `"target"` ou `"assessed"`. La justification `rationale` est une
chaîne non vide. Pour `assessed`, `date` et `evidence` sont aussi des chaînes
non vides obligatoires ; utiliser une date ISO `AAAA-MM-JJ` et une référence de
preuve. Le format de date et la réalité de la preuve ne sont pas vérifiés.
Une hausse de la cotation résiduelle reste autorisée si la réévaluation le justifie.

`validate-risks(risks, severity: severity-scale, likelihood: likelihood-scale)`
vérifie cette structure. Un tableau vide est accepté.

## Structure d'une étude

`validate-study(study, severity: severity-scale, likelihood: likelihood-scale)`
attend les neuf tableaux suivants. Les identifiants sont uniques à l'intérieur
de chaque tableau. Les champs descriptifs sont des chaînes ou du contenu Typst,
sauf lorsqu'un autre type est indiqué. Les champs supplémentaires sont autorisés.

| Tableau | Champs requis dans chaque ligne |
| --- | --- |
| `assets` | `id`, `name`, `mission`, `owner`, `supports` |
| `baseline` | `id`, `reference`, `status`, `gap`, `action` |
| `events` | `id`, `title`, `assets` (tableau d'ID VM), `gravity` (entier), `impact`, `rationale` |
| `sources` | `id`, `source`, `objective`, `motivation`, `resources`, `relevance`, `retained` (booléen), `rationale` |
| `stakeholders` | `id`, `name`, `exposure`, `reliability`, `danger`, `retained` (booléen), `rationale`, `measures` (tableau d'ID M) |
| `strategic` | `id`, `title`, `source` (ID SR/OV), `events` (tableau d'ID ER), `stakeholders` (tableau d'ID PP), `path` (tableau non vide d'étapes), `gravity` |
| `operational` | `id`, `title`, `strategic` (ID SS), `path` (tableau non vide d'étapes), `supports`, `likelihood`, `rationale` |
| `risks` | Format précédent avec rattachements SS, SO et ER |
| `measures` | `id`, `title`, `risks` (tableau d'ID R), `owner`, `due`, `status`, `priority`, `evidence` |

Chaque SR/OV référencé doit être retenu. Chaque ER référence au moins une valeur
métier. Chaque SS référence au moins un ER ; sa gravité est, **par convention
de ce modèle**, le maximum des gravités de ces ER. Le risque hérite de la gravité
du SS et de la vraisemblance du SO, qui doit lui-même appartenir à ce SS.
Ses ER doivent appartenir au SS. Séparer les scénarios si des chemins conduisent
à des conséquences de gravité différente.

Les supports et les écarts au socle sont ici des textes descriptifs, pas des
objets contrôlés par référence. Les mesures peuvent avoir un tableau `risks`
vide, par exemple pour un écart de conformité. La présence d'un propriétaire
ou d'une décision pertinente reste à vérifier humainement. Les ateliers vides
restent compilables afin de permettre une étude en cours de préparation.

## Composants d'atelier

Chaque fonction ci-dessous reçoit le tableau correspondant :
`assets-table(rows)`, `baseline-table(rows)`, `events-table(rows)`,
`sources-table(rows)`, `stakeholders-table(rows)`, `strategic-table(rows)`,
`operational-table(rows)`, `treatment-table(rows)`.

Pour une étude complète, appeler `validate-study(study)` avant ces fonctions.
Ces tables n'effectuent pas individuellement tous les contrôles de cohérence.

`attack-path(steps)` affiche un parcours vertical avec des étapes numérotées. Les
branches alternatives doivent être décrites dans des lignes distinctes. Cette
fonction ne représente pas de portes logiques ET/OU.

`coverage(events, risks)` renvoie un tableau de `(event: "ER1", risks: ("R1",))`.
`coverage-table(events, risks)` le rend et signale « À instruire » si aucun risque
ne référence l'ER. La couverture ne démontre pas la maîtrise du risque.

`workshop(number, title, body)` ajoute un titre d'atelier (numéro de 1 à 5).

`scope-card(title: "Périmètre de l'étude", objective: [], scope: [],
participants: [], decision-maker: [], strategic-cycle: [], operational-cycle: [],
assumptions: [])` affiche le cadrage fourni par l'auteur.

`data-table(rows, columns, font-size: 8.8pt)` rend un tableau libre. Chaque colonne
est un dictionnaire `(key: "champ", label: [Titre], width: 1fr)` ; `width` est
facultatif. Chaque ligne doit contenir les clés demandées. Un tableau vide
produit un message explicite. Les en-têtes sont répétés après les sauts de page.

## Rapport

`risk-report(title: "Analyse de risque", organization: "", author: "",
date: "", version: "0.1", classification: "Diffusion à définir",
font: "Libertinus Serif", body)`
s'utilise par `#show: risk-report.with(...)`. Il configure le papier A4,
les marges, le français, les titres, les en-têtes et la pagination.
La police est configurable avec `font`. Le rapport et le modèle de démonstration
utilisent par défaut Libertinus Serif, fournie avec le compilateur Typst standard.
L'import du package seul ne modifie pas les paramètres du document.
