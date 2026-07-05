# ✉️ Simple-Preavis

**simple-preavis** est un template typst pour écrire une lettre de préavis d'état des lieux à son propriétaire.

Il est fortement inspiré de cet [outil](https://www.service-public.fr/simulateur/calcul/CongeLogement) réalisés par les services publics 🙏.

## Utilisation
### Exemple d'utilisation

```typst
#import "@preview/simple-preavis:0.1.0":*
#lettre-preavis(
  locataire: locataire(
     "Dupont locataire",
     "Jean",
     adresse(
       "123 rue de la Paix",
       "75000",
       "Paris",
       complement: "Appartement 2"
    )
  ),
  proprietaire: proprietaire(
     "Martin proprietaire",
    "Sophie",
     adresse(
       "456 avenue des Champs-Élysées",
       "75008",
       "Paris"
    ),
    "Madame"
  ),
  date-etat-des-lieux: datetime(year:2024, month:9, day:21)
)
```
## TODO
- [ ] Supporter plusieurs locataires
- [ ] Supporter la législation zone tendu en fonction du code postal
- [ ] Améliorer la documentation des fonctions
- [ ] Séparer en une librairie et un template pour que cela ressemble plus aux autres template types

## Mention license

Conformément à la license [etalab](https://github.com/etalab/licence-ouverte/blob/master/LO.md)
- Condérant : Direction de l'information légale et administrative (Premier ministre)
- Date de mise à jour : Vérifié le 23 Avril 2024

## License
[license MIT](LICENSE)