//        ___ ____   ____      _   _ _____ ___
//       |_ _/ ___| / ___|    | | | | ____|_ _|     Informatique et
//        | |\___ \| |   ___  | |_| |  _|  | |       systèmes de communication
//        | | ___) | |__|___| |  _  | |___ | |       HEI Sion · HES-SO Valais / mui 24-26
//       |___|____/ \____|    |_| |_|_____|___|
//
//   52 65 61 64 69 6e 67 20 68 65 78 20 66 6f 72 20 66 75 6e 3f 20 49 53 43 20 66 6f 72 65 76 65 72
// 

#import "@preview/isc-hei-poster:0.8.1": isc-poster, isc-card, isc-colbreak
#import "@preview/cetz:0.5.2": canvas, draw

// Choose orientation: "portrait" or "landscape"
#let poster-orientation = "portrait"

#show: isc-poster.with(
  title: [Apprentissage fédéré et vie privée],
  subtitle: [Confidentialité différentielle et agrégation distribuée des gradients],
  student: "Margaret Hamilton",
  permanent-email: "margaret.hamilton@hevs.ch",
  supervisor: "Prof. Dr John von Neumann",
  co-supervisor: "Lady Ada Lovelace",  // optional, use none if not needed
  expert: "Prof. Dr Grace Hopper", // optional, use none if not needed
  thesis-id: "ISC-ID-26-1",
  academic-year: "2025-2026",
  school: "Haute École d'Ingénierie de Sion",
  programme: "Informatique et systèmes de communication",
  major: "Data engineering", // One of: Software engineering, Embedded systems, Computer security, Networks and systems, Data engineering
  orientation: poster-orientation,
  language: "fr", // Valid values are [en, fr, de]
  num-columns: 2,
  distribute-columns: true,  // evenly distributes cards vertically; set false to disable
)

// ─── Column 1 ────────────────────────────────────────────────────────────────

#isc-card(title: "Résumé")[
  Les dossiers de santé électroniques ne peuvent être centralisés sans risque juridique et éthique. Ce travail présente *MediFL*, un cadre d'apprentissage fédéré intégrant la
  confidentialité différentielle (ε-DP) et une agrégation robuste aux nœuds défaillants. Évalué sur trois cohortes hospitalières totalisant 180 000 patients, MediFL atteint une AUC de *0.91* avec un budget de confidentialité ε = 0.5, à seulement trois points de l'oracle centralisé (AUC 0.94). La convergence est assurée en *60 rounds* de communication, sans qu'aucune donnée brute ne quitte les établissements participants.
]

#isc-card(title: "Introduction")[
  L'accès partagé aux dossiers médicaux électroniques permettrait d'entraîner des modèles prédictifs plus robustes et de détecter des pathologies rares. Cependant, la réglementation (RGPD, LPD suisse) et les impératifs éthiques empêchent la transmission de données brutes entre établissements. L'apprentissage fédéré déplace le calcul vers les données plutôt que l'inverse : seuls des gradients de modèle sont échangés, jamais les dossiers patients.

  *Verrou scientifique :* comment garantir une confidentialité formelle (ε-DP) tout en préservant la convergence du modèle global face à l'hétérogénéité statistique des   cohortes — chaque hôpital ayant ses propres pratiques de codage et démographies ?

  #figure(
    rect(width: 100%, height: 7cm, fill: luma(235), stroke: none,
      align(center + horizon)[_Architecture MediFL — des hôpitaux au modèle global_]),
    caption: [Vue d'ensemble de MediFL : chaque établissement entraîne localement et transmet des gradients bruités au serveur agrégateur.],
  )
]

#isc-card(title: "Méthodologie")[
  Le protocole MediFL se déroule en trois phases par round :

  + *Distribution* — le serveur envoie les poids globaux $theta_t$ aux $K$ participants sélectionnés aléatoirement.
  + *Entraînement local + clipping* — chaque hôpital minimise la cross-entropie sur ses données puis clippe les gradients à norme $≤ C$.
  + *Agrégation DP-FedAvg* — le serveur somme les gradients bruités et met à jour $theta_{t+1}$.

  #table(
    columns: (1fr, auto, auto, auto),
    inset: 7pt,
    align: (left, center, center, center),
    table.header([*Méthode*], [*AUC*], [*Rounds*], [*ε*]),
    [FedAvg (baseline)],   [0.84], [50],   [∞],
    [FedAvg + DP],         [0.82], [80],   [1.0],
    [*MediFL (hybride)*],  [*0.91*], [*60*], [*0.5*],
    [Oracle centralisé],   [0.94], [—],    [∞],
  )

  Concrètement, le code correspond à une agrégation DP-FedAvg classique:  
  #figure(
    ```python
    def dp_fedavg(grads, sizes, eps=0.5, C=1.0):
        clipped = [clip(g, norm=C) for g in grads]
        sigma   = C * calibrate_sigma(eps, delta=1e-5)
        noisy   = [g + randn(sigma) for g in clipped]
        w       = [n / sum(sizes) for n in sizes]
        return sum(wi * gi for wi, gi in zip(w, noisy))
    ```,
        caption: [Agrégation DP-FedAvg — clipping + bruit gaussien calibré sur ε.],  
    )
]

