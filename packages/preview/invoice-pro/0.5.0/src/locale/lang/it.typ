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
    credit-note: "Nota di credito",
    corrected: "Fattura rettificativa",
    prepayment: "Fattura di acconto",
    // Mention required on a self-billed invoice (art. 21 DPR 633/1972).
    self-billed: "Autofatturazione",
  ),

  /// Denominazioni relative all'indirizzo
  address: (
    recipient: "Destinatario/a",
    sender: "Mittente",
  ),

  /// Denominazioni per numeri di riferimento e metadati
  reference: (
    tax-number: "Codice Fiscale",
    invoice-number: "Numero fattura",
    vat-id: "Partita IVA",
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
    delivery-address: "Indirizzo di consegna",
    preceding-invoice-number: "N. fattura precedente",
    preceding-invoice-date: "Data fattura precedente",
    due-date: "Data di scadenza",
    payment-reference: "Causale di pagamento",
    contact-person: "Referente",
    contact-phone: "Telefono",
    contact-email: "E-mail",
    payee: "Beneficiario del pagamento",
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
    prepayment: "Acconto",
    conjunction: "e",
    origin: "Paese di origine",
  ),

  /// Etichette per la sezione riepilogativa (piè di pagina della tabella)
  summary: (
    sum: "Subtotale",
    vat-tax: "IVA",
    total: "Totale fattura",
    including: "incl.",
    excluding: "escl.",
    prepayment: "Acconto",
    amount-due: "Totale dovuto",
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

  tax-exemption: (
    reverse-charge: "Inversione contabile",
    intra-community: "Cessione intracomunitaria non imponibile",
    export: "Esportazione non imponibile",
    outside-scope: "Operazione fuori campo IVA",
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
    account-holder: "Intestatario/a del conto",
    bank: "Banca",
    iban: "IBAN",
    bic: "BIC",
    reference: "Causale",
  ),

  /// Testi dei mezzi di pagamento oltre ai dettagli bancari
  payment-means: (
    method: "Modalità di pagamento",
    transfer: "Bonifico",
    direct-debit: "Addebito diretto",
    sepa-direct-debit: "Addebito diretto SEPA",
    card: "Pagamento con carta",
    credit-card: "Carta di credito",
    debit-card: "Carta di debito",
    cash: "Contanti",
    cheque: "Assegno",
    online: "Pagamento online",
    mandate: "Riferimento del mandato",
    creditor-id: "Identificativo del creditore",
    debtor-iban: "Il Suo IBAN",
    card-number: "Numero della carta",
    card-holder: "Titolare della carta",
    paid: (
      sum,
      date,
    ) => [L'importo totale di *#sum* è stato pagato#if date != none [ il #date].],
    paid-due: (
      sum,
      date,
    ) => [L'importo dovuto di *#sum* è stato pagato#if date != none [ il #date].],
    paid-credit: (
      sum,
      date,
    ) => [Vi abbiamo versato l'importo di *#sum*#if date != none [ il #date].],
  ),

  /// Blocchi di testo per i termini di pagamento
  payment: (
    /// Genera la frase finale delle istruzioni di pagamento.
    text: (
      sum,
      deadline,
    ) => [Si prega di versare l'importo totale di *#sum* #deadline sul conto indicato di seguito.],

    /// Frase di pagamento quando gli acconti riducono l'importo da versare.
    text-due: (
      sum,
      deadline,
    ) => [Si prega di versare l'importo dovuto di *#sum* #deadline sul conto indicato di seguito.],

    /// Frase di pagamento per un addebito diretto.
    text-direct-debit: (
      sum,
      deadline,
    ) => [L'importo totale di *#sum* sarà addebitato sul Suo conto tramite addebito diretto #deadline.],
    text-direct-debit-due: (
      sum,
      deadline,
    ) => [L'importo dovuto di *#sum* sarà addebitato sul Suo conto tramite addebito diretto #deadline.],

    /// Frase di pagamento per un pagamento con carta.
    text-card: (
      sum,
      deadline,
    ) => [L'importo totale di *#sum* sarà addebitato sulla Sua carta #deadline.],
    text-card-due: (
      sum,
      deadline,
    ) => [L'importo dovuto di *#sum* sarà addebitato sulla Sua carta #deadline.],

    /// Nota di uno sconto per pagamento anticipato.
    cash-discount: (
      percent,
      deadline,
      basis,
    ) => [Per pagamento #deadline è concesso uno sconto del #percent#if basis != none [ su #basis].],

    /// Testo per una data di scadenza fissa.
    deadline-date: date => ("entro il", date).join(" "),

    /// Testo per una scadenza relativa (in X giorni).
    deadline-days: days => "entro " + str(days) + " giorni",

    /// Testo per pagamento immediato/rapido.
    deadline-soon: "alla ricezione",

    /// Frase di pagamento di una nota di credito o di un'autofattura: il
    /// mittente versa l'importo al destinatario.
    text-credit: (
      sum,
      deadline,
    ) => [Vi verseremo l'importo di *#sum* #deadline sul conto indicato di seguito.],

    /// Testo per un pagamento immediato in `text-credit`.
    deadline-soon-credit: "senza indugio",
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
