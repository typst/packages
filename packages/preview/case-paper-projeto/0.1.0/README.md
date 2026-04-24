
Modelos acadêmicos para Typst seguindo as normas ABNT, inspirados no pacote `abntyp`.

## Estrutura
- `src/`: Arquivos core, elements, citation e templates.
- `exemplos/`: Modelos prontos para projeto, paper e case.

## Exemplo de Uso

```typst
#import "@preview/case-paper-projeto:0.1.0": template-paper, citacao-longa, referencias

#show: template-paper.with(
  titulo: "Título do Trabalho",
  autor: "Nome do Autor",
  resumo: [Resumo aqui.],
  palavras-chave: ("A", "B"),
)

= INTRODUÇÃO
Seu texto aqui...

#citacao-longa[Citação com 4cm de recuo.]

#referencias[ / Autor. Título. 2024. ]
```

## Funções Principais
- `template-projeto`: Capa, folha de rosto e sumário.
- `template-paper`: Formato de artigo científico.
- `template-case`: Estudo de caso simplificado.
- `sumario()`: Gera o sumário automático.

**Nota:** requer fontes Arial ou Times New Roman instaladas.