// ─── Column 2 ────────────────────────────────────────────────────────────────

#isc-colbreak()


// ─── Dodecahedron figure (reused from exec-summary) ──────────────────────────
#let ex_fig = canvas(length: 2cm, {
  import draw: *
  let phi = (1 + calc.sqrt(5)) / 2
  ortho(flatten: true, {
    hide({
      line((-phi, -1, 0), (-phi, 1, 0), (phi, 1, 0), (phi, -1, 0), close: true, name: "xy")
      line((-1, 0, -phi), (1, 0, -phi), (1, 0, phi), (-1, 0, phi), close: true, name: "xz")
      line((0, -phi, -1), (0, -phi, 1), (0, phi, 1), (0, phi, -1), close: true, name: "yz")
    })
    intersections("a", "yz", "xy")
    intersections("b", "xz", "yz")
    intersections("c", "xy", "xz")
    set-style(stroke: (thickness: 0.5pt, cap: "round", join: "round"))
    line((0, 0, 0), "c.1", (phi, 1, 0), (phi, -1, 0), "c.3")
    line("c.0", (-phi, 1, 0), "a.2")
    line((0, 0, 0), "b.1", (1, 0, phi), (-1, 0, phi), "b.3")
    line("b.0", (1, 0, -phi), "c.2")
    line((0, 0, 0), "a.1", (0, phi, 1), (0, phi, -1), "a.3")
    line("a.0", (0, -phi, 1), "b.2")
    anchor("A", (0, phi, 1))
    content("A", [$A$], anchor: "north", padding: .1)
    anchor("B", (-1, 0, phi))
    content("B", [$B$], anchor: "south", padding: .1)
    anchor("C", (1, 0, phi))
    content("C", [$C$], anchor: "south", padding: .1)
    line("A", "B", stroke: (dash: "dashed"))
    line("A", "C", stroke: (dash: "dashed"))
  })
})

#isc-card(title: "Résultats")[
  Évaluation sur les cohortes des HUG (Genève), du CHUV (Lausanne) et de l'Inselspital (Berne), ainsi que sur le jeu de données public MIMIC-IV (53 000 séjours UCI). La
  convergence est atteinte en 60 rounds, contre 80 pour FedAvg+DP classique.

  #figure(
    grid(
      columns: (1fr, 1fr),
      gutter: 8pt,
      align(center + horizon, ex_fig),
      image("figs/made.svg", height: 7cm, fit: "contain"),
    ),
    caption: [Graphe de connectivité inter-sites (gauche) et courbes de convergence AUC par méthode (droite). MediFL converge plus vite malgré le bruit différentiel.],
  )

  Le budget de confidentialité ε = 0.5 est maintenu grâce à la composition RDP (*Rényi Differential Privacy*). L'écart résiduel avec l'oracle centralisé (3 points AUC)   s'explique principalement par l'hétérogénéité des distributions inter-sites (Non-IID). Sur les cohortes de plus de 10 000 patients, l'AUC monte à *0.93*.
]

#isc-card(title: "Discussion")[
  *Forces :* MediFL ne nécessite aucun transfert de données brutes entre établissements. La confidentialité est prouvable formellement (ε = 0.5, δ = 10⁻⁵). L'architecture
  tolère jusqu'à 30 % de participants défaillants par round grâce à l'agrégation pondérée par taille de cohorte.

  *Limites :* l'ajout de bruit gaussien dégrade la convergence sur les cohortes de petite taille (\< 2 000 patients). L'optimisation conjointe du budget ε et du taux de
  participation par round reste un problème ouvert. La communication reste un goulot d'étranglement pour des réseaux hospitaliers à faible bande passante.

  *Perspective :* extension à la confidentialité locale (LDP) pour des scénarios sans serveur central de confiance, et intégration de techniques de compression de gradients
  (Top-k sparsification) pour réduire la charge réseau.
]

#isc-card(title: "Conclusion")[
  MediFL démontre qu'il est possible d'approcher la précision d'un modèle centralisé (AUC 0.91 vs 0.94) tout en offrant des garanties formelles de confidentialité
  différentielle (ε = 0.5). Le cadre est générique : il s'applique à toute tâche de classification médicale distribuée sans modification architecturale majeure. Le code
  source est publié en open source sous licence Apache 2.0.
]

#isc-card(title: "Références")[
  + B. McMahan et al., _Communication-Efficient Learning of Deep Networks_, AISTATS 2017.
  + M. Abadi et al., _Deep Learning with Differential Privacy_, CCS 2016.
  + T. Li et al., _Federated Learning: Challenges, Methods, and Future Directions_, IEEE Signal Processing Magazine, 2020.
  + I. Mironov, _Rényi Differential Privacy of the Gaussian Mechanism_, CSF 2017.
]
