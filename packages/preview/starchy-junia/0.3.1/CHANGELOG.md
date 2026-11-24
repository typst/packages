# Suivi des versions / Version history

---

## 0.3.1 — 2026-10-19

### Français

#### Nouveautés
- **Signets des annexes** : les titres d'annexes apparaissent dans les signets du PDF, sous « Annexes ». Ils sont pour cela décalés d'un niveau (`heading(offset: 1)`) ; leur numérotation (A, A.1…) et leur mise en forme ne changent pas.
- **Délimiteur après le numéro des titres** : `numerotation: (delimiteur: ")")` donne « 1.1) Titre », dans le document, les sommaires et l'en-tête. Les citations ne sont pas concernées.
- **Numérotation des annexes au choix** : `numerotation: (annexes: "A")` (défaut), `"1"`, `"Annexe A"` ou `"Annexe 1"` (mot traduit selon `langue`, devant les titres `=`).
- **Mots-clés** : paramètre `mots-cles: ("IoT", "LoRa")`, dans la langue du document, enregistré dans les métadonnées PDF et affiché sous le résumé par la nouvelle fonction `#fbc-mots-cles()` (« Mots clés : » / « Keywords: »).
- **`date` accepte une date précise**, ex : `datetime(year: 2025, month: 6, day: 30)`, affichée « Juin 2025 » / « June 2025 » et utilisée comme date des métadonnées PDF. `date: none` n'affiche pas de date. Une valeur invalide produit une erreur explicite, en particulier un texte entre guillemets (`"2025-06-30"`), auparavant affiché tel quel.

#### Corrections
- **Auteurs des métadonnées PDF** : chaque auteur est enregistré séparément, et non plus en une seule chaîne « A,B ».
- **Filigranes sur la page de garde générée** : le bandeau CONFIDENTIEL y est désormais affiché, comme le filigrane BROUILLON ; les deux sont gérés à un seul endroit pour toutes les pages.
- **Équations numérotées en annexes** : numéro de l'annexe en lettre, ex : (B.1), au lieu de son rang en chiffre.
- **Citation d'un titre d'annexe** : `@titre` donne « Annexe A » au lieu de « chap. A ».
- **Logo JUNIA** : texte alternatif « Logo JUNIA » (accessibilité, PDF/UA).
- **Dépôt** : le dossier du squelette `Modele/` est renommé `template/`, comme dans typst/packages.
- **Documentation** : page de garde sans logo ni adresse JUNIA ; README et guide IA complétés (export PDF/A, citations du lexique `@cle:long`, `@cle:pl`…, pluriel des sigles).

#### Mise à jour depuis la 0.3.0
Remplacer `0.3.0` par `0.3.1` dans `ressources/commun.typ`. Aucun autre changement n'est nécessaire. Deux comportements changent :
- une règle personnelle `show heading.where(level: 1)` ne s'applique plus aux titres d'annexes, devenus de niveau 2 ;
- une annexe citée avec `@etiquette` s'affiche « Annexe A » au lieu de « chap. A ».

### English

#### New features
- **Appendix bookmarks**: appendix headings appear in the PDF bookmarks, under "Appendices". They are shifted by one level (`heading(offset: 1)`) for this; their numbering (A, A.1…) and styling are unchanged.
- **Delimiter after heading numbers**: `numerotation: (delimiteur: ")")` gives "1.1) Title", in the document, the outlines and the header. References are unaffected.
- **Appendix numbering style**: `numerotation: (annexes: "A")` (default), `"1"`, `"Annexe A"` or `"Annexe 1"` (word translated according to `langue`, before `=` headings).
- **Keywords**: `mots-cles: ("IoT", "LoRa")` parameter, in the document language, stored in the PDF metadata and shown under the abstract by the new `#fbc-mots-cles()` function ("Mots clés :" / "Keywords:").
- **`date` accepts a precise date**, e.g. `datetime(year: 2025, month: 6, day: 30)`, shown as "June 2025" / « Juin 2025 » and used as the PDF metadata date. `date: none` shows no date. An invalid value raises an explicit error, in particular a quoted string (`"2025-06-30"`), previously shown as is.

