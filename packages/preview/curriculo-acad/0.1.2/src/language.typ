#import "utils.typ": *

// Função create-languages(): Cria área de idiomas
// Argumentos:
// - detalhes: o banco de dados de Lattes (TOML)
#let create-languages(detalhes) = {

    // criando banco de dados
    let languages = detalhes.DADOS-GERAIS.IDIOMAS.IDIOMA

    // criando ordem: compreensão > falar > escrita > leitura > nome da língua
    languages = languages.sorted(key: (item) => (item.PROFICIENCIA-DE-COMPREENSAO, item.PROFICIENCIA-DE-FALA, item.PROFICIENCIA-DE-ESCRITA, item.PROFICIENCIA-DE-LEITURA, item.DESCRICAO-DO-IDIOMA))

    // loop pelas entradas nas idiomas
    let i = 0
    let count = languages.len() - 1 

    if languages.len() > 0 {
        [= Idiomas <idiomas>]

        // create columns with year and description
        while i <= count {
            let lang_content = languages.at(i).DESCRICAO-DO-IDIOMA
            let compreensao = languages.at(i).PROFICIENCIA-DE-COMPREENSAO
            let falar = languages.at(i).PROFICIENCIA-DE-FALA
            let escrita = languages.at(i).PROFICIENCIA-DE-ESCRITA
            let leitura = languages.at(i).PROFICIENCIA-DE-LEITURA
            let descricao_content = [compreende #compreensao, fala #falar, escreve #escrita, le #leitura]

            // publicando content
            _create-cols([*#lang_content*], [#descricao_content], "small")

            i += 1
        }   
    }
    linebreak()

    line(length: 100%)
}

