# epsi-thesis

Template de tese para a Universidade do Minho (UMinho).

Suporta teses de **Mestrado** e **Doutoramento**, em **Português** ou **Inglês**, para todas as 12 escolas da UMinho.

## Início Rápido

**Typst Web App** — clica em *Start from template* e procura `epsi-thesis`.

**CLI:**
```bash
typst init @preview/epsi-thesis:0.1.0 my-thesis
cd my-thesis
typst compile --font-path assets/fonts main.typ
```

## Configuração

O ficheiro `main.typ` contém todas as opções com comentários explicativos. Os principais parâmetros são:

| Parâmetro | Descrição |
|---|---|
| `title` | Título da tese |
| `author` | Nome do autor |
| `degree_type` | `"msc"` ou `"phd"` |
| `school_id` | Identificador da escola (ver tabela abaixo) |
| `supervisors` | Lista de orientadores |
| `language` | `"PT"` ou `"EN"` |

## Escolas (`school_id`)

| ID | Escola |
|---|---|
| `EAAD` | Escola de Arquitetura, Arte e Design |
| `EC` | Escola de Ciências |
| `ED` | Escola de Direito |
| `EE` | Escola de Engenharia |
| `EEG` | Escola de Economia e Gestão |
| `ELACH` | Escola de Letras, Artes e Ciências Humanas |
| `EM` | Escola de Medicina |
| `EP` | Escola de Psicologia |
| `ESE` | Escola Superior de Enfermagem |
| `I3Bs` | Instituto de Investigação em Biomateriais, Biodegradáveis e Biomiméticos |
| `ICS` | Instituto de Ciências Sociais |
| `IE` | Instituto de Educação |

## Fonte

O template usa a fonte **NewsGotT**, incluída em `assets/fonts/`. No Typst Web App é carregada automaticamente. Na CLI, usa `--font-path assets/fonts` ao compilar.

## Licença

MIT — Luís Cunha
