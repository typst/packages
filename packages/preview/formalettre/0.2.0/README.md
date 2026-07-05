# Formalettre : writing french letters with typst



Un template destiné à écrire des lettres selon une typographie francophone, et inspiré du package LaTeX [lettre](https://ctan.org/pkg/lettre).

Pour utiliser le template, il est possible de recopier le fichier exemple.



## Documentation des variables



### Expéditeur 

- `expediteur.nom` : nom complet l'expéditeur·ice, **requis**.
- `expediteur.adresse` : addresse, sans la commune, sous forme de contenu ou de liste s'il y a plusieurs lignes, **requis**.
- `expediteur.commune` : code postal et commune de l'expéditeur·ice, **requis**.
- `expediteur.pays` : pays de l'expéditeur⋅ice, *facultatif*.
-  `expediteur.telephone` : le numéro de téléphone fourni sera cliquable. *Chaîne de caractères*, *facultatif*.
-  `expediteur.email` : l'email fourni sera affiché en police mono et cliquable. *Chaîne de caractères*, *facultatif*.
- `expediteur.signature` : précise le nom à afficher en signature de fin de lettre. Par défaut, cela reprend le prénom et le nom, *facultatif*.
- `expediteur.image_signature` : peut être rempli avec un contenu de type `image("signature.png")` pour intégrer l'image d'une signature numérisée. *Facultatif*

### Destinataire

- `destinataire.nom` : nom ou titre du ou de la destinataire, **requis**.
- `destinataire.adresse` : adresse, sans la commune, sous forme de contenu ou de liste s'il y a aucune ou plusieurs lignes, **requis**.
- `destinataire.commune` : code postal et commune du ou de la destinataire, **requis**.
- `destinataire.pays` : pays du ou de la destinataire, *facultatif*.

### Intermédiaire

Dans le cas d'une lettre transmise par voie hiérarchique, on peut spécifier
l'intermédiaire, qui sera indiqué par la mention « s/c de » (sous couvert de)
dans l'en-tête de la lettre, et qui apparaîtra comme destinaitaire sur
l'enveloppe, si on en imprime une.

- `intermediaire.nom` : nom ou titre de l'intermédiaire, **requis**.
- `intermediaire.adresse` : adresse, sans la commune, sous forme de contenu ou de liste s'il y a plusieurs lignes, **requis** en cas de génération d'enveloppe.
- `intermediaire.commune` : code postal et commune de l'intermédiaire, **requis** en cas de génération d'enveloppe.
- `intermediaire.pays` : pays de l'intermédiaire, *facultatif*.

### Lettre

- `objet` : l'objet du courrier, *facultatif*.
- `date` : date à indiquer sous forme libre, **requis**.
- `lieu` : lieu de rédaction, **requis**.
- `envoi` : informations d'envoi, par exemple « Recommandé avec accusé de réception numéro XXXXXXXX », *facultatif*.
- `ref` : référence du courrier, *facultatif*.
- `vref` : votre référence (référence utilisée par le destinataire), *facultatif*.
- `nref` : notre référence (référence utilisée par l'expéditeur), *facultatif*.
- `appel` : formule d'appel, autrement dit formule initiale, désactivée par défaut. *Facultatif*.
- `salutation` : formule de salutation, autrement dit formule finale, désactivée par défaut. *Facultatif*.
- `ps` : permet de préciser un post-scriptum (ou plusieurs), *facultatif*.
- `pj` : permet d'indiquer la présence de pièces jointes.  Il est possible d'en faire une liste, par exemple :

```typc
pj: [
	+ Dossier n°1
	+ Dossier n° 2
	+ Attestation
	]
```

- `cc` : permet d'indiquer les destinataires additionnels de cette lettre, sous la forme d'une liste, *facultatif*.
- `marges` : indiquer deux dimensions pour ajouter des marges supplémentaires à gauche et à droite du corps de la lettre: `(1cm, 1cm)` par défaut, *facultatif*.
- `marque_pliage` : `false` par défaut, mettre à `true` pour imprimer une petite ligne indiquant où plier la page pour la mettre dans une enveloppe DL ou C5/6. *Facultatif*.
- `enveloppe` : permet de générer une page à imprimer sur une enveloppe de la taille indiquée, qui peut être une chaîne contenant le nom d'un format courant (`c4`, `c5`, `c6`, `c56` ou `dl`) ou une spécification manuelle sous la forme `(<longueur>, <largeur>)`. *Facultatif*.
- `affranchissement` : fournir une chaîne (code d'affranchissement) ou un contenu tel que `image("timbre.png")` pour imprimer un affranchissement dans la zone idoine de l'enveloppe. *Facultatif*.
- `capitalisation` : indiquer un niveau de capitalisation des adresses, *facultatif* :
  - 0 (défaut) : ne pas modifier les adresses fournies,
  - 1 : mettre en petites majuscules les communes et pays,
  - 1.5 : mettre en majuscules les communes et pays,
  - 2 : mettre en petites majuscules les adresses, communes et pays,
  - 2.5 : mettre en majuscules les adresses, communes et pays,
  - 3 : mettre en petites majuscules l'ensemble des blocs d'adresses (noms, adresses, communes et pays),
  - 3.5 : mettre en majuscules l'ensemble des blocs d'adresses (noms, adresses, communes et pays).

Le texte de la lettre proprement dite se situe après la configuration de la lettre.

À la fin de la lettre, il est possible de décommenter les deux dernières lignes pour ajouter une image en guise de signature. Veillez dans ce cas à positionner la varibale `expediteur.signature` à `true`.


## Notes

### Signature

Par défaut, le prénom et le nom de l'expéditeur sont repris pour la signature, mais on peut indiquer spécifiquement ce qu'on veut en renseignant l'option `signature`, par exemple pour signer avec son seul prénom.

L'option `signature` permet également de préciser plusieurs signataires, sous la forme d'une liste :

```typc
expediteur: (
    …,
    signature: ([Pierre], [Paul], [Jacques]),
)
```

Dans le cas ordinaire d'un signataire unique, on peut également inclure une image de signature numérisée avec l'option `image_signature`. Celle-ci prend un contenu libre, ce qui suffit à inclure simplement une image à sa taille naturelle `image("signature.png")` ou au besoin de régler sa taille et de l'espacer :

```typc
expediteur: (
    …,
    image_signature: pad(
        top: 10mm, bottom: 5mm,
        image("signature.png", height: 3cm)
    ),
)
```

### Post-scriptum

On peut préciser un post-scriptum, sous forme de texte ou de contenu :

```typc
ps: [Au fait, j'ai pris la liberté de prendre rendez-vous pour nous deux samedi prochain.]
```

On peut également définir plusieurs post-scriptums en fournissant une liste. Ils apparaîtront sous le nom de « P.-S. », « P.-P.-S. », etc., donc n'en abusez pas :

```typc
ps: (
    "Au fait, …",
    "N'oubliez pas non plus que…",
)
```

Enfin, si vous souhaitez libeller différemment les post-scriptums, vous pouvez les fournir sous forme de dictionnaire :

```typc
ps: (
    "PS": "Au fait…",
    "PS2" : "N"oubliez pas non plus que…",
)
```

### Pièces jointes

Vous pouvez préciser les pièces jointes sous forme de contenu libre :

```typc
pj: [
	+ Dossier n°1
	+ Dossier n° 2
	+ Attestation
]
```

Vous pouvez également fournir une liste, auquel cas elles seront indiquées sous forme de liste verticale sans marqueur :

```typc
ps: ("Dossier n°1", "Dossier n°2", "Attestation")
```

### Affranchissement

Les services postaux de plusieurs pays proposent des services en ligne d'affranchissement à domicile. Il s'agit :

* soit de codes d'affranchissement à écrire sur l'enveloppe ;
* soit de timbres à imprimer.

Le premier cas est le plus facile à intégrer sur une enveloppe générée par formalettre, en précisant :

```typc
affranchissement: "<code d'affranchissement>",
```

Dans le second cas, les timbres à imprimer ne sont malheureusement pas fournis sous forme d'image individuelle, mais dans un document PDF à imprimer sur feuille A4, sur planche d'étiquette ou sur feuille A4. Pour l'intégrer à l'enveloppe générée par formalettre, vous devez alors en extraire une image correspondant au timbre seul, puis remplir ainsi les paramètres de formalettre :

```typc
affranchissement: image("timbre.png"),
```
