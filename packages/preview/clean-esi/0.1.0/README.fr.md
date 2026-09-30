# clean-esi

[English version](README.md)

Un modèle [Typst](https://typst.app) pour le mémoire de projet de fin d'études (PFE) de
l'[ESI Alger](https://www.esi.dz) (École nationale Supérieure d'Informatique), conforme aux
normes de mise en forme de l'école. Il convient aux mémoires d'ingénieur d'État comme de Master.

Voir le modèle compilé dans le [PDF d'exemple](https://github.com/Chamiln17/clean-esi/releases/download/v0.1.0/example.pdf).

<a href="thumbnail.png"><img src="thumbnail.png" alt="Aperçu de la page de garde" width="360"></a>

## Fonctionnalités

- Page de garde ESI avec l'en-tête bilingue de l'État, les encadrants, le jury et l'organisme d'accueil
- Pagination en chiffres romains pour les pages liminaires, en chiffres arabes à partir de l'introduction
- En-tête courant indiquant le chapitre ou l'annexe en cours
- Séparateurs de parties (Partie I / Partie II) optionnels, avec une numérotation continue des chapitres
- Résumés en anglais, en français et en arabe (de droite à gauche), dédicace, remerciements et liste des abréviations
- Titres des tableaux au-dessus, légendes des figures en dessous ; tableaux numérotés par chapitre (`Table 2.1`) et par annexe (`Table A.1`)
- Fonctions pour les tableaux, les algorithmes et les blocs de code

## Utilisation

Ouvrez le modèle [dans l'application web Typst](https://typst.app/?template=clean-esi&version=0.1.0),
ou créez un projet en ligne de commande :

```sh
typst init @preview/clean-esi:0.1.0 mon-memoire
cd mon-memoire
typst watch main.typ
```

Renseignez les métadonnées dans `main.typ`, puis rédigez vos chapitres dans `chapters/`.
`main.typ` est le seul fichier qui fixe l'ordre des chapitres : pour ajouter un chapitre, créez un
fichier et incluez-le avec `#include`.

### Avant la publication sur Typst Universe

Clonez ce dépôt dans le répertoire local des paquets Typst, puis lancez la même commande
`typst init` :

```sh
# Windows (PowerShell)
git clone https://github.com/Chamiln17/clean-esi "$env:APPDATA\typst\packages\preview\clean-esi\0.1.0"
# Linux
git clone https://github.com/Chamiln17/clean-esi ~/.local/share/typst/packages/preview/clean-esi/0.1.0
# macOS
git clone https://github.com/Chamiln17/clean-esi ~/Library/Application\ Support/typst/packages/preview/clean-esi/0.1.0
```

### Logo

Le paquet ne contient pas le logo de l'ESI. Téléchargez-le depuis
[ce dépôt](https://github.com/Chamiln17/clean-esi/blob/v0.1.0/assets/esi_logo.png) ou le site de
l'école, placez-le à côté de `main.typ`, puis indiquez `logo: image("esi_logo.png", width: 6cm)`.

### Polices

Le corps du texte utilise New Computer Modern, fournie avec Typst. Les parties en arabe (en-tête
de la page de garde, résumé arabe) utilisent [Amiri](https://fonts.google.com/specimen/Amiri).
Installez-la sur votre système, ajoutez-la à votre projet dans l'application web, ou indiquez au
compilateur un dossier qui la contient :

```sh
typst watch main.typ --font-path fonts/
```

## Configuration

`thesis` produit la page de garde et les pages liminaires. Appliquez-la avec une règle `show` :

```typ
#import "@preview/clean-esi:0.1.0": *

#show: thesis.with(
  title: "Titre de votre mémoire",
  authors: ("Nom Prénom",),
  supervisor: "Dr. Nom de l'encadrant (ESI)",
  jury: (("Dr. Nom du président", "ESI", "President"),),
)
```

Le modèle génère les libellés fixes (« Supervised by », « Chapter », titres des listes) en
anglais ; seuls les résumés existent en trois langues.

| Argument | Type | Valeur par défaut |
|---|---|---|
| `title` | str ou content | `"Thesis Title"` |
| `authors` | tableau de str | `()` |
| `supervisor` | str ou `none` | `none` |
| `co-supervisor` | tableau de str | `()` |
| `report-type` | str | `"Final Year Thesis"` |
| `institution` | str | `"National Higher School of Computer Science"` |
| `option` | str | `"Computer Systems (SIQ)"` |
| `degree-type` | str | `"State Engineer Degree in Computer Science"` |
| `host-organization` | str | `""` (affiche une ligne vide) |
| `promotion` | str, l'année universitaire | `"2024/2025"` |
| `defense-date` | str | `"XX/XX/2025"` |
| `jury` | tableau de `(nom, affiliation, rôle)` | `()` (bloc du jury masqué) |
| `logo` | content, par ex. `image(...)`, ou `none` | `none` |
| `page-margin` | dictionnaire | `2.5cm` sur chaque bord |

### Structure du document

| Fonction | Effet |
|---|---|
| `main-content[...]` | Passe en chiffres arabes et ajoute l'en-tête courant |
| `part-divider(label, title, summary)` | Page de séparation de partie, avec son propre signet PDF |
| `numbered-part[...]` | Place les chapitres qu'elle contient sous la partie précédente |
| `appendix-content[...]` | Numérotation des titres en `A.1`, tableaux renumérotés dans chaque annexe |
| `table-of-contents()`, `list-of-figures()`, `list-of-tables()` | Table des matières et listes, chacune sur sa propre page |

Les parties sont optionnelles. Sans elles, supprimez les appels à `part-divider` et les blocs
`numbered-part`, et incluez les chapitres directement dans `main-content`. Pour que
l'introduction et la conclusion restent non numérotées, entourez-les de
`#[ #set heading(numbering: none) ... ]`, comme dans `main.typ`.

Étiquetez les chapitres `<ch:...>`, les figures `<fig:...>` et les tableaux `<tab:...>`, puis
faites-y référence avec `@label`. Les références aux chapitres s'affichent sous la forme
« Chapter N ».

### Pages liminaires

| Fonction | Effet |
|---|---|
| `abstract-page-en(abstract-content: [...], keywords: (...))` | Résumé en anglais ; les variantes `-fr` et `-ar` (de droite à gauche) prennent les mêmes arguments |
| `dedication-page[...]` | Dédicace centrée, en italique |
| `arabic-dedication-page(verse, body)` | Dédicace en arabe, avec un verset d'ouverture mis en valeur |
| `acknowledgments-page[...]` | Remerciements |
| `abbreviations-page(((abrév, signification), ...))` | Liste des abréviations sur deux colonnes |

### Fonctions de contenu

| Fonction | Effet |
|---|---|
| `thesis-table(..args)` | `table` au style du mémoire : filets, en-tête coloré, lignes alternées |
| `thesis-readable-table`, `thesis-compact-table`, `thesis-wide-table`, `thesis-schema-table` | Même style avec un texte plus petit (argument `size:`) pour les tableaux denses |
| `thesis-descriptive-table(header: (...), ..cells)`, `thesis-booktabs-table(header: (...), ..cells)` | Tableaux simples et de style booktabs |
| `table-lines(..items)`, `table-code-lines(..items)` | Plusieurs lignes, ou lignes de code, dans une cellule |
| `thesis-algorithm(caption: [...])[+ étape ...]` | Algorithme en pseudo-code, numéroté par chapitre |
| `thesis-code-block(numbering: true)[...]`, avec un bloc de code délimité à l'intérieur | Code avec lignes alternées ; `thesis-json-block` est un alias |
| `info-box(title, body)`, `warning-box(title, body)` | Encadrés mis en valeur |
| `definition(term, description)`, `quote-block(body, author: ...)` | Ligne de définition et bloc de citation |
| `todo(body)`, `divider()` | Marqueur de brouillon et filet horizontal |

Placez les tableaux et les algorithmes dans `#figure(..., caption: [...])` pour les numéroter et
les faire apparaître dans la liste des tableaux. Le dossier `template/chapters/` contient un
exemple fonctionnel de chaque fonction.

## Autres écoles et départements

Les textes de la page de garde (établissement, diplôme, option) proviennent des arguments de
`thesis` : le modèle s'adapte donc à d'autres filières de l'ESI ou à d'autres écoles algériennes
qui suivent la même mise en page. Les adaptations et corrections sont les bienvenues sous forme
d'issues ou de pull requests.

## Paquets utilisés

- [lovelace](https://typst.app/universe/package/lovelace) pour le pseudo-code
- [zebraw](https://typst.app/universe/package/zebraw) pour les blocs de code
- [booktabs](https://typst.app/universe/package/booktabs) pour les tableaux de style booktabs

## Contribuer

Signalez les bogues ou proposez des modifications dans les
[issues GitHub](https://github.com/Chamiln17/clean-esi/issues).

## Licence

Le code et le modèle sont sous licence [MIT-0](LICENSE) : vous pouvez les utiliser dans votre
mémoire sans conserver aucune mention. Le logo de l'ESI présent dans `assets/` appartient à l'ESI
Alger, n'est pas couvert par cette licence et ne fait pas partie du paquet Typst.