#### Fixes
- **PDF metadata authors**: each author is stored separately instead of a single "A,B" string.
- **Watermarks on the generated cover page**: the CONFIDENTIAL banner is now shown there, like the DRAFT watermark; both are handled in one place for all pages.
- **Numbered equations in appendices**: appendix letter, e.g. (B.1), instead of its rank as a digit.
- **Appendix heading references**: `@label` gives "Appendix A" instead of "chap. A".
- **JUNIA logo**: alt text "Logo JUNIA" (accessibility, PDF/UA).
- **Repository**: the scaffold folder `Modele/` is renamed `template/`, as in typst/packages.
- **Documentation**: cover page without the JUNIA logo and address; README and AI guide extended (PDF/A export, glossary references `@key:long`, `@key:pl`…, plural of acronyms).

#### Updating from 0.3.0
Replace `0.3.0` with `0.3.1` in `ressources/commun.typ`. No other change is needed. Two behaviours change:
- a custom `show heading.where(level: 1)` rule no longer applies to appendix headings, which are now level 2;
- an appendix referenced with `@label` is shown as "Appendix A" instead of "chap. A".

---

## 0.3.0 — 2026-10-15

Version de remise à plat : un seul modèle, une bibliothèque séparée du squelette de projet, des paramètres renommés de façon cohérente et une arborescence simplifiée. **Elle n'est pas compatible avec les projets 0.2.x** : voir la note de migration ci-dessous. Les anciens noms de paramètres produisent un message d'erreur qui indique le nouveau nom.

### Français

#### Changements importants
- **Un seul modèle** : `junia-light` et `junia-expert` sont supprimés, seul `modele-junia` est conservé.
- **Typst 0.15.0 minimum**, imposé par le passage à codly 2.0.0.
- **Bibliothèque séparée du squelette** : le moteur du modèle vit dans le paquet (`lib.typ`, `src/`) et n'apparaît plus dans les fichiers du projet ; `Modele/` ne contient que le squelette et le contenu de l'étudiant. `lib.typ` n'exporte que l'API publique : `modele-junia`, les `fbc-*`, `fmp-corps-document`, `fmp-annexes`, `fm-afficher-pdf`, ainsi que `gls`/`glspl` (glossarium) et le module `codly`.
- **codly 2.0.0** : son interface a été réécrite. Les réglages d'un bloc s'écrivent `#codly.new(```py ... ```, highlights: ...)` au lieu de `#codly(highlights: ...)` avant le bloc ; ceux des blocs suivants `#show: codly.set_(...)` ou `#show: codly.theme(...)` ; `local`, `no-codly`, `codly-range`… n'existent plus (voir le [guide de migration de codly](https://codly.dherse.dev/v2.0.0/migration-1.3.html)).
- **Paquets de rédaction côté projet** : `cetz`, `fletcher`, `zap`, `timeliney`, `lilaq` et `echarm` sont importés dans `ressources/commun.typ` et non plus par le paquet. Les formes de fletcher s'écrivent `fletcher.shapes.ellipse`… ; la fonction native `ellipse` de Typst n'est plus masquée.
- **Fichiers externes passés sous forme d'image** : le paquet ne peut pas résoudre un chemin relatif au projet, les fichiers sont donc toujours fournis sous la forme `image("chemin")`, écrite dans le fichier appelant :
  - `page-de-garde` remplace `generate-cover` et `cover-pdf-path` : `auto` (page générée), `image("garde.pdf")` (page externe, *à la place* de la page générée) ou `none` ;
  - `fm-afficher-pdf(image("plan.pdf"), ...)` remplace `fm-afficher-pdf(chemin: "...")` ;
  - `logo-gauche`, `logo-centre`, `logo-droite` reçoivent une image ; `auto` = logo de JUNIA à gauche.
- **Paramètres renommés** (français, sans abréviation) et **paramètres regroupés** en dictionnaires dont seules les clés à modifier sont nécessaires — voir le tableau de migration.
- **Bibliographie** : `fbc-bibliographie` ne charge plus elle-même les fichiers (`chemins-biblio`, `style-biblio` supprimés, le paquet ne pouvant résoudre un chemin du projet) : `squelette.typ` appelle `#bibliography(...)` juste après, et `fbc-bibliographie` lui donne son titre traduit.
- **Mode ébauche simplifié** : `ebauche: true` n'affiche plus que le filigrane BROUILLON. Les notes de relecture (`fr-note-de-marge`, `fr-note-de-texte`, liste des notes) et la dépendance `drafting` sont supprimées.
- **Nouvelle arborescence du squelette** : `fiches/{pre-sommaire,corps,annexes}/NN-nom.typ`, `images/`, `ressources/{commun.typ,lexique.typ,bibliographie.yml,bibliographie.bib}`. Chaque fiche ne commence plus que par `#import "../../ressources/commun.typ": *` et la version du paquet n'est écrite qu'à un seul endroit, dans `commun.typ`.

