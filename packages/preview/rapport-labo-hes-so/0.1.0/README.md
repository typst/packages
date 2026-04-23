# 📋 Modèle de Rapport HES-SO avec Typst

Un template professionnel et complet pour créer des rapports de laboratoire avec **Typst**, optimisé pour HES-SO.

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Typst](https://img.shields.io/badge/Typst-compatible-purple.svg)

---

## ✨ Caractéristiques principales

### 📄 Mise en page professionnelle
- ✅ Page de garde personnalisable
- ✅ En-têtes et pieds de page automatiques
- ✅ Numérotation intelligente des pages
- ✅ Table des matières automatique

### 📊 Contenu riche et flexible
- ✅ Tableaux avec mise en forme automatique
- ✅ Équations numérotées et référençables
- ✅ Code source numéroté avec coloration
- ✅ Glossaire avec acronymes
- ✅ Figures et images intégrées

### 👥 Support multi-auteurs et professeurs
- ✅ Jusqu'à **5 auteurs** configurables
- ✅ Jusqu'à **3 professeurs** configurables
- ✅ Signatures automatiques

### 🎨 Boîtes utilitaires
- 📘 Boîte information
- ⚠️ Boîte attention/danger
- ✅ Boîte validation
- 🔥 Boîte erreur
- 💡 Boîte idée
- 📝 Boîte TODO

---

## 🚀 Démarrage rapide

### 1. Structure du projet
```
.

├── lib.typ                     ← Exports des fonctions
├── typst.toml                  ← Configuration Typst
│
├── template/
|       ├── main.typ                    ← Votre rapport (à remplir)
|       ├── TEMPLATE_STARTER.typ        ← Exemples de toutes les fonctionnalités
|       ├──src/
│       |   ├── settings/
│       |   ├── name.typ            ← ⚙️ SEUL FICHIER À MODIFIER !
│       |   ├── glossaire.typ       ← Définitions des acronymes
│       |   └── refs.bib            ← Références bibliographiques



|       └── assets/
|         │   ├── picture/                ← Vos images et log
|         │    ├── code/                   ← Fichiers code à importe|         │     └── PDF/                    ← Annexes PDF
│
├──layout/
│       ├── 1-layout.typ        ← Mise en page
│       ├── 2-layout.typ        ← Contenu final
│       ├── cover-page-layout.typ
│       ├── signature.typ
│       └── box-layout.typ      ← Boîtes utilitaires
└── docs/                       ← Documentation
```

### 2. Configuration (⚠️ IMPORTANT)

**Modifiez UNIQUEMENT le fichier `src/settings/name.typ`**

Tous les paramètres sont centralisés là :

```typst
#let config = (
  cours: "Électrotechnique",
  titre: "Labo 4",
  sous-titre: "Votre sous-titre",
  filiere: "Votre filière",
  date: datetime.today().display("19/04/2026"),
  afficher-glossaire: true,
  afficher-annexes: false,
  afficher-bibliographie: false,
  afficher-numéros-équations: true,
)
```

### 3. Ajouter du contenu

Modifiez `main.typ` pour ajouter vos chapitres et contenu.

Consultez `TEMPLATE_STARTER.typ` pour voir tous les exemples disponibles.

---

## 📝 Utilisation

### Boîtes utilitaires
```typst
#info-box[Votre texte d'information]
#danger-box[Attention !]
#valid-box[✅ Succès]
#feu-box[🔥 Erreur]
#idea-box[💡 Idée]
#todo-box[- Tâche 1\n- Tâche 2]
```

### Équations numérotées
```typst
$ x = 2 + 2 $ <eq:exemple>

Voir l'équation @eq:exemple pour plus de détails.
```

### Tableaux
```typst
#figure(
  table(
    columns: (auto, 1fr),
    [*Colonne 1*], [*Colonne 2*],
    [Ligne 1], [Données],
  ),
  caption: [Titre du tableau],
)
```

### Code source
```typst
#figure(
  mon_code(
    ```python
    print("Hello World")
    ```,
  ),
  caption: [Exemple Python],
)
```

### Glossaire
```typst
Le @rust est un langage moderne.
```

(Les termes doivent être définis dans `src/settings/glossaire.typ`)

---

## 🎓 Supports Typst

Pour approfondir votre connaissance de Typst, consultez :
- [Documentation Typst](https://typst.app/docs)
- [Typst Community Forum](https://typst.app/community)

---

## 📄 License

MIT - Libre d'utilisation et de modification

---

## ✍️ Auteur

Template créé pour HES-SO
