# Post-it simple — faboxyst 0.3.0

Le complément propose des éléments indépendants : `postit` conserve l’ombre
sous le trait (jaune foncé orangé `#C07800` par défaut) ; `postit-butterfly`
ajoute l’ombre native `fabox` *large/lifted*, en forme d’ailes dans la bande
inférieure ; `garnet-box` reprend le style visuel de la bannière grenat de
l’image de référence, sans reprendre sa mise en page. La variante papillon
garde sa silhouette native à l’intérieur du post-it, décalée vers le haut de
sa hauteur visible plus `2pt` ; l’inset inférieur reste à `0pt`. `numbered-header-box`
ajoute une box normale avec un bandeau arrondi fusionné à un trapèze numéroté.

`garnet-box` est une bannière arrondie grenat (`#A60650`) à texte blanc et
gras. Elle reçoit l’ombre native `large` du post-it standard, retournée vers
le bas en forme de cuve, centrée sur le bord inférieur et longue d’environ
50% de la box par défaut ; le centre de sa cuve est légèrement abaissé et son
profil est adouci. La face reçoit aussi le relief intérieur natif
`shadow: "creuse"` de faboxyst 0.3.0, pour un aspect enfoncé. L’ombre extérieure
éclaircit nettement le haut-centre et assombrit les extrémités horizontales,
sans modifier sa géométrie native ; le contact avec le bord inférieur reste
fondu. Ce n’est pas la variante papillon. En LTR, le texte est centré ; en RTL, il est aligné à
droite.

## Mode d’impression monochrome

Le thème `print` reprend l’approche monochrome de Blockst : surfaces
principales blanches, contours et texte noirs. Pour les ombres, la règle est
stricte : la peinture colorée d’origine est convertie en gris, sans la
remplacer par un gris pâle fixe. Son intensité relative, son opacité, sa forme
et ses décalages restent ceux configurés par le style. Les notes réservent en
print la bande déjà prévue à l’ombre afin qu’elle soit visible hors du papier.
Les styles normaux restent inchangés ; la direction RTL/LTR et la géométrie
du bandeau numéroté restent actives.

```typst
#show: faboxyst.with(theme: "print")
// Variante dictionnaire : #show: faboxyst.with(theme: themes.print)

#print-group[
  #numbered-header-box(title: [Étape], number: 12)[Texte RTL ou LTR.]
  #postit(title: [Note])[Une surface blanche, un contour noir.]
]
```

`print-group` limite le thème au groupe et restaure ensuite le thème précédent.
La suite `tests/test-print-rtl.typ` vérifie le badge et les alignements RTL ;
`tests/test-print-cover.typ` vérifie la couverture pleine page ;
`tests/test-print-all.typ` compile les familles de boîtes.

## Box normale à bandeau trapézoïdal numéroté

`numbered-header-box` associe un cadre carré à un bandeau arrondi dont le
contour fusionne avec un trapèze étroit qui traverse verticalement le bandeau.
Le trapèze est placé à 5% du côté de départ (à gauche en LTR, à droite en RTL) ;
sa grande base est en haut et ses deux pointes dépassent du bandeau. Son cercle
central affiche `number: auto` (compteur à partir de `01`) ou un numéro
personnalisé. Une petite ombre décalée en haut à gauche donne à la partie
saillante un bord de type parallélogramme ; elle se place en haut à droite en RTL.
Le bandeau dépasse légèrement le cadre (`bar-width: 104%` par défaut), avec
des coins arrondis de `2pt` par défaut (`bar-radius`). Le titre est centré verticalement;
le cercle s’élargit automatiquement pour contenir deux chiffres.

La largeur s’ajuste au contenu par défaut. `width:` accepte une longueur ou un
ratio ; `inset:` accepte une longueur uniforme ou `(horizontal, vertical)`, et
`inset-x:` / `inset-y:` règlent les marges séparément.

```typst
#import "src/numbered-header-box.typ": numbered-header-box
#numbered-header-box(title: [Concept essentiel])[Texte de la box.]
#numbered-header-box(title: [Étape personnalisée], number: 8, width: 8cm,
  inset: (0.55cm, 0.40cm))[Autre texte.]
```

