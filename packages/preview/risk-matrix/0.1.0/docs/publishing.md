# Soumission à Typst Universe

Le code source est hébergé dans
[summoningshells/risk-matrix](https://github.com/summoningshells/risk-matrix).
Le nom du package Typst est `risk-matrix` ; son auteur est `summoningshells`.
Les scripts préparent et vérifient les fichiers, sans effectuer de publication.

## Vérification et dossier à soumettre

```sh
python3 scripts/build.py
python3 scripts/check.py
python3 scripts/package.py
```

La dernière commande exécute les vérifications, teste à nouveau le modèle et
produit `dist/preview/risk-matrix/0.1.0/` et une archive `.tar.gz` correspondante.
Le contenu de ce dossier est destiné à
`packages/preview/risk-matrix/0.1.0/` dans le dépôt `typst/packages`.
Les rapports générés, les données de travail et les scripts ne sont pas ajoutés
à l'archive. Seul le cas fictif fourni accompagne le modèle.

Le manifeste comprend les métadonnées du composant et une section `[template]`.
`template/main.typ` utilise l'import absolu `@preview/risk-matrix:0.1.0`.
Le script de build exécute réellement `typst init` dans un répertoire isolé
puis compile le document initialisé. La vignette provient de sa première page.

## Procédure distante

1. Publier la version dans le dépôt source. Son URL figure dans le champ
   `repository` de `typst.toml`.
2. Vérifier une dernière fois la disponibilité du nom et des PR concurrentes.
   Le nom `risk-matrix` est descriptif ; les règles du registre peuvent imposer
   un nom plus distinctif lors de la revue.
3. Forker `typst/packages`, y copier le dossier préparé dans l'emplacement
   indiqué, puis ouvrir une pull request avec le titre proposé ci-dessous.
4. Traiter les remarques des mainteneurs. L'import public devient disponible
   après fusion et traitement par l'infrastructure du registre.

Une présence dans Universe ne constitue pas une labellisation ANSSI.

## Texte de PR proposé

**Titre :** `risk-matrix:0.1.0`

> Add reusable components and a French report template for EBIOS Risk Manager
> assessments: configurable risk matrices, workshop tables, scenario references,
> coverage checks and treatment tracking. Targets and assessed residual risks are
> distinguished explicitly. Based on ANSSI's published guidance; independently
> developed and not affiliated with or labelled by ANSSI.
>
> Pure Typst with no package dependencies. Verified on Typst 0.15.1 through
> compilation checks, expected validation failures, an isolated `typst init`
> build, and visual inspection of the resulting PDF and thumbnail. MIT license;
> source attribution is included in NOTICE and the methodological documentation.

## Références du registre

- [Règles de soumission](https://github.com/typst/packages/blob/main/docs/README.md)
- [Manifeste, noms et vignettes](https://github.com/typst/packages/blob/main/docs/manifest.md)
- [Fonctionnement des packages locaux](https://github.com/typst/packages#local-packages)

Règles consultées le 6 octobre 2026. Le champ `compiler` correspond à la version
effectivement testée ; aucune compatibilité antérieure n'est revendiquée.
