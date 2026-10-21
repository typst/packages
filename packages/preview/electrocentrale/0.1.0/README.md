<h1 align="center"> electrocentrale — Modèles Typst</h1>

<p align="center">
  <a href="https://typst.app">
    <img alt="Typst logo" src="https://img.shields.io/badge/Typst-%232f90ba.svg?&logo=Typst&logoColor=white" />
  </a>
  <a href="LICENSE">
    <img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue.svg" />
  </a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/ece-elec/Electrocentrale/623b9e400a70dbf3d01a6814538e607f82b44570/assets/preview-tp.png" width="23.5%" alt="Aperçu Rapport de TP" />
   
  <img src="https://raw.githubusercontent.com/ece-elec/Electrocentrale/623b9e400a70dbf3d01a6814538e607f82b44570/assets/preview-projet.png" width="23.5%" alt="Aperçu Rapport de Projet" />
   
  <img src="https://raw.githubusercontent.com/ece-elec/Electrocentrale/623b9e400a70dbf3d01a6814538e607f82b44570/assets/preview-conception.png" width="23.5%" alt="Aperçu Document de Conception" />
   
  <img src="https://raw.githubusercontent.com/ece-elec/Electrocentrale/623b9e400a70dbf3d01a6814538e607f82b44570/assets/preview-stage.png" width="23.5%" alt="Aperçu Rapport de Stage" />
</p>

**electrocentrale** propose des modèles **Typst** pour la rédaction de **Rapports de Travaux Pratiques (`tp`)**, **Rapports de Projet (`projet`)**, **Documents de Conception (`conception`)** et **Rapports de Stage (`stage`)** à l'**ECE (École Centrale d'Électronique)**.

---

## Démarrage rapide

### Option A : Depuis Typst Universe

```bash
# Initialiser un nouveau rapport
typst init @preview/electrocentrale mon-rapport
cd mon-rapport
typst watch main.typ
```

### Option B : Utilisation locale directe

```bash
git clone https://github.com/ece-elec/Electrocentrale.git
cd Electrocentrale

# Tester les exemples complets
typst watch examples/rapport-tp/rapport-tp.typ
typst watch examples/rapport-projet/rapport-projet.typ
typst watch examples/document-conception/document-conception.typ
typst watch examples/rapport-stage/rapport-stage.typ
```

---

## Documentation

La documentation complète est disponible sur le dépôt GitHub du projet :

- [**Tutoriel pas à pas**](https://github.com/ece-elec/Electrocentrale/blob/623b9e400a70dbf3d01a6814538e607f82b44570/docs/tutoriel.md) : installation de Typst, configuration de VS Code (Tinymist) et rédaction d'un premier rapport.
- [**Paramètres de configuration**](https://github.com/ece-elec/Electrocentrale/blob/623b9e400a70dbf3d01a6814538e607f82b44570/docs/parametres.md) : référence complète des options (`tp`, `projet`, `conception`, `stage`), tuteurs et styles de polices.
- [**Composants d'ingénierie**](https://github.com/ece-elec/Electrocentrale/blob/623b9e400a70dbf3d01a6814538e607f82b44570/docs/composants.md) : organigrammes, chaînes de blocs, algorigrammes ISO, diagrammes UML, Gantt, tables BDD et encarts.
- [**Exemples complets**](https://github.com/ece-elec/Electrocentrale/tree/623b9e400a70dbf3d01a6814538e607f82b44570/examples) : rapports et galeries de diagrammes prêts à compiler.

---

## Contributions

Les contributions, signalements de bugs et suggestions sont les bienvenus via [Issues](https://github.com/ece-elec/Electrocentrale/issues) ou [Pull Requests](https://github.com/ece-elec/Electrocentrale/pulls).

---

## Licence

- **Code source & gabarits** : sous licence [MIT](LICENSE).
- **Logos & identité visuelle** : propriété exclusive de l'ECE.
