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
    page: (current, total) => [Pagina #current di #total],
    continued-on: page => [Continua a pagina #page],
  ),

  /// Denominazioni relative all'indirizzo
  address: (
    recipient: "Destinatario/a",
    sender: "Mittente",
  ),

  sections: (
    details: "Dettagli della fattura",
    payment: "Pagamento",
    bank-details: "Coordinate bancarie",
    how-to-pay: "Come pagare",
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
    item-id: "Cod. art.",
    unit: "Unità",
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
    piece: (singular: "pezzo", plural: "pezzi"),
    "set": "set",
    pair: (singular: "paio", plural: "paia"),
    "lump-sum": "a forfait",
    hour: (singular: "ora", plural: "ore"),
    day: (singular: "giorno", plural: "giorni"),
    month: (singular: "mese", plural: "mesi"),
    year: (singular: "anno", plural: "anni"),
    kilogram: (singular: "chilogrammo", plural: "chilogrammi"),
    gram: (singular: "grammo", plural: "grammi"),
    tonne: (singular: "tonnellata", plural: "tonnellate"),
    metre: (singular: "metro", plural: "metri"),
    "square-metre": (singular: "metro quadrato", plural: "metri quadrati"),
    millimetre: (singular: "millimetro", plural: "millimetri"),
    centimetre: (singular: "centimetro", plural: "centimetri"),
    kilometre: (singular: "chilometro", plural: "chilometri"),
    litre: (singular: "litro", plural: "litri"),
    "cubic-metre": (singular: "metro cubo", plural: "metri cubi"),
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
    thanks: "Grazie per la fiducia.",
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

  validation: (
    marker: field => [‹manca: #field›],
    missing: field => [*Manca:* #field],
    part-empty: name => [‹#raw(name) non produce nulla›],
    badge: n => (
      "BOZZA · " + str(n) + if n == 1 { " problema" } else { " problemi" }
    ),
    watermark: "BOZZA",
    e-invoice-short: "senza fattura elettronica",
    report-title: "Rapporto di validazione",
    report-intro: n => [Questo documento *non è pronto per l'invio*: invoice-pro ha rilevato #n #if n == 1 [problema] else [problemi]. I marcatori ‹…› indicano i dati mancanti. Questa pagina, il badge e i marcatori scompaiono non appena tutto è completo.],
    report-strict: [Con `validation: "strict"` (o `--input invoice-pro-validation=strict`) la compilazione si interrompe a ogni problema. Consigliato per l'invio e in CI.],
    e-invoice-withheld: profile => [*La fattura elettronica (profilo #profile) non è stata incorporata*, perché mancano dati obbligatori. Dati incompleti verrebbero elaborati automaticamente dal sistema del destinatario o della destinataria.],
    number: "N.",
    problem: "Problema",
    reference: "Base giuridica",
    fix: "Correzione",
    fix-or: "o",
    classes: (
      data: "Dato obbligatorio",
      theme: "Tema",
      lint: "Controllo",
    ),
    fields: (
      invoice-number: "numero fattura",
      sender-name: "nome (mittente)",
      sender-address: "indirizzo (mittente)",
      sender-tax-id: "partita IVA o codice fiscale (mittente)",
      recipient-name: "nome (destinatario/a)",
      recipient-address: "indirizzo (destinatario/a)",
      recipient-vat-id: "partita IVA (destinatario/a)",
      line-items: "righe della fattura",
    ),
    issues: (
      iban: a => [L'IBAN #raw(a.iban) non è valido (cifre di controllo ISO 13616).],
      iban-missing: a => [Manca l'IBAN delle coordinate bancarie.],
      epc-qr: a => [Il codice QR EPC non può essere generato: #a.problems.],
      creditor-id: a => [L'identificativo del creditore #raw(a.creditor-id) dell'addebito diretto non è valido (cifre di controllo).],
      debtor-iban: a => [L'IBAN #raw(a.iban) del conto addebitato (`debtor-iban`) non è valido (cifre di controllo ISO 13616).],
      part-empty: a => [La parte #raw(a.part) non produce alcun contenuto, ma riporta indicazioni obbligatorie per legge.],
      part-none: a => [La parte #raw(a.part) riporta indicazioni obbligatorie per legge e non può essere `none`; avvolgerla (`wrap`) o sostituirne il renderer.],
      role: a => [Il layout #raw(a.layout) deve collocare #a.parts.map(raw).join[ o ] in #if a.exactly [esattamente un'area] else [almeno un'area] #if a.tagged [con tag (prima pagina o flusso)] else [disegnata a pagina 1] (trovate: #a.found). Riporta indicazioni obbligatorie per legge: #a.why. Se ne può cambiare l'aspetto sostituendo il renderer, ma deve restare collocata.],
      overprint: a => [L'area #raw(a.area) è fissa nelle pagine successive (#raw("pages: \"" + a.pages + "\"")) e vi coprirebbe il contenuto; usare `pages: "first"` o spostarla nei margini.],
      window: a => [L'area #raw(a.area) si sovrappone all'area dell'indirizzo #raw(a.window); spostarla o ridurla, le finestre delle buste devono restare libere.],
      qr-bill-paper: a => [Il layout #raw(a.layout) contiene `qr-bill`, che richiede carta A4 verticale (QR-fattura SIX: sezione di pagamento di 210 × 105 mm).],
      envelope: a => [La busta #raw(a.envelope) non accoglie il foglio piegato: piego #str(a.packet-w).replace(".", ",") × #str(a.packet-h).replace(".", ",") mm, busta #str(a.envelope-w).replace(".", ",") × #str(a.envelope-h).replace(".", ",") mm. Verificare la carta, `marks.fold` o il `fold` della busta.],
      fine-size: a => [Il token `sizes.fine` (#raw(a.size)) deve essere una lunghezza assoluta di almeno 6 pt (minimo DIN 5008 per l'indirizzo del mittente e il piè di pagina legale).],
      logo-alt: a => [L'immagine del logo richiede un testo alternativo, ad es. `image("logo.svg", alt: "ACME GmbH")`. PDF/UA-1 lo prescrive; il controllo è sempre attivo, perché un documento non vede `--pdf-standard`.],
      cmyk: a => [#raw(a.path) è un colore CMYK. Typst non può incorporare un profilo di output CMYK, quindi PDF/A-3 (ZUGFeRD) lo rifiuta; usare `rgb()` o `oklch()`.],
      pdf-image-stationery: a => [La carta intestata per #raw(a.page) incorpora un'immagine PDF. Le esportazioni PDF/A e PDF/UA non possono incorporare immagini PDF (limite di Typst); convertire l'intestazione in SVG.],
      pdf-image-logo: a => [Il logo è un'immagine PDF. Le esportazioni PDF/A e PDF/UA non possono incorporare immagini PDF (limite di Typst); usare SVG o PNG.],
      contrast: a => [#if a.bg-name == none [La coppia di colori #raw(a.fg-name)] else [#raw(a.fg-name) su #raw(a.bg-name)] (#a.fg su #a.bg) ha un contrasto di #str(a.ratio).replace(".", ","):1, inferiore a `checks.min-contrast` #str(a.min).replace(".", ","):1.],
      footer-fit: a => [Il piè di pagina è alto #str(a.need).replace(".", ",") mm, ma il margine inferiore lascia solo #str(a.avail).replace(".", ",") mm tra `footer-descent` e il `footer-clearance` di #str(a.clearance).replace(".", ",") mm. Usare il margine calcolato, aumentare `margin.bottom` o accorciare il piè di pagina.],
      identity: a => [#if a.what == "number" [Il numero di fattura] else [La data della fattura] (#a.shown) non compare nel contenuto della prima pagina; l'area che ospita `title` deve mostrare #raw(if a.what == "number" { "view.document.number" } else { "view.document.date.text" }).],
    ),
    roles: (
      title: "identità del documento: numero e data della fattura",
      recipient: "nome e indirizzo del destinatario o della destinataria",
      supplier: "nome e indirizzo del cedente o prestatore",
      tax-id: "partita IVA o codice fiscale del cedente o prestatore",
    ),
  ),
)
