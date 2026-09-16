/// Italian language overrides.
#let it = (
  meta: (
    /// Il codice lingua ISO 639-1 del file.
    lang: "it",
  ),

  /// Denominazioni per i tipi di documento
  document: (
    invoice: "Fattura",
  ),

  /// Denominazioni relative all'indirizzo
  address: (
    recipient: "Destinatario",
    sender: "Mittente",
  ),

  /// Denominazioni per numeri di riferimento e metadati
  reference: (
    tax-number: "P. IVA",
    invoice-number: "Numero fattura",
  ),

  /// Intestazioni di colonna ed etichette per la tabella degli articoli
  line-items: (
    position: "Art.",
    description: "Descrizione",
    quantity: "Qtà",
    unit-price: "Prezzo unitario",
    price: "Prezzo",
    total: "Totale",
    vat: "IVA",
    net: "netto",
    gross: "lordo",
    discount: "Sconto",
    surcharge: "Maggiorazione",
    subtotal: "Subtotale",
  ),

  /// Etichette per la sezione riepilogativa (piè di pagina della tabella)
  summary: (
    sum: "Subtotale",
    vat-tax: "IVA",
    total: "Totale da pagare",
    including: "incl.",
    excluding: "escl.",
  ),

  /// Frasi informative globali
  global-info: (
    /// Sentenza che specifica l'aliquota d'imposta universale applicata
    tax-statement: (
      tax-text,
      rate,
      vat-tax,
    ) => [Tutti gli articoli sono #tax-text #rate #vat-tax],
    unit: "Unità per tutti gli articoli:",
    quantity: "Quantità per tutti gli articoli:",
    date: "Data della prestazione per tutti gli articoli:",
  ),

  /// Denominazioni per i dettagli bancari e di pagamento
  bank-details: (
    account-holder: "Intestatario del conto",
    bank: "Banca",
    iban: "IBAN",
    bic: "BIC",
    reference: "Causale",
  ),

  /// Blocchi di testo per i termini di pagamento
  payment: (
    /// Genera la frase finale delle istruzioni di pagamento.
    text: (
      sum,
      deadline,
    ) => [Si prega di versare l'importo totale di *#sum* #deadline sul conto indicato di seguito.],

    /// Testo per una data di scadenza fissa.
    deadline-date: date => ("entro il", date).join(" "),

    /// Testo per una scadenza relativa (in X giorni).
    deadline-days: days => "entro " + str(days) + " giorni",

    /// Testo per pagamento immediato/rapido.
    deadline-soon: "alla ricezione",
  ),

  /// Saluti e area firma
  signature: (
    closing: "Cordiali saluti,",
  ),

  /// Testi legali standard (Spiegazione per il destinatario)
  legal: (
    vat-exemption: "IVA non addebitata a causa dell'esenzione per le piccole imprese.",
  ),

  /// Messaggi di errore e avviso per gli sviluppatori
  errors: (
    name-missing: "Il nome è mancante!",
    address-missing: "L'indirizzo è mancante!",
    city-missing: "La città è mancante!",
    ambiguous-tax: "Rilevata aliquota IVA 0% ambigua.",
    invalid-tax: "Rilevata aliquota IVA non valida: ",
  ),
)
