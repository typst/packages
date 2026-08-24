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
  if num == 1 {
    v.at("singular", default: fallback)
  } else {
    v.at("plural", default: fallback)
  }
}

/// Italian language overrides.
#let it = (
  meta: (
    /// Il codice lingua ISO 639-1 del file.
    lang: "it",
    resolve-plural: resolve-plural,
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
    vat-id: "P. IVA",
    invoice-date: "Data fattura",
    service-time: "Periodo di prestazione",
    customer-number: "N. cliente",
    buyer-reference: "Riferimento acquirente",
    recipient-vat-id: "P.IVA acquirente",
    recipient-tax-number: "Codice fiscale acquirente",
    order-number: "N. ordine",
    order-date: "Data ordine",
    project: "Progetto",
    contract-number: "N. contratto",
    quote-number: "N. preventivo",
    delivery-note-number: "N. documento di trasporto",
    preceding-invoice-number: "N. fattura precedente",
    due-date: "Data di scadenza",
    payment-reference: "Causale di pagamento",
    contact-person: "Referente",
    contact-phone: "Telefono",
    contact-email: "E-mail",
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
    ) => [Tutti gli articoli sono #tax-text #rate #vat-tax.],
    unit: "Unità per tutti gli articoli:",
    quantity: "Quantità per tutti gli articoli:",
    date: "Data della prestazione per tutti gli articoli:",
  ),

  units: (
    piece: "pezzo",
    "set": "set",
    pair: "paio",
    "lump-sum": "a forfait",
    hour: "ora",
    day: "giorno",
    month: "mese",
    year: "anno",
    kilogram: "chilogrammo",
    gram: "grammo",
    tonne: "tonnellata",
    metre: "metro",
    "square-metre": "metro quadrato",
    millimetre: "millimetro",
    centimetre: "centimetro",
    kilometre: "chilometro",
    litre: "litro",
    "cubic-metre": "metro cubo",
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