#### Nouveautés
- **Figures de code** : un bloc de code dans une `figure` devient un *programme* (« Programme 1.1 » / « Listing 1.1 », légende au-dessus, citation « prog. 1.1 »), listé par la nouvelle fonction `fbc-liste-programme`, affichée seulement s'il existe des programmes. Paramètre `code: (mode, supplement, court, coloration)` : `mode: "figure"` traite les programmes comme des figures (même numérotation, table des figures) ; `coloration: false` désactive la mise en forme codly.
- **Tous les types de figures** sont numérotés par chapitre et cités sous forme courte, y compris les types personnalisés (`figure(kind: "algo", supplement: [Algorithme], ...)`).
- **Police réglable** : `police: (famille, taille, titres)`.
- **Messages de migration** : un paramètre d'une version précédente ou une clé inconnue dans un dictionnaire produit une erreur explicite.
- **Guide pour les assistants IA** (facultatif) : `docs/AGENTS.md`, disponible sur le dépôt Codeberg et non inclus dans les projets, décrit le fonctionnement du modèle (arborescence, paramètres, tâches courantes, erreurs fréquentes).

#### Corrections
- Les figures `raw` (code) partageaient le nom « Figure » et la numérotation des images, ce qui produisait deux « Figure 1.1 » dans un même chapitre ; leurs citations `@ref` n'avaient pas de forme courte.
- Un bloc de code long dépassait de la page au lieu de se poursuivre sur la suivante, y compris en annexe.
- Les compteurs des types de figures personnalisés n'étaient pas remis à zéro à chaque chapitre.
- Un logo de page de garde fourni par l'utilisateur (`img-cen`, `img-dro`) était introuvable.
- Dès qu'une entrée du lexique était citée, la compilation pouvait ne pas converger (« layout did not converge ») : l'affichage du lexique dépendait de citations dont le rendu change d'une passe à l'autre. Il repose désormais sur un repère invisible et stable posé à chaque citation (`@cle`, `gls`, `glspl`).

#### Maintenance
- Licence MIT-0 (MIT No Attribution) au lieu de MIT : les rapports créés à partir du modèle peuvent être diffusés sans mention de copyright, comme le recommande Typst Universe pour les templates.
- Suite de tests fonctionnels (`tests/`, exclue du paquet) : 62 cas couvrant chaque fonction, les messages de migration et la convergence de la compilation, vérifiés sur Typst 0.15.0 et 0.15.1.

#### Note de migration 0.2.x → 0.3.0
1. Créer un nouveau projet à partir du modèle 0.3.0 et y recopier le contenu des fiches, des images, du lexique et de la bibliographie (correspondance ci-dessous), ou adapter le projet existant en suivant les mêmes étapes.
2. Dans chaque fiche, remplacer `#import "../../00-configuration/005-centralisation.typ": *` par `#import "../../ressources/commun.typ": *` et adapter les chemins des images (`../../03-images/` → `../../images/`).
3. Dans `squelette.typ`, remplacer l'import de `00-configuration/` par ceux de `ressources/commun.typ` et `ressources/lexique.typ`, renommer les paramètres de `modele-junia` selon le tableau, et ajouter l'appel `#bibliography(...)` juste après `#show: fbc-bibliographie` (le plus simple : reprendre le `squelette.typ` du nouveau projet et y reporter sa configuration).
4. Les chemins passés au modèle étaient résolus depuis `00-configuration/` (ex : `"../03-images/plan.pdf"`) ; ils s'écrivent maintenant `image(...)` depuis le fichier appelant : `image("images/plan.pdf")` dans `squelette.typ`, `image("../../images/plan.pdf")` dans une fiche.
5. Remplacer `#fr-note-de-marge[...]` et `#fr-note-de-texte[...]` (supprimées) par des commentaires, ou importer soi-même le paquet `drafting` dans `ressources/commun.typ`.
6. Remplacer les formes de fletcher utilisées seules (`ellipse`, `diamond`…) par `fletcher.shapes.ellipse`…, et déplacer les fonctions personnalisées de `01-utilisateurs/` vers `ressources/commun.typ`.

