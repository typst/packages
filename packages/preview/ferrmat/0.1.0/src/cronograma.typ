// =============================================================================
// cronograma.typ — Módulo de gráfico de Gantt para ferrmat
// Usa CeTZ como engine de desenho
// =============================================================================

#import "@preview/cetz:0.4.0"
#import "cores.typ": *

// =============================================================================
// Seção 1: Utilitários de data
// =============================================================================

/// Cria um dicionário de data. Formato brasileiro: dia, mês, ano.
#let data(dia, mes, ano) = {
  assert(type(mes) == int and mes >= 1 and mes <= 12,
    message: "data: 'mes' deve ser inteiro entre 1 e 12, recebeu " + repr(mes))
  assert(type(dia) == int and dia >= 1 and dia <= 31,
    message: "data: 'dia' deve ser inteiro entre 1 e 31, recebeu " + repr(dia))
  assert(type(ano) == int,
    message: "data: 'ano' deve ser inteiro, recebeu " + repr(ano))
  (ano: ano, mes: mes, dia: dia)
}

/// Retorna true se o ano é bissexto.
#let _bissexto(ano) = {
  calc.rem(ano, 4) == 0 and (calc.rem(ano, 100) != 0 or calc.rem(ano, 400) == 0)
}

/// Retorna o número de dias em um mês.
#let _dias-no-mes(ano, mes) = {
  let tabela = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  if mes == 2 and _bissexto(ano) { 29 } else { tabela.at(mes - 1) }
}

/// Converte uma data-dict para um número ordinal de dias (desde uma época fixa).
/// Usa uma fórmula simples: acumula dias por ano e mês.
#let _data-para-dias(d) = {
  let dias = 0
  // Acumular anos completos (simplificado — conta de 1 até ano-1)
  dias += (d.ano - 1) * 365
  dias += calc.floor((d.ano - 1) / 4)
  dias -= calc.floor((d.ano - 1) / 100)
  dias += calc.floor((d.ano - 1) / 400)
  // Acumular meses completos do ano corrente
  let m = 1
  while m < d.mes {
    dias += _dias-no-mes(d.ano, m)
    m += 1
  }
  dias += d.dia
  dias
}

/// Diferença em dias entre duas datas (d2 - d1).
#let _diff-dias(d1, d2) = {
  _data-para-dias(d2) - _data-para-dias(d1)
}

/// Gera array de meses entre início e fim.
/// Cada item: (ano: int, mes: int, dia-inicio: int, dia-fim: int, dias-visiveis: int)
#let _gerar-meses(inicio, fim) = {
  let meses = ()
  let ano = inicio.ano
  let mes = inicio.mes

  while ano < fim.ano or (ano == fim.ano and mes <= fim.mes) {
    let dim = _dias-no-mes(ano, mes)

    let d-inicio = if ano == inicio.ano and mes == inicio.mes { inicio.dia } else { 1 }
    let d-fim = if ano == fim.ano and mes == fim.mes { fim.dia } else { dim }

    meses.push((
      ano: ano,
      mes: mes,
      dia-inicio: d-inicio,
      dia-fim: d-fim,
      dias-visiveis: d-fim - d-inicio + 1,
    ))

    mes += 1
    if mes > 12 {
      mes = 1
      ano += 1
    }
  }
  meses
}

/// Gera subdivisões semanais entre início e fim.
/// Cada item: (inicio: data, dias: int)
#let _gerar-semanas(inicio, fim) = {
  let semanas = ()
  let d-atual = inicio
  let total = _diff-dias(inicio, fim) + 1

  let consumidos = 0
  while consumidos < total {
    // Dias até domingo (dia 7). Dia da semana é aproximado:
    // Usamos Zeller simplificado — mas como não precisamos de precisão de dia-da-semana,
    // vamos simplesmente dividir em blocos de 7 dias.
    let restantes = total - consumidos
    let dias-semana = calc.min(7, restantes)

    semanas.push((
      offset: consumidos,
      dias: dias-semana,
    ))

    consumidos += dias-semana
  }
  semanas
}

