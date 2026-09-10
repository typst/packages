# vote-card

🇫🇷 [Lire en Français](#version-française) | 🇬🇧 [Read in English](#english-version)

---

## Version Française

Un package Typst permettant d'afficher des résultats de vote sous forme de carte, avec des barres de progression dynamiques et un support multi-langues.

### Utilisation

```typst
#import "@preview/vote-card:0.1.0": vote-card

// En français par défaut
#vote-card(numero: 1, pour: 45, contre: 30, abstention: 5, connexions: 82)

// Dans une autre langue (ex: anglais)
#vote-card(numero: 2, pour: 45, contre: 30, abstention: 5, connexions: 82, lang: "en")
```

### Paramètres

- `numero` (entier, texte ou `none`, optionnel) : Affiche "Vote n°X" en haut de la carte
- `pour` (entier) : Nombre de votes pour
- `contre` (entier) : Nombre de votes contre
- `abstention` (entier) : Nombre d'abstentions
- `connexions` (entier) : Nombre de connexions en direct
- `lang` (texte) : Langue d'affichage de la carte (`"fr"`, `"en"`, `"es"`, `"de"`). Par défaut `"fr"`

---

## English Version

A Typst package to display beautiful voting results as a card, featuring dynamic progress bars and multi-language support.

### Usage

```typst
#import "@preview/vote-card:0.1.0": vote-card

// Default (French)
#vote-card(numero: 1, pour: 45, contre: 30, abstention: 5, connexions: 82)

// In English
#vote-card(numero: 2, pour: 45, contre: 30, abstention: 5, connexions: 82, lang: "en")
```

### Parameters

- `numero` (integer, text, or `none`, optional): Displays "Vote #X" at the top of the card
- `pour` (integer): Number of "For" votes
- `contre` (integer): Number of "Against" votes
- `abstention` (integer): Number of abstentions
- `connexions` (integer): Number of live connections
- `lang` (text): Language of the card (`"fr"`, `"en"`, `"es"`, `"de"`). Default is `"fr"`
