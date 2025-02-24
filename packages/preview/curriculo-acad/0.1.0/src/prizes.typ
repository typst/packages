#import "utils.typ": *

// Função create-prices(): Cria área de prêmios e títulos
// Argumentos:
// - detalhes: o banco de dados de Lattes (TOML)
#let create-prices(detalhes) = {
    // criando banco de dados
    let premios = detalhes.DADOS-GERAIS.PREMIOS-TITULOS.PREMIO-TITULO

    let i = premios.len() - 1
    let count = premios.len() - 1 

    // Loop pelas entradas
    if type(premios) == array {
        // caso tem mais de um prêmio
        if premios.len() > 0 {
            [= Prêmios e títulos <premios>]
            while i >= 0 {
                let ano_content = premios.at(i).ANO-DA-PREMIACAO
                
                let nome = premios.at(i).NOME-DO-PREMIO-OU-TITULO

                nome = replace-quotes(nome)

                let descricao_content = [#nome, #emph(premios.at(i).NOME-DA-ENTIDADE-PROMOTORA)]

                // publicando content
                create-cols([*#ano_content*], [#descricao_content], "enum")

                // diminuir número
                i -= 1
            }
        } 
    // caso tem um prêmio
    } else if type(premios) == dictionary {
        [= Prêmios e títulos <premios>]
        let ano_content = premios.ANO-DA-PREMIACAO
                
        let nome = premios.NOME-DO-PREMIO-OU-TITULO

        nome = replace-quotes(nome)

        let descricao_content = [#nome, #emph(premios.NOME-DA-ENTIDADE-PROMOTORA)]

        // publicando content
        create-cols([*#ano_content*], [#descricao_content], "enum")

    }
       
    linebreak()

    line(length: 100%)
}

