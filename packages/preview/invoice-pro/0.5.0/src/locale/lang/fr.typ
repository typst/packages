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
  ),

  /// Address-related designations
  address: (
    recipient: "Destinataire",
    sender: "Expéditeur·rice",
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
    piece: "pièce",
    "set": "ensemble",
    pair: "paire",
    "lump-sum": "forfait",
    hour: "heure",
    day: "jour",
    month: "mois",
    year: "an",
    kilogram: "kilogramme",
    gram: "gramme",
    tonne: "tonne",
    metre: "mètre",
    "square-metre": "mètre carré",
    millimetre: "millimètre",
    centimetre: "centimètre",
    kilometre: "kilomètre",
    litre: "litre",
    "cubic-metre": "mètre cube",
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
)
