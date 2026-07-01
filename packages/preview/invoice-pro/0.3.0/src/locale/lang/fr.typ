/// French language overrides.
#let fr = (
  meta: (
    /// The ISO 639-1 language code of the file.
    lang: "fr",
  ),

  /// Designations for document types
  document: (
    invoice: "Facture",
  ),

  /// Address-related designations
  address: (
    recipient: "Destinataire",
    sender: "Expéditeur",
  ),

  /// Designations for reference numbers and metadata
  reference: (
    tax-number: "N° de TVA",
    invoice-number: "N° de facture",
  ),

  /// Column headers and labels for the line-items table
  line-items: (
    position: "Pos.",
    description: "Description",
    quantity: "Qté",
    unit-price: "Prix unitaire",
    price: "Prix",
    total: "Total",
    vat: "TVA",
    net: "net",
    gross: "brut",
    discount: "Remise",
    surcharge: "Supplément",
    subtotal: "Sous-total",
  ),

  /// Labels for the summary section (footer of the table)
  summary: (
    sum: "Sous-total",
    vat-tax: "TVA",
    total: "Total à payer",
    including: "incl.",
    excluding: "hors",
  ),

  /// Global informational sentences
  global-info: (
    tax-statement: (
      tax-text,
      rate,
      vat-tax,
    ) => [Tous les articles sont #tax-text #rate #vat-tax],
    unit: "Unité pour tous les articles :",
    quantity: "Quantité pour tous les articles :",
    date: "Date de prestation pour tous les articles :",
  ),

  /// Designations for bank and payment details
  bank-details: (
    account-holder: "Titulaire du compte",
    bank: "Banque",
    iban: "IBAN",
    bic: "BIC",
    reference: "Référence",
  ),

  /// Text blocks for payment terms
  payment: (
    text: (
      sum,
      deadline,
    ) => [Veuillez transférer le montant total de *#sum* #deadline sur le compte indiqué ci-dessous.],

    deadline-date: date => ("au plus tard le", date).join(" "),
    deadline-days: days => (
      "sous",
      str(days),
      "jours",
    ).join(" "),
    deadline-soon: "dès réception",
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
