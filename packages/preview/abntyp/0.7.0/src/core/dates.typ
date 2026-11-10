// Representacao de datas e horas conforme NBR 5892:2019
// Informacao e documentacao - Representacao e formatos de tempo

/// Abreviaturas dos meses conforme NBR 5892:2019
/// Nota: "maio" nao e abreviado
#let month-abbreviations = (
  "janeiro": "jan.",
  "fevereiro": "fev.",
  "março": "mar.",
  "marco": "mar.", // alias sem cedilha (entrada)
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
  "março",      // 3
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
  "terça-feira",    // 2
  "quarta-feira",   // 3
  "quinta-feira",   // 4
  "sexta-feira",    // 5
  "sábado",         // 6
)

/// Dias da semana abreviados (formato 1)
#let weekday-abbrev1 = (
  "dom.",      // 0
  "2ª feira",  // 1
  "3ª feira",  // 2
  "4ª feira",  // 3
  "5ª feira",  // 4
  "6ª feira",  // 5
  "sáb.",      // 6
)

/// Dias da semana abreviados (formato 2)
#let weekday-abbrev2 = (
  "dom.",  // 0
  "seg.",  // 1
  "ter.",  // 2
  "qua.",  // 3
  "qui.",  // 4
  "sex.",  // 5
  "sáb.",  // 6
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

/// Exige o ano com quatro digitos (NBR 5892, 3.1.3): 2018, nao 18
#let _check-year(year) = {
  assert(
    str(year).match(regex("^\\d{4}$")) != none,
    message: "NBR 5892 3.1.3: o ano deve ter quatro digitos (recebido: " + repr(year) + ")",
  )
}

/// Formata data no formato misto (padrao para texto corrido)
/// Exemplo: "4 de abril de 2018"
/// - day: dia
/// - month: mes (numero 1-12)
/// - year: ano (quatro digitos)
#let format-date-mixed(day, month, year) = {
  _check-year(year)
  let month-name = month-names.at(month - 1)
  [#day de #month-name de #year]
}

/// Formata data no formato resumido
/// Exemplo: "4 abr. 2018"
/// - day: dia
/// - month: mes (numero 1-12)
/// - year: ano (quatro digitos)
#let format-date-short(day, month, year) = {
  _check-year(year)
  let month-name = month-names.at(month - 1)
  let abbrev = month-abbreviations.at(month-name)
  [#day #abbrev #year]
}

