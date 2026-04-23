# Changelog

Tous les changements importants du projet sont documentés dans ce fichier.

## [2.0.0] - 2026-04-20

### ✨ Nouvelles fonctionnalités

- **Support jusqu'à 5 auteurs** - Système dynamique avec boucles (auparavant 3)
- **Support jusqu'à 3 professeurs** - Affichage automatique sur la page de garde
- **Équations numérotées** - Configuration `afficher-numéros-équations`
- **Graphiques lilaq** - Support complet des diagrammes scientifiques
- **Boîte TODO** - Nouvelle boîte utilitaire pour listes à faire
- **Fichier example.typ indépendant** - Rapport complet autonome démontrant toutes les fonctionnalités
- **Photographies avec légende** - Fonction `#photo()` améliorée
- **Documentation complète** - README.md professionnel et détaillé

### 🔧 Améliorations

- **Refactorisation du layout**:
  - `1-layout.typ` : Mise en page uniquement
  - `2-layout.typ` : Contenu final (bibliographie, figures, annexes, glossaire)
  - `cover-page-layout.typ` : Page de garde améliorée
  - `signature.typ` : Signatures dynamiques pour N auteurs

- **Simplification de la configuration**
  - Toutes les variables centralisées dans `settings/name.typ`
  - Suppression des variables dérivées intermédiaires
  - Utilisation directe des variables de configuration

- **Amélioration des boîtes utilitaires**
  - Couleurs optimisées
  - Icônes emoji intégrés
  - Mise en forme cohérente

- **Code source**
  - Affichage numéroté automatique
  - Support multilingue (Python, C++, VHDL, etc.)
  - Extraction de portions de fichier

### 🐛 Corrections

- Correction du placement de la numérotation des équations
- Correction des imports manquants dans example.typ
- Correction de la fonction `#photo()` utilisant config.logo

### 📚 Documentation

- README.md complètement réécrit
- CHANGELOG.md créé (ce fichier)
- Exemple.typ enrichi avec toutes les fonctionnalités
- Commentaires ajoutés dans tous les fichiers layout

### ⚠️ Breaking Changes

- Variable `config.professeur` → structure `professeurs[]`
- Variables dérivées supprimées (utiliser `config.*` directement)
- Changement du paramètre `size` → `size-image`

---

## [1.0.0] - 2026-04-01

### Caractéristiques initiales

- ✅ Page de garde personnalisable
- ✅ Mise en page automatisée
- ✅ Boîtes utilitaires (info, danger, validation, erreur, idée)
- ✅ Support 3 auteurs avec signatures
- ✅ Glossaire automatique
- ✅ Tableaux professionnels
- ✅ Code source numéroté
- ✅ Bibliographie intégrée
- ✅ Annexes PDF
- ✅ Configuration centralisée

---

## Format des versions

Les versions suivent le format [Semantic Versioning](https://semver.org/).

- **MAJOR** : Changements incompatibles (breaking changes)
- **MINOR** : Nouvelles fonctionnalités (compatibles)
- **PATCH** : Corrections de bugs

---

## Prochaines améliorations prévues

- [ ] Support des appendices (figures, tables)
- [ ] Thème sombre optionnel
- [ ] Exporte direct vers PDF avec métadonnées
- [ ] Templates pour différentes filières
- [ ] Support multilingue complet (EN, DE)
- [ ] Intégration GitHub Pages
