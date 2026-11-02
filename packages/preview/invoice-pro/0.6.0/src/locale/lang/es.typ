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
    page: (current, total) => [Página #current de #total],
    continued-on: page => [Continúa en la página #page],
  ),

  /// Denominaciones relacionadas con la dirección
  address: (
    recipient: "Facturar a",
    sender: "De",
  ),

  sections: (
    details: "Detalles de la factura",
    payment: "Pago",
    bank-details: "Datos bancarios",
    how-to-pay: "Cómo pagar",
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
    item-id: "Ref.",
    unit: "Unidad",
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
    piece: (singular: "unidad", plural: "unidades"),
    "set": (singular: "juego", plural: "juegos"),
    pair: (singular: "par", plural: "pares"),
    "lump-sum": (singular: "suma global", plural: "sumas globales"),
    hour: (singular: "hora", plural: "horas"),
    day: (singular: "día", plural: "días"),
    month: (singular: "mes", plural: "meses"),
    year: (singular: "año", plural: "años"),
    kilogram: (singular: "kilogramo", plural: "kilogramos"),
    gram: (singular: "gramo", plural: "gramos"),
    tonne: (singular: "tonelada", plural: "toneladas"),
    metre: (singular: "metro", plural: "metros"),
    "square-metre": (singular: "metro cuadrado", plural: "metros cuadrados"),
    millimetre: (singular: "milímetro", plural: "milímetros"),
    centimetre: (singular: "centímetro", plural: "centímetros"),
    kilometre: (singular: "kilómetro", plural: "kilómetros"),
    litre: (singular: "litro", plural: "litros"),
    "cubic-metre": (singular: "metro cúbico", plural: "metros cúbicos"),
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
    thanks: "Gracias por su confianza.",
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

  validation: (
    marker: field => [‹falta: #field›],
    missing: field => [*Falta:* #field],
    part-empty: name => [‹#raw(name) no produce nada›],
    badge: n => (
      "BORRADOR · " + str(n) + if n == 1 { " problema" } else { " problemas" }
    ),
    watermark: "BORRADOR",
    e-invoice-short: "sin factura electrónica",
    report-title: "Informe de validación",
    report-intro: n => [Este documento *no está listo para enviarse*: invoice-pro ha encontrado #n #if n == 1 [problema] else [problemas]. Los marcadores ‹…› indican dónde faltan datos. Esta página, la insignia y los marcadores desaparecen en cuanto todo está completo.],
    report-strict: [Con `validation: "strict"` (o `--input invoice-pro-validation=strict`) la compilación se detiene ante cualquier problema. Recomendado para el envío y en CI.],
    e-invoice-withheld: profile => [*La factura electrónica (perfil #profile) no se ha incrustado*, porque faltan datos obligatorios. Unos datos incompletos serían procesados automáticamente por el sistema de quien la reciba.],
    number: "N.º",
    problem: "Problema",
    reference: "Base legal",
    fix: "Corrección",
    fix-or: "o",
    classes: (
      data: "Dato obligatorio",
      theme: "Tema",
      lint: "Comprobación",
    ),
    fields: (
      invoice-number: "número de factura",
      sender-name: "nombre (emisor/a)",
      sender-address: "dirección (emisor/a)",
      sender-tax-id: "NIF-IVA o NIF (emisor/a)",
      recipient-name: "nombre (destinatario/a)",
      recipient-address: "dirección (destinatario/a)",
      recipient-vat-id: "NIF-IVA (destinatario/a)",
      line-items: "líneas de factura",
    ),
    issues: (
      iban: a => [El IBAN #raw(a.iban) no es válido (dígitos de control ISO 13616).],
      iban-missing: a => [Falta el IBAN de los datos bancarios.],
      epc-qr: a => [No se puede generar el código QR EPC: #a.problems.],
      creditor-id: a => [El identificador de acreedor #raw(a.creditor-id) del adeudo directo no es válido (dígitos de control).],
      debtor-iban: a => [El IBAN #raw(a.iban) de la cuenta de cargo (`debtor-iban`) no es válido (dígitos de control ISO 13616).],
      part-empty: a => [La parte #raw(a.part) no produce contenido, pero contiene menciones obligatorias por ley.],
      part-none: a => [La parte #raw(a.part) contiene menciones obligatorias por ley y no puede ser `none`; envolverla (`wrap`) o sustituir su renderizador.],
      role: a => [El diseño #raw(a.layout) debe colocar #a.parts.map(raw).join[ o ] en #if a.exactly [exactamente un área] else [al menos un área] #if a.tagged [etiquetada (primera página o flujo)] else [dibujada en la página 1] (encontradas: #a.found). Contiene menciones obligatorias por ley: #a.why. Su aspecto puede cambiarse sustituyendo el renderizador, pero debe seguir colocada.],
      overprint: a => [El área #raw(a.area) es fija en las páginas siguientes (#raw("pages: \"" + a.pages + "\"")) y taparía allí el contenido; usar `pages: "first"` o moverla a los márgenes.],
      window: a => [El área #raw(a.area) se superpone al área de la dirección #raw(a.window); moverla o reducirla, las ventanas de los sobres deben quedar libres.],
      qr-bill-paper: a => [El diseño #raw(a.layout) contiene `qr-bill`, que requiere papel A4 vertical (QR-factura SIX: sección de pago de 210 × 105 mm).],
      envelope: a => [El sobre #raw(a.envelope) no admite la hoja plegada: pliego #str(a.packet-w).replace(".", ",") × #str(a.packet-h).replace(".", ",") mm, sobre #str(a.envelope-w).replace(".", ",") × #str(a.envelope-h).replace(".", ",") mm. Revisar el papel, `marks.fold` o el `fold` del sobre.],
      fine-size: a => [El token `sizes.fine` (#raw(a.size)) debe ser una longitud absoluta de al menos 6 pt (mínimo DIN 5008 para el remite y el pie legal).],
      logo-alt: a => [La imagen del logotipo necesita un texto alternativo, p. ej. `image("logo.svg", alt: "ACME GmbH")`. PDF/UA-1 lo exige; se comprueba siempre, porque un documento no puede ver `--pdf-standard`.],
      cmyk: a => [#raw(a.path) es un color CMYK. Typst no puede incrustar un perfil de salida CMYK, por lo que PDF/A-3 (ZUGFeRD) lo rechaza; usar `rgb()` u `oklch()`.],
      pdf-image-stationery: a => [El papel con membrete para #raw(a.page) incrusta una imagen PDF. Las exportaciones PDF/A y PDF/UA no pueden incrustar imágenes PDF (limitación de Typst); convertir el membrete a SVG.],
      pdf-image-logo: a => [El logotipo es una imagen PDF. Las exportaciones PDF/A y PDF/UA no pueden incrustar imágenes PDF (limitación de Typst); usar SVG o PNG.],
      contrast: a => [#if a.bg-name == none [El par de colores #raw(a.fg-name)] else [#raw(a.fg-name) sobre #raw(a.bg-name)] (#a.fg sobre #a.bg) tiene un contraste de #str(a.ratio).replace(".", ","):1, inferior a `checks.min-contrast` #str(a.min).replace(".", ","):1.],
      footer-fit: a => [El pie mide #str(a.need).replace(".", ",") mm, pero el margen inferior solo deja #str(a.avail).replace(".", ",") mm entre `footer-descent` y el `footer-clearance` de #str(a.clearance).replace(".", ",") mm. Usar el margen calculado, aumentar `margin.bottom` o acortar el pie.],
      identity: a => [#if a.what == "number" [El número de factura] else [La fecha de factura] (#a.shown) no aparece en el contenido de la primera página; el área que aloja `title` debe mostrar #raw(if a.what == "number" { "view.document.number" } else { "view.document.date.text" }).],
    ),
    roles: (
      title: "identidad del documento: número y fecha de la factura",
      recipient: "nombre y dirección del destinatario o de la destinataria",
      supplier: "nombre y dirección del emisor o de la emisora",
      tax-id: "NIF-IVA o número fiscal del emisor o de la emisora",
    ),
  ),
)