/// Formata data no formato numerico
/// Exemplo: "04.04.2018"
/// - day: dia
/// - month: mes (numero 1-12)
/// - year: ano (quatro digitos)
#let format-date-numeric(day, month, year) = {
  _check-year(year)
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
/// - second: segundo (opcional; decimais com virgula: 32,3 s)
#let format-time-abbrev(hour, minute, second: none) = {
  if second != none {
    let second = str(second).replace(".", ",")
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
    let s = s.replace(".", ",")
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

/// Detalha data e hora na ordem dia, mes, ano, hora, minuto e segundo
/// (NBR 5892, 3.3.1)
/// Exemplo: "30 de junho de 1954, às 12 h 21 min 32,3 s"
/// - day, month, year: data (ano com quatro digitos)
/// - hour, minute: hora e minuto
/// - second: segundo (opcional; decimais aceitos)
/// - date-format: "mixed" (padrao), "short" ou "numeric"
/// - time-format: "abbrev" (padrao) ou "digital"
/// - separator: ligacao entre data e hora (padrao: ", às " com a data "mixed"
///   e a hora "abbrev"; senao, um espaco)
#let format-date-time(
  day, month, year, hour, minute,
  second: none,
  date-format: "mixed",
  time-format: "abbrev",
  separator: auto,
) = {
  let date = if date-format == "short" {
    format-date-short(day, month, year)
  } else if date-format == "numeric" {
    format-date-numeric(day, month, year)
  } else {
    format-date-mixed(day, month, year)
  }
  let time = if time-format == "digital" {
    format-time-digital(hour, minute, second: second)
  } else {
    format-time-abbrev(hour, minute, second: second)
  }
  let sep = if separator != auto {
    separator
  } else if date-format == "mixed" and time-format == "abbrev" {
    ", às "
  } else {
    " "
  }
  [#date#sep#time]
}

/// Dia da semana de uma data: 0 = domingo ... 6 = sabado (indice dos vetores
/// `weekday-names`, `weekday-abbrev1` e `weekday-abbrev2`).
/// Segue o calendario da NBR 5892 (2.1): juliano ate 4 de outubro de 1582 e
/// gregoriano a partir de 15 de outubro de 1582 (5 a 14 de outubro de 1582 nao existem).
/// - day, month, year: data (ano a partir de 1)
#let get-weekday(day, month, year) = {
  let year = int(year)
  assert(year >= 1 and month >= 1 and month <= 12, message: "get-weekday: data invalida")
  let gregorian = (year, month, day) >= (1582, 10, 15)
  assert(gregorian or (year, month, day) <= (1582, 10, 4), message: "get-weekday: 5 a 14 de outubro de 1582 nao existem")
  let leap = if gregorian {
    calc.rem(year, 4) == 0 and (calc.rem(year, 100) != 0 or calc.rem(year, 400) == 0)
  } else {
    calc.rem(year, 4) == 0
  }
  let days-in-month = (31, if leap { 29 } else { 28 }, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  assert(day >= 1 and day <= days-in-month.at(month - 1), message: "get-weekday: dia inexistente nesse mes")
  // Numero do dia juliano
  let a = calc.div-euclid(14 - month, 12)
  let y = year + 4800 - a
  let m = month + 12 * a - 3
  let jdn = day + calc.div-euclid(153 * m + 2, 5) + 365 * y + calc.div-euclid(y, 4)
  let jdn = if gregorian {
    jdn - calc.div-euclid(y, 100) + calc.div-euclid(y, 400) - 32045
  } else {
    jdn - 32083
  }
  calc.rem-euclid(jdn + 1, 7)
}

/// Nome do dia da semana de uma data (NBR 5892, 3.3.2)
/// Exemplo: "quarta-feira" (full), "4ª feira" (abbrev1), "qua." (abbrev2)
/// - day, month, year: data (ano a partir de 1)
/// - format: "full" (padrao), "abbrev1" ou "abbrev2"
#let format-weekday(day, month, year, format: "full") = {
  let index = get-weekday(day, month, year)
  if format == "abbrev1" {
    weekday-abbrev1.at(index)
  } else if format == "abbrev2" {
    weekday-abbrev2.at(index)
  } else {
    weekday-names.at(index)
  }
}

/// Converte numero inteiro (1-3999) para romano
#let to-roman(num) = {
  if num >= 1 and num <= 3999 {
    let values = (1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1)
    let symbols = ("M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I")
    let rest = num
    let result = ""
    for (value, symbol) in values.zip(symbols) {
      while rest >= value {
        result += symbol
        rest -= value
      }
    }
    result
  } else {
    str(num)
  }
}

/// Formata seculo em algarismos romanos
/// Exemplo: "século XX" ou "séc. XX"
/// - century: numero do seculo
/// - abbreviated: usar forma abreviada
#let format-century(century, abbreviated: false) = {
  let roman = to-roman(century)

  if abbreviated {
    [séc. #roman]
  } else {
    [século #roman]
  }
}

/// Formata milenio em algarismos romanos
/// Exemplo: "II milênio a.C." ou "II mil. a.C."
/// - millennium: numero do milenio
/// - bc: antes da era crista (default: false)
/// - abbreviated: usar forma abreviada
#let format-millennium(millennium, bc: false, abbreviated: false) = {
  let roman = to-roman(millennium)
  let suffix = if bc { " a.C." } else { "" }

  if abbreviated {
    [#roman mil.#suffix]
  } else {
    [#roman milênio#suffix]
  }
}

/// Formata intervalo de meses para legendas bibliograficas
/// Exemplo: "jan./mar." ou "janeiro/março"
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
