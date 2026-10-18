#import "@preview/exercise-bank:0.7.0": exo, exo-setup, exo-cite
#import "@preview/beautitled:0.3.1": beautitled-init, beautitled-setup
#set page(width: 16cm, height: auto, margin: 1cm, numbering: "1")
#set text(size: 10pt, lang: "fr")
#show: beautitled-init
#beautitled-setup(enable-parts: true, part-fullpage: false, part-prefix: "Partie")
#exo-setup(display: "ex", badge-style: "underline", exercise-label: "Exercice", number-prefix: "chapter")

= Algèbre
== Équations
On utilisera plus loin #exo-cite("pythagoras", show-part: true).
#exo(id: "linear", exercise: [Résoudre $2x + 5 = 13$.])

= Géométrie
== Triangles
#exo(id: "pythagoras", exercise: [Calculer l’hypoténuse d’un triangle rectangle de côtés 3 et 4.])
Voir aussi #exo-cite("linear", show-part: true).
