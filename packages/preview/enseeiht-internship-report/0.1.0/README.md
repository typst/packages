# ENSEEIHT Internship Report Template

Unofficial Typst Internship Report Template for ENSEEIHT
An unofficial Typst template designed for internship reports at ENSEEIHT (École Nationale Supérieure d'Électrotechnique, d'Électronique, d'Informatique, d'Hydraulique et des Télécommunications).
Features:

- Customizable cover page with school and company logos
- Automatic title formatting and numbering
- Headers and footers with integrated logos
- Support for multiple authors and supervisors
- Built-in bibliography management
- Typography optimized for French academic reports

This community-created template streamlines the creation of professional internship reports while following typical ENSEEIHT formatting conventions.


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
  logo-company: "chemin/vers/logo_entreprise.png",
  logo-school: "chemin/vers/logo_enseeiht.png",
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
- `logo-company`: Chemin vers le logo de l'entreprise
- `logo-school`: Chemin vers le logo de l'ENSEEIHT

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