/// Adiciona n dias a uma data-dict.
#let _adicionar-dias(d, n) = {
  let dia = d.dia + n
  let mes = d.mes
  let ano = d.ano
  while dia > _dias-no-mes(ano, mes) {
    dia -= _dias-no-mes(ano, mes)
    mes += 1
    if mes > 12 { mes = 1; ano += 1 }
  }
  while dia < 1 {
    mes -= 1
    if mes < 1 { mes = 12; ano -= 1 }
    dia += _dias-no-mes(ano, mes)
  }
  (ano: ano, mes: mes, dia: dia)
}

// Nomes abreviados dos meses em português
#let _meses-pt = ("Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez")
#let _meses-en = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")


// =============================================================================
// Seção 2: Layout engine
// =============================================================================

/// Calcula todas as posições e dimensões do gráfico.
/// Retorna um dicionário com geometria completa.
#let _calcular-layout(
  tarefas,
  inicio,
  fim,
  largura-chart,  // largura da área do gráfico (sem nomes) em pt
  altura-linha,   // altura de cada linha em pt
  cabecalho,
  fonte-cabecalho,
) = {
  let inicio-dias = _data-para-dias(inicio)
  let total-dias = _data-para-dias(fim) - inicio-dias + 1
  assert(total-dias > 0, message: "cronograma: intervalo de datas inválido (fim deve ser após início)")

  let escala-x = largura-chart / total-dias  // pt por dia

  // Calcular posições das tarefas (considerar grupos)
  let linhas = ()
  let grupo-atual = none
  let y-pos = 0

  for t in tarefas {
    // Separador de grupo
    if t.at("grupo", default: none) != none and t.grupo != grupo-atual {
      linhas.push((tipo: "grupo", nome: t.grupo, y: y-pos))
      grupo-atual = t.grupo
      y-pos += 1
    }

    let t-inicio = calc.max(0, _data-para-dias(t.inicio) - inicio-dias)
    let t-fim = calc.max(0, _data-para-dias(t.fim) - inicio-dias)
    // Clamp ao range visível
    let t-inicio-c = calc.min(calc.max(t-inicio, 0), total-dias - 1)
    let t-fim-c = calc.min(calc.max(t-fim, 0), total-dias - 1)

    linhas.push((
      tipo: if t.at("marco", default: false) { "marco" } else { "tarefa" },
      nome: t.nome,
      x-inicio: t-inicio-c * escala-x,
      x-fim: (t-fim-c + 1) * escala-x,  // +1 pois o dia é inclusivo
      y: y-pos,
      cor: t.at("cor", default: none),
      progresso: t.at("progresso", default: none),
      rotulo: t.at("rotulo", default: none),
      depende-de: t.at("depende-de", default: ()),
    ))
    y-pos += 1
  }

  // Gerar cabeçalhos
  let meses = _gerar-meses(inicio, fim)

  let cab-nivel1 = ()  // meses
  let offset-acum = 0
  for m in meses {
    let x = offset-acum * escala-x
    let w = m.dias-visiveis * escala-x
    cab-nivel1.push((
      x: x,
      largura: w,
      texto: m.mes,  // índice do mês (1-12)
      ano: m.ano,
    ))
    offset-acum += m.dias-visiveis
  }

  // Nível 2: semanas ou dias
  let cab-nivel2 = ()
  if cabecalho == "mes-semana" or cabecalho == "semana" {
    // Gerar blocos de 7 dias POR MÊS, com labels = dia do mês
    let offset-global = 0
    for m in meses {
      let dia = m.dia-inicio
      let dias-restantes = m.dias-visiveis
      while dias-restantes > 0 {
        let dias-bloco = calc.min(7, dias-restantes)
        let x = offset-global * escala-x
        let w = dias-bloco * escala-x
        cab-nivel2.push((x: x, largura: w, texto: str(dia)))
        dia += dias-bloco
        offset-global += dias-bloco
        dias-restantes -= dias-bloco
      }
    }
  } else if cabecalho == "mes-dia" or cabecalho == "dia" {
    let d = 0
    while d < total-dias {
      let x = d * escala-x
      cab-nivel2.push((x: x, largura: escala-x, texto: str(d + 1)))
      d += 1
    }
  }

  // Linha do hoje
  let hoje-x = none

  (
    total-dias: total-dias,
    escala-x: escala-x,
    linhas: linhas,
    total-linhas: y-pos,
    cab-nivel1: cab-nivel1,
    cab-nivel2: cab-nivel2,
    largura-chart: largura-chart,
  )
}


