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
    due-date: "Fecha de vencimiento",
    payment-reference: "Concepto de pago",
    contact-person: "Persona de contacto",
    contact-phone: "Teléfono",
    contact-email: "Correo electrónico",
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

  /// Bloques de texto para condiciones de pago
  payment: (
    /// Genera la frase final de instrucciones de pago.
    text: (
      sum,
      deadline,
    ) => [Por favor, transfiera el importe total de *#sum* #deadline a la cuenta indicada a continuación.],

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
