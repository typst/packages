// points.typ (farfadet-exo) — FAÇADE publique des points et du barème (new-bfcours-environments.sty).
// Moteur : moteur/points.typ (boîtes réglables) ; état partagé `bf-points` : farfadet-socle.

#import "moteur/points.typ" as _m
#import "../../socle/lib.typ": interne as _socle

/// Points d'un item (\tcbitempoint{points}[décalage v][décalage h] et \itempoint, fusionnés) : ajoute des points
/// au barème et, si `displayitempoints(true)` ou `boite: true`, pose la boîte « n pts ». Les points d'un exercice
/// alimentent la case de score de son en-tête.
///
/// *Écriture normale : les points en tête, le texte de l'item en second argument.* Le professeur voit tout de
/// suite ce que vaut la question, et la fonction sait où poser la boîte : à droite, en haut de l'item, le texte de
/// la première ligne coulant à sa gauche puis reprenant toute la largeur dessous (`position: "droite"`, défaut),
/// ou en ligne, juste avant le premier mot (`position: "gauche"`). Le texte ne passe jamais sous la boîte.
///
/// Ancien usage conservé : appel en fin d'item, sans texte (`Texte. #itempoint(2)`). La boîte est alors posée
/// à droite de la dernière ligne, dont la place est réservée.
///
/// ```example
/// #displayitempoints(true)
/// + #itempoint(1)[Calculer $3 + 4$.]
/// + #itempoint(0.5, dx: 5mm)[Calculer $3 times 4$.]
/// + #itempoint(2)[Étudier les variations de la fonction $f(x) = (3x^2 - 5x + 2) e^(-x/2) + ln(x^2 + 1)$ sur l'intervalle $[0 ; 10]$ et dresser son tableau.]
/// + #itempoint(1, position: "gauche")[Boîte en ligne, avant le texte.]
/// ```
///
/// - n (int, float): nombre de points (0,5 permis).
/// - corps (content): texte de l'item (second argument, entre crochets). Sans lui : ancien usage en fin d'item.
/// - position (str): `"droite"` (défaut : boîte flottante à droite, texte enroulé) ou `"gauche"` (boîte en ligne avant le texte).
/// - dy (length): décalage vertical (appel en fin d'item seulement). Défaut : 0 pt.
/// - dx (length, auto): décalage horizontal (vers la gauche). Défaut : auto (0 cm, ou 2 cm avec `dys`).
/// - dys (bool): variante DYS, décalée de 2 cm vers la gauche (ancien `dystcbitempoint`). Défaut : false.
/// - variante (str): `"standard"` (boîte mauve) ou `"gris"` (ancien `itempoint` : boîte grise, plus près du bord). Défaut : "standard".
/// - boite (bool, auto): affiche la boîte pour ce seul appel. Défaut : auto (suit displayitempoints).
/// - reserver (bool): appel en fin d'item : réserve la place de la boîte au bout de la dernière ligne. Défaut : true.
/// - colback, colframe (color, str), boxrule, arc, boxsep, min-width, xshift (length), singular, plural (content): apparence (réglable par `setrdexo(pour: "itempoint", …)`).
/// -> content
#let itempoint(n, ..args) = _m.bf-itempoint(n, corps: args.pos().at(0, default: none), ..args.named())

/// Points « informatique » (\infotcbitempoint) : boîte verte avec icône d'ordinateur, totaux séparés
/// (`getinfoexopoint`, `getsavedinfototalpoints`). Mêmes écritures et mêmes clés qu'`itempoint`.
///
/// ```example
/// #displayitempoints(true)
/// #infotcbitempoint(3)[Programme Python.]
/// ```
/// -> content
#let infotcbitempoint(n, ..args) = _m.bf-infotcbitempoint(n, corps: args.pos().at(0, default: none), ..args.named())

/// Affiche ou masque les boîtes de points (\displayitempointstrue / \displayitempointsfalse).
///
/// ```example
/// #displayitempoints(true)
/// ```
///
/// - valeur (bool): true pour afficher.
/// -> content
#let displayitempoints(valeur) = _socle.displayitempoints(valeur)

/// Boîte rouge « n pts » au-dessus d'un contenu (\baremepoint{contenu}{points}), si
/// `displaybaremepoints(true)` ; n'entre dans aucun total.
///
/// ```example
/// #displaybaremepoints(true)
/// #v(1em) Résultat : #baremepoint[$x = 3$][2]
/// ```
///
/// - contenu (content): contenu repéré.
/// - n (int, float): points.
/// -> content
#let baremepoint(contenu, n, ..cles) = _m.bf-baremepoint(contenu, n, ..cles)

/// Affiche ou masque les boîtes de `baremepoint` (\displaybaremepointstrue / false).
///
/// ```example
/// #displaybaremepoints(true)
/// ```
/// -> content
#let displaybaremepoints(valeur) = _m.bf-displaybaremepoints(valeur)

/// Points « informatique » de l'exercice n (\getinfoexopoint{n}).
///
/// ```example
/// #getinfoexopoint(1)
/// ```
/// -> content
#let getinfoexopoint(n) = _m.bf-getinfoexopoint(n)

/// Total des points du document (\getsavedtotalpoints), suivi d'un \phantom{A}.
///
/// ```example
/// Le devoir est noté sur#getsavedtotalpoints()points.
/// ```
/// -> content
#let getsavedtotalpoints() = _socle.getsavedtotalpoints()

/// Total des points « informatique » du document (\getsavedinfototalpoints).
///
/// ```example
/// #getsavedinfototalpoints()
/// ```
/// -> content
#let getsavedinfototalpoints() = _m.bf-getsavedinfototalpoints()