Pour `postit-butterfly`, la teinte suit celle du papier avec une légère nuance
rouge (`#C64A2B`, mélange à `12%`) pour réchauffer l’ombre vers l’orange. Par
défaut, le gradient va du mélange papier/rouge assombri de `20%` au centre
à ce même mélange assombri de `5%` aux extrémités. L’opacité de peinture est renforcée pour que la
couleur reste visible dans les couches translucides natives ; leur silhouette
et leur profil relatif ne changent pas. Le centre du demi-cercle supérieur est
abaissé de `0.03cm` par défaut.

## Utilisation et réglages

```typst
#import "src/postit.typ": postit
#import "src/postit-butterfly.typ": postit-butterfly
#import "src/garnet-box.typ": garnet-box

#postit(title: [À retenir])[Un post-it autonome.]
#garnet-box[ما يجب معرفته]
#garnet-box(width: 8cm, inset: 0.30cm, direction: rtl)[ما يجب معرفته]
#postit-butterfly(title: [À retenir])[Variante à ombre papillon.] 
#postit-butterfly(
  width: 8cm,
  radius: 0.30cm,
  tab-drop: 0.04cm,
  shadow-red-mix: 15%,
  line-color: rgb("#C64A2B"),
  line-length: 92%,
  shadow-length: 94%,
  shadow-center-darken: 30%,
  shadow-edge-darken: 8%,
)[Note personnalisée.]
#postit-butterfly(
  shadow-gradient-in: rgb("#A93C1F"),
  shadow-gradient-out: rgb("#E7A72C"),
)[Stops de gradient personnalisés.] 
```

- `radius:` règle l’arrondi des coins (défaut : `0.24cm`). `tab-drop:` abaisse
  le centre du demi-cercle supérieur (défaut : `0.03cm`).
- Pour `garnet-box`, `shadow: "large"` active par défaut l’ombre native du
  post-it standard (`shadow: none` la désactive). `shadow-color: auto` dérive
  une ombre grenat de la couleur du bandeau ; `shadow-length:` règle sa largeur
  (défaut : `50%`, centrée sous la box). `width: auto` (défaut) adapte la box
  au contenu ; une longueur ou un ratio permet d’imposer sa largeur. `inset:`
  règle les marges intérieures (défaut : `(0.50cm, 0.22cm)` ; une longueur
  unique ou une paire `(horizontal, vertical)` est acceptée). `inset-x:` et
  `inset-y:` permettent de les régler séparément.
- `line-color: auto` reprend visuellement la couleur du fond ; sous l’ombre,
  ce trait invisible est omis. Passez une couleur pour l’afficher au-dessus
  de l’ombre.
- `line-length:` règle la longueur du trait ; `shadow-length:` règle
  indépendamment celle de l’ombre. Les deux valent `93%` par défaut et
  acceptent un pourcentage ou une longueur.
- `shadow-color: auto` prend la couleur du papier comme base du gradient ; une
  couleur explicite permet de choisir une autre base. `shadow-red-color:` et
  `shadow-red-mix:` règlent la nuance rouge (défauts : `#C64A2B` et `12%`).
  `shadow-center-darken:` et `shadow-edge-darken:` règlent l’assombrissement
  automatique (défauts : `20%` et `5%`). `shadow-gradient-in:` fixe la couleur
  au centre ; `shadow-gradient-out:` fixe les deux extrémités. `auto` conserve
  les couleurs calculées ; le gradient horizontal est `out → in → out`.
- `width` et `height` s’ajustent au contenu par défaut. `height:` est une
  hauteur minimale ; le texte n’est jamais coupé.
- `direction: auto | ltr | rtl` suit la direction du texte ou la force.

## En ligne / hors ligne

L’ombre native réutilise l’implémentation de `fabox`. Dans un éditeur en ligne,
Typst récupère les dépendances au premier rendu ; pour compiler ensuite hors
ligne, faites d’abord ce rendu afin qu’elles soient mises en cache.

La copie locale exporte `postit`, `study-postit`, `postit-butterfly`,
`garnet-box` et `numbered-header-box` par `lib.typ`. Depuis un document placé
à côté du dossier `faboxyst/`, utilisez `#import "faboxyst/lib.typ": *` ;
les exemples du dossier utilisent leurs propres chemins relatifs locaux.
Voir aussi `examples/postit-simple.typ`, `examples/postit-butterfly.typ`,
`examples/garnet-box.typ` et `examples/numbered-header-box.typ`.
