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

/// Spanish language overrides.
#let es = (
  meta: (
    /// El código de idioma ISO 639-1 del archivo.
    lang: "es",
    resolve-plural: resolve-plural,
  ),

  /// Denominaciones para tipos de documentos
  document: (
    invoice: "Factura",
    credit-note: "Factura de abono",
    corrected: "Factura rectificativa",
    prepayment: "Factura de anticipo",
    // Mention required on a self-billed invoice (art. 6 RD 1619/2012).
    self-billed: "Facturación por el destinatario",
  ),

  /// Denominaciones relacionadas con la dirección
  address: (
    recipient: "Facturar a",
    sender: "De",
  ),

  /// Denominaciones para números de referencia y metadatos
  reference: (
    tax-number: "NIF",
    invoice-number: "Número de factura",
    vat-id: "NIF-IVA",
    invoice-date: "Fecha de la factura",
    service-time: "Periodo de servicio",
    customer-number: "Nº de cliente",
    buyer-reference: "Referencia del comprador/a",
    recipient-vat-id: "NIF-IVA del comprador/a",
    recipient-tax-number: "NIF del comprador/a",
    order-number: "Nº de pedido",
    order-date: "Fecha de pedido",
    project: "Proyecto",
    contract-number: "Nº de contrato",
    quote-number: "Nº de presupuesto",
    delivery-note-number: "Nº de albarán",
    delivery-address: "Dirección de entrega",
    preceding-invoice-number: "Nº de factura rectificada",
    preceding-invoice-date: "Fecha de la factura rectificada",
    due-date: "Fecha de vencimiento",
    payment-reference: "Concepto de pago",
    contact-person: "Persona de contacto",
    contact-phone: "Teléfono",
    contact-email: "Correo electrónico",
    payee: "Beneficiario del pago",
  ),

  /// Encabezados de columna y etiquetas para la tabla de artículos
  line-items: (
    position: "Pos.",
    description: "Descripción",
    quantity: "Cant.",
    unit-price: "Precio unitario",
    price: "Precio",
    total: "Total",
    vat: "IVA",
    net: "neto",
    gross: "bruto",
    discount: "Descuento",
    surcharge: "Recargo",
    subtotal: "Subtotal",
    prepayment: "Anticipo",
    conjunction: "y",
    origin: "País de origen",
  ),

  /// Etiquetas para la sección de resumen (pie de la tabla)
  summary: (
    sum: "Subtotal",
    vat-tax: "IVA",
    total: "Total factura",
    including: "incl.",
    excluding: "excl.",
    prepayment: "Anticipo",
    amount-due: "Total a pagar",
  ),

  /// Frases informativas globales
  global-info: (
    /// Sentencia que especifica el tipo impositivo universal aplicado
    tax-statement: (
      tax-text,
      rate,
      vat-tax,
    ) => [Todos los artículos son #tax-text #rate #vat-tax.],
    unit: "Unidad para todos los artículos:",
    quantity: "Cantidad para todos los artículos:",
    date: "Fecha de servicio para todos los artículos:",
  ),

  tax-exemption: (
    reverse-charge: "Inversión del sujeto pasivo",
    intra-community: "Entrega intracomunitaria exenta de IVA",
    export: "Exportación exenta de IVA",
    outside-scope: "Operación no sujeta a IVA",
  ),

  units: (
    piece: "unidad",
    "set": "juego",
    pair: "par",
    "lump-sum": "suma global",
    hour: "hora",
    day: "día",
    month: "mes",
    year: "año",
    kilogram: "kilogramo",
    gram: "gramo",
    tonne: "tonelada",
    metre: "metro",
    "square-metre": "metro cuadrado",
    millimetre: "milímetro",
    centimetre: "centímetro",
    kilometre: "kilómetro",
    litre: "litro",
    "cubic-metre": "metro cúbico",
  ),

  /// Denominaciones para detalles bancarios y de pago
  bank-details: (
    account-holder: "Titular de la cuenta",
    bank: "Banco",
    iban: "IBAN",
    bic: "SWIFT/BIC",
    reference: "Concepto",
  ),

  /// Textos de los medios de pago además de los datos bancarios
  payment-means: (
    method: "Forma de pago",
    transfer: "Transferencia",
    direct-debit: "Domiciliación bancaria",
    sepa-direct-debit: "Adeudo directo SEPA",
    card: "Pago con tarjeta",
    credit-card: "Tarjeta de crédito",
    debit-card: "Tarjeta de débito",
    cash: "Efectivo",
    cheque: "Cheque",
    online: "Pago en línea",
    mandate: "Referencia del mandato",
    creditor-id: "Identificador del acreedor",
    debtor-iban: "Su IBAN",
    card-number: "Número de tarjeta",
    card-holder: "Titular de la tarjeta",
    paid: (
      sum,
      date,
    ) => [El importe total de *#sum* ha sido pagado#if date != none [ el #date].],
    paid-due: (
      sum,
      date,
    ) => [El importe pendiente de *#sum* ha sido pagado#if date != none [ el #date].],
    paid-credit: (
      sum,
      date,
    ) => [Le hemos pagado el importe de *#sum*#if date != none [ el #date].],
  ),

  /// Bloques de texto para condiciones de pago
  payment: (
    /// Genera la frase final de instrucciones de pago.
    text: (
      sum,
      deadline,
    ) => [Por favor, transfiera el importe total de *#sum* #deadline a la cuenta indicada a continuación.],

    /// Frase de pago cuando los anticipos reducen el importe a pagar.
    text-due: (
      sum,
      deadline,
    ) => [Por favor, transfiera el importe pendiente de *#sum* #deadline a la cuenta indicada a continuación.],

    /// Frase de pago para una domiciliación bancaria.
    text-direct-debit: (
      sum,
      deadline,
    ) => [El importe total de *#sum* se cargará en su cuenta mediante domiciliación bancaria #deadline.],
    text-direct-debit-due: (
      sum,
      deadline,
    ) => [El importe pendiente de *#sum* se cargará en su cuenta mediante domiciliación bancaria #deadline.],

    /// Frase de pago para un pago con tarjeta.
    text-card: (
      sum,
      deadline,
    ) => [El importe total de *#sum* se cargará en su tarjeta #deadline.],
    text-card-due: (
      sum,
      deadline,
    ) => [El importe pendiente de *#sum* se cargará en su tarjeta #deadline.],

    /// Nota de un descuento por pronto pago.
    cash-discount: (
      percent,
      deadline,
      basis,
    ) => [Por pago #deadline se concede un descuento por pronto pago del #percent#if basis != none [ sobre #basis].],

    /// Texto para una fecha de vencimiento fija.
    deadline-date: date => ("antes del", date).join(" "),

    /// Texto para un plazo relativo (en X días).
    deadline-days: days => (
      "en un plazo de",
      str(days),
      "días",
    ).join(" "),

    /// Texto para pago inmediato.
    deadline-soon: "al recibir la factura",

    /// Frase de pago de una factura de abono o de una factura emitida por el
    /// destinatario: el remitente paga el importe al destinatario.
    text-credit: (
      sum,
      deadline,
    ) => [Le transferiremos el importe de *#sum* #deadline a la cuenta indicada a continuación.],

    /// Texto para un pago inmediato en `text-credit`.
    deadline-soon-credit: "de inmediato",
  ),

  /// Saludo y área de firma
  signature: (
    closing: "Atentamente,",
  ),

  /// Textos legales estándar (Explicación para el destinatario)
  legal: (
    vat-exemption: "IVA no repercutido por exención para pequeñas empresas.",
  ),

  /// Mensajes de error y advertencia para desarrolladores
  errors: (
    name-missing: "¡Falta el nombre!",
    address-missing: "¡Falta la dirección!",
    city-missing: "¡Falta la ciudad!",
    ambiguous-tax: "Se ha detectado un tipo de IVA del 0% ambiguo.",
    invalid-tax: "Se ha detectado un tipo de impuesto no válido: ",
  ),
)
