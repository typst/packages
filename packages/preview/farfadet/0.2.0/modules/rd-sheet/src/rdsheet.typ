// rdsheet.typ (façade) — l'environnement `rdsheet` et le réglage `setrdsheet`, noms exacts.

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre
#import "moteur/rdsheet.typ" as _m

/// `rdsheet` : compose une capture de feuille de calcul (style LibreOffice Calc ou Excel) : en-têtes de colonnes
/// (A, B, C…) et de lignes (1, 2, 3…) générés et protégés, sélection active avec cadre et poignée de recopie,
/// barre de formule facultative.
///
/// Les lignes de données sont les arguments positionnels : chacune est un tableau de cellules
/// (`("Janvier", "1250", "1420")`) ou une chaîne « a & b & c ». Une cellule est un contenu ou une chaîne ;
/// un nombre est écrit avec ses chiffres exacts en chaîne (`"1.20"`). Aucune cellule d'en-tête n'est à fournir :
/// le nombre de colonnes est le plus grand nombre de cellules d'une ligne.
///
/// Les coordonnées sont celles du tableur : `"B2"` désigne la deuxième cellule de la deuxième ligne, avec
/// l'origine réglée par `row-start`, `col-start` ou `range`. Les styles de cellules sont des dictionnaires aux
/// clés de tabularray : `bg` (fond), `fg` (texte), `font`, `halign` (`"l"`, `"c"`, `"r"`), `valign`
/// (`"t"`, `"m"`, `"b"`), `ht`, `wd`, `mode` (`"math"`), `r` et `c` (fusions), `cmd`, `preto`, `appto`.
/// Les clés des options externes (`theme`, `bw`, `contrast`, `row-start`, `col-start`, `range`, `head-width`) et
/// des spécifications se donnent dans le même appel. Les alias LaTeX (`print`, `rowstart`, `head_width`…) sont acceptés.
///
/// ```example
/// #rdsheet(
///   select: "B2",
///   ("Article", "Prix"), ("Bureau", "249"), ("Chaise", "89"),
/// )
/// ```
///
/// - ..lignes (array, str): lignes de données.
/// - theme (auto, str): `"default"` (LibreOffice Calc ; alias `"calc"`, `"libreoffice"`, `"classic"`, `"blue"`) ou `"excel"` (alias `"green"`, `"office"`) ; `"print"` et `"bw"` activent le mode noir et blanc. Défaut : `"default"`.
/// - bw (auto, bool): mode noir et blanc, indépendant du thème (alias `print`, `monochrome`, `blackandwhite`, `gray`, `grey`). Défaut : `false`.
/// - contrast (auto, float): contraste du mode noir et blanc, de 0 (doux) à 1 (franc). Défaut : `0.5`.
/// - row-start (auto, int): numéro de la première ligne de données visible (alias `rowstart`, `start-row`, `startrow`). Défaut : `1`.
/// - col-start (auto, int, str): première colonne de données visible, lettre ou entier (alias `colstart`, `start-col`, `startcol`). Défaut : `1`.
/// - range (auto, none, str): plage de tableur `"C12:E15"` : règle l'origine et impose des dimensions minimales à la grille ; les cellules manquantes sont créées vides. Défaut : `none`.
/// - head-width (auto, length): largeur de l'en-tête de ligne, `auto` : 2em (2.5em dès la ligne 100, 3.2em dès la ligne 1000) (alias `headwidth`). Défaut : `auto`.
/// - width (auto, length, ratio, str): largeur totale de la grille. Défaut : `100%`.
/// - colspec (auto, str, array): colonnes de données, chaîne tabularray (`"Q[l,m,wd=2cm] Q[c,m,wd=2cm]"`) ou tableau de largeurs (`(2cm, 1fr)`) ; la colonne des numéros de ligne est ajoutée automatiquement. Défaut : `auto` (colonnes égales `X[l,m]`).
/// - select (auto, none, str): cellule ou plage active `"B2"` ou `"B2:C3"` : cadre de sélection, poignée de recopie, en-têtes en surbrillance. Défaut : `none`.
/// - bar (auto, bool): barre de formule au-dessus de la grille ; `auto` : affichée seulement si `name` ou `formula` est donné. Défaut : `false`.
/// - name (auto, none, str, content): texte de la zone de nom ; par défaut, la cellule ou plage sélectionnée. Défaut : `none`.
/// - name-width (auto, length): largeur de la zone de nom (alias `namewidth`). Défaut : `60pt`.
/// - formula (auto, none, str, content): texte du champ de formule ; par défaut, avec une cellule unique sélectionnée, le contenu de cette cellule. Défaut : `none`.
/// - cell (auto, none, dictionary, array): styles de cellules : `("B2": style, "A1:C1": style)`, ou tableau d'éléments `("B2", style)` et `(lignes, colonnes, style)` avec des sélecteurs comme `("2-3", "B-C", style)`. Défaut : `none`.
/// - row (auto, none, dictionary, array): styles de lignes : `("1": style, "odd": style, "Z": style)` ; sélecteurs : numéro, plage `"2-3"`, liste `"1, 3"`, `"odd"`, `"even"`, ancres `"Z"` (dernière), `"Y"` (avant-dernière)… Défaut : `none`.
/// - column (auto, none, dictionary, array): styles de colonnes : `("A": style, "B-C": style)`, par lettre ou numéro. Défaut : `none`.
/// - cells (auto, none, dictionary): style de toutes les cellules de données, sans toucher aux en-têtes. Défaut : `none`.
/// - rows (auto, none, dictionary): style de toutes les lignes de données. Défaut : `none`.
/// - columns (auto, none, dictionary): style de toutes les colonnes de données. Défaut : `none`.
/// - hline (auto, none, dictionary, array): filets horizontaux : `("2": "1.2pt, red")` trace le filet au sommet de la ligne de données 2 ; `("3": ("B-C", "1pt, dashed, blue"))` le restreint aux colonnes B à C. Défaut : `none`.
/// - vline (auto, none, dictionary, array): filets verticaux, même syntaxe que `hline` (`("2": ("1-3", filet))` restreint aux lignes). Défaut : `none`.
/// - hlines (auto, none, str, length, color, stroke, dictionary): filet de tous les filets horizontaux de la zone de données. Défaut : `0.5pt, gris du thème`.
/// - vlines (auto, none, str, length, color, stroke, dictionary): filet de tous les filets verticaux de la zone de données. Défaut : `0.5pt, gris du thème`.
/// - long (auto, bool): autorise la coupure de la grille entre deux pages (options `long` et `tall` de tabularray). Défaut : `false`.
/// - baseline (auto, none, str, length, ratio): ligne de base de la feuille dans le texte (option `baseline` de tabularray) : `"t"`, `"c"`, `"b"` ou longueur ; `none` : feuille isolée. Défaut : `none`.
/// - colsep (auto, length): marge gauche et droite des cellules (ajout ; `colsep` de tabularray). Défaut : `6pt`.
/// - rowsep (auto, length): marge haute et basse des cellules (ajout ; `rowsep` de tabularray). Défaut : `2pt`.
/// - row-height (auto, length): hauteur minimale des lignes (ajout ; `rows = {ht=1.4em}` du `.sty`). Défaut : `1.4em`.
/// - grid-width (auto, length): épaisseur des filets de la grille (ajout). Défaut : `0.5pt`.
/// - border-width (auto, length): épaisseur des bordures extérieures et du filet d'en-tête (ajout). Défaut : `0.8pt`.
/// - select-width (auto, length): épaisseur du cadre de sélection (ajout). Défaut : `1.5pt`.
/// - handle-size (auto, length): côté de la poignée de recopie (ajout). Défaut : `4.5pt`.
/// - sans-font (auto, str, array): police sans empattement de la feuille (ajout ; `\sffamily`). Défaut : `("Latin Modern Sans", "TeX Gyre Heros", "Liberation Sans", "Arial")`.
/// - colors (auto, none, dictionary): couleurs du thème à remplacer, par nom (ajout) : `(headerbg: …, selectborder: …)`. Noms : `headerbg`, `headerfg`, `grid`, `headerborder`, `border`, `selectborder`, `selecthandle`, `selectheadbg`, `selectheadfg`, `toolbarbg`, `btnsep`, `btnfg`, `arrowbg`, `barborder`, `btnneutral`, `dotsfg`, `fxcolor`, `cornertriangle`. Défaut : `none`.
/// - style (auto, str, array): style(s) nommé(s) défini(s) par `setrdsheet(definir: …)`. Défaut : `auto`.
/// -> content
#let rdsheet(..options) = {
  let lignes = options.pos()
  let local = _m.rdsheet-cles(options.named())
  context {
    let r = reglages-resoudre(_m.rdsheet-reglages, local: local, commande: "rdsheet")
    _m.rdsheet-rendu(r, lignes)
  }
}

