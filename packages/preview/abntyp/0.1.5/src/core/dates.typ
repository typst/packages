// Representacao de datas e horas conforme NBR 5892:2019
// Informacao e documentacao - Representacao e formatos de tempo

/// Abreviaturas dos meses conforme NBR 5892:2019
/// Nota: "maio" nao e abreviado
#let month-abbreviations = (
  "janeiro": "jan.",
  "fevereiro": "fev.",
  "marco": "mar.",
  "abril": "abr.",
  "maio": "maio",
  "junho": "jun.",
  "julho": "jul.",
  "agosto": "ago.",
  "setembro": "set.",
  "outubro": "out.",
  "novembro": "nov.",
  "dezembro": "dez.",
)

/// Nomes dos meses em portugues (array indexado por 1)
/// Usar: month-names.at(mes - 1)
#let month-names = (
  "janeiro",    // 1
  "fevereiro",  // 2
  "marco",      // 3
  "abril",      // 4
  "maio",       // 5
  "junho",      // 6
  "julho",      // 7
  "agosto",     // 8
  "setembro",   // 9
  "outubro",    // 10
  "novembro",   // 11
  "dezembro",   // 12
)

/// Nomes dos meses por extenso (para uso formal)
#let month-names-full = month-names

/// Dias da semana por extenso (array indexado por 0 = domingo)
#let weekday-names = (
  "domingo",        // 0
  "segunda-feira",  // 1
  "terca-feira",    // 2
  "quarta-feira",   // 3
  "quinta-feira",   // 4
  "sexta-feira",    // 5
  "sabado",         // 6
)

/// Dias da semana abreviados (formato 1)
#let weekday-abbrev1 = (
  "dom.",      // 0
  "2a feira",  // 1
  "3a feira",  // 2
  "4a feira",  // 3
  "5a feira",  // 4
  "6a feira",  // 5
  "sab.",      // 6
)

/// Dias da semana abreviados (formato 2)
#let weekday-abbrev2 = (
  "dom.",  // 0
  "seg.",  // 1
  "ter.",  // 2
  "qua.",  // 3
  "qui.",  // 4
  "sex.",  // 5
  "sab.",  // 6
)

/// Retorna o nome do mes por extenso
/// - month: numero do mes (1-12)
#let get-month-name(month) = {
  month-names.at(month - 1)
}

/// Retorna a abreviatura do mes
/// - month: numero do mes (1-12) ou nome do mes
#let get-month-abbrev(month) = {
  if type(month) == int {
    let name = month-names.at(month - 1)
    month-abbreviations.at(name)
  } else {
    month-abbreviations.at(lower(month))
  }
}

/// Formata data no formato misto (padrao para texto corrido)
/// Exemplo: "4 de abril de 2018"
/// - day: dia
/// - month: mes (numero 1-12)
/// - year: ano
#let format-date-mixed(day, month, year) = {
  let month-name = month-names.at(month - 1)
  [#day de #month-name de #year]
}

/// Formata data no formato resumido
/// Exemplo: "4 abr. 2018"
/// - day: dia
/// - month: mes (numero 1-12)
/// - year: ano
#let format-date-short(day, month, year) = {
  let month-name = month-names.at(month - 1)
  let abbrev = month-abbreviations.at(month-name)
  [#day #abbrev #year]
}

/// Formata data no formato numerico
/// Exemplo: "04.04.2018"
/// - day: dia
/// - month: mes (numero 1-12)
/// - year: ano
#let format-date-numeric(day, month, year) = {
  let d = if day < 10 { "0" + str(day) } else { str(day) }
  let m = if month < 10 { "0" + str(month) } else { str(month) }
  [#d.#m.#year]
}

/// Formata data a partir de um objeto datetime
/// - date: objeto datetime do Typst
/// - format: "mixed" (padrao), "short", "numeric"
#let format-date(date, format: "mixed") = {
  let day = date.day()
  let month = date.month()
  let year = date.year()

  if format == "mixed" {
    format-date-mixed(day, month, year)
  } else if format == "short" {
    format-date-short(day, month, year)
  } else if format == "numeric" {
    format-date-numeric(day, month, year)
  } else {
    format-date-mixed(day, month, year)
  }
}

