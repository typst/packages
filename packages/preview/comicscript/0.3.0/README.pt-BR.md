# comicscript 0.3.0

[English](README.md) | Português

A API em inglês está disponível em paralelo à API em português; veja a
[referência bilíngue de comandos](docs/api.md). Os nomes de campos internos e
os rótulos dos PDFs continuam em português.

Pacote Typst independente para escrever e revisar roteiros de HQ. A fonte segue
a hierarquia **página → linha → quadrinho**; os construtores devolvem dados e
`renderizar` escolhe como apresentá-los. Sem dependências externas ou do FerrMat.

Esta versão acrescenta esquema geométrico, produção da arte e relatórios ao
núcleo de autoria e revisão. O import do Typst Universe ficará disponível após
a aprovação da submissão. Para desenvolvimento local, use `lib.typ`.
Requer Typst 0.14.1 ou superior.

## Começar

Crie um arquivo Typst:

```typst
#import "@preview/comicscript:0.3.0" as hq

#set page(paper: "a4", margin: 20mm)
#set text(size: 11pt, lang: "pt", region: "BR")

#let p1 = hq.pagina(
  1,
  hq.linha(
    hq.quadro[Uma porta se abre.],
    hq.quadro(
      textos: (hq.fala("Alex")[Vamos?],),
    )[Alex espera junto à porta.],
  ),
)

#hq.renderizar(p1)
```

O número da página e a descrição visual são as únicas informações que você
precisa escrever, além da hierarquia. Os quadrinhos e as linhas são argumentos
posicionais; não há campos `linhas:` e `quadros:`. Nos arrays de um único item,
mantenha a vírgula final: `(item,)`.

## API

| Função | Argumentos essenciais | Opcionais e padrões |
| --- | --- | --- |
| `pagina(numero, ..linhas)` | Inteiro positivo e uma ou mais linhas | `titulo: none`, `objetivo: none`, `estado: none`, `notas: ()` |
| `linha(..quadros)` | Um ou mais quadrinhos | `peso: 1`, `id: none`, `notas: ()` |
| `quadro[visual]` | Texto livre da descrição | `id: none`, `peso: 1`, `plano: none`, `composicao: none`, `textos: ()`, `notas: ()`, `referencias: ()` |
| `fala(personagem)[corpo]` | Nome do personagem e fala | `modo: "normal"` |
| `legenda[corpo]` | Texto da legenda | — |
| `som[corpo]` | Onomatopeia ou efeito sonoro | — |
| `nota(categoria)[corpo]` | Categoria livre e observação | `estado: "aberta"`, `autor: none` |
| `validar(paginas)` | Uma página ou array de páginas | Devolve um array validado |
| `renderizar(paginas)` | Uma página ou array de páginas | `modo: "roteiro"`, `estados-notas: ("aberta", "resolvida", "descartada")`, `limite-palavras: 60` |
| `mapa-narrativo(paginas)` | Uma página ou array de páginas | — |
| `pendencias(paginas)` | Uma página ou array de páginas | Apenas notas abertas |
| `dialogos(paginas)` | Uma página ou array de páginas | `personagem: none` (todos) |
| `relatorio-textos(paginas)` | Uma página ou array de páginas | `limite-palavras: 60` |

Descrições e demais campos de conteúdo aceitam blocos Typst ou strings.
`personagem`, `modo` da fala, `id`, `categoria` e `autor` são strings não vazias.
`textos`, `notas` e `referencias` são arrays. Os modos de fala são livres, por
exemplo `"pensamento"`, `"fora de campo"` ou `"sussurro"`; o modo aparece junto
ao nome do personagem. Use `legenda` também para inscrições do cenário.

```typst
hq.quadro(
  id: "porta-aberta",
  peso: 2,
  plano: "geral",
  composicao: [A porta fica no canto esquerdo.],
  textos: (
    hq.legenda[No dia seguinte...],
    hq.fala("Alex", modo: "pensamento")[Há algo estranho aqui.],
    hq.som[CRASH!],
  ),
  notas: (
    hq.nota("subtexto")[Ela reconhece o lugar, mas não demonstra.],
    hq.nota("alternativa", estado: "descartada")[Abrir a cena com um close.],
  ),
  referencias: ([Estudo de perspectiva da oficina.],),
)[Uma porta aparece entre as estantes.]
```

Referências são conteúdo livre, apresentado nos modos textuais. Para incluir uma
imagem ou link, passe, por exemplo, `referencias: ([#image("estudo.png", width: 40mm)],)`.
O caminho é resolvido pelo Typst onde a chamada a `image` foi escrita. Uma
referência editorial privada pode ser registrada como `nota("referencia")[...]`.

## Quatro apresentações da mesma fonte

**Roteiro** mostra descrições, planos, composição, referências e textos na ordem
de leitura. **Editorial** acrescenta objetivo e estado da página, IDs, pesos de
linhas, notas dos três níveis e avisos editoriais.

