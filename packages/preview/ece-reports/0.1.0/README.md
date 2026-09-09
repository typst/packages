<h1 align="center">🎓 ECE — Modèles de Rapport avec Typst</h1>

<p align="center">
  <a href="https://typst.app">
    <img alt="Typst" src="https://img.shields.io/badge/Typst-%232f90ba.svg?&logo=Typst&logoColor=white" />
  </a>
  <a href="LICENSE">
    <img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue.svg" />
  </a>
  <a href="#-avertissement--disclaimer">
    <img alt="Status: Unofficial" src="https://img.shields.io/badge/Status-Non%20Officiel-lightgrey.svg" />
  </a>
</p>

<p align="center">
  <img src="assets/preview-tp.png" width="46%" alt="Aperçu Rapport de TP" />
    
  <img src="assets/preview-projet.png" width="46%" alt="Aperçu Rapport de Projet" />
</p>

Modèles **Typst** pour la rédaction de **Rapports de Travaux Pratiques (`tp`)** et de **Rapports de Projet (`projet`)** à l'**ECE (École Centrale d'Électronique)**.

> [!NOTE]
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

## 📚 Documentation complète

La documentation détaillée est disponible dans le dossier [`docs/`](docs/) :

- [⚙️ **Référence des Paramètres de Configuration**](docs/parametres.md) : options communes, spécifiques `tp` et `projet`, styles de polices commutables (`font-presets`), auteurs structurés, mode filigrane `draft`.
- [🛠️ **Utilitaires & Composants d'Ingénierie**](docs/composants.md) : questions `#t()` / `#e()`, encarts `#callout`, tableaux BOM `#table-composants`, brochage `#table-brochage`, glossaires, figures intelligentes et gestionnaire d'annexes `#show: annexes`.
- [📂 **Exemples prêts à l'emploi**](examples/) : rapports complets en français et en anglais avec bibliographie BibTeX.

---

## ✨ Fonctionnalités clés

- ⚡ **Deux modèles académiques** : Rapport de TP (`tp`) et Rapport de Projet complet (`projet`).
- 🌍 **Bilingue natif (FR / EN)** : bascule transparente de tous les intitulés via `lang: "fr"` ou `lang: "en"`.
- 🎨 **Styles typographiques** : `latex` (Computer Modern), `typst-modern` (Libertinus), `modern-sans` (Helvetica/Arial) et `editorial` (Charter).
- 🏷️ **Suppléments de figures intelligents** : renvois automatiques *Figure*, *Tableau* (`@tab:...`) et *Code* (`@code:...`).
- 🔧 **Outils d'ingénierie intégrés** : encarts d'alerte, nomenclature BOM, brochage pinout, glossaires et mode filigrane brouillon.

---

## 🤝 Contributions

Les contributions, signalements de bugs et suggestions sont les bienvenus via [Issues](https://github.com/leonpwd/ece-reports/issues) ou [Pull Requests](https://github.com/leonpwd/ece-reports/pulls).

---

## 📄 Licence

- **Code source & gabarits** : sous licence [MIT](LICENSE).
- **Logos & identité visuelle** : propriété exclusive de l'ECE.
