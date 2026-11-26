# Gabarit Typst ÉTS — Guide d'utilisation

Ce guide explique comment rédiger une thèse, un mémoire ou un rapport de projet
de l'École de technologie supérieure avec le gabarit Typst `boreal-thesis-ets`. Il suit le
même plan que le `GUIDE_FR.md` du gabarit LaTeX d'origine, de sorte qu'on peut
passer de l'un à l'autre section par section.

---

## Table des matières

1. [Premiers pas](#1-premiers-pas)
2. [Contraintes de mise en page imposées](#2-contraintes-de-mise-en-page-imposées)
3. [Page de titre et jury](#3-page-de-titre-et-jury)
4. [Sections préliminaires](#4-sections-préliminaires)
5. [Structure du corps du document](#5-structure-du-corps-du-document)
6. [Commandes de sectionnement](#6-commandes-de-sectionnement)
7. [Listes](#7-listes)
8. [Équations](#8-équations)
9. [Figures](#9-figures)
10. [Tableaux](#10-tableaux)
11. [Extraits de code](#11-extraits-de-code)
12. [Algorithmes](#12-algorithmes)
13. [Source des figures et tableaux](#13-source-des-figures-et-tableaux)
14. [Références et citations](#14-références-et-citations)
15. [Mémoire ou thèse par articles](#15-mémoire-ou-thèse-par-articles)
16. [Annexes et appendices](#16-annexes-et-appendices)
17. [Écarts connus par rapport au gabarit LaTeX](#17-écarts-connus-par-rapport-au-gabarit-latex)

---

## 1. Premiers pas

Tout document commence par l'importation du gabarit et par une règle `show` qui
applique la mise en page :

```typ
#import "@preview/boreal-thesis-ets:0.1.0": *

#show: ets-document.with(
  type: "these",
  title: [Titre du document],
  author: (firstname: "Prénom", lastname: "Nom de famille"),
  deposit-date: datetime(year: 2025, month: 11, day: 30),
  defense-date: datetime(year: 2026, month: 5, day: 15),
  supervisor: (name: "Prénom Nom", dept: "Nom du département"),
  chair: (name: "Prénom Nom", dept: "Nom du département"),
)
```

### Type de document (obligatoire)

| Valeur | Type de document |
|--------|-----------------|
| `"these"` | Thèse de doctorat |
| `"thesepararticles"` | Thèse de doctorat par articles |
| `"memoire"` | Mémoire de maîtrise |
| `"memoirepararticles"` | Mémoire de maîtrise par articles |
| `"rapportprojet"` | Rapport de projet de maîtrise |

Les noms anglais sont également acceptés : `"thesis"`,
`"manuscriptbasedthesis"`, `"masterdegreethesis"`,
`"manuscriptbasedmasterdegreethesis"`, `"projectreport"`.

### Autres paramètres de `ets-document`

| Paramètre | Défaut | Signification |
|-----------|--------|--------------|
| `lang` | `"fr"` | Langue du document (`"fr"` ou `"en"`) |
| `licence` | `"reserved"` | `"reserved"` (tous droits réservés) ou `"creativecommons"` |
| `confidential` | `false` | Filigrane « CONFIDENTIEL » sur la page de titre |
| `title` | `[]` | Titre du document |
| `author` | — | `(firstname: "…", lastname: "…")` ; le nom est mis en majuscules |
| `copyright-holder` | auteur | Libellé du droit d'auteur, s'il diffère de l'auteur |
| `copyright-year` | année courante | Année de la notice de droit d'auteur |
| `concentration` | `none` | Concentration ajoutée à l'intitulé du diplôme |
| `cotutorship` | `none` | École partenaire, pour une cotutelle |
| `defense-date` | `none` | Date de soutenance (`datetime`) |
| `deposit-date` | `none` | Date de dépôt (`datetime`) |
| `supervisor`, `cosupervisor`, `chair` | `none` | Membres du jury (voir §3) |
| `jury` | `()` | Liste des membres du jury |
| `external-examiners` | `()` | Liste des examinateurs externes |
| `independent-examiner` | `none` | Examinateur externe indépendant |
| `title-page` | `true` | Génère la page de titre |
| `jury-page` | `true` | Génère la page de présentation du jury |

Les dates s'écrivent avec `datetime(year: …, month: …, day: …)`. Le gabarit les
met en forme selon la langue : « 15 mai 2026 » ou « May 15, 2026 ».

---

## 2. Contraintes de mise en page imposées

Ces valeurs sont fixées dans `src/config.typ` du paquet et ne doivent pas être modifiées
sans validation du service de rédaction.

| Paramètre | Valeur imposée |
|-----------|---------------|
| Format du papier | US Letter |
| Recto-verso | Oui (marges intérieure / extérieure) |
| Corps de texte | 12 pt |
| Colonnes | Une seule |
| Début des chapitres | Page impaire uniquement |
| Marges | Haut 3,81 cm, intérieur 3,81 cm, extérieur 1,90 cm, bas 1,90 cm |
| Interligne (corps) | 1,5× (équivalent Word) |
| Interligne (légendes, bibliographies, annexes) | Simple |
| Indentation des paragraphes | Aucune |
| Espacement entre paragraphes | 12 pt |
| Folio | En-tête, côté extérieur ; absent des pages d'ouverture de bloc |

Le gabarit LaTeX fixe `\baselineskip` à 14,5 pt puis applique `\setstretch{0.95}`
(interligne simple) et `\setstretch{1.43}` (interligne 1,5). Typst mesure la
hauteur de ligne de la hauteur de capitale à la ligne de base ; les valeurs
correspondantes, `leading-single` et `leading-onehalf`, sont calculées et
commentées dans `config.typ`.

---

## 3. Page de titre et jury

La page de titre et la page du jury sont générées automatiquement à partir des
paramètres de `ets-document`. Chaque membre du jury est un dictionnaire :

```typ
supervisor: (name: "Prénom Nom", dept: "Nom du département"),
cosupervisor: (name: "Prénom Nom", dept: "Nom du département", affiliation: "à l'École XXX"),
external-examiners: (
  (name: "Prénom Nom", affiliation: "Nom de la compagnie"),
),
```

- `name` — prénom et nom ;
- `dept` — département, facultatif ;
- `affiliation` — affiliation, facultative. Omise, elle vaut implicitement
  « École de technologie supérieure ».

Les libellés de rôle (« direction de thèse », « présidence du jury »…) sont
choisis automatiquement selon le type de document et la langue.

Pour un rapport de projet, le bloc de soutenance est omis, comme dans le
gabarit LaTeX.

---

## 4. Sections préliminaires

Les sections préliminaires précèdent l'introduction et utilisent la numérotation
romaine des pages. Elles doivent apparaître dans l'ordre ci-dessous.

```typ
#foreword          // Avant-propos (facultatif)
Texte de l'avant-propos.

#acknowledgements  // Remerciements (facultatif)
Texte des remerciements.

#resume(keywords: "mot-clé1, mot-clé2")[
  Texte du résumé en français.
]

#abstract(title: [English title of the thesis], keywords: "keyword1, keyword2")[
  English abstract text.
]

#table-of-contents()
#list-of-tables()
#list-of-figures()
#list-of-algorithms()
```

`#foreword` et `#acknowledgements` sont de simples marqueurs : le texte les suit
librement. `#resume` et `#abstract` reçoivent le texte entre crochets, car les
mots-clés sont imprimés après.

Dans un document **anglais**, les rôles s'inversent : `#abstract(keywords: …)`
utilise le titre du document et `#resume(title: …, keywords: …)` demande le
titre français.

`#list-of-algorithms()` produit une liste unifiée des algorithmes et des
extraits de code, comme le gabarit LaTeX. Ne l'inclure que si le document en
contient au moins un.

### Abréviations et symboles

Les deux listes prennent un tableau de paires `(étiquette, description)`. Le
paramètre `label-width` fixe la largeur de la colonne des étiquettes (3 cm par
défaut).

```typ
#list-of-abbreviations((
  ("ETS", "École de technologie supérieure"),
  ("ASC", "Agence spatiale canadienne"),
))

// Tri alphabétique automatique
#list-of-abbreviations(sorted: true, (
  ("PDF", "Portable Document Format"),
  ("API", "Interface de programmation applicative"),
))

#list-of-symbols((
  ($a$, "Première lettre de l'alphabet"),
  ($alpha$, "Coefficient alpha"),
), label-width: 3cm)
```

---

## 5. Structure du corps du document

```typ
#show: introduction
Texte de l'introduction.

= Titre du chapitre
Texte du chapitre.

#conclusion
Texte de la conclusion.

#recommendations   // facultatif
Texte des recommandations.
```

`#show: introduction` bascule la numérotation des pages du romain vers l'arabe,
repart à 1 et ajoute « Introduction » dans la table des matières. La forme
`show` est nécessaire : elle permet au changement de numérotation de s'appliquer
à tout ce qui suit. `#introduction[Texte…]` fonctionne également si vous
préférez délimiter explicitement le bloc.

`#conclusion` et `#recommendations` sont de simples marqueurs.

---

## 6. Commandes de sectionnement

| Écriture | Niveau | Numéroté | Dans la TDM |
|----------|--------|----------|-------------|
| `= Titre` | Chapitre | Oui | Oui |
| `== Titre` | Section | Oui | Oui |
| `=== Titre` | Sous-section | Oui | Oui |
| `==== Titre` | Sous-sous-section | Oui | Oui |
| `===== Titre` | Paragraphe | Non | Non |
| `====== Titre` | Sous-paragraphe | Non | Non |

Un chapitre s'ouvre toujours sur une page impaire, sans folio, avec
« CHAPITRE *n* » puis le titre, tous deux centrés, en gras et en majuscules.

Comme dans le gabarit LaTeX, il n'y a pas de titre court : le même texte sert
dans le corps, dans la table des matières et dans les signets PDF.

---

## 7. Listes

La syntaxe Typst standard est déjà mise en forme selon le gabarit :

```typ
+ premier élément
+ second élément

- premier élément
- second élément
```

Les énumérations sont numérotées « 1. » au premier niveau et « a. » au second ;
les listes à puces alternent « • » et « – ».

---

## 8. Équations

```typ
$ beta = 8 $ <eq:beta>

$ bold(gamma) = alpha times 3 $
```

Les équations isolées sont numérotées par chapitre : `(1.1)`, `(1.2)`… Dans les
annexes, elles prennent le préfixe « A » : `(A I-1)`.

---

## 9. Figures

```typ
#ets-figure(
  image("Figures/vueEts.jpg", width: 100%),
  caption: [Exemple de figure],
  label: <fig:vueEts>,
  source: "Source de l'image",
  year: 2024,
)
```

| Paramètre | Défaut | Rôle |
|-----------|--------|------|
| `caption` | `none` | Légende, placée sous la figure |
| `label` | `none` | Étiquette pour les références croisées (voir l'encadré) |
| `source` | `none` | Attribution de la source |
| `year` | `none` | Année de la source |
| `width` | 75 % de la largeur du texte | Largeur du bloc image |
| `frame` | `true` | Cadre autour de la figure |
| `frame-sep` | `0pt` | Écart contenu ↔ cadre |
| `caption-width-factor` | `0.95` | Largeur de la légende, en fraction de `width` |
| `placement` | `none` | `none` (à sa place), `top`, `bottom` ou `auto` |

> **Étiquettes.** Passer l'étiquette par le paramètre `label:`, et non en
> l'écrivant après l'appel. `#ets-figure(…) <fig:x>` attacherait l'étiquette au
> bloc englobant et la référence `@fig:x` échouerait.

### Sous-figures

Les sous-figures se composent dans une grille passée en corps de `#ets-figure`.
Leurs légendes sont numérotées « a) », « b) », … et repartent de `a)` dans
chaque figure parente.

```typ
#ets-figure(
  width: 0.975 * thets-config.text-width,
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.02 * thets-config.text-width,
    ets-subfigure(image("Figures/a.jpg", width: 100%),
      caption: [Première sous-figure], label: <fig:sub-a>),
    ets-subfigure(image("Figures/b.jpg", width: 100%),
      caption: [Deuxième sous-figure], label: <fig:sub-b>),
  ),
  caption: [Exemple de figure avec sous-figures],
  label: <fig:grid>,
)
```

---

## 10. Tableaux

La légende d'un tableau est placée **au-dessus**, et la source juste en dessous
de la légende.

```typ
#ets-table(
  caption: [Exemple de tableau],
  label: <tab:exemple>,
  source: "Source du tableau",
  year: 2024,
  table(
    columns: 3,
    align: center,
    [titre], [titre], [titre],
    [a], [b], [c],
  ),
)
```

Le paramètre `caption-width` fixe la largeur de la légende (75 % de la largeur
du texte par défaut).

### Tableaux longs

`#ets-longtable` compose un tableau qui se poursuit sur plusieurs pages.
L'en-tête est répété grâce à `table.header` :

```typ
#ets-longtable(
  caption: [Exemple de tableau long avec en-tête répété],
  label: <tab:long>,
  table(
    columns: 2,
    align: center,
    table.header([Colonne 1], [Colonne 2]),
    [a], [b],
    [c], [d],
  ),
)
```

---

## 11. Extraits de code

```typ
#ets-listing(
  ```python
  def bonjour_ets():
      return "ok"
  ```,
  caption: [Exemple Python],
  label: <lst:exemple>,
  source: "Dépôt d'exemple",
  year: 2024,
)
```

La légende est placée au-dessus du cadre. Les extraits de code partagent le
compteur et la liste des algorithmes : ils sont numérotés « Algorithme 1.1 »,
« Algorithme 1.2 »… et apparaissent dans `#list-of-algorithms()`.

Typst colorise la syntaxe des blocs de code. Pour un rendu strictement
monochrome, ajouter `#show raw: set text(fill: black)` dans votre document.

---

## 12. Algorithmes

`#ets-algorithm` encadre un pseudo-code libre. `#algo-reset()` remet à zéro la
numérotation des lignes, `#algo-line[…]` numérote une ligne et `#kw[…]` met un
mot-clé en gras.

```typ
#ets-algorithm(
  caption: [Exemple d'algorithme],
  label: <alg:exemple>,
  {
    algo-reset()
    [#kw[Entrées :] Galerie $cal(G)$]
    parbreak()
    algo-line[Estimer le seuil $gamma^u$]
    algo-line[#kw[pour] tout $d_l in cal(D)$ #kw[faire]]
    algo-line[#h(1.5em) Calculer la similarité]
  },
)
```

---

## 13. Source des figures et tableaux

L'attribution de source s'écrit avec les paramètres `source` et `year`, sur tous
les flottants du gabarit. Elle est composée en interligne simple, centrée, sous
la légende, et n'apparaît jamais dans les listes.

```typ
source: "Nom de la source", year: 2024   →   Tiré de Nom de la source (2024)
```

---

## 14. Références et citations

### Citations bibliographiques

```typ
Comme montré dans des travaux antérieurs @AuteurDate2020.
```

Typst produit `(Auteur, 2020)` selon le style `ets.csl`. Au-delà de deux
auteurs, la citation est abrégée dès la première occurrence :
`(De Guise et al., 1995)`.

Pour citer une page précise, passez le renvoi avec `supplement`. Écrivez
l'abréviation vous-même : Typst ne transmet pas au style le type de renvoi, et
`p.` ne peut donc pas être ajouté automatiquement.

```typ
#cite(<Malo1996>, supplement: [p. 36])   // (Malo, 1996, p. 36)
#cite(<Smith2011>, form: "prose")        // Smith (2011)
```

### Style APA-ÉTS

`ets.csl` reproduit le style APA adapté par la bibliothèque de l'ÉTS, dont les
règles et les exemples sont publiés ici :
<https://bibliotheque.etsmtl.ca/Services/Bibliographies-et-citations/Citer-avec-le-style-APA-ETS>.
Il remplace `bibETS.bst` du gabarit LaTeX et couvre les mêmes types d'entrées ;
`biblio_fr.bib` et `biblio_en.bib` en donnent un exemple de chacun.

| Type de document | Entrée `.bib` | Champs déterminants |
| --- | --- | --- |
| Livre, ouvrage collectif | `@book` | `edition`, `address`, `publisher`, `editor` |
| Chapitre, entrée d'encyclopédie | `@incollection`, `@inbook` | `booktitle`, `editor`, `chapter`, `pages` |
| Article de revue | `@article` | `journal`, `volume`, `number`, `pages` |
| Article publié dans des actes | `@inproceedings` | `booktitle`, `volume`, `number`, `pages` |
| Communication, affiche | `@inproceedings` | `type`, `booktitle`, `address`, `month` |
| Mémoire, thèse | `@mastersthesis`, `@phdthesis` | `type`, `school`, `address` |
| Rapport technique | `@techreport` | `type`, `number`, `institution`, `address` |
| Norme | `@misc` | `organization`, `howpublished`, `address` |
| Brevet | `@patent` | `type`, `number`, `organization`, `address` |
| Page web, vidéo, jeu de données | `@online` | `type`, `url`, `urldate` |
| Logiciel, notes de cours | `@misc` | `type`, `institution`, `publisher` |
| Document inédit | `@unpublished` | `type`, `institution`, `note` |

Quatre points méritent attention au moment de saisir une entrée.

**Nom d'organisme comme auteur.** Un auteur est découpé en prénom et nom. Pour
qu'une collectivité reste intacte, doublez les accolades :

```bibtex
author = {{Ordre des ingénieurs du Québec}},   % Ordre des ingénieurs du Québec
author = {Ordre des ingénieurs du Québec},     % Québec, O. des ingénieurs du
```

**Libellé du type.** Les champs `type` des thèses, mémoires, rapports, brevets
et documents inédits sont repris tels quels. En leur absence, Typst insère un
libellé anglais (« Master's thesis », « technical report »). Renseignez donc
`type = {Mémoire de maîtrise}`, `type = {Rapport technique}`, etc.

**Mois.** Indiquez-le en chiffres (`month = {10}`) : un nom de mois français
n'est pas reconnu et le jour s'afficherait seul.

**DOI et URL.** Le DOI a la priorité sur l'URL. Avec `urldate`, la date de
consultation est ajoutée : « Repéré le 2013-05-16 à … ».

### Références croisées

```typ
Voir la @fig:ma-figure.
Voir le @tab:mon-tableau.
Voir l'@eq:mon-equation.
```

Le libellé (« Figure », « Tableau », « Algorithme », « Équation ») et le numéro
sont insérés automatiquement, y compris dans les annexes (« Figure-A I-1 »).

### Liens

```typ
#link("https://www.etsmtl.ca")[Texte du lien]
#link("https://www.etsmtl.ca")            // affiche l'adresse
```

### Bibliographie

À placer à la fin du document :

```typ
#ets-bibliography(read("biblio_fr.bib", encoding: none), full: true)
```

- un paquet Typst ne peut pas lire les fichiers de votre projet : on lui passe
  donc le contenu du fichier, lu par `read` depuis **votre** document ;
- `full: true` imprime toutes les entrées du fichier, y compris celles qui ne
  sont pas citées (équivalent de `\nocite{*}`) ;
- le titre « LISTE DE RÉFÉRENCES BIBLIOGRAPHIQUES » est ajouté à la table des
  matières.

Le chemin peut aussi désigner un fichier situé ailleurs : `read` est
résolu depuis **votre** fichier :

```typ
#ets-bibliography(bytes(read("../mes-references/biblio.bib")), full: true)
```

> **N'utilisez pas de chemin commençant par `/`.** Un tel chemin est résolu
> depuis la racine du projet, et celle-ci n'est pas la même partout : la ligne
> de commande prend le dossier du document, tandis que l'extension Tinymist de
> VS Code prend la racine de l'espace de travail. Le gabarit lui-même n'en
> dépend jamais.

Une liste secondaire, intitulée « BIBLIOGRAPHIE », s'ajoute avec :

```typ
#ets-references("refs.bib", full: true)
```

Contrairement au gabarit LaTeX, qui demandait une passe BibTeX distincte pour
cette seconde liste, Typst résout les deux en une seule compilation.

---

## 15. Mémoire ou thèse par articles

Le bloc auteurs / affiliations s'insère juste après le titre du chapitre
correspondant à l'article :

```typ
#article-authors(
  authors: ([Prénom Nom#super[1]], [Prénom Nom#super[2]]),
  affiliations: (
    [#super[1] Département de génie mécanique, École de technologie supérieure,
     1100 Notre-Dame Ouest, Montréal, Québec, Canada H3C 1K3],
    [#super[2] HydroClimat TVT, 83000 Toulon, France],
  ),
  status: article-submitted(datetime(year: 2025, month: 9, day: 1)),
)
```

Le paramètre `status` est facultatif. Trois mentions sont fournies :

| Fonction | Rendu |
|----------|-------|
| `article-submitted(date)` | Article soumis pour publication, septembre 2025. |
| `article-accepted(revue, date)` | Article accepté pour publication dans *revue*, mars 2025. |
| `article-published(revue, détails)` | Article publié dans *revue*, détails. |

Pour `article-submitted` et `article-accepted`, seuls le mois et l'année sont
affichés.

---

## 16. Annexes et appendices

```typ
#show: annexes

= Exemple d'annexe
== Première section de l'annexe

#show: appendices

= Exemple d'appendice
```

`#show: annexes` :

- numérote les chapitres en chiffres romains (Annexe I, II, III…) ;
- renomme les flottants (Figure-A, Tableau-A, Algorithme-A) et les renumérote
  « I-1 », « I-2 »… ;
- préfixe les équations d'un « A » ;
- passe à l'interligne simple ;
- limite la table des matières au niveau chapitre ;
- retire les flottants des listes principales.

`#show: appendices` numérote les chapitres en lettres (Appendice A, B, C…) et
applique les mêmes règles, à ceci près que les libellés des flottants restent
inchangés — c'est le comportement de `\appendix` dans `thETS.cls`.

La forme `#annexes[…]` est également acceptée si vous préférez délimiter le bloc
explicitement.

---

## 17. Écarts connus par rapport au gabarit LaTeX

Le portage est fidèle sur la mise en page, la numérotation et les libellés. Les
points suivants diffèrent et sont assumés.

**Étiquettes des flottants.** Elles se passent par le paramètre `label:` plutôt
qu'en écrivant `<nom>` après l'appel. Un flottant du gabarit rend un bloc qui
contient la figure ; une étiquette écrite après l'appel se fixerait sur ce bloc
et la référence échouerait.

**Numérotation des flottants.** Typst évalue la fonction de numérotation d'un
élément à l'endroit où le numéro est *affiché*, et non où l'élément se trouve.
Lire le compteur de chapitre directement donnerait le mauvais numéro dans les
références croisées et dans les listes. Le gabarit contourne cela avec un
registre de chapitres (`src/floats.typ`) : les compteurs de flottants ne sont
jamais remis à zéro, et le numéro de chapitre est retrouvé à partir du numéro
global. Le résultat est identique à celui de LaTeX ; seule la mécanique diffère.

**Libellés de type dans la bibliographie.** `bibETS.bst` traduisait
« Mémoire de maîtrise », « Thèse de doctorat » et « Rapport » par des macros
LaTeX. Un style CSL ne peut pas traduire un champ de la base ; Typst remplit
d'office ces libellés en anglais. Indiquez celui que vous voulez dans le champ
`type` de l'entrée `.bib` :

```bibtex
@phdthesis{MaThese,
  type = {Thèse de doctorat},
  ...
}
```

**Champs `.bib` non repris par Typst.** Le lecteur BibTeX de Typst ignore
`version`, et ignore `booktitle` sur une entrée `@misc`. Le gabarit LaTeX s'en
servait pour la mention de version d'un logiciel et pour le numéro d'une norme.
Utilisez `howpublished` (ou `note`), que Typst conserve et que le style place
après le titre :

```bibtex
@misc{NormeCSA,
  organization = {Association canadienne de normalisation},
  title        = {Titre de la norme},
  howpublished = {Norme CSA Z317.13-07},
  year         = 2007,
  address      = {Mississauga, ON}
}
```

**Mois écrit en toutes lettres.** `bibETS.bst` recopiait le champ `month` tel
quel, ce qui permettait `month = {Octobre}`. Typst analyse la date et rejette
un nom de mois français. Les bases d'exemple du portage utilisent donc
`month = {10}` ; c'est le seul écart de contenu entre les fichiers `.bib`
du gabarit LaTeX et ceux de ce portage.

**Renvoi de page dans une citation.** Typst ne transmet pas au style le type de
renvoi passé à `supplement`. Le style ne peut donc pas préfixer « p. » ;
écrivez-le dans le renvoi : `#cite(<clé>, supplement: [p. 36])`.

**Retrait suspendu de la bibliographie.** Le gabarit LaTeX impose 3 em. Typst
compose les entrées dans une grille, hors de portée de `par(hanging-indent:)` ;
le retrait est donc celui de la propriété CSL `hanging-indent`, légèrement plus
faible.

**Marge droite de la table des matières.** Le gabarit LaTeX réduit de 1,2 cm la
largeur des lignes de repli tout en laissant le folio atteindre la pleine
largeur. Le portage aligne les folios sur la pleine largeur pour toutes les
lignes ; la différence n'est visible que sur les titres qui se replient.

**`algorithm2e`.** Typst n'a pas d'équivalent direct. `#ets-algorithm` fournit le
cadre, la légende, la source, le compteur partagé avec les extraits de code et
la numérotation des lignes ; la mise en forme du pseudo-code reste à votre main.

**Racine du projet.** Le gabarit ne résout aucun chemin depuis la racine du
projet, car celle-ci dépend de l'outil : `typst compile` prend le dossier du
document, l'extension Tinymist prend la racine de l'espace de travail VS Code.
Les fichiers fournis avec le gabarit (logo Creative Commons, `ets.csl`) sont
atteints par des chemins relatifs aux modules, et vos propres fichiers par des
chemins relatifs à votre document.

**Étiquettes PDF des pages.** Les folios affichés respectent la règle ÉTS
(romain puis arabe). Les étiquettes de pages du lecteur PDF suivent la même
numérotation.
