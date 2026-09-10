<h1 align="center">🎓 ECE — Modèles Typst Non Officiels</h1>

<p align="center">
  <a href="https://typst.app">
    <img alt="Typst logo" src="https://img.shields.io/badge/Typst-%232f90ba.svg?&logo=Typst&logoColor=white" />
  </a>
  <a href="LICENSE">
    <img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue.svg" />
  </a>
  <a href="#-avertissement">
    <img alt="Status: Unofficial" src="https://img.shields.io/badge/Status-Non%20Officiel-lightgrey.svg" />
  </a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/leonpwd/ece-reports/v0.1.0/assets/preview-tp.png" width="46%" alt="Aperçu Rapport de TP" />
    
  <img src="https://raw.githubusercontent.com/leonpwd/ece-reports/v0.1.0/assets/preview-projet.png" width="46%" alt="Aperçu Rapport de Projet" />
</p>

Modèles **Typst** pour la rédaction de **Rapports de Travaux Pratiques (`tp`)** et de **Rapports de Projet (`projet`)** à l'**ECE (École Centrale d'Électronique)**.

> **Avertissement** : Ce projet est un template **non officiel**, non affilié à l'administration de l'établissement.

---

## 🚀 Démarrage rapide

### Option A : Depuis Typst Universe

```bash
# Initialiser un nouveau rapport
typst init @preview/ece-reports mon-rapport
cd mon-rapport
typst watch main.typ
```

### Option B : Utilisation locale directe

```bash
git clone https://github.com/leonpwd/ece-reports.git
cd ece-reports

# Tester les exemples complets
typst watch examples/rapport-tp/rapport-tp-fr.typ
typst watch examples/rapport-projet/rapport-projet-fr.typ
```

---

## 📚 Documentation

La documentation détaillée est disponible sur le dépôt GitHub du projet :

- [⚙️ **Référence des Paramètres de Configuration**](https://github.com/leonpwd/ece-reports/blob/v0.1.0/docs/parametres.md) : options communes, spécifiques `tp` et `projet`, encadrant/tuteur (`supervisor`), styles de polices commutables (`font-presets`), auteurs structurés, mode filigrane `draft`.
- [🛠️ **Utilitaires & Composants d'Ingénierie**](https://github.com/leonpwd/ece-reports/blob/v0.1.0/docs/composants.md) : questions `#t()` / `#e()`, encarts `#callout`, tableaux au style ECE (`#table`, `#table-double-entree`), figures intelligentes et gestionnaire d'annexes `#show: annexes`.
- [📂 **Exemples prêts à l'emploi**](https://github.com/leonpwd/ece-reports/tree/v0.1.0/examples) : rapports en français et en anglais avec bibliographie BibTeX.

---

## Fonctionnalités clés

- **Deux modèles académiques** : Rapport de TP (`tp`) et Rapport de Projet complet (`projet`).
- **Styles typographiques** : `latex` (Computer Modern), `typst-modern` (Libertinus), `modern-sans` (Helvetica/Arial) et `editorial` (Charter).
- **Suppléments de figures intelligents** : renvois automatiques *Figure*, *Tableau* (`@tab:...`) et *Code* (`@code:...`).

---

## 🤝 Contributions

Les contributions, signalements de bugs et suggestions sont les bienvenus via [Issues](https://github.com/leonpwd/ece-reports/issues) ou [Pull Requests](https://github.com/leonpwd/ece-reports/pulls).

---

## 📄 Licence

- **Code source & gabarits** : sous licence [MIT](LICENSE).
- **Logos & identité visuelle** : propriété exclusive de l'ECE.