Nos modos textuais, `PÁGINA N` aparece em bege alaranjado, com 22pt, acima do
título também em 22pt. Cada quadrinho tem uma única faixa teal com linha,
quadrinho e percentual de largura, juntos à esquerda. Quando algum peso difere
de 1, a faixa acrescenta `PESO L/Q`, na ordem linha/quadrinho. Os IDs ficam
abaixo da faixa nos modos editorial e produção. As caixas usam cantos
arredondados, inclusive notas, campos técnicos e quadros do esquema.

**Esquema** mostra a geometria em retângulos com bordas escuras, usando os pesos
das linhas para as alturas e os pesos dos quadrinhos para as larguras. Cada
página narrativa ocupa uma folha, com o desenho em tamanho fixo e resumos
automáticos das primeiras oito palavras da descrição. O comprimento do roteiro
não modifica a geometria.

```typst
#hq.renderizar(paginas, modo: "esquema")
// Sem resumos, somente a posição L1 · Q1 etc.:
#hq.renderizar(paginas, modo: "esquema", resumos-esquema: false)
```

O esquema usa `largura-esquema: 140mm` e `altura-esquema: 180mm`, com sarjetas de
3mm. Você pode passar outros comprimentos absolutos positivos. Escolha dimensões
que caibam na área útil da folha, incluindo título e legenda. Retângulos muito
pequenos deixam de mostrar o resumo ou a identificação; a geometria permanece
intacta. O esquema representa linhas horizontais, sem quadros atravessando linhas.

**Produção** contém descrições, enquadramento, composição, referências, textos,
IDs e pesos. Acrescenta apenas notas das categorias `"composicao"`,
`"continuidade"`, `"referencia"` e `"tecnica"`, nos estados aberta ou resolvida.
Esse filtro vale para notas de página, linha e quadrinho. Não inclui notas
descartadas, objetivos, estados das páginas ou avisos editoriais. Outras
categorias, inclusive categorias personalizadas, ficam fora dessa apresentação.
Para enviar uma orientação ao desenhista, registre-a em uma dessas categorias.

```typst
#hq.renderizar(paginas, modo: "producao")
```

Todas as categorias de notas são aceitas. `problema`, `ideia`, `alternativa`,
`continuidade`, `subtexto`, `pista`, `referencia`, `decisao` e `composicao` têm
sinais e cores próprios; categorias novas recebem um estilo neutro. A categoria
e o estado sempre aparecem por escrito.

### Largura e posição das caixas internas

Nos modos textuais, as caixas dentro dos quadrinhos variam conforme a frequência
do seu tipo nas páginas renderizadas. O tipo mais frequente usa toda a largura
interna; cada faixa de frequência menor reduz mais 1cm. Tipos empatados mantêm
a mesma largura. Todas as categorias de notas contam juntas como o tipo `nota`;
notas de página e de linha não entram nessa contagem. Notas ocultadas pelo modo
ou pelo filtro de estados também não entram.

Falas e referências ficam à esquerda; planos, legendas e avisos ficam ao centro;
composição, notas e sons ficam à direita. O alinhamento muda a posição da caixa,
mantendo seu texto alinhado à esquerda. Plano e composição têm caixas separadas.
Em áreas estreitas, o encolhimento é limitado a 60% da largura interna para
preservar a leitura. O texto continua podendo quebrar linhas e folhas.

No exemplo completo editorial, a contagem é: seis notas, quatro falas, dois
planos e uma composição. As reduções são, respectivamente, 0cm, 1cm, 2cm e 3cm.
Caixas de página e linha, quadros externos, esquema e relatórios mantêm suas
dimensões anteriores.

Os estados possíveis são `"aberta"`, `"resolvida"` e `"descartada"`. Por padrão,
o editorial mostra todo o histórico. Para exibir apenas pendências abertas:

```typst
#hq.renderizar(paginas, modo: "editorial", estados-notas: ("aberta",))
```

Para selecionar o modo pelo terminal, use no seu arquivo principal:

```typst
#hq.renderizar(paginas, modo: sys.inputs.at("modo", default: "roteiro"))
```

Executando a partir da pasta do pacote:

```sh
typst compile --root . examples/exemplo-minimo.typ examples/minimo.pdf
typst compile --root . examples/exemplo-completo.typ examples/roteiro.pdf --input modo=roteiro
typst compile --root . examples/exemplo-completo.typ examples/editorial.pdf --input modo=editorial
typst compile --root . examples/exemplo-completo.typ examples/pendencias.pdf --input modo=editorial --input notas=abertas
typst compile --root . examples/exemplo-esquema.typ examples/esquema.pdf
typst compile --root . examples/exemplo-producao.typ examples/producao.pdf
typst compile --root . examples/exemplo-relatorios.typ examples/relatorios.pdf
```

`--root .` permite que os exemplos importem a oficina na pasta superior.
No editor, configure a raiz do projeto como a pasta do pacote se a extensão
limitar importações à pasta do arquivo ativo.

## Pesos, numeração e identidade

- Cada linha e cada quadro têm peso padrão 1. Os pesos devem ser números finitos
  positivos. Numa linha com pesos 2, 1 e 1, os quadros representam 50%, 25% e 25%.
