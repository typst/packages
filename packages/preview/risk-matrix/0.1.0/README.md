# risk-matrix

Des matrices et des tableaux pour rédiger une analyse de risque EBIOS Risk Manager.
Le modèle fourni réunit les cinq ateliers dans un rapport en français.

Typst 0.15.0+ · Licence MIT · [Code source](https://github.com/summoningshells/risk-matrix)

![Aperçu du rapport](thumbnail.png)

## Une matrice

L'import suivant nécessite la publication sur Universe ou une installation locale
du package dans l'espace `preview`.

```typst
#import "@preview/risk-matrix:0.1.0": risk, risk-matrix, example-policy

#let risks = (
  risk("R1", "Interruption des commandes", 3, 3),
  risk("R2", "Divulgation de données", 4, 2),
)

#risk-matrix(risks, policy: example-policy)
```

La gravité augmente vers le haut, la vraisemblance vers la droite. Les échelles
et les couleurs sont configurables. Remplacez `example-policy` par les seuils
retenus pour votre étude ; sans `policy`, la matrice affiche les risques sans
leur attribuer de classe.

## Le rapport

`template/main.typ` contient le rapport et `template/data.typ` les données du
cas fictif « Atelier Boréal ». Pour démarrer une étude, adaptez ces données,
les critères de cotation et la politique de classement.

`risk-report` applique la mise en page avec une règle `show`. Les composants
peuvent aussi être utilisés séparément dans un document existant.

| Usage | Fonctions |
| --- | --- |
| Matrices et registre | `risk-matrix`, `risk-comparison`, `risk-register` |
| Cadrage | `scope-card`, `assets-table`, `events-table`, `baseline-table` |
| Sources de risque | `sources-table` |
| Écosystème et scénarios stratégiques | `stakeholders-table`, `strategic-table` |
| Scénarios opérationnels | `operational-table`, `attack-path` |
| Traitement | `treatment-table`, `coverage-table` |
| Mise en page | `risk-report`, `workshop`, `data-table` |
| Données | `risk`, `risk-level`, `validate-risks`, `validate-study`, `coverage` |

Les repères C et E distinguent les cibles (`target`) des risques résiduels évalués
(`assessed`). Une réévaluation exige une justification, une date et une référence
de preuve. Voir les [formats et exemples de l'API](docs/api.md).

## Essayer depuis les sources

Avec [Typst](https://github.com/typst/typst) et Python 3.11+ installés :

```sh
git clone https://github.com/summoningshells/risk-matrix.git
cd risk-matrix
python3 scripts/build.py
python3 scripts/check.py
```

`build.py` initialise le modèle avec `typst init` dans un dossier temporaire,
puis produit `output/pdf/ebios-demo.pdf` et la vignette. Les scripts acceptent
`--typst /chemin/vers/typst`.

## Références

Le package s'appuie sur le [guide EBIOS Risk Manager de l'ANSSI](https://messervices.cyber.gouv.fr/guides/la-methode-ebios-risk-manager-le-guide),
version 1.5, septembre 2024. C'est un projet indépendant, sans affiliation
ni labellisation ANSSI.

- [Conventions de cotation, limites et sources](docs/methodology.md)
- [Publication sur Universe](docs/publishing.md)
- [Licence MIT](LICENSE) et [attribution des sources](NOTICE)
