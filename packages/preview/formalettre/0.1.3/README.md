# Formalettre : writing french letters with typst



Un template destiné à écrire des lettres selon une typographie francophone, et inspiré du package LaTeX [lettre](https://ctan.org/pkg/lettre).

Pour utiliser le template, il est possible de recopier le fichier exemple.



## Documentation des variables



### Expéditeur 

- `expediteur.nom` : nom de famille de l'expéditeur·ice, **requis**.
- `expediteur.prenom` : prénom de l'expéditeur·ice, **requis**.
- `expediteur.voie` : numéro de voie et nom de la voie, **requis**.
- `expediteur.complement_adresse` : la seconde ligne parfois requise dans une adresse, *facultatif*.
- `expediteur.code_postal` : code postal, **requis**.
- `expediteur.commune` : commune de l'expéditeur·ice, **requis**.
-  `expediteur.telephone` : numéro de téléphone. Le format est libre et l'affichage en police mono. *Facultatif*.
-  `expediteur.email` : l'email fourni sera affiché en police mono et cliquable. *Facultatif*
- `expediteur.signature` : peut être `true` ou `false`, par défaut `false`. Prévient le paquet qu’une image de signature sera ajoutée, de manière à organiser la superposition de la signature et du nom apposé en fin de courrier.

## Destinataire

- `destinataire.titre` : titre du ou de la destinataire, **requis**.
- `destinataire.voie` : numéro de voie et nom de la voie, **requis**.
- `destinataire.complement_adresse` : la seconde ligne parfois requise dans une adresse, *facultatif*.
- `destinataire.code_postal` : code postal, **requis**.
- `destinataire.commune` : commune de l'expéditeur·ice, **requis**.
- `destinataire.sc` : si le courrier est envoyé “sous couvert” d'une hiérarchie intermédiaire, spécifier cette autorité. *Facultatif*.

## Lettre

- `objet` : l'objet du courrier, **requis**.
- `date` : date à indiquer sous forme libre, **requis**.
- `lieu` : lieu de rédaction, **requis**.
- `pj` : permet d'indiquer la présence de pièces jointes.  Il est possible d'en faire une liste, par exemple :

```
pj: [
	+ Dossier n°1
	+ Dossier n° 2
	+ Attestation
	]
```

Le texte de la lettre proprement dite se situe après la configuration de la lettre.

À la fin de la lettre, il est possible de décommenter les deux dernières lignes pour ajouter une image en guise de signature. Veillez dans ce cas à positionner la varibale `expediteur.signature` à `true`.



