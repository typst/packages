/// Spanish language overrides.
#let es = (
  meta: (
    /// El código de idioma ISO 639-1 del archivo.
    lang: "es",
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
    tax-number: "NIF/CIF",
    invoice-number: "Número de factura",
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
  ),

  /// Etiquetas para la sección de resumen (pie de la tabla)
  summary: (
    sum: "Subtotal",
    vat-tax: "IVA",
    total: "Total a pagar",
    including: "incl.",
    excluding: "base",
  ),

  /// Frases informativas globales
  global-info: (
    /// Sentencia que especifica el tipo impositivo universal aplicado
    tax-statement: (
      tax-text,
      rate,
      vat-tax,
    ) => [Todos los artículos incluyen #tax-text #rate #vat-tax],
    unit: "Unidad para todos los artículos:",
    quantity: "Cantidad para todos los artículos:",
    date: "Fecha de servicio para todos los artículos:",
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
