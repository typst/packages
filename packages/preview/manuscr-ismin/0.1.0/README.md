# _Template_ rapport ISMIN

Ce _template_ est celui que j'utilise pour écrire mes rapports à l'EMSE.
Il utilise le langage Typst et est grandement inspiré de [celui de Timothé Dupuch](https://github.com/thimotedupuch/Template_Rapport_ISMIN_Typst),
du [_template_ Bubble](https://github.com/hzkonor/bubble-template),
du [_template_ ilm](https://github.com/talal/ilm),
et enfin du [_template_ Diatypst](https://github.com/skriptum/Diatypst).
Beaucoup des règles de typographie ont été tirées du [_Butterick's Practical Typography_](https://practicaltypography.com/).

Le fichier `template_report_ISMIN.pdf` est un apercu en PDF du résultat de la compilation.
J'ai essayé de montrer toutes les possibilités qu'offrait Typst, le contenu étant évidemment à ajuster à votre guise.

Pour en savoir plus sur les fonctions l'utilisation de Typst, vous pouvez utiliser [la documentation](https://typst.app/docs), elle est très complète.
Le Ctrl+Clic (ou Cmd+Clic) marche aussi sur les fonctions (dans l'éditeur de l'application web).

## Utilisation

Je conseille d'utiliser [l'application Web Typst](https://typst.app/), mais il est possible de l'installer le compilateur en CLI sur sa machine.
- Le fichier `template.typ` contient toutes les règles et fonctions d'affichage
- Le fichier `main.typ` lui contient le contenu que vous souhaitez inclure dans le rapport
- Le fichier `bibs.yaml` contient les références bibliographiques (au format Hayagriva, mais Typst prend aussi en charge le format BibLaTeX)
- Le dossier `assets` contient les ressources graphiques pour le thème du _template_
- Le dossier `fonts` contient des polices de caractères
- Le dossier `images` contient les images inclues dans le document

### `manuscr-imsin`

Ci-suit une description des paramètres de la fonction `manuscr-ismin` :
- `title` : le titre du document (obligatoire)
- `subtitle` : le sous-titre
- `authors` : champ des auteurs sous forme de dictionnaire ; pour n'utiliser qu'un auteur, ne pas oublier de laisser quand même une virgule à la fin
	- `name` : le nom de l'auteur
	- `affiliation` : la filière de l'auteur
	- `year` : l'année dans laquelle est l'auteur dans son cursus
	- `class` : la classe de l'auteur
- `date` : la date
- `logo` : le logo que vous voulez utiliser ; par défaut, c'est celui de l'EMSE
- `main-color` : la couleur de thème du document ; par défaut, il s'agit du "violet EMSE"
- `header-title` : le texte à gauche dans l'en-tête
- `header-middle` : le texte centré et gras dans l'en-tête
- `header-subtitle` : le text à droite et en italique de l'en-tête
- `body-font` : la police pour le corps du texte ; par défaut, il s'agit de Libertinus Serif mais pour un _look_ LaTeX, utiliser New Computer Modern
- `code-font` : la police pour la fonction `raw` ; par défaut, il s'agit de Cascadia Mono mais pour un _look_ __vraiment__ LaTeX, utiliser New Computer Modern Mono
- `math-font` : la police pour la fonction `equation` ; par défaut, il s'agit de New Computer Modern Math
- `mono-font` : la police pour la fonction non-native `mono` ; par défaut il s'agit de Libertinus Mono (prendre une fonction monospace)
- `number-style` : le style des nombres ; par défaut en `"old-style"` (donc elzéviriens), possible de le changer pour `"lining"` (chiffres classiques)

### Les fonctions

- `violet-emse` : la couleur violette de l'EMSE
- `gray-emse` : la couleur grise de l'EMSE
- `lining` : pour avoir des nombres en style classique localement si vous avez pris "old-style" ; les chiffres elzéviriens s'intégrent bien au texte minuscule, mais mal à celui en majusucule.
	Par exemple, `#lining[STM32L436RG]` est bien plus élégant que `STM32L476RG`
- `arcosh` : la fonction arc cosinus hyperbolique pour le mode mathématique
- `mono` : à utiliser pour retourner rapidement du texte en monospace sans la mise en forme de `raw`.
	À utiliser pour par exemple indiquer des noms de fichier : `toto_tigre.png`
