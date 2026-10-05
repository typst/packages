# Publication sur Typst Universe

[Code source](https://github.com/summoningshells/risk-matrix) ·
[Première soumission : PR #6029](https://github.com/typst/packages/pull/6029)

## Préparer les fichiers

```sh
python3 scripts/package.py
```

Cette commande compile les exemples, vérifie les données invalides et teste le
modèle avec `typst init`. Elle produit :

- `dist/preview/risk-matrix/0.1.0/`, à copier dans le registre ;
- `dist/risk-matrix-0.1.0.tar.gz`, qui contient les mêmes fichiers.

Le script accepte `--typst /chemin/vers/typst`. Les rapports générés et les scripts
de développement restent hors de l'archive.

## Soumettre une version

1. Mettre à jour la version dans le manifeste, les imports et le changelog.
2. Exécuter `package.py`, puis vérifier le PDF et la vignette.
3. Copier le dossier préparé dans `packages/preview/risk-matrix/0.1.0/` d'un fork
   de `typst/packages` et ouvrir une PR intitulée `risk-matrix:0.1.0`.
4. Répondre à la revue. L'import public devient disponible après fusion et
   traitement par le registre.

Le nom descriptif `risk-matrix` et la licence MIT du modèle sont signalés dans
la PR pour revue. La licence MIT s'applique à tous les fichiers du projet.

## Règles du registre

- [Soumission](https://github.com/typst/packages/blob/main/docs/README.md)
- [Manifeste, noms et vignettes](https://github.com/typst/packages/blob/main/docs/manifest.md)
- [Licences des packages et modèles](https://github.com/typst/packages/blob/main/docs/licensing.md)

Règles consultées le 6 octobre 2026.