// =============================================================================
// Seção 3: Renderizador CeTZ
// =============================================================================

/// Altura do cabeçalho em unidades de linha
#let _alt-cabecalho = 2

/// Renderiza o fundo alternado
#let _render-fundo(layout, config) = {
  import cetz.draw: *

  let al = config.altura-linha
  let pitch = al + config.gap
  let y-base = -_alt-cabecalho * al

  for i in range(layout.total-linhas) {
    let linha = layout.linhas.at(i)
    let y = y-base - linha.y * pitch

    if linha.tipo == "grupo" {
      // Fundo do grupo — tom mais escuro
      rect(
        (-config.largura-nomes, y),
        (layout.largura-chart, y - pitch),
        fill: config.cor-grade.lighten(50%),
        stroke: none,
      )
    } else if calc.rem(linha.y, 2) == 1 {
      // Fundo alternado
      rect(
        (0pt, y),
        (layout.largura-chart, y - pitch),
        fill: config.cor-alternada,
        stroke: none,
      )
    }
  }
}

/// Renderiza linhas de grade verticais
#let _render-grade(layout, config) = {
  import cetz.draw: *

  let al = config.altura-linha
  let pitch = al + config.gap
  let y-topo = -_alt-cabecalho * al
  let y-base = y-topo - layout.total-linhas * pitch

  // Linhas verticais para cada mês
  for cab in layout.cab-nivel1 {
    line(
      (cab.x, y-topo),
      (cab.x, y-base),
      stroke: config.espessura-grade + config.cor-grade,
    )
  }
  // Linha final à direita
  line(
    (layout.largura-chart, y-topo),
    (layout.largura-chart, y-base),
    stroke: config.espessura-grade + config.cor-grade,
  )

  // Linhas horizontais para cada tarefa
  for i in range(layout.total-linhas + 1) {
    let y = y-topo - i * pitch
    line(
      (0pt, y),
      (layout.largura-chart, y),
      stroke: config.espessura-grade + config.cor-grade,
    )
  }
}

/// Renderiza o cabeçalho com dois níveis
#let _render-cabecalho(layout, config) = {
  import cetz.draw: *

  let al = config.altura-linha
  let nomes-meses = if config.meses-pt { _meses-pt } else { _meses-en }
  let ct = config.cor-texto

  // Cores do cabeçalho: auto = derivar de cor-padrao; explícito = usar diretamente
  let cor-n1 = if config.cor-cabecalho != auto {
    config.cor-cabecalho
  } else {
    config.cor-padrao.lighten(80%)
  }
  let cor-n2 = if config.cor-cabecalho != auto {
    config.cor-cabecalho.lighten(15%)
  } else {
    config.cor-padrao.lighten(92%)
  }

  // Nível 1: meses
  for cab in layout.cab-nivel1 {
    let x = cab.x
    let w = cab.largura
    let nome = nomes-meses.at(cab.texto - 1)

    // Fundo do cabeçalho mês
    rect(
      (x, 0pt),
      (x + w, -al),
      fill: cor-n1,
      stroke: config.espessura-grade + config.cor-grade,
    )
    // Texto do mês — adapta ao espaço disponível
    let make-text(corpo) = if ct != auto {
      text(size: config.fonte-cabecalho, weight: "bold", fill: ct)[#corpo]
    } else {
      text(size: config.fonte-cabecalho, weight: "bold")[#corpo]
    }
    let texto-completo = make-text[#nome #str(cab.ano)]
    let texto-curto = make-text[#nome]
    let larg-completo = measure(texto-completo).width
    let larg-curto = measure(texto-curto).width
    let pad = 4pt  // margem mínima de cada lado

    if w >= larg-completo + 2 * pad {
      content((x + w / 2, -al / 2), texto-completo)
    } else if w >= larg-curto + 2 * pad {
      content((x + w / 2, -al / 2), texto-curto)
    }
    // Se nem o nome curto cabe, não renderiza texto
  }

  // Nível 2: semanas ou dias
  if layout.cab-nivel2.len() > 0 {
    for cab in layout.cab-nivel2 {
      let x = cab.x
      let w = cab.largura

      rect(
        (x, -al),
        (x + w, -2 * al),
        fill: cor-n2,
        stroke: config.espessura-grade + config.cor-grade,
      )
      // Texto — só mostra se couber com margem
      let txt = if ct != auto {
        text(size: config.fonte-cabecalho * 0.85, fill: ct)[#cab.texto]
      } else {
        text(size: config.fonte-cabecalho * 0.85)[#cab.texto]
      }
      if measure(txt).width + 4pt <= w {
        content(
          (x + w / 2, -al - al / 2),
          txt,
        )
      }
    }
  }
}

/// Renderiza os nomes das tarefas à esquerda
#let _render-nomes(layout, config) = {
  import cetz.draw: *

  let al = config.altura-linha
  let pitch = al + config.gap
  let y-base = -_alt-cabecalho * al
  let ct = config.cor-texto

  for linha in layout.linhas {
    let y = y-base - linha.y * pitch - al / 2

    if linha.tipo == "grupo" {
      let cor-grupo = if ct != auto { ct } else { config.cor-padrao.darken(20%) }
      content(
        (-config.largura-nomes / 2, y),
        box(
          width: config.largura-nomes - 4pt,
          text(size: config.fonte-tarefa, weight: "bold", fill: cor-grupo)[#linha.nome],
        ),
      )
    } else {
      let nome-content = if ct != auto {
        text(size: config.fonte-tarefa, fill: ct)[#linha.nome]
      } else {
        text(size: config.fonte-tarefa)[#linha.nome]
      }
      content(
        (-config.largura-nomes / 2, y),
        box(
          width: config.largura-nomes - 4pt,
          nome-content,
        ),
      )
    }
  }
}

/// Renderiza uma barra de tarefa (pill-shaped)
#let _render-barra(linha, config) = {
  import cetz.draw: *

  let al = config.altura-linha
  let pitch = al + config.gap
  let y-base = -_alt-cabecalho * al
  let y = y-base - linha.y * pitch
  let pad = al * 0.15  // padding vertical

  let x1 = linha.x-inicio
  let x2 = linha.x-fim
  let largura-barra = x2 - x1

  // Largura mínima para visibilidade
  let largura-barra = calc.max(largura-barra, 3pt)
  let x2 = x1 + largura-barra

  let cor = if linha.cor != none and linha.cor != auto { linha.cor } else { config.cor-padrao }

  // Barra principal (arredondada)
  rect(
    (x1, y - pad),
    (x2, y - al + pad),
    fill: cor.lighten(30%),
    stroke: 0.5pt + cor,
    radius: config.raio-barra,
  )

  // Barra de progresso
  if config.mostrar-progresso and linha.progresso != none and linha.progresso > 0 {
    let prog-largura = largura-barra * linha.progresso / 100
    let prog-largura = calc.max(prog-largura, 2pt)

    let cor-prog = if config.cor-progresso == auto { cor.darken(25%) } else { config.cor-progresso }
    let raio-prog = calc.min(config.raio-barra, prog-largura / 2)

    rect(
      (x1, y - pad),
      (x1 + prog-largura, y - al + pad),
      fill: cor-prog.lighten(10%),
      stroke: none,
      radius: raio-prog,
    )

    // Se o progresso não cobre toda a barra, redesenhar o contorno
    if linha.progresso < 100 {
      rect(
        (x1, y - pad),
        (x2, y - al + pad),
        fill: none,
        stroke: 0.5pt + cor,
        radius: config.raio-barra,
      )
    }
  }

  // Rótulo dentro da barra
  if config.mostrar-rotulo and largura-barra > 20pt {
    let texto-rotulo = if linha.rotulo != none {
      linha.rotulo
    } else if linha.progresso != none {
      str(linha.progresso) + "%"
    } else {
      none
    }
    if texto-rotulo != none {
      content(
        ((x1 + x2) / 2, y - al / 2),
        text(size: config.fonte-tarefa * 0.8, fill: white, weight: "bold")[#texto-rotulo],
      )
    }
  }
}

/// Renderiza um marco (losango / diamond)
#let _render-marco(linha, config) = {
  import cetz.draw: *

  let al = config.altura-linha
  let pitch = al + config.gap
  let y-base = -_alt-cabecalho * al
  let y-centro = y-base - linha.y * pitch - al / 2
  let x-centro = (linha.x-inicio + linha.x-fim) / 2

  let cor = if linha.cor != none and linha.cor != auto { linha.cor } else { config.cor-padrao }
  let tam = al * 0.3  // tamanho do losango

  // Desenhar losango como polígono
  line(
    (x-centro, y-centro + tam),
    (x-centro + tam, y-centro),
    (x-centro, y-centro - tam),
    (x-centro - tam, y-centro),
    close: true,
    fill: cor,
    stroke: 0.5pt + cor.darken(20%),
  )
}

/// Renderiza a linha "hoje"
#let _render-hoje(layout, config, inicio) = {
  import cetz.draw: *

  let al = config.altura-linha
  let pitch = al + config.gap
  let offset = _diff-dias(inicio, config.hoje)

  if offset >= 0 {
    let x = offset * layout.escala-x
    let y-topo = 0pt
    let y-base = -_alt-cabecalho * al - layout.total-linhas * pitch

    line(
      (x, y-topo),
      (x, y-base),
      stroke: (paint: config.cor-hoje, thickness: 1.5pt, dash: "dashed"),
    )
  }
}

/// Renderiza dependências como setas em L no espaço entre linhas
#let _render-dependencias(layout, config) = {
  import cetz.draw: *

  let al = config.altura-linha
  let pitch = al + config.gap
  let y-base = -_alt-cabecalho * al
  let pad = al * 0.15

  // Criar mapa de nomes para linhas
  let mapa = (:)
  for linha in layout.linhas {
    if linha.tipo != "grupo" {
      mapa.insert(linha.nome, linha)
    }
  }

  let cor-seta = config.cor-dependencia
  let estilo = 0.8pt + cor-seta

  for linha in layout.linhas {
    if linha.tipo == "grupo" { continue }
    let deps = linha.at("depende-de", default: ())
    for dep-nome in deps {
      if dep-nome in mapa {
        let dep = mapa.at(dep-nome)

        // Saída: fundo da barra predecessora, a 1/4 do comprimento
        let largura-dep = dep.x-fim - dep.x-inicio
        let x1 = dep.x-inicio + largura-dep * 0.25
        let y1 = y-base - dep.y * pitch - al + pad

        // Entrada: lado esquerdo da barra dependente, meia-altura
        let x2 = linha.x-inicio
        let y-dep = y-base - linha.y * pitch - al / 2

        // L puro: desce até a linha do dependente, depois vai pra direita
        line(
          (x1, y1),
          (x1, y-dep),
          (x2, y-dep),
          stroke: estilo,
          mark: (end: ">", size: 3.5pt, fill: cor-seta),
        )
      }
    }
  }
}

/// Renderiza borda externa da área de nomes + chart
#let _render-bordas(layout, config) = {
  import cetz.draw: *

  let al = config.altura-linha
  let pitch = al + config.gap
  let y-base = -_alt-cabecalho * al - layout.total-linhas * pitch

  // Borda externa
  rect(
    (-config.largura-nomes, 0pt),
    (layout.largura-chart, y-base),
    stroke: 0.8pt + config.cor-grade,
    fill: none,
  )

  // Separador vertical entre nomes e chart
  line(
    (0pt, 0pt),
    (0pt, y-base),
    stroke: 0.8pt + config.cor-grade,
  )

  // Separador horizontal do cabeçalho
  line(
    (-config.largura-nomes, -_alt-cabecalho * al),
    (layout.largura-chart, -_alt-cabecalho * al),
    stroke: 0.8pt + config.cor-grade,
  )
}


// =============================================================================
// Seção 4: API pública
// =============================================================================

/// Cria um dicionário de tarefa para uso no cronograma.
#let tarefa(
  nome,
  inicio,
  fim,
  cor: auto,
  progresso: none,
  grupo: none,
  marco: false,
  depende-de: (),
  rotulo: none,
) = {
  assert(type(nome) == str, message: "tarefa: 'nome' deve ser uma string")
  assert(type(inicio) == dictionary, message: "tarefa: 'inicio' deve ser um dict de data — use data(dia, mes, ano)")
  assert(type(fim) == dictionary, message: "tarefa: 'fim' deve ser um dict de data — use data(dia, mes, ano)")

  // Validar dias para o mês específico
  assert(inicio.dia <= _dias-no-mes(inicio.ano, inicio.mes),
    message: "tarefa '" + nome + "': dia " + str(inicio.dia) + " inválido para mês " + str(inicio.mes))
  assert(fim.dia <= _dias-no-mes(fim.ano, fim.mes),
    message: "tarefa '" + nome + "': dia " + str(fim.dia) + " inválido para mês " + str(fim.mes))

  if not marco {
    assert(
      _data-para-dias(fim) >= _data-para-dias(inicio),
      message: "tarefa '" + nome + "': data 'fim' não pode ser anterior a 'inicio'",
    )
  }

  (
    nome: nome,
    inicio: inicio,
    fim: fim,
    cor: cor,
    progresso: progresso,
    grupo: grupo,
    marco: marco,
    depende-de: depende-de,
    rotulo: rotulo,
  )
}

/// Gráfico de Gantt estilizado com barras arredondadas e cabeçalho multi-nível.
///
/// - `tarefas` — array de dicts (use `tarefa()` para criar)
/// - `inicio` — data de início do gráfico (auto = mais cedo das tarefas)
/// - `fim` — data de fim do gráfico (auto = mais tarde das tarefas)
#let cronograma(
  tarefas,
  inicio: auto,
  fim: auto,
  // --- Dimensões ---
  largura: 100%,
  altura-linha: 22pt,
  largura-nomes: 8em,
  // --- Cabeçalho ---
  cabecalho: "mes-semana",
  meses-pt: true,
  cor-cabecalho: auto,
  // --- Visual ---
  cor-padrao: azul,
  cor-fundo: branco,
  cor-alternada: luma(248),
  cor-grade: luma(220),
  raio-barra: 4pt,
  espessura-grade: 0.3pt,
  // --- Progresso ---
  mostrar-progresso: true,
  cor-progresso: auto,
  // --- Hoje ---
  hoje: none,
  cor-hoje: vermelho,
  // --- Dependências ---
  mostrar-dependencias: false,
  cor-dependencia: cinza,
  // --- Texto ---
  cor-texto: auto,
  fonte-tarefa: 0.85em,
  fonte-cabecalho: 0.8em,
  mostrar-rotulo: false,
) = {
  assert(tarefas.len() > 0, message: "cronograma: 'tarefas' não pode estar vazio")

  // Validar nomes únicos e dependências válidas
  let _nomes-vistos = (:)
  for t in tarefas {
    assert(not (t.nome in _nomes-vistos),
      message: "cronograma: nome de tarefa duplicado: '" + t.nome + "'")
    _nomes-vistos.insert(t.nome, true)
  }
  for t in tarefas {
    for dep in t.at("depende-de", default: ()) {
      assert(dep in _nomes-vistos,
        message: "cronograma: tarefa '" + t.nome + "' depende de '" + dep + "', que não existe")
    }
  }

  // Determinar range de datas
  let d-inicio = inicio
  let d-fim = fim

  if d-inicio == auto {
    let min-dias = _data-para-dias(tarefas.at(0).inicio)
    let min-data = tarefas.at(0).inicio
    for t in tarefas {
      let d = _data-para-dias(t.inicio)
      if d < min-dias {
        min-dias = d
        min-data = t.inicio
      }
    }
    d-inicio = min-data
  }

  if d-fim == auto {
    let max-dias = _data-para-dias(tarefas.at(0).fim)
    let max-data = tarefas.at(0).fim
    for t in tarefas {
      let d = _data-para-dias(t.fim)
      if d > max-dias {
        max-dias = d
        max-data = t.fim
      }
    }
    d-fim = _adicionar-dias(max-data, 2)
  }

  // Usar layout() para medir a largura disponível
  layout(size => {
    let largura-total = if type(largura) == ratio {
      size.width * (largura / 100%)
    } else {
      // Resolve relative, length, etc. via measure
      measure(line(length: largura)).width
    }

    // Converter largura-nomes e altura-linha para pt absoluto
    let ln = measure(line(length: largura-nomes)).width
    let al = measure(line(length: altura-linha)).width
    let gap = if mostrar-dependencias { al * 0.5 } else { 0pt }

    let largura-chart = largura-total - ln

    // Config dict para passar ao renderer
    let config = (
      altura-linha: al,
      largura-nomes: ln,
      cabecalho: cabecalho,
      meses-pt: meses-pt,
      cor-cabecalho: cor-cabecalho,
      cor-padrao: cor-padrao,
      cor-fundo: cor-fundo,
      cor-alternada: cor-alternada,
      cor-grade: cor-grade,
      raio-barra: raio-barra,
      espessura-grade: espessura-grade,
      mostrar-progresso: mostrar-progresso,
      cor-progresso: cor-progresso,
      hoje: hoje,
      cor-hoje: cor-hoje,
      mostrar-dependencias: mostrar-dependencias,
      cor-dependencia: cor-dependencia,
      gap: gap,
      cor-texto: cor-texto,
      fonte-tarefa: fonte-tarefa,
      fonte-cabecalho: fonte-cabecalho,
      mostrar-rotulo: mostrar-rotulo,
    )

    // Calcular layout
    let lay = _calcular-layout(
      tarefas,
      d-inicio,
      d-fim,
      largura-chart,
      al,
      cabecalho,
      fonte-cabecalho,
    )

    // Altura total do canvas (com margem inferior para descenders)
    let altura-total = _alt-cabecalho * al + lay.total-linhas * (al + gap) + al * 0.15

    // Desenhar com CeTZ
    box(width: largura-total, {
      cetz.canvas(length: 1pt, {
        import cetz.draw: *

        // Transladar para que (0,0) seja o canto superior esquerdo da área do chart
        // CeTZ y cresce para cima, mas usamos y negativo para baixo
        set-origin((ln, 0pt))

        // Fundo geral
        rect(
          (-ln, 0pt),
          (lay.largura-chart, -altura-total),
          fill: config.cor-fundo,
          stroke: none,
        )

        // Fundo alternado
        _render-fundo(lay, config)

        // Grade
        _render-grade(lay, config)

        // Cabeçalho
        _render-cabecalho(lay, config)

        // Nomes das tarefas
        _render-nomes(lay, config)

        // Barras e marcos
        for linha in lay.linhas {
          if linha.tipo == "tarefa" {
            _render-barra(linha, config)
          } else if linha.tipo == "marco" {
            _render-marco(linha, config)
          }
        }

        // Dependências
        if config.mostrar-dependencias {
          _render-dependencias(lay, config)
        }

        // Linha "hoje"
        if config.hoje != none {
          _render-hoje(lay, config, d-inicio)
        }

        // Bordas
        _render-bordas(lay, config)
      })
    })
  })
}