| 0.2.x | 0.3.0 |
|---|---|
| `02-fiches/021-pre-sommaire/B-resume.typ`… | `fiches/pre-sommaire/01-resume.typ`… |
| `02-fiches/022-post-sommaire/G-introduction.typ`… `M-conclusion.typ` | `fiches/corps/01-introduction.typ`… `07-conclusion.typ` |
| `02-fiches/023-annexes/P-annexes.typ` | `fiches/annexes/01-annexes.typ` |
| `00-configuration/` (moteur copié dans le projet) | supprimé — le moteur vient du paquet |
| `01-utilisateurs/010-auxiliaires.typ`, `011-figures.typ` | `ressources/commun.typ` |
| `03-images/` | `images/` |
| `04-ressources/040-lexique/E-lexique.typ` | `ressources/lexique.typ` |
| `04-ressources/041-bibliographies/N-bibliographie.{yml,bib}` | `ressources/bibliographie.{yml,bib}` |
| `lang-doc` | `langue` |
| `mois-annee` | `date` |
| `filigrane` | `bandeau-confidentiel` |
| `num-equations: true` | `numerotation: (equations: true)` |
| `fmp-corps-document.with(profondeur: 2)` | `numerotation: (profondeur: 2)` |
| `tailles-police: (...)` | `police: (titres: (...))` |
| `couleurs-cite: (a, b, c)` | `couleurs-liens: (glossaire: a, bibliographie: b, annexe: c)` |
| `generate-cover: false` + `cover-pdf-path: "../03-images/garde.pdf"` | `page-de-garde: image("images/garde.pdf")` |
| `img-gau` / `img-cen` / `img-dro: "../03-images/logo.png"` | `logo-gauche` / `logo-centre` / `logo-droite: image("images/logo.png")` |
| `adr-gau` / `adr-cen` / `adr-dro` | `adresse-gauche` / `adresse-centre` / `adresse-droite` |
| `fm-afficher-pdf(chemin: "../03-images/doc.pdf", tag: "x")` | `fm-afficher-pdf(image("../../images/doc.pdf"), etiquette: "x")` |
| `fbc-*.with(titre-utilisateur: [...])` | `fbc-*.with(titre: [...])` |
| `fbc-bibliographie.with(chemins-biblio: (...), style-biblio: "apa")` | `#show: fbc-bibliographie` puis `#bibliography((...), style: "apa")` |
| `fr-note-de-marge`, `fr-note-de-texte` | supprimées |
| `junia-light`, `junia-expert` | supprimés — utiliser `modele-junia` |

### English

This release flattens the template: a single model, a library separated from the project scaffold, consistently renamed parameters and a simpler folder structure. **It is not compatible with 0.2.x projects**: see the migration table above. Old parameter names produce an error message giving the new name.

