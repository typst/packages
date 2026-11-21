#let resolve-plural(v, n) = {
  if type(v) != dictionary { return v }
  if v.len() == 0 { return none }
  let num = if type(n) == decimal or type(n) == int or type(n) == float {
    float(n)
  } else if type(n) == str {
    float(n)
  } else {
    1.0
  }
  let fallback = v.pairs().first(default: (none, none)).last()
  if num >= 0 and num < 2 {
    v.at("singular", default: fallback)
  } else {
    v.at("plural", default: fallback)
  }
}

/// French language overrides.
#let fr = (
  meta: (
    /// The ISO 639-1 language code of the file.
    lang: "fr",
    resolve-plural: resolve-plural,
  ),

  /// Designations for document types
  document: (
    invoice: "Facture",
    credit-note: "Avoir",
    corrected: "Facture rectificative",
    prepayment: "Facture d'acompte",
    // Mention required on a self-billed invoice (art. 242 nonies A CGI).
    self-billed: "Autofacturation",
    page: (current, total) => [Page #current sur #total],
    continued-on: page => [Suite à la page #page],
  ),

  /// Address-related designations
  address: (
    recipient: "Destinataire",
    sender: "Expéditeur·rice",
  ),

  sections: (
    details: "Détails de la facture",
    payment: "Paiement",
    bank-details: "Coordonnées bancaires",
    how-to-pay: "Modalités de paiement",
  ),

  /// Designations for reference numbers and metadata
  reference: (
    tax-number: "Numéro fiscal",
    invoice-number: "N° de facture",
    vat-id: "N° de TVA intra.",
    invoice-date: "Date de facturation",
    service-time: "Période de prestation",
    customer-number: "N° client·e",
    buyer-reference: "Référence client·e",
    recipient-vat-id: "N° TVA client·e",
    recipient-tax-number: "N° fiscal client·e",
    order-number: "N° de commande",
    order-date: "Date de commande",
    project: "Projet",
    contract-number: "N° de contrat",
    quote-number: "N° de devis",
    delivery-note-number: "N° de bon de livraison",
    delivery-address: "Adresse de livraison",
    preceding-invoice-number: "N° facture rectifiée",
    preceding-invoice-date: "Date de la facture rectifiée",
    due-date: "Date d'échéance",
    payment-reference: "Référence de paiement",
    contact-person: "Personne de contact",
    contact-phone: "Téléphone",
    contact-email: "E-mail",
    payee: "Bénéficiaire du paiement",
  ),

  /// Column headers and labels for the line-items table
  line-items: (
    position: "Pos.",
    item-id: "Réf.",
    unit: "Unité",
    description: "Désignation",
    quantity: "Qté",
    unit-price: "Prix unitaire",
    price: "Prix",
    total: "Total",
    vat: "TVA",
    net: "HT",
    gross: "TTC",
    discount: "Remise",
    surcharge: "Supplément",
    subtotal: "Sous-total",
    prepayment: "Acompte",
    conjunction: "et",
    origin: "Pays d'origine",
  ),

  /// Labels for the summary section (footer of the table)
  summary: (
    sum: "Sous-total",
    vat-tax: "TVA",
    total: "Total TTC",
    including: "incl.",
    excluding: "hors",
    prepayment: "Acompte",
    amount-due: "Net à payer",
  ),

  /// Global informational sentences
  global-info: (
    tax-statement: (
      tax-text,
      rate,
      vat-tax,
    ) => [Tous les articles sont #tax-text #rate #vat-tax.],
    unit: "Unité pour tous les articles :",
    quantity: "Quantité pour tous les articles :",
    date: "Date de prestation pour tous les articles :",
  ),

  tax-exemption: (
    reverse-charge: "Autoliquidation",
    intra-community: "Livraison intracommunautaire exonérée de TVA",
    export: "Exportation exonérée de TVA",
    outside-scope: "Opération non soumise à la TVA",
  ),

  units: (
    piece: (singular: "pièce", plural: "pièces"),
    "set": (singular: "ensemble", plural: "ensembles"),
    pair: (singular: "paire", plural: "paires"),
    "lump-sum": (singular: "forfait", plural: "forfaits"),
    hour: (singular: "heure", plural: "heures"),
    day: (singular: "jour", plural: "jours"),
    month: "mois",
    year: (singular: "an", plural: "ans"),
    kilogram: (singular: "kilogramme", plural: "kilogrammes"),
    gram: (singular: "gramme", plural: "grammes"),
    tonne: (singular: "tonne", plural: "tonnes"),
    metre: (singular: "mètre", plural: "mètres"),
    "square-metre": (singular: "mètre carré", plural: "mètres carrés"),
    millimetre: (singular: "millimètre", plural: "millimètres"),
    centimetre: (singular: "centimètre", plural: "centimètres"),
    kilometre: (singular: "kilomètre", plural: "kilomètres"),
    litre: (singular: "litre", plural: "litres"),
    "cubic-metre": (singular: "mètre cube", plural: "mètres cubes"),
  ),

  /// Designations for bank and payment details
  bank-details: (
    account-holder: "Titulaire du compte",
    bank: "Banque",
    iban: "IBAN",
    bic: "BIC",
    reference: "Référence",
  ),

  /// Texts of the payment means besides the bank details
  payment-means: (
    method: "Mode de paiement",
    transfer: "Virement",
    direct-debit: "Prélèvement",
    sepa-direct-debit: "Prélèvement SEPA",
    card: "Paiement par carte",
    credit-card: "Carte de crédit",
    debit-card: "Carte de débit",
    cash: "Espèces",
    cheque: "Chèque",
    online: "Paiement en ligne",
    mandate: "Référence unique du mandat",
    creditor-id: "Identifiant créancier",
    debtor-iban: "Votre IBAN",
    card-number: "Numéro de carte",
    card-holder: "Titulaire de la carte",
    paid: (
      sum,
      date,
    ) => [Le montant total de *#sum* a été payé#if date != none [ le #date].],
    paid-due: (
      sum,
      date,
    ) => [Le montant restant dû de *#sum* a été payé#if date != none [ le #date].],
    paid-credit: (
      sum,
      date,
    ) => [Nous vous avons versé le montant de *#sum*#if date != none [ le #date].],
  ),

  /// Text blocks for payment terms
  payment: (
    text: (
      sum,
      deadline,
    ) => [Veuillez transférer le montant total de *#sum* #deadline sur le compte indiqué ci-dessous.],
    text-due: (
      sum,
      deadline,
    ) => [Veuillez transférer le montant restant dû de *#sum* #deadline sur le compte indiqué ci-dessous.],
    text-direct-debit: (
      sum,
      deadline,
    ) => [Le montant total de *#sum* sera prélevé sur votre compte #deadline.],
    text-direct-debit-due: (
      sum,
      deadline,
    ) => [Le montant restant dû de *#sum* sera prélevé sur votre compte #deadline.],
    text-card: (
      sum,
      deadline,
    ) => [Le montant total de *#sum* sera débité de votre carte #deadline.],
    text-card-due: (
      sum,
      deadline,
    ) => [Le montant restant dû de *#sum* sera débité de votre carte #deadline.],
    cash-discount: (
      percent,
      deadline,
      basis,
    ) => [En cas de paiement #deadline, un escompte de #percent#if basis != none [ sur #basis] est accordé.],

    deadline-date: date => ("au plus tard le", date).join(" "),
    deadline-days: days => (
      "sous",
      str(days),
      "jours",
    ).join(" "),
    deadline-soon: "dès réception",
    text-credit: (
      sum,
      deadline,
    ) => [Nous vous virerons le montant de *#sum* #deadline sur le compte indiqué ci-dessous.],
    deadline-soon-credit: "sans délai",
  ),

  /// Greetings and signature area
  signature: (
    closing: "Cordialement,",
    thanks: "Merci de votre confiance.",
  ),

  /// Standard legal texts (Explanation for the recipient)
  legal: (
    vat-exemption: "La TVA n'est pas facturée en raison de l'exonération pour les petites entreprises.",
  ),

  /// Error and warning messages for developers
  errors: (
    name-missing: "Le nom est manquant !",
    address-missing: "L'adresse est manquante !",
    city-missing: "La ville est manquante !",
    ambiguous-tax: "Taux de taxe 0% ambigu détecté.",
    invalid-tax: "Taux de taxe invalide détecté : ",
  ),

  validation: (
    marker: field => [‹manque : #field›],
    missing: field => [*Manque :* #field],
    part-empty: name => [‹#raw(name) ne produit rien›],
    badge: n => (
      "BROUILLON · " + str(n) + if n == 1 { " problème" } else { " problèmes" }
    ),
    watermark: "BROUILLON",
    e-invoice-short: "sans facture électronique",
    report-title: "Rapport de validation",
    report-intro: n => [Ce document n'est *pas prêt à être envoyé* : invoice-pro a détecté #n #if n == 1 [problème] else [problèmes]. Les marqueurs ‹…› indiquent les données manquantes. Cette page, le badge et les marqueurs disparaissent dès que tout est complet.],
    report-strict: [Avec `validation: "strict"` (ou `--input invoice-pro-validation=strict`), la compilation s'arrête à chaque problème. Recommandé pour l'envoi et en CI.],
    e-invoice-withheld: profile => [*La facture électronique (profil #profile) n'a pas été intégrée*, car des mentions obligatoires manquent. Des données incomplètes seraient traitées automatiquement par le système du ou de la destinataire.],
    number: "N°",
    problem: "Problème",
    reference: "Base légale",
    fix: "Correction",
    fix-or: "ou",
    classes: (
      data: "Mention obligatoire",
      theme: "Thème",
      lint: "Contrôle",
    ),
    fields: (
      invoice-number: "numéro de facture",
      sender-name: "nom (émetteur·rice)",
      sender-address: "adresse (émetteur·rice)",
      sender-tax-id: "n° de TVA ou n° fiscal (émetteur·rice)",
      recipient-name: "nom (destinataire)",
      recipient-address: "adresse (destinataire)",
      recipient-vat-id: "n° de TVA (destinataire)",
      line-items: "lignes de facture",
    ),
    issues: (
      iban: a => [L'IBAN #raw(a.iban) n'est pas valide (chiffres de contrôle ISO 13616).],
      iban-missing: a => [L'IBAN des coordonnées bancaires manque.],
      epc-qr: a => [Le code QR EPC ne peut pas être généré : #a.problems.],
      creditor-id: a => [L'identifiant créancier SEPA #raw(a.creditor-id) du prélèvement n'est pas valide (chiffres de contrôle).],
      debtor-iban: a => [L'IBAN #raw(a.iban) du compte débité (`debtor-iban`) n'est pas valide (chiffres de contrôle ISO 13616).],
      part-empty: a => [La partie #raw(a.part) ne produit rien, alors qu'elle porte des mentions légalement obligatoires.],
      part-none: a => [La partie #raw(a.part) porte des mentions légalement obligatoires et ne peut pas être `none` ; l'envelopper (`wrap`) ou remplacer son moteur de rendu.],
      role: a => [La mise en page #raw(a.layout) doit placer #a.parts.map(raw).join[ ou ] dans #if a.exactly [exactement une] else [au moins une] #if a.tagged [zone balisée (première page ou flux)] else [zone dessinée sur la page 1] (trouvé : #a.found). Elle porte des mentions légalement obligatoires : #a.why. Son apparence peut changer via son moteur de rendu, mais elle doit rester placée.],
      overprint: a => [La zone #raw(a.area) est fixe sur les pages suivantes (#raw("pages: \"" + a.pages + "\"")) et y recouvrirait le contenu ; utiliser `pages: "first"` ou la déplacer dans les marges.],
      window: a => [La zone #raw(a.area) chevauche la zone d'adresse #raw(a.window) ; la déplacer ou la réduire, les fenêtres d'enveloppe doivent rester dégagées.],
      qr-bill-paper: a => [La mise en page #raw(a.layout) contient `qr-bill`, qui exige du papier A4 portrait (QR-facture SIX : section paiement de 210 × 105 mm).],
      envelope: a => [L'enveloppe #raw(a.envelope) ne peut pas recevoir la feuille pliée : pli #str(a.packet-w).replace(".", ",") × #str(a.packet-h).replace(".", ",") mm, enveloppe #str(a.envelope-w).replace(".", ",") × #str(a.envelope-h).replace(".", ",") mm. Vérifier le papier, `marks.fold` ou le `fold` de l'enveloppe.],
      fine-size: a => [Le jeton `sizes.fine` (#raw(a.size)) doit être une longueur absolue d'au moins 6 pt (minimum DIN 5008 pour l'adresse de retour et le pied de page légal).],
      logo-alt: a => [L'image du logo doit avoir un texte alternatif, p. ex. `image("logo.svg", alt: "ACME GmbH")`. PDF/UA-1 l'exige ; le contrôle est toujours actif, car un document ne voit pas `--pdf-standard`.],
      cmyk: a => [#raw(a.path) est une couleur CMJN. Typst ne peut pas intégrer de profil de sortie CMJN, donc PDF/A-3 (ZUGFeRD) la refuse ; utiliser `rgb()` ou `oklch()`.],
      pdf-image-stationery: a => [Le papier à en-tête pour #raw(a.page) intègre une image PDF. Les exports PDF/A et PDF/UA ne peuvent pas intégrer d'images PDF (limite de Typst) ; convertir l'en-tête en SVG.],
      pdf-image-logo: a => [Le logo est une image PDF. Les exports PDF/A et PDF/UA ne peuvent pas intégrer d'images PDF (limite de Typst) ; utiliser SVG ou PNG.],
      contrast: a => [#if a.bg-name == none [La paire de couleurs #raw(a.fg-name)] else [#raw(a.fg-name) sur #raw(a.bg-name)] (#a.fg sur #a.bg) a un contraste de #str(a.ratio).replace(".", ","):1, inférieur à `checks.min-contrast` #str(a.min).replace(".", ","):1.],
      footer-fit: a => [Le pied de page mesure #str(a.need).replace(".", ",") mm, mais la marge inférieure ne laisse que #str(a.avail).replace(".", ",") mm entre `footer-descent` et le `footer-clearance` de #str(a.clearance).replace(".", ",") mm. Utiliser la marge calculée, augmenter `margin.bottom` ou raccourcir le pied de page.],
      identity: a => [#if a.what == "number" [Le numéro de facture] else [La date de facture] (#a.shown) n'apparaît pas dans le contenu de la première page ; la zone qui accueille `title` doit afficher #raw(if a.what == "number" { "view.document.number" } else { "view.document.date.text" }).],
    ),
    roles: (
      title: "identité du document : numéro et date de facture",
      recipient: "nom et adresse du ou de la destinataire",
      supplier: "nom et adresse de l'émetteur·rice",
      tax-id: "n° de TVA ou n° fiscal de l'émetteur·rice",
    ),
  ),
)
