# Méthodologie, périmètre et sources

## Référence principale

[ANSSI, EBIOS Risk Manager, guide v1.5, septembre 2024, ANSSI-PA-048](https://messervices.cyber.gouv.fr/documents-guides/250129_np_anssi_guide_ebios_fr_final_collection_WEB.pdf),
disponible sur la [page des ressources EBIOS RM](https://messervices.cyber.gouv.fr/guides/la-methode-ebios-risk-manager-le-guide).
Les numéros ci-dessous désignent les pages imprimées du guide, et non les index PDF.

| Partie du package | Référence | Transposition |
| --- | --- | --- |
| Chaîne ER → SR/OV → SS → SO → risque | pp. 8-10 | Identifiants et validation des liens |
| Cadrage, métier et socle | pp. 17-31 | Fiche de cadrage, valeurs, supports, écarts et événements |
| Gravité | p. 26 | Libellés de quatre niveaux ; critères à définir par étude |
| Sources et objectifs | pp. 33-39 | Paires documentées avec justification de la sélection |
| Écosystème et stratégie | pp. 41-55 | Parties prenantes, chemins métier et mesures associées |
| Scénarios techniques | pp. 57-68 | Chemins et jugement de vraisemblance justifié |
| Vraisemblance | p. 66 | Libellés de quatre niveaux, sans conversion en fréquence |
| Traitement et revue | pp. 69-81 | Registre, mesures, cibles, résiduels et décisions |
| Contrôle de couverture | p. 73 | ER sans risque lié signalés comme restant à instruire |

## Fiches complémentaires

Consultées le 5 octobre 2026.

- [Gravité des événements redoutés, atelier 1](https://messervices.cyber.gouv.fr/documents-guides/Fiche_methode-Evaluer_la_gravite_des_evenements_redoute-atelier_1.pdf) : construction d'une échelle adaptée aux impacts métier.
- [Sources de risque, atelier 2](https://messervices.cyber.gouv.fr/documents-guides/Fiche_methode-Identifier_et_caracteriser_les_sources_de_risque-atelier_2.pdf) : contexte, profils et sélection des couples ; aucune taxonomie figée dans le code.
- [Dangerosité des parties prenantes, atelier 3](https://messervices.cyber.gouv.fr/documents-guides/Fiche_methode-Construire_lestimation_de_la_dangerosite_des_parties_prenantes_de_l_ecosysteme-atelier_3.pdf) : éléments de relation et de confiance cyber ; le package restitue les appréciations de l'atelier.
- [Vraisemblance des scénarios, atelier 4](https://messervices.cyber.gouv.fr/documents-guides/Fiche_methode-Evaluer_la_vraisemblance_des_scenarios_operationnels-atelier_4.pdf) : la version 0.1.0 accepte une cotation globale saisie et justifiée, sans calcul des méthodes standard ou avancée.
- [Mesures de traitement, atelier 5](https://messervices.cyber.gouv.fr/documents-guides/Fiche_methode-Structurer_les_mesures_de_traitement_du_risque-atelier_5.pdf) : propriétaire, échéance et critère de vérification dans le plan ; les coûts et la complexité peuvent être ajoutés avec `data-table`.

## Choix propres au package

1. La politique colorée est facultative. `example-policy` sert uniquement à
   démontrer le rendu ; elle n'est ni un barème officiel ni une recommandation
   d'acceptation. Les indices G et V sont traités séparément.
2. Les matrices acceptent des échelles personnalisées. Pour un usage EBIOS RM,
   établir avec les participants des niveaux cohérents et des critères explicites.
3. Le statut d'une mesure ne recalcule jamais un risque. Une cible peut être
   proposée ; un résiduel évalué demande une justification, une date et une preuve.
   L'existence des preuves n'est pas contrôlée par le compilateur.
4. Le validateur de l'étude utilise une convention explicite : gravité du SS
   égale au maximum des ER liés, puis héritage par le risque. Ce choix de structure
   n'est pas une règle universelle de calcul attribuée à l'ANSSI. Décomposer les
   scénarios si les chemins ont des conséquences différentes.
5. Les décisions d'acceptation et les appréciations de dangerosité sont des
   données de l'analyste. Le package ne les infère pas d'une couleur.

## Limites de la version 0.1.0

Pas de calcul automatique de menace, de graphe ET/OU, d'agrégation de probabilités,
d'inventaire de conformité réglementaire ni de moteur d'acceptation.
Les biens supports sont des descriptions libres. La couverture signale les ER
non reliés à des risques, mais ne prouve pas l'exhaustivité de l'analyse.
Le validateur contrôle la structure des données ; les hypothèses, les preuves
et l'exhaustivité de l'étude restent à examiner en atelier.

Le guide est crédité sous sa Licence Ouverte Etalab V1. Les libellés usuels sont
repris pour assurer la cohérence du vocabulaire ; les explications et exemples
sont rédigés pour ce projet. Aucun guide PDF, illustration ou logo ANSSI n'est
redistribué dans le package. Voir `NOTICE`.
