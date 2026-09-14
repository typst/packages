// ============================================================================
// ferrmat – Módulo de Unidades e Números (equivalente ao siunitx do LaTeX)
// Formatação de números, unidades SI e quantidades com padrões brasileiros.
// ============================================================================

// ---------------------------------------------------------------------------
// Constantes Unicode
// ---------------------------------------------------------------------------

#let _efino = "\u{2009}" // thin space (separador de milhar SI)
#let _emenos = "\u{2212}" // minus sign correto
#let _evezes = "\u{00D7}" // multiplication sign ×

// ---------------------------------------------------------------------------
// Estado global de configuração
// ---------------------------------------------------------------------------

#let _config-numeros = state("ferrmat-config-numeros", (
  decimal: ",",
  milhar: _efino,
  grupo: 3,
  minimo-agrupamento: 5, // ≤4 dígitos não agrupam (regra SI)
  notacao: auto, // auto, "cientifica", "fixa"
  limiar-superior: 1000000000, // 10⁹
  limiar-inferior: 0.001,
  unidade-modo: "simbolo", // "simbolo", "produto"
  separador-unidade: _efino,
  unidade-produto: sym.dot.op,
))

// Banco de unidades customizadas do usuário
#let _unidades-custom = state("ferrmat-unidades-custom", (:))

// ---------------------------------------------------------------------------
// Banco de unidades SI
// ---------------------------------------------------------------------------

#let _banco-unidades = (
  // --- 7 unidades de base ---
  "m":   (nome: "metro",      plural: "metros"),
  "kg":  (nome: "quilograma", plural: "quilogramas"),
  "s":   (nome: "segundo",    plural: "segundos"),
  "A":   (nome: "ampère",     plural: "ampères"),
  "K":   (nome: "kelvin",     plural: "kelvins"),
  "mol": (nome: "mol",        plural: "mols"),
  "cd":  (nome: "candela",    plural: "candelas"),

  // --- Unidades derivadas com nome ---
  "Hz":  (nome: "hertz",      plural: "hertz"),
  "N":   (nome: "newton",     plural: "newtons"),
  "Pa":  (nome: "pascal",     plural: "pascals"),
  "J":   (nome: "joule",      plural: "joules"),
  "W":   (nome: "watt",       plural: "watts"),
  "C":   (nome: "coulomb",    plural: "coulombs"),
  "V":   (nome: "volt",       plural: "volts"),
  "F":   (nome: "farad",      plural: "farads"),
  "Ω":   (nome: "ohm",        plural: "ohms"),
  "ohm": (nome: "ohm",        plural: "ohms"),
  "S":   (nome: "siemens",    plural: "siemens"),
  "Wb":  (nome: "weber",      plural: "webers"),
  "T":   (nome: "tesla",      plural: "teslas"),
  "H":   (nome: "henry",      plural: "henrys"),
  "lm":  (nome: "lúmen",      plural: "lúmens"),
  "lx":  (nome: "lux",        plural: "lux"),
  "Bq":  (nome: "becquerel",  plural: "becquerels"),
  "Gy":  (nome: "gray",       plural: "grays"),
  "Sv":  (nome: "sievert",    plural: "sieverts"),
  "kat": (nome: "katal",      plural: "katals"),
  "rad": (nome: "radiano",    plural: "radianos"),
  "sr":  (nome: "esferorradiano", plural: "esferorradianos"),

  // --- Unidades aceitas pelo SI ---
  "L":   (nome: "litro",      plural: "litros"),
  "l":   (nome: "litro",      plural: "litros"),
  "min": (nome: "minuto",     plural: "minutos"),
  "h":   (nome: "hora",       plural: "horas"),
  "d":   (nome: "dia",        plural: "dias"),
  "ha":  (nome: "hectare",    plural: "hectares"),
  "t":   (nome: "tonelada",   plural: "toneladas"),
  "eV":  (nome: "elétron-volt", plural: "elétrons-volt"),
  "u":   (nome: "unidade de massa atômica", plural: "unidades de massa atômica"),
  "Da":  (nome: "dalton",     plural: "daltons"),
  "au":  (nome: "unidade astronômica", plural: "unidades astronômicas"),

  // --- Unidades brasileiras / uso comum ---
  "bar":  (nome: "bar",       plural: "bars"),
  "atm":  (nome: "atmosfera", plural: "atmosferas"),
  "mmHg": (nome: "milímetro de mercúrio", plural: "milímetros de mercúrio"),
  "rpm":  (nome: "rotação por minuto", plural: "rotações por minuto"),
  "cal":  (nome: "caloria",   plural: "calorias"),
  "Wh":   (nome: "watt-hora", plural: "watts-hora"),
  "Ah":   (nome: "ampère-hora", plural: "ampères-hora"),
  "dB":   (nome: "decibel",   plural: "decibéis"),

  // --- Ângulo (grau, minuto, segundo de arco) ---
  "deg":  (nome: "grau",      plural: "graus"),
  "°":    (nome: "grau",      plural: "graus"),
  "arcmin": (nome: "minuto de arco", plural: "minutos de arco"),
  "arcsec": (nome: "segundo de arco", plural: "segundos de arco"),

  // --- Percentagem ---
  "%":   (nome: "por cento",  plural: "por cento"),
)

