// Entirely fictional teaching example. Replace these judgments and evidence.
#let study = (
  assets: (
    (id: "VM1", name: "Gestion des commandes", mission: "Livrer les clients dans les délais", owner: "Direction des opérations", supports: "Portail, annuaire, équipe logistique"),
    (id: "VM2", name: "Dossiers clients", mission: "Assurer le suivi contractuel", owner: "Direction commerciale", supports: "CRM, stockage documentaire, sauvegardes"),
  ),
  baseline: (
    (id: "B1", reference: "Politique interne : accès privilégiés", status: "Partiel", gap: "Accès prestataire sans second facteur", action: "M1 : revue des accès et authentification forte"),
    (id: "B2", reference: "Politique interne : reprise d'activité", status: "À vérifier", gap: "Restauration globale non testée", action: "M2 : exercice de restauration isolée"),
  ),
  events: (
    (id: "ER1", title: "Commandes indisponibles au-delà de deux jours", assets: ("VM1",), gravity: 3, impact: "Retards de livraison et perte de chiffre d'affaires", rationale: "Mode dégradé limité à deux jours, puis suspension des expéditions."),
    (id: "ER2", title: "Divulgation massive des dossiers clients", assets: ("VM2",), gravity: 3, impact: "Perte de confiance et exposition des clients", rationale: "Les dossiers contiennent des informations commerciales sensibles."),
    (id: "ER3", title: "Altération ponctuelle d'une commande", assets: ("VM1",), gravity: 2, impact: "Reprise manuelle et retard localisé", rationale: "La réconciliation permet une correction avant expédition."),
  ),
  sources: (
    (id: "SR1", source: "Groupe cybercriminel", objective: "Obtenir un paiement par extorsion", motivation: "Forte : gain financier", resources: "Outillage courant et accès achetés", relevance: "Forte pour le périmètre", retained: true, rationale: "La dépendance au portail rend l'interruption pénalisante."),
    (id: "SR2", source: "Concurrent déloyal", objective: "Récupérer le portefeuille clients", motivation: "Ciblée sur les données commerciales", resources: "Sous-traitance possible", relevance: "Plausible, à documenter", retained: true, rationale: "Le CRM concentre les contrats et les interlocuteurs."),
    (id: "SR3", source: "Activiste", objective: "Donner de la visibilité à une cause", motivation: "Non établie", resources: "Non caractérisées", relevance: "Faible dans cet exemple", retained: false, rationale: "Aucun contexte de ciblage identifié ; à revoir si le contexte change."),
  ),
  stakeholders: (
    (id: "PP1", name: "Prestataire de maintenance", exposure: "Forte : accès distant à l'administration", reliability: "Insuffisamment démontrée : contrôle d'accès partiel", danger: "Élevée, jugement d'atelier", retained: true, rationale: "Un compte tiers ouvre une voie vers les systèmes de production.", measures: ("M1",)),
    (id: "PP2", name: "Hébergeur du CRM", exposure: "Forte dépendance, accès contractuellement limité", reliability: "Documents de sécurité disponibles, vérification à poursuivre", danger: "Sous surveillance", retained: false, rationale: "Pas de chemin via cet acteur dans l'itération présente.", measures: ()),
  ),
  strategic: (
    (id: "SS1", title: "Extorsion par interruption des commandes", source: "SR1", events: ("ER1",), stakeholders: ("PP1",), path: ("Source criminelle", "Prestataire de maintenance", "Service de commandes indisponible"), gravity: 3),
    (id: "SS2", title: "Vol du portefeuille commercial", source: "SR2", events: ("ER2",), stakeholders: (), path: ("Concurrent", "Accès direct au SI", "Dossiers clients divulgués"), gravity: 3),
  ),
  operational: (
    (id: "SO1", title: "Détournement d'un accès de maintenance", strategic: "SS1", path: ("Accès tiers compromis", "Abus de privilèges", "Interruption du portail"), supports: "Passerelle distante, annuaire, portail", likelihood: 3, rationale: "Accès exposé et droits larges ; absence de second facteur dans l'hypothèse d'étude."),
    (id: "SO2", title: "Abus d'un compte commercial", strategic: "SS2", path: ("Compte compromis", "Consultation du CRM", "Extraction des dossiers"), supports: "Identité, CRM", likelihood: 2, rationale: "L'accès est filtré mais les exports sont insuffisamment surveillés."),
  ),
  risks: (
    (id: "R1", title: "Interruption des commandes par extorsion", gravity: 3, likelihood: 3, owner: "Direction des opérations", strategic: "SS1", operational: "SO1", feared-events: ("ER1",), decision: "Réduire. Cible à valider par le décideur après preuves.", residual: (gravity: 3, likelihood: 1, status: "target", rationale: "Effet attendu de M1 et M2 ; aucune baisse acquise à ce stade.")),
    (id: "R2", title: "Vol des dossiers clients", gravity: 3, likelihood: 2, owner: "Direction commerciale", strategic: "SS2", operational: "SO2", feared-events: ("ER2",), decision: "Surveiller. Acceptation formelle à instruire en comité.", residual: (gravity: 3, likelihood: 1, status: "assessed", rationale: "Réévaluation fictive après limitation et supervision des exports.", date: "2026-10-01", evidence: "PV-DEMO-03 : contrôle simulé des droits et alertes.")),
  ),
  measures: (
    (id: "M1", title: "Renforcer et limiter les accès tiers", risks: ("R1",), owner: "Responsable infrastructure", due: "2026-11-15", status: "Planifiée", priority: "P1", evidence: "Critère : tous les comptes de maintenance protégés et revus."),
    (id: "M2", title: "Tester la restauration du portail", risks: ("R1",), owner: "Responsable exploitation", due: "2026-12-01", status: "Planifiée", priority: "P1", evidence: "Critère : restauration sur environnement isolé en moins de deux jours."),
    (id: "M3", title: "Limiter les exports et vérifier les alertes CRM", risks: ("R2",), owner: "Responsable CRM", due: "2026-10-01", status: "Vérifiée dans la simulation", priority: "P2", evidence: "PV-DEMO-03, preuve fictive utilisée pour illustrer un résiduel évalué."),
  ),
)
