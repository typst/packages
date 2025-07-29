# ENSEEIHT Internship Report Template

Un template Typst pour les rapports de stage de l'ENSEEIHT (École Nationale Supérieure d'Électrotechnique, d'Électronique, d'Informatique, d'Hydraulique et des Télécommunications).

## Fonctionnalités

- Page de couverture personnalisable avec logos école et entreprise
- Mise en forme automatique des titres et numérotation
- En-têtes et pieds de page avec logos
- Support pour auteurs multiples et tuteurs
- Bibliographie intégrée
- Style typographique adapté aux rapports académiques français

## Usage

```typst
#import "@preview/enseeiht-internship-report:0.1.0": cover

#show: doc => cover(
  title: [Titre du Rapport],
  subtitle: [Sous-titre optionnel],
  subject: [Description du sujet de stage],
  author: (
    name: "Nom Prénom",
    job: "Fonction/Poste",
    affiliation: "ENSEEIHT",
    email: "email@example.com",
    date: "Période de stage"
  ),
  tutors: (
    (
      name: "Tuteur École",
      affiliation: "ENSEEIHT",
      email: "tuteur.ecole@toulouse-inp.fr",
    ),
    (
      name: "Tuteur Entreprise", 
      affiliation: "Nom Entreprise",
      email: "tuteur.entreprise@example.com",
    ),
  ),
  abstract: [Résumé du rapport...],
  logo_company: "chemin/vers/logo_entreprise.png",
  logo_school: "chemin/vers/logo_enseeiht.png",
  doc,
)

= Introduction
Votre contenu ici...
```

## Paramètres

- `title`: Titre principal du rapport
- `subtitle`: Sous-titre (optionnel)
- `subject`: Description du sujet de stage
- `author`: Informations sur l'étudiant (nom, poste, affiliation, email, dates)
- `tutors`: Liste des tuteurs (école et entreprise)
- `abstract`: Résumé du rapport
- `logo_company`: Chemin vers le logo de l'entreprise
- `logo_school`: Chemin vers le logo de l'ENSEEIHT

## Structure recommandée

```
projet/
├── main.typ          # Fichier principal
├── assets/           # Dossier pour les images et logos
│   ├── logo_enseeiht.png
│   └── logo_entreprise.png
└── sources.yml       # Bibliographie (optionnel)
```

## Installation locale

Pour utiliser ce template localement :

1. Téléchargez les fichiers du template
2. Placez-les dans votre répertoire de packages Typst local :
   ```
   ~/.local/share/typst/packages/local/enseeiht-internship-report/0.1.0/
   ```
3. Importez avec : `#import "@local/enseeiht-internship-report:0.1.0": cover`

## Licence

MIT License - Libre d'utilisation et de modification.

## Contribution

Ce template est conçu spécifiquement pour l'ENSEEIHT. Les contributions pour améliorer la mise en forme ou ajouter des fonctionnalités sont les bienvenues.