// ---------------------------------------------------------------------------
// Prefixos SI (incluindo 2022: quetta, ronna, ronto, quecto)
// Ordenados por comprimento do símbolo (desc) para matching correto.
// ---------------------------------------------------------------------------

#let _prefixos-si = (
  // dois caracteres primeiro
  (simbolo: "da", nome: "deca",   fator: 1),
  // um caractere — maiores primeiro
  (simbolo: "Q",  nome: "quetta", fator: 30),
  (simbolo: "R",  nome: "ronna",  fator: 27),
  (simbolo: "Y",  nome: "yotta",  fator: 24),
  (simbolo: "Z",  nome: "zetta",  fator: 21),
  (simbolo: "E",  nome: "exa",    fator: 18),
  (simbolo: "P",  nome: "peta",   fator: 15),
  // "T" conflita com tesla — resolvido por exact-match primeiro
  (simbolo: "G",  nome: "giga",   fator: 9),
  (simbolo: "M",  nome: "mega",   fator: 6),
  (simbolo: "k",  nome: "quilo",  fator: 3),
  // "h" conflita com hora — resolvido por exact-match primeiro
  // "d" conflita com dia  — resolvido por exact-match primeiro
  (simbolo: "c",  nome: "centi",  fator: -2),
  // "m" conflita com metro — resolvido por exact-match primeiro
  (simbolo: "µ",  nome: "micro",  fator: -6),
  (simbolo: "u",  nome: "micro",  fator: -6), // alias ASCII
  (simbolo: "n",  nome: "nano",   fator: -9),
  (simbolo: "p",  nome: "pico",   fator: -12),
  (simbolo: "f",  nome: "femto",  fator: -15),
  (simbolo: "a",  nome: "atto",   fator: -18),
  (simbolo: "z",  nome: "zepto",  fator: -21),
  (simbolo: "y",  nome: "yocto",  fator: -24),
  (simbolo: "r",  nome: "ronto",  fator: -27),
  (simbolo: "q",  nome: "quecto", fator: -30),
)

// Lookup rápido: símbolo do prefixo → dados do prefixo (O(1) em vez de iteração)
#let _prefixo-lookup = {
  let d = (:)
  for pref in _prefixos-si {
    if pref.simbolo not in d {
      d.insert(pref.simbolo, pref)
    }
  }
  d
}

// ---------------------------------------------------------------------------
// Helpers internos — manipulação de strings
// ---------------------------------------------------------------------------

/// Repete uma string `n` vezes.
#let _repetir(s, n) = {
  if n <= 0 { return "" }
  range(n).map(_ => s).join()
}

/// Agrupa dígitos da direita para a esquerda (parte inteira).
#let _agrupar-inteiro(digitos, grupo) = {
  let n = digitos.len()
  if n <= grupo { return (digitos,) }
  let resultado = ()
  let i = n
  while i > 0 {
    let inicio = calc.max(0, i - grupo)
    resultado.insert(0, digitos.slice(inicio, i))
    i = inicio
  }
  resultado
}

/// Agrupa dígitos da esquerda para a direita (parte decimal).
#let _agrupar-decimal(digitos, grupo) = {
  let n = digitos.len()
  if n <= grupo { return (digitos,) }
  let resultado = ()
  let i = 0
  while i < n {
    let fim = calc.min(n, i + grupo)
    resultado.push(digitos.slice(i, fim))
    i = fim
  }
  resultado
}

/// Garante exatamente `casas` dígitos decimais na string de um número.
/// Ex: _garantir-casas("3", 2) → "3.00"; _garantir-casas("3.1", 2) → "3.10"
#let _garantir-casas(s, casas) = {
  if casas == 0 {
    if "." in s { s.split(".").at(0) } else { s }
  } else {
    let partes = if "." in s { s.split(".") } else { (s, "") }
    let inteiro = partes.at(0)
    let decimal = partes.at(1)
    if decimal.len() < casas {
      inteiro + "." + decimal + _repetir("0", casas - decimal.len())
    } else if decimal.len() > casas {
      inteiro + "." + decimal.slice(0, casas)
    } else {
      inteiro + "." + decimal
    }
  }
}

// ---------------------------------------------------------------------------
// Arredondamento
// ---------------------------------------------------------------------------

/// Arredonda para `n` algarismos significativos.
#let _arredondar-sig(valor, n) = {
  if valor == 0 { return 0 }
  let mag = calc.floor(calc.log(calc.abs(valor), base: 10))
  let casas = n - 1 - mag
  if casas >= 0 {
    calc.round(valor, digits: casas)
  } else {
    // calc.round não suporta digits negativo; usar fator
    let fator = calc.pow(10.0, -casas)
    calc.round(valor / fator) * fator
  }
}

// ---------------------------------------------------------------------------
// Formatação interna de número → conteúdo
// ---------------------------------------------------------------------------