- O roteiro textual informa essas proporções, mas não distribui caixas lado a
  lado nem força alturas. O modo esquema aplica esses pesos na composição geométrica.
- A numeração das linhas reinicia em cada página; a dos quadrinhos reinicia em
  cada linha, Use página + linha +
  quadrinho para identificar uma posição.
- IDs explícitos são opcionais e devem ser únicos entre linhas e quadrinhos de
  **todas** as páginas entregues a `validar` ou `renderizar`. Permanecem iguais se
  você mover o elemento. Não são gerados IDs com promessa de estabilidade.
- Cada página narrativa começa em uma nova folha do PDF e pode ocupar várias
  folhas nos modos textuais. No esquema, a composição é fixa em uma folha.
  A numeração física do documento é configurada por você com `set page`.
- Nos modos textuais, quadros que cabem na área útil de uma folha são mantidos
  inteiros. Quadros maiores continuam nas folhas seguintes, sem cortar o conteúdo.

## Relatórios

As funções recebem as mesmas páginas entregues a `renderizar`, sem manter
uma cópia separada do roteiro:

```typst
#hq.mapa-narrativo(paginas) // Página, quantidade de quadros, título, objetivo e estado.
#hq.pendencias(paginas) // Notas abertas dos três níveis, agrupadas por página e posição.
#hq.dialogos(paginas) // Todas as falas e pensamentos, na ordem do roteiro.
#hq.dialogos(paginas, personagem: "Sam") // Correspondência exata do nome.
#hq.relatorio-textos(paginas, limite-palavras: 60)
```

`dialogos` extrai apenas elementos `fala`; legendas e sons não fazem parte
desse relatório. A contagem em `relatorio-textos` inclui todos os tipos de
`textos`, usa a mesma regra do aviso editorial e marca quadros acima do limiar.
Com `limite-palavras: none`, a contagem continua sendo exibida, sem sinalização.

## Validação e avisos

Os construtores verificam os tipos, a hierarquia, o número da página, linhas e
páginas vazias, pesos, estados das notas e campos desconhecidos. `renderizar`
chama `validar` para detectar IDs duplicados no conjunto completo e rejeita
modos inexistentes. Use os construtores para montar os dados; não edite os
dicionários internos à mão.

Uma descrição vazia continua compilando. No editorial, recebe um aviso. O outro
aviso ocorre quando a soma das palavras de **todos os textos** do quadro supera
`limite-palavras` (60 por padrão). O valor é um limiar de revisão, não uma regra
de escrita. Altere-o ou desative apenas esse aviso com `limite-palavras: none`.

A contagem usa palavras separadas por espaços no conteúdo estático, incluindo
negrito, ênfase e links. Não avalia texto produzido por `context`, fórmulas ou
imagens. A verificação da descrição também procura texto estático: um quadro
com apenas uma imagem pode receber o aviso mesmo tendo conteúdo visual.
Avisos aparecem no PDF editorial; não são alertas de compilação e não alteram
o modo roteiro.

## Exemplos e verificações

- `examples/exemplo-minimo.typ`: uso sem metadados opcionais.
- `examples/exemplo-completo.typ`: páginas 1 e 2, notas em três níveis e estados.
- `examples/exemplo-esquema.typ`: composição geométrica das mesmas páginas.
- `examples/exemplo-producao.typ`: roteiro com as notas relevantes para desenhar.
- `examples/exemplo-relatorios.typ`: mapa, pendências, diálogos de todos,
  diálogos de Sam e contagem de palavras em cinco folhas. O limiar 12 nesse
  exemplo serve apenas para demonstrar a sinalização de revisão.
- [Índice dos exemplos e PDFs](examples/README.md).
- `examples/pages/p01.typ` e `examples/pages/p02.typ`: cena fictícia escrita
  exclusivamente para demonstrar os recursos do pacote.

Para verificar, com Typst e Poppler (`pdftotext`) instalados:

```sh
typst compile --root . tests/test-modelo.typ /tmp/comicscript-modelo.pdf
typst compile --root . tests/test-blocos.typ /tmp/comicscript-blocos.pdf
python3 tests/verificar.py
```

Os testes cobrem dados, erros estruturais, IDs duplicados entre páginas,
visibilidade editorial e de produção, relatórios, filtros, ordem dos textos,
avisos, proporções geométricas e conteúdo longo atravessando várias folhas.
Os arquivos temporários são removidos pelo teste.

## Organização e próximas versões

`lib.typ` exporta a API. `src/modelo.typ` contém os construtores;
`src/validacao.typ`, validação e inspeção textual. Em `src/apresentacoes`,
`roteiro.typ` contém a apresentação comum e `editorial.typ` acrescenta notas,
avisos e validação das opções editoriais. O pacote não muda fonte, tamanho do
papel ou margens globalmente.

`src/apresentacoes/esquema.typ` calcula e desenha a geometria.
O modo produção reaproveita a apresentação textual com filtragem de notas.
`src/relatorios.typ` percorre os dados para gerar os quatro relatórios.

Continuam fora desta versão: índices temáticos, exportação de dados e
quadrinhos atravessando várias linhas.

Licenciado sob a [licença MIT](LICENSE).
