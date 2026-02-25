#import "utils.typ": *

// Função create-areas-work: Cria áreas de conhecimento
// Argumento:
//  - detalhes: o banco de dados de Lattes (TOML File)
#let create-areas-work(detalhes) = {
    if "AREAS-DE-ATUACAO" in detalhes.DADOS-GERAIS.keys() {
        if "AREA-DE-ATUACAO" in detalhes.DADOS-GERAIS.AREAS-DE-ATUACAO.keys() {
            let areas_atuacao = detalhes.DADOS-GERAIS.AREAS-DE-ATUACAO.AREA-DE-ATUACAO

            // somente criar essa área se tiver ao mínimo uma entrada
            if areas_atuacao.len() > 0 {

                // criando cabeçalho
                [= Área de atuação <areas_atuacao>]

                // criando número para ordem
                let i = 1

                // loop pelo entrada, pode ter ordem de 4 áreas em uma entrada
                for entrada in areas_atuacao {
                    // criando variáveis
                    let descricao_content = []
                    
                    // Manipular GRANDE ÁREA (para Ciências Humanas tinha um _ e todas as letras maiúsculas)
                    let grande_area = entrada.NOME-GRANDE-AREA-DO-CONHECIMENTO


                    // manipular string de grande area
                    // let capitalize = (text) => [#text.slice(0, 1)#lower(text.slice(1))]
                    let grande_area_parts = grande_area.split("_")
                    grande_area = grande_area_parts.map(capitalize).join(" ")
                    
                    // criando descricao
                    if entrada.NOME-DA-ESPECIALIDADE == "" {
                        if entrada.NOME-DA-SUB-AREA-DO-CONHECIMENTO == "" {
                            if entrada.NOME-DA-AREA-DO-CONHECIMENTO == "" {
                                // caso somente grande area
                                descricao_content = [#i. Grande área: #grande_area]
                            } else {
                                descricao_content = [
                                    Grande área: #grande_area / Área: #entrada.NOME-DA-AREA-DO-CONHECIMENTO
                                ]
                            }
                        } else {
                            // caso grande area, area, e subarea
                            descricao_content = [
                                Grande área: #grande_area / Área: #entrada.NOME-DA-AREA-DO-CONHECIMENTO / Subárea: #entrada.NOME-DA-SUB-AREA-DO-CONHECIMENTO
                            ]
                        }
                    } else {
                        // caso grande area, area, subarea, e especialidade
                        descricao_content = [
                            Grande área: #grande_area / Área: #entrada.NOME-DA-AREA-DO-CONHECIMENTO / Subárea: #entrada.NOME-DA-SUB-AREA-DO-CONHECIMENTO / Especialidade: #entrada.NOME-DA-ESPECIALIDADE
                        ]
                    }

                    // publicando content
                    create-cols([*#i. *], [#descricao_content], "enum")
                    
                    // aumentar número para ordem
                    i += 1
                } 
    
            linebreak() 

            line(length: 100%)
            }
        }
    }
}