/// Formata um número e retorna conteúdo Typst.
/// `config` é o dicionário de configuração (já mesclado com overrides).
#let _formatar-numero(valor, config) = {
  // --- Converter para float para operações ---
  let v = if type(valor) == str { float(valor) } else { float(valor) }

  // --- Valores especiais (NaN, Inf) ---
  // NaN: a única valor onde v != v é verdadeiro
  if v != v { return [NaN] }
  if v == float.inf { return [#sym.infinity] }
  if v == -float.inf { return [#_emenos#sym.infinity] }

  let negativo = v < 0
  let v = calc.abs(v)

  // --- Limpar ruído de ponto flutuante IEEE 754 ---
  // Arredonda para 12 algarismos significativos quando nenhum arredondamento explícito
  if v != 0 and config.at("casas", default: none) == none {
    v = _arredondar-sig(v, 12)
  }

  // --- Arredondamento ---
  let casas-exibir = none // casas decimais para exibição (zeros à direita)
  if config.at("casas", default: none) != none {
    casas-exibir = config.casas
    v = calc.round(v, digits: config.casas)
  }

  // --- Notação científica ---
  let expoente = none
  let usar-cientifica = config.at("notacao") == "cientifica"
  if config.at("notacao") == auto and v != 0 {
    if v >= config.at("limiar-superior") or v < config.at("limiar-inferior") {
      usar-cientifica = true
    }
  }

  if usar-cientifica and v != 0 {
    let mag = calc.floor(calc.log(v, base: 10))
    expoente = mag
    v = v / calc.pow(10.0, mag)
    // Re-limpar ruído de float após divisão
    v = _arredondar-sig(v, 12)
    // Re-arredondar a mantissa
    if config.at("casas", default: none) != none {
      v = calc.round(v, digits: config.casas)
    }
  }

  // --- Suprimir mantissa = 1 em notação científica ---
  let suprimir-mantissa = false
  if usar-cientifica and v == 1.0 and config.at("casas", default: none) == none {
    suprimir-mantissa = true
  }

  // --- Suprimir expoente = 0 ---
  if expoente != none and expoente == 0 {
    expoente = none
  }

  // --- Converter para string com zeros preservados ---
  let s = str(v)
  if casas-exibir != none and config.at("preservar-zeros", default: true) {
    s = _garantir-casas(s, casas-exibir)
  }

  // --- Separar parte inteira e decimal ---
  let partes = if "." in s { s.split(".") } else { (s,) }
  let digitos-int = partes.at(0)
  let digitos-dec = if partes.len() > 1 { partes.at(1) } else { none }

  // --- Agrupamento ---
  let separador = config.at("milhar")
  let agrupamento = config.at("minimo-agrupamento")
  let grupo = config.at("grupo")

  let int-formatado = if digitos-int.len() >= agrupamento {
    _agrupar-inteiro(digitos-int, grupo).join(separador)
  } else {
    digitos-int
  }

  let dec-formatado = if digitos-dec != none and digitos-dec.len() > grupo {
    _agrupar-decimal(digitos-dec, grupo).join(separador)
  } else {
    digitos-dec
  }

  // --- Montar conteúdo ---
  let resultado = []
  if negativo {
    resultado = resultado + [#_emenos]
  }

  if not suprimir-mantissa {
    resultado = resultado + [#int-formatado]
    if dec-formatado != none {
      resultado = resultado + [#config.at("decimal")#dec-formatado]
    }
  }

  // --- Expoente (notação científica) ---
  if expoente != none {
    if not suprimir-mantissa {
      resultado = resultado + [ #_evezes ]
    }
    let exp-str = if expoente < 0 { _emenos + str(calc.abs(expoente)) } else { str(expoente) }
    resultado = resultado + [10#super[#exp-str]]
  }

  resultado
}

// ---------------------------------------------------------------------------
// Parsing de unidades
// ---------------------------------------------------------------------------

/// Resolve um token de unidade (ex: "km", "MHz") → (simbolo, nome, plural, prefixo)
#let _resolver-unidade(token, banco, custom) = {
  // 1. Exato no custom
  if token in custom {
    let dados = custom.at(token)
    return (
      simbolo: dados.at("simbolo", default: token),
      nome: dados.at("nome", default: token),
      plural: dados.at("plural", default: token),
      prefixo: "",
    )
  }

  // 2. Exato no banco padrão
  if token in banco {
    let dados = banco.at(token)
    return (
      simbolo: token,
      nome: dados.nome,
      plural: dados.plural,
      prefixo: "",
    )
  }

  // 3. Tentar prefixo + unidade base via lookup O(1)
  //    Tenta prefixo de 2 caracteres primeiro, depois 1 caractere.
  //    Usa clusters() para lidar com caracteres multibyte (ex: µ).
  let chars = token.clusters()
  for plen in (2, 1) {
    if chars.len() > plen {
      let ps = chars.slice(0, plen).join()
      if ps in _prefixo-lookup {
        let pref = _prefixo-lookup.at(ps)
        let resto = chars.slice(plen).join()
        if resto in banco {
          let dados = banco.at(resto)
          let ps-display = if ps == "u" { "µ" } else { ps }
          return (
            simbolo: ps-display + resto,
            nome: pref.nome + dados.nome,
            plural: pref.nome + dados.plural,
            prefixo: ps-display,
          )
        }
      }
    }
  }

  // 4. Desconhecido — usar como está
  (simbolo: token, nome: token, plural: token, prefixo: "")
}

/// Analisa um token de unidade com potência: "m^2" → (token: "m", potencia: 2)
#let _parse-token-potencia(s) = {
  if "^" in s {
    let partes = s.split("^")
    assert(partes.len() == 2,
      message: "unidade: potência inválida em \"" + s + "\" (use formato \"unidade^n\")")
    assert(partes.at(0).len() > 0,
      message: "unidade: token vazio antes de ^ em \"" + s + "\"")
    (token: partes.at(0), potencia: int(partes.at(1)))
  } else {
    (token: s, potencia: 1)
  }
}

/// Analisa string de unidade completa: "kg.m/s^2" → (num: [...], den: [...])
#let _parse-unidade-str(s) = {
  let num-str = s
  let den-str = none

  // Separar numerador / denominador
  if "/" in s {
    let idx = s.position("/")
    num-str = s.slice(0, idx)
    den-str = s.slice(idx + 1)
    // Remover parênteses do denominador: "(kg.K)" → "kg.K"
    if den-str.starts-with("(") and den-str.ends-with(")") {
      den-str = den-str.slice(1, den-str.len() - 1)
    }
  }

  let numerador = num-str.split(".").map(_parse-token-potencia)
  let denominador = if den-str != none {
    den-str.split(".").map(_parse-token-potencia)
  } else {
    ()
  }

  (numerador: numerador, denominador: denominador)
}

// ---------------------------------------------------------------------------
// Renderização de unidades
// ---------------------------------------------------------------------------

/// Renderiza um único token de unidade resolvido com sua potência.
#let _renderizar-token(token-info, potencia) = {
  let simb = token-info.simbolo
  if potencia == 1 {
    math.upright(simb)
  } else {
    math.attach(math.upright(simb), t: [#potencia])
  }
}

/// Renderiza uma lista de tokens como produto (com separador).
#let _renderizar-produto(tokens, separador) = {
  tokens.join(separador)
}

/// Formata unidade completa em modo símbolo.
/// `parsed` é resultado de _parse-unidade-str, `banco` e `custom` são os bancos de dados.
#let _formatar-unidade-simbolo(parsed, banco, custom, config) = {
  let sep = [#h(0.16667em)]
  let prod = config.at("unidade-produto")

  let num-tokens = parsed.numerador.map(item => {
    let info = _resolver-unidade(item.token, banco, custom)
    _renderizar-token(info, item.potencia)
  })

  let den-tokens = parsed.denominador.map(item => {
    let info = _resolver-unidade(item.token, banco, custom)
    _renderizar-token(info, item.potencia)
  })

  if den-tokens.len() == 0 {
    // Só numerador
    math.equation(block: false, _renderizar-produto(num-tokens, [#prod]))
  } else {
    // Modo fração: num / den
    let num-content = _renderizar-produto(num-tokens, [#prod])
    let den-content = _renderizar-produto(den-tokens, [#prod])
    math.equation(block: false, [#num-content \/ #den-content])
  }
}

/// Formata unidade em modo produto (tudo com expoentes, sem fração).
#let _formatar-unidade-produto(parsed, banco, custom, config) = {
  let prod = config.at("unidade-produto")

  let todos = parsed.numerador.map(item => {
    let info = _resolver-unidade(item.token, banco, custom)
    _renderizar-token(info, item.potencia)
  })

  // Denominador entra com expoentes negativos
  for item in parsed.denominador {
    let info = _resolver-unidade(item.token, banco, custom)
    todos.push(_renderizar-token(info, -item.potencia))
  }

  math.equation(block: false, _renderizar-produto(todos, [#prod]))
}

// ---------------------------------------------------------------------------
// Helpers para mesclar config com overrides locais
// ---------------------------------------------------------------------------

#let _mesclar-config(config, notacao, limiar-superior, limiar-inferior) = {
  let c = config
  if notacao != auto { c.insert("notacao", notacao) }
  if limiar-superior != auto { c.insert("limiar-superior", limiar-superior) }
  if limiar-inferior != auto { c.insert("limiar-inferior", limiar-inferior) }
  c
}

// ===================================================================
// ATALHOS PARA MODO MATEMÁTICO
// ===================================================================

// ---------------------------------------------------------------------------
// ee — notação científica (×10^n) para uso dentro de $...$
// ---------------------------------------------------------------------------

/// Notação científica para modo matemático: `$6,022 ee(23)$` → 6,022 × 10²³
#let ee(n) = $times 10^#n$

// ---------------------------------------------------------------------------
// Atalhos de unidades — variáveis para uso direto dentro de $...$
// Cada uma inclui espaço fino embutido para separar número da unidade.
// ---------------------------------------------------------------------------

/// m/s² — aceleração: `$9,8 mss$`
#let mss = $thin "m/s"^2$
/// m/s — velocidade: `$25 ms$`
#let ms = $thin "m/s"$
/// m² — área: `$25 msq$`
#let msq = $thin "m"^2$
/// m³ — volume: `$10 mcb$`
#let mcb = $thin "m"^3$
/// km/h — velocidade: `$120 kmh$`
#let kmh = $thin "km/h"$
/// kg/m³ — densidade: `$1000 kgm$`
#let kgm = $thin "kg/m"^3$
/// mol⁻¹ — inverso de mol: `$6,022 ee(23) molinv$`
#let molinv = $thin "mol"^(-1)$
/// J/mol — energia molar: `$8,314 jmol$`
#let jmol = $thin "J/mol"$

// ===================================================================
// API PÚBLICA
// ===================================================================

// ---------------------------------------------------------------------------
// num — formatar número
// ---------------------------------------------------------------------------

/// Formata um número com separadores brasileiros e notação científica.
///
/// - `valor`: Número (int, float ou string).
/// - `notacao`: `auto`, `"cientifica"` ou `"fixa"`.
///
/// ```example
/// #num(3.14159)            // → 3,14159
/// #num(1234567.89)         // → 1 234 567,89
/// #num("2.998e8")          // → 2,998 × 10⁸
/// ```
#let num(
  valor,
  casas: auto,          // uso interno (tablenum, ang)
  preservar-zeros: auto, // uso interno (tablenum)
  notacao: auto,
  limiar-superior: auto,
  limiar-inferior: auto,
  expoente: none,
) = context {
  let config = _config-numeros.get()
  let config = _mesclar-config(config, notacao, limiar-superior, limiar-inferior)
  if casas != auto { config.insert("casas", casas) }
  if preservar-zeros != auto { config.insert("preservar-zeros", preservar-zeros) }

  // Forçar expoente específico
  if expoente != none {
    config.insert("notacao", "cientifica")
  }

  // Lidar com expoente embutido na string: "2.998e8"
  // Passa a mantissa diretamente + força notação científica com expoente fixo
  // para evitar perda de precisão ao multiplicar floats grandes.
  let valor-real = valor
  let exp-embutido = none
  if type(valor) == str and ("e" in valor or "E" in valor) {
    let partes = valor.split(regex("[eE]"))
    valor-real = float(partes.at(0)) // manter só a mantissa como float
    exp-embutido = int(partes.at(1))
    if config.at("notacao") == auto {
      config.insert("notacao", "cientifica")
    }
  }

  let corpo = _formatar-numero(valor-real, config)

  // Se havia expoente embutido na string, compor com o expoente da formatação
  if exp-embutido != none {
    // Normalizar mantissa para [1, 10) e somar expoente
    let mantissa-config = config
    mantissa-config.insert("notacao", "fixa")
    let mantissa = _formatar-numero(valor-real, mantissa-config)
    let exp-total = exp-embutido

    if valor-real != 0 and (calc.abs(valor-real) >= 10 or calc.abs(valor-real) < 1) {
      let mag = calc.floor(calc.log(calc.abs(valor-real), base: 10))
      let v-norm = valor-real / calc.pow(10.0, mag)
      exp-total = exp-embutido + mag
      let norm-config = config
      norm-config.insert("notacao", "fixa")
      mantissa = _formatar-numero(v-norm, norm-config)
    }
    let exp-str = if exp-total < 0 { _emenos + str(calc.abs(exp-total)) } else { str(exp-total) }
    corpo = [#mantissa #_evezes 10#super[#exp-str]]
  }

  corpo
}

// ---------------------------------------------------------------------------
// unidade — formatar unidade
// ---------------------------------------------------------------------------

/// Formata uma unidade SI a partir de string.
///
/// Sintaxe da string:
/// - `.` separa unidades multiplicadas: `"kg.m"` → kg⋅m
/// - `/` separa numerador/denominador: `"m/s"` → m/s
/// - `^` indica potência: `"m^2"` → m²
/// - `()` agrupa denominador: `"J/(kg.K)"` → J/(kg⋅K)
///
/// - `modo`: `"simbolo"` (padrão), `"produto"` (tudo com expoentes), `"por"` (texto extenso)
///
/// ```example
/// #unidade("m/s^2")        // → m/s²
/// #unidade("kg.m/s^2")     // → kg⋅m/s²
/// ```
#let unidade(
  u,
  modo: auto,
) = context {
  let config = _config-numeros.get()
  let custom = _unidades-custom.get()
  let modo = if modo != auto { modo } else { config.at("unidade-modo") }
  let parsed = _parse-unidade-str(u)

  if modo == "produto" {
    _formatar-unidade-produto(parsed, _banco-unidades, custom, config)
  } else {
    _formatar-unidade-simbolo(parsed, _banco-unidades, custom, config)
  }
}

/// Alias curto para `unidade()`.
#let un = unidade

// ---------------------------------------------------------------------------
// qtd — quantidade (número + unidade)
// ---------------------------------------------------------------------------

/// Formata uma quantidade: número + espaço fino + unidade.
///
/// ```example
/// #qtd(9.8, "m/s^2")        // → 9,8 m/s²
/// #qtd(3.14, "rad")         // → 3,14 rad
/// #qtd(1e6, "Hz")           // → 10⁶ Hz
/// ```
#let qtd(
  valor,
  u,
  notacao: auto,
  limiar-superior: auto,
  limiar-inferior: auto,
  expoente: none,
  modo-unidade: auto,
) = {
  let n = num(
    valor,
    notacao: notacao,
    limiar-superior: limiar-superior,
    limiar-inferior: limiar-inferior,
    expoente: expoente,
  )
  let un = unidade(u, modo: modo-unidade)
  [#n#h(0.16667em)#un]
}

// ---------------------------------------------------------------------------
// declarar-unidade — registrar unidade customizada
// ---------------------------------------------------------------------------

/// Registra uma unidade customizada no banco de dados.
///
/// ```example
/// #declarar-unidade("pH", nome: "pH", plural: "pH")
/// #qtd(7.4, "pH") // → 7,4 pH
/// ```
#let declarar-unidade(
  simbolo,
  nome: none,
  plural: none,
) = {
  _unidades-custom.update(d => {
    d.insert(simbolo, (
      simbolo: simbolo,
      nome: if nome != none { nome } else { simbolo },
      plural: if plural != none { plural } else { if nome != none { nome } else { simbolo } },
    ))
    d
  })
}

// ---------------------------------------------------------------------------
// configurar-numeros — alterar configuração global
// ---------------------------------------------------------------------------

/// Altera a configuração global de formatação de números.
///
/// ```example
/// #configurar-numeros(decimal: ".", milhar: ",")
/// #num(1234.56) // → 1,234.56
/// ```
#let configurar-numeros(
  decimal: auto,
  milhar: auto,
  grupo: auto,
  minimo-agrupamento: auto,
  notacao: auto,
  limiar-superior: auto,
  limiar-inferior: auto,
  unidade-modo: auto,
  separador-unidade: auto,
  unidade-produto: auto,
) = _config-numeros.update(config => {
  if decimal != auto { config.insert("decimal", decimal) }
  if milhar != auto { config.insert("milhar", milhar) }
  if grupo != auto { config.insert("grupo", grupo) }
  if minimo-agrupamento != auto { config.insert("minimo-agrupamento", minimo-agrupamento) }
  if notacao != auto { config.insert("notacao", notacao) }
  if limiar-superior != auto { config.insert("limiar-superior", limiar-superior) }
  if limiar-inferior != auto { config.insert("limiar-inferior", limiar-inferior) }
  if unidade-modo != auto { config.insert("unidade-modo", unidade-modo) }
  if separador-unidade != auto { config.insert("separador-unidade", separador-unidade) }
  if unidade-produto != auto { config.insert("unidade-produto", unidade-produto) }
  config
})

// ---------------------------------------------------------------------------
// faixa-num / faixa-qtd — intervalos
// ---------------------------------------------------------------------------

/// Formata um intervalo de números: "a a b".
///
/// ```example
/// #faixa-num(1, 5) // → 1 a 5
/// ```
#let faixa-num(a, b) = {
  [#num(a) a #num(b)]
}

/// Formata um intervalo com unidade: "a u a b u" ou "a a b u".
///
/// ```example
/// #faixa-qtd(20, 25, "°C") // → 20 °C a 25 °C
/// #faixa-qtd(1, 5, "m", repetir-unidade: false) // → 1 a 5 m
/// ```
#let faixa-qtd(a, b, u, repetir-unidade: true) = {
  if repetir-unidade {
    [#qtd(a, u) a #qtd(b, u)]
  } else {
    [#num(a) a #num(b)#h(0.16667em)#unidade(u)]
  }
}

// ---------------------------------------------------------------------------
// lista-num / lista-qtd — listas
// ---------------------------------------------------------------------------

/// Formata uma lista de números: "a, b e c".
///
/// ```example
/// #lista-num(1, 2, 3) // → 1, 2 e 3
/// ```
#let lista-num(..valores) = {
  let vals = valores.pos()
  if vals.len() == 0 { return [] }
  if vals.len() == 1 { return num(vals.first()) }
  let formatados = vals.map(v => num(v))
  let init = formatados.slice(0, -1).join([, ])
  [#init e #formatados.last()]
}

/// Formata uma lista de quantidades: "a u, b u e c u".
///
/// ```example
/// #lista-qtd(1, 2, 3, u: "m") // → 1 m, 2 m e 3 m
/// #lista-qtd(1, 2, 3, u: "kg", repetir-unidade: false) // → 1, 2 e 3 kg
/// ```
#let lista-qtd(..args) = {
  let u = args.named().at("u")
  let repetir = args.named().at("repetir-unidade", default: true)
  let valores = args.pos()
  if valores.len() == 0 { return [] }
  if repetir {
    let items = valores.map(v => [#num(v)#h(0.16667em)#unidade(u)])
    if items.len() == 1 { return items.first() }
    let init = items.slice(0, -1).join([, ])
    [#init e #items.last()]
  } else {
    let items = valores.map(v => num(v))
    if items.len() == 1 { return [#items.first()#h(0.16667em)#unidade(u)] }
    let init = items.slice(0, -1).join([, ])
    [#init e #items.last()#h(0.16667em)#unidade(u)]
  }
}

// ---------------------------------------------------------------------------
// ang — ângulos
// ---------------------------------------------------------------------------

/// Formata um ângulo em graus, minutos e segundos.
///
/// ```example
/// #ang(45.5)                              // → 45,5°
/// #ang(45, minutos: 30)                   // → 45°30′
/// #ang(45, minutos: 30, segundos: 15)     // → 45°30′15″
/// ```
#let ang(graus, minutos: none, segundos: none) = context {
  let config = _config-numeros.get()
  if minutos == none and segundos == none {
    let g = _formatar-numero(float(graus), config)
    [#g°]
  } else {
    [#int(graus)°#if minutos != none [#int(minutos)′]#if segundos != none [#int(segundos)″]]
  }
}

// ---------------------------------------------------------------------------
// tablenum — número alinhado para tabelas
// ---------------------------------------------------------------------------

/// Formata um número para uso em tabelas, com alinhamento à direita.
///
/// ```example
/// #tablenum(3.14, casas: 2, largura: 100%)
/// ```
#let tablenum(valor, casas: auto, largura: auto) = {
  let n = num(valor, casas: casas, preservar-zeros: true)
  if largura != auto {
    box(width: largura, align(right, n))
  } else {
    n
  }
}