/// `\setrdsheet{clés}` : le réglage de `rdsheet`, sous ses quatre formes (mêmes clés que `rdsheet`).
///
/// - `setrdsheet(cle: v, …)` : réglage global, pour la suite du document ; les appels s'ajoutent clé par clé.
/// - `setrdsheet(definir: "nom", cle: v, …)` : définit le style nommé « nom », appelé ensuite par `style: "nom"`
///   sur `rdsheet` ou `setrdsheet`. Un style peut en appeler un autre (`style:`).
/// - `setrdsheet(reinitialiser: true)` : oublie les réglages (styles gardés) ; avec des clés, repart des
///   défauts puis les applique. `reinitialiser: "tout"` oublie aussi les styles.
///
/// ```example
/// #setrdsheet(theme: "excel", contrast: 0.8)
/// #rdsheet(select: "B1", ("42", "84"), ("10", "20"))
/// #setrdsheet(reinitialiser: "tout")
/// #rdsheet(select: "B1", ("42", "84"), ("10", "20"))
/// ```
///
/// - pour (none, str): sans effet ici (`rdsheet` n'a pas de types) ; gardé pour la signature commune des setters. Défaut : `none`.
/// - reinitialiser (bool, str): `true` : oublie les réglages ; `"tout"` : oublie aussi les styles. Défaut : `false`.
/// - definir (none, str): nom du style à définir avec les clés données. Défaut : `none`.
/// - ..cles (any): clés de `rdsheet` (et `style:`).
/// -> content
#let setrdsheet(pour: none, reinitialiser: false, definir: none, ..cles) = {
  if cles.pos().len() > 0 {
    panic("setrdsheet : seuls des arguments nommés sont acceptés ; reçu : " + repr(cles.pos().first()) + ".")
  }
  _m.rd-regler(_m.rdsheet-reglages, "setrdsheet", pour, reinitialiser, definir, _m.rdsheet-cles(cles.named()))
}

/// `\rdsheetsetup{clés}` : alias de `setrdsheet`.
///
/// ```example
/// #rdsheetsetup(bw: true)
/// #rdsheet(select: "A1", ("1", "2"))
/// ```
///
/// - pour (none, str): voir `setrdsheet`. Défaut : `none`.
/// - reinitialiser (bool, str): voir `setrdsheet`. Défaut : `false`.
/// - definir (none, str): voir `setrdsheet`. Défaut : `none`.
/// - ..cles (any): clés de `rdsheet`.
/// -> content
#let rdsheetsetup(pour: none, reinitialiser: false, definir: none, ..cles) = setrdsheet(
  pour: pour, reinitialiser: reinitialiser, definir: definir, ..cles,
)