#### Breaking changes
- **Single model**: `junia-light` and `junia-expert` are removed; only `modele-junia` remains.
- **Typst 0.15.0 minimum**, required by codly 2.0.0.
- **Library separated from the scaffold**: the engine lives in the package (`lib.typ`, `src/`); `Modele/` only holds the scaffold and the student's content. `lib.typ` exports the public API only: `modele-junia`, the `fbc-*` functions, `fmp-corps-document`, `fmp-annexes`, `fm-afficher-pdf`, plus `gls`/`glspl` (glossarium) and the `codly` module.
- **codly 2.0.0**: its interface was rewritten. Per-block settings are written `#codly.new(```py ... ```, highlights: ...)` instead of `#codly(highlights: ...)` before the block; settings for following blocks `#show: codly.set_(...)` or `#show: codly.theme(...)`; `local`, `no-codly`, `codly-range`… no longer exist (see codly's [migration guide](https://codly.dherse.dev/v2.0.0/migration-1.3.html)).
- **Writing packages on the project side**: `cetz`, `fletcher`, `zap`, `timeliney`, `lilaq` and `echarm` are imported in `ressources/commun.typ`, no longer by the package. Fletcher shapes are written `fletcher.shapes.ellipse`…; Typst's native `ellipse` is no longer shadowed.
- **External files passed as images** (`image("path")`, written in the calling file, since the package cannot resolve project-relative paths): `page-de-garde` (`auto` / `image("cover.pdf")` *instead of* the generated page / `none`) replaces `generate-cover` and `cover-pdf-path`; `fm-afficher-pdf(image("plan.pdf"), ...)`; `logo-gauche`, `logo-centre`, `logo-droite`.
- **Renamed parameters** (French, no abbreviations) and **grouped parameters** as dictionaries where only the keys to change are needed — see the migration table.
- **Bibliography**: `fbc-bibliographie` no longer loads the files itself (`chemins-biblio`, `style-biblio` removed, since the package cannot resolve project paths): `squelette.typ` calls `#bibliography(...)` right after it, and `fbc-bibliographie` gives it its translated title.
- **Simplified draft mode**: `ebauche: true` only shows the DRAFT watermark. Review notes (`fr-note-de-marge`, `fr-note-de-texte`, list of notes) and the `drafting` dependency are removed.
- **New scaffold layout**: `fiches/{pre-sommaire,corps,annexes}/NN-name.typ`, `images/`, `ressources/{commun.typ,lexique.typ,bibliographie.yml,bibliographie.bib}`. Each content file starts with a single `#import "../../ressources/commun.typ": *` line and the package version is written in one place only.

#### New features
- **Code listings**: a code block inside a `figure` becomes a listing ("Programme 1.1" / "Listing 1.1", caption on top, cited as "prog. 1.1" / "lst. 1.1"), listed by the new `fbc-liste-programme`, shown only when listings exist. Parameter `code: (mode, supplement, court, coloration)`: `mode: "figure"` treats listings as figures (shared numbering, list of figures); `coloration: false` disables codly styling.
- **All figure kinds** are numbered per chapter and cited in short form, custom kinds included.
- **Configurable font**: `police: (famille, taille, titres)`.
- **Migration messages**: a parameter from a previous version or an unknown dictionary key produces an explicit error.
- **AI assistant guide** (optional): `docs/AGENTS.md`, available in the Codeberg repository and not included in projects, describes how the template works.

#### Maintenance
- MIT-0 (MIT No Attribution) license instead of MIT: reports created from the template can be distributed without any copyright notice, as Typst Universe recommends for templates.
- Functional test suite (`tests/`, excluded from the package): 62 cases covering every function, migration messages and compilation convergence, checked on Typst 0.15.0 and 0.15.1.

#### Fixes
- `raw` (code) figures shared the "Figure" name and the image numbering, producing two "Figure 1.1" in the same chapter; their `@ref` citations had no short form.
- A long code block overflowed the page instead of continuing on the next one, appendices included.
- Counters of custom figure kinds were not reset at each chapter.
- A user-provided cover-page logo (`img-cen`, `img-dro`) could not be found.
- As soon as a glossary entry was cited, compilation could fail to converge ("layout did not converge"): the glossary display depended on citations whose rendering changes between passes. It now relies on an invisible, stable marker placed at each citation (`@key`, `gls`, `glspl`).

---

## 0.2.1 — 2026-09-03

### Français

#### Corrections
- Citations courtes (`@ref`) de figures, tableaux et équations : le format de numérotation réellement actif à l'emplacement de l'élément référencé est maintenant respecté (pré-sommaire en chiffres romains, annexes et `junia-light` en numérotation simple, corps du document en `chapitre.numéro`), y compris pour une citation croisée vers un autre chapitre — le chapitre de l'élément référencé était auparavant confondu avec celui de la référence
- `fm-afficher-pdf` : la première page affichée hérite désormais du format de numérotation global au lieu d'un numéro simple forcé ; les pages de continuation d'un PDF multi-pages n'apparaissent plus dans la liste des figures

#### Nouveautés
- Exemple commenté pour `tailles-police` ajouté dans `squelette.typ`

#### Maintenance
- Mise à jour des paquets Typst vers leur dernière version disponible : `cetz` 0.5.2, `zap` 0.6.0, `hydra` 0.6.3, `echarm` 0.4.0 — compilation vérifiée sans erreur

---

### English

#### Fixes
- Short-form citations (`@ref`) for figures, tables and equations: the numbering format actually active where the referenced element lives is now respected (roman numerals in the pre-summary, simple numbering in appendices and `junia-light`, `chapter.number` in the document body), including for cross-chapter references — the referenced element's chapter was previously mixed up with the citing reference's own chapter
- `fm-afficher-pdf`: the first displayed page now inherits the global numbering format instead of a forced plain number; continuation pages of a multi-page PDF no longer appear in the list of figures

#### New features
- Commented `tailles-police` example added to `squelette.typ`

#### Maintenance
- Updated Typst packages to their latest available version: `cetz` 0.5.2, `zap` 0.6.0, `hydra` 0.6.3, `echarm` 0.4.0 — compilation verified error-free

---

## 0.2.0 — 2026-05-03

### Français

#### Changements importants
- Architecture refactorisée : `Modele/Configuration/setup.typ` → `Modele/00-configuration/` (6 fichiers)
- Renommage `math-num` → `num-equations` (paramètre de `modele-junia` et `junia-expert`)
- Renommage des fonctions : `f-lexique` → `fbc-lexique`, `f-sommaire` → `fbc-sommaire`, etc.
- Nommage kebab-case unifié (suppression des variantes underscore)

#### Nouveautés
- Deux nouveaux modèles : `junia-light` (document court, fichier unique) et `junia-expert` (architecture libre)
- Support bilingue FR/EN via `lang-doc`
- Page de garde avec logos et adresses paramétrables (`img-gau/cen/dro`, `adr-gau/cen/dro`)
- Suppléments forme courte/longue pour figures, tableaux, équations
- Gestion des équations mathématiques numérotées par chapitre
- Gestion améliorée du glossaire via `state` et convergence automatique en deux passes
- Documentation intégrée via tidy (`00-configuration/009-documentation.typ`)
- Fonctions utilitaires : `fr-note-de-marge`, `fr-note-de-texte`, `fm-afficher-pdf`

---

### English

#### Breaking changes
- Architecture refactored: `Modele/Configuration/setup.typ` → `Modele/00-configuration/` (6 files)
- Renamed `math-num` → `num-equations` (parameter of `modele-junia` and `junia-expert`)
- Functions renamed: `f-lexique` → `fbc-lexique`, `f-sommaire` → `fbc-sommaire`, etc.
- Unified kebab-case naming (underscore variants removed)

#### New features
- Two new models: `junia-light` (short document, single file) and `junia-expert` (free architecture)
- Bilingual FR/EN support via `lang-doc`
- Configurable cover page logos and addresses (`img-gau/cen/dro`, `adr-gau/cen/dro`)
- Short/long form supplements for figures, tables, equations
- Per-chapter equation numbering
- Improved glossary management via `state` with automatic two-pass convergence
- Integrated documentation via tidy (`00-configuration/009-documentation.typ`)
- Utility functions: `fr-note-de-marge`, `fr-note-de-texte`, `fm-afficher-pdf`

---

## Versions précédentes / Previous versions

### Français

Version 1 :
Ajouté :
  - Gestion de la page de garde paramétrable
  - Gestion des métadonnées du document
  - Gestion des bibliothèques utilisateurs
  - Définition du format du document et de la langue

Version 2 : 
Ajouté :
  - Ajout de la police "Latin Modern"
  - Gestion du pied de page et du haut de page
  - Style centralisé

Version 3 :
Ajouté :
  - Ajout de la bibliothèque "glossarium"
  - Gestion des citations bibliographiques et appels lexique automatisé
    - Mise en couleur automatique selon une fonction 

Version 4 : 
Ajouté :
  - Gestion du mode "ébauche"
    - Modification des tailles de marges 
    - Variable pour l'activation
  - Gestion des tailles de titres selon les niveaux (1-6)
    
Version 5 : 
Ajouté :
  - Modèle renommé
  - Ajout de commentaires pour expliquer les fonctions et le fonctionnement du modèle 
  - Réécriture de certaines fonctions trop compliquées pour l'utilisation
    - Utilisation de "hydra" pour le haut de page et les titres
  - Gestion paramétrée des tailles de titres en une seule fonction
  - Numérotation par chapitres des figures dans le corps du document
  - Ajout de paramètres dans le modèle pour les filigranes brouillon et confidentiel
Retiré : 
  - Mode ébauche :
    - Modification des tailles de marges en mode ébauche
    - Variables en dehors du modèle

Version 6 :
Ajouté :
  - Modification de la gestion des annexes
    - Ajout d'une fonction de basculement
    - Mise en couleur des citations vers les annexes (violet)
    - Style centralisé des annexes
  - Ajout d'un paramètre pour la numérotation des équations mathématiques
  - Ajout de "l'article" `Chap.` avant la citation d'un chapitre dans le document.

Version 7 :
Ajouté :
  - Ajout de la gestion de langue
    - Traduction de certaines parties "fixe" en français et en anglais
  - Ajout du paramètre `formation` pour plus de modularité sur la page de garde
  - Gestion dynamique des sommaires selon leurs positions dans le document
    - Affichage dans le sommaire principal 
    - Numérotation des titres
  - Gestion de l'affichage des titres dans les fonctions de "basculement"

Retiré :
  - Variable `entrees_glossaire` relative au lexique dans le modèle
    - Import direct depuis E_Lexique.typ

Version 8 :
Ajouté :
  - Gestion de la taille des notes de bas de page (9pt)
  - Légende des tableaux positionnée au-dessus (conformité charte)
  - Refactorisation en fonctions "maison" pour les sections du pré-sommaire
    et post-sommaire (lexique, sommaires, bibliographie)
  - Affichage de tous les titres dans les signets PDF
    - Pré-sommaire : bookmarked activé explicitement
    - Annexes : bookmarked désactivé
  - Nouvelle gestion du sommaire des annexes par position dans le document
    - Ciblage via .after(<end_of_main_doc>) — suppression du label <annexe> manuel
  - Centralisation du délimitateur FR/EN dans liste_trad_auto
  - Centralisation du mois dans liste_trad_auto (suppression de la double variable)
  - Correction du code postal de l'adresse JUNIA (59104 → 59014)
  - Fonction pour l'affichage de plusieurs pages d'un PDF
  
Retiré :
  - Appels directs aux fonctions Typst dans main.typ pour les sections
    (sommaire, lexique, listes, bibliographie) → remplacés par #show: f_*
  - Fonction f_trad_auto() → accès direct à liste_trad_auto
  - Double gestion de la date selon la langue (mois_annee == auto avec lang_doc)
    → unifié dans liste_trad_auto via la clé mois_date

---

### English

Version 1:
Added:
  - Parameterized cover page management
  - Document metadata management
  - User library management
  - Document format and language definition

Version 2:
Added:
  - Added "Latin Modern" font
  - Header and footer management
  - Centralised style

Version 3:
Added:
  - Added "glossarium" library
  - Bibliographic citation and automated glossary entry management
    - Automatic colour-coding via a function

Version 4:
Added:
  - Draft mode management
    - Margin size adjustment
    - Activation variable
  - Heading size management per level (1–6)

Version 5:
Added:
  - Template renamed
  - Comments added to explain functions and template behaviour
  - Rewriting of overly complex functions for easier use
    - Use of "hydra" for headers and section titles
  - Parameterised heading size management in a single function
  - Chapter-numbered figure captions in the document body
  - Draft and confidential watermark parameters added to the template
Removed:
  - Draft mode:
    - Margin size adjustment in draft mode
    - Variables defined outside the template

Version 6:
Added:
  - Modified appendix management
    - Addition of a switch function
    - Colour-coded appendix citations (purple)
    - Centralised appendix style
  - New parameter for mathematical equation numbering
  - Addition of the "Chap." article before chapter citations in the document

Version 7:
Added:
  - Language management
    - Translation of certain "fixed" parts into French and English
  - Addition of the `formation` parameter for more modularity on the cover page
  - Dynamic table of contents management based on position in the document
    - Display in the main table of contents
    - Heading numbering
  - Dynamic heading display in switch functions
Removed:
  - `entrees_glossaire` variable related to the glossary in the template
    - Direct import from E_Lexique.typ

Version 8:
Added:
  - Footnote size management (9pt)
  - Table captions positioned above (charter compliance)
  - Refactoring into custom functions for pre-TOC and post-TOC sections
    (glossary, TOCs, bibliography)
  - All headings displayed in PDF bookmarks
    - Pre-TOC: bookmarked enabled explicitly
    - Appendices: bookmarked disabled
  - New appendix TOC management by position in the document
    - Targeting via .after(<end_of_main_doc>) — removal of the manual <annexe> label
  - Centralisation of the FR/EN delimiter in liste_trad_auto
  - Centralisation of the month in liste_trad_auto (removal of the double variable)
  - Correction of JUNIA postal code (59104 → 59014)
  - Function for displaying multiple pages of a PDF
Removed:
  - Direct calls to Typst functions in main.typ for sections
    (TOC, glossary, lists, bibliography) → replaced by #show: f_*
  - Function f_trad_auto() → direct access to liste_trad_auto
  - Dual date management per language (mois_annee == auto with lang_doc)
    → unified in liste_trad_auto via the mois_date key