/// Formata hora no formato abreviado
/// Exemplo: "8 h 21 min 32 s"
/// - hour: hora
/// - minute: minuto
/// - second: segundo (opcional)
#let format-time-abbrev(hour, minute, second: none) = {
  if second != none {
    [#hour h #minute min #second s]
  } else {
    [#hour h #minute min]
  }
}

/// Formata hora no formato digital
/// Exemplo: "08:21:32"
/// - hour: hora
/// - minute: minuto
/// - second: segundo (opcional)
#let format-time-digital(hour, minute, second: none) = {
  let h = if hour < 10 { "0" + str(hour) } else { str(hour) }
  let m = if minute < 10 { "0" + str(minute) } else { str(minute) }

  if second != none {
    let s = if second < 10 { "0" + str(second) } else { str(second) }
    [#h:#m:#s]
  } else {
    [#h:#m]
  }
}

/// Formata hora a partir de um objeto datetime
/// - time: objeto datetime do Typst
/// - format: "abbrev" (padrao), "digital"
/// - show-seconds: mostrar segundos (default: true)
#let format-time(time, format: "abbrev", show-seconds: true) = {
  let hour = time.hour()
  let minute = time.minute()
  let second = if show-seconds { time.second() } else { none }

  if format == "abbrev" {
    format-time-abbrev(hour, minute, second: second)
  } else if format == "digital" {
    format-time-digital(hour, minute, second: second)
  } else {
    format-time-abbrev(hour, minute, second: second)
  }
}

/// Converte numero para romano (1-21)
#let to-roman(num) = {
  let roman-numerals = (
    "I", "II", "III", "IV", "V",
    "VI", "VII", "VIII", "IX", "X",
    "XI", "XII", "XIII", "XIV", "XV",
    "XVI", "XVII", "XVIII", "XIX", "XX",
    "XXI",
  )
  if num >= 1 and num <= 21 {
    roman-numerals.at(num - 1)
  } else {
    str(num)
  }
}

/// Formata seculo em algarismos romanos
/// Exemplo: "seculo XX" ou "sec. XX"
/// - century: numero do seculo
/// - abbreviated: usar forma abreviada
#let format-century(century, abbreviated: false) = {
  let roman = to-roman(century)

  if abbreviated {
    [sec. #roman]
  } else {
    [seculo #roman]
  }
}

/// Formata milenio em algarismos romanos
/// Exemplo: "II milenio a.C." ou "II mil. a.C."
/// - millennium: numero do milenio
/// - bc: antes da era crista (default: false)
/// - abbreviated: usar forma abreviada
#let format-millennium(millennium, bc: false, abbreviated: false) = {
  let roman = to-roman(millennium)
  let suffix = if bc { " a.C." } else { "" }

  if abbreviated {
    [#roman mil.#suffix]
  } else {
    [#roman milenio#suffix]
  }
}

/// Formata intervalo de meses para legendas bibliograficas
/// Exemplo: "jan./mar." ou "janeiro/marco"
/// - start-month: mes inicial (1-12)
/// - end-month: mes final (1-12)
/// - abbreviated: usar forma abreviada (default: true)
#let format-month-range(start-month, end-month, abbreviated: true) = {
  if abbreviated {
    let start = get-month-abbrev(start-month)
    let end = get-month-abbrev(end-month)
    [#start/#end]
  } else {
    let start = month-names.at(start-month - 1)
    let end = month-names.at(end-month - 1)
    [#start/#end]
  }
}

/// Data de acesso para documentos eletronicos
/// Formato: "Acesso em: 15 jan. 2026."
/// - day: dia
/// - month: mes (1-12)
/// - year: ano
#let access-date(day, month, year) = {
  let abbrev = get-month-abbrev(month)
  [Acesso em: #day #abbrev #year.]
}

/// Data de acesso a partir de datetime
/// - date: objeto datetime
#let access-date-from(date) = {
  access-date(date.day(), date.month(), date.year())
}

/// Data atual formatada
/// - format: "mixed", "short", "numeric"
#let today(format: "mixed") = {
  format-date(datetime.today(), format: format)
}
