// ============================================================================
// ABNTyp - ABNTyp Base Normativa Typst
// ============================================================================
//
// Copyright (c) 2024-2026 Esdras
// Licenca: MIT
//
// Este projeto foi inspirado no abnTeX2 (https://github.com/abntex/abntex2),
// o excelente pacote LaTeX para formatacao de documentos conforme normas ABNT,
// mantido por Lauro Cesar Araujo e a equipe abnTeX2.
//
// A estrutura de documentacao, os modelos canonicos de exemplos, e varias
// decisoes de design foram influenciadas pelo trabalho do abnTeX2.
//
// Agradecimentos especiais:
// - Lauro Cesar Araujo e equipe abnTeX2
// - Gerald Weber, Miguel Frasson, Leslie H. Watter (abnTeX original)
// - Sadao Massago
// - Comunidade abnTeX
//
// ============================================================================
// Baseado nas normas ABNT atualizadas (2018-2025)
//
// Normas implementadas:
// - NBR 14724:2024 - Trabalhos academicos
// - NBR 6023:2018 - Referencias
// - NBR 10520:2023 - Citacoes (sistemas autor-data E numerico - ambos permitidos)
// - NBR 6024:2012 - Numeracao progressiva
// - NBR 6027:2012 - Sumario
// - NBR 6028:2021 - Resumo
// - NBR 6022:2018 - Artigo em publicacao periodica
// - NBR 6021:2015 - Publicacao periodica
// - NBR 6029:2023 - Livros e folhetos
// - NBR 6032:1989 - Abreviacao de titulos
// - NBR 6033:1989 - Ordem alfabetica
// - NBR 6025:2002 - Revisao de originais e provas
// - NBR 5892:2019 - Representacao de datas e horas
// - NBR 15287:2025 - Projeto de pesquisa
// - NBR 6034:2004 - Indice
// - NBR 12225:2004 - Lombada
// - NBR 10719:2015 - Relatorio tecnico
// - NBR 15437:2006 - Posteres tecnicos e cientificos
// - NBR ISO 2108:2006 - ISBN
// - NBR 10525:2005 - ISSN
// - IBGE 1993 - Normas de apresentacao tabular
//
// NOTA: Apresentacoes de slides NAO possuem norma ABNT especifica.
// O template de slides (slides.typ) segue boas praticas academicas,
// mas NAO representa exigencia normativa. As unicas normas ABNT
// aplicaveis em slides sao NBR 6023 (referencias) e NBR 10520 (citacoes),
// quando houver citacoes na apresentacao.

// Core
#import "src/core/page.typ": *
#import "src/core/fonts.typ": *
#import "src/core/spacing.typ": *
#import "src/core/sorting.typ": *
#import "src/core/proofreading.typ": *
#import "src/core/identifiers.typ": *
#import "src/core/dates.typ": *  // NBR 5892:2019 - Representacao de datas e horas

// Elementos pre-textuais
#import "src/elements/cover.typ": *
#import "src/elements/title-page.typ": *
#import "src/elements/abstract.typ": *
#import "src/elements/toc.typ": *
#import "src/elements/index.typ": *  // NBR 6034:2004 - Indice
#import "src/elements/spine.typ": *  // NBR 12225:2004 - Lombada

// Elementos textuais
#import "src/text/headings.typ": *
#import "src/text/quotes.typ": *
#import "src/text/figures.typ": *
#import "src/text/tables.typ": *

// Referencias
#import "src/references/citation.typ": *        // Sistema autor-data (NBR 10520:2023)
#import "src/references/numeric.typ": *         // Sistema numerico (NBR 10520:2023) - inspirado no abntex2-num.bst
#import "src/references/bibliography.typ": *
#import "src/references/abbreviations.typ": *  // NBR 6032:1989 - Abreviacao de titulos

// Templates
#import "src/templates/thesis.typ": *
#import "src/templates/article.typ": *
#import "src/templates/periodical.typ": *  // NBR 6021:2015 - Publicacao periodica
#import "src/templates/book.typ": *  // NBR 6029:2023 - Livros e folhetos
#import "src/templates/research-project.typ": *  // NBR 15287:2025 - Projeto de pesquisa
#import "src/templates/technical-report.typ": *  // NBR 10719:2015 - Relatorio tecnico
#import "src/templates/poster.typ": *  // NBR 15437:2006 - Posteres tecnicos e cientificos
#import "src/templates/slides.typ": *  // Apresentacoes de slides (SEM NORMA ABNT - boas praticas)
