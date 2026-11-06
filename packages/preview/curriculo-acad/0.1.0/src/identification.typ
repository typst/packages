#import "utils.typ": *

// FUNÇÕES de criar áreas do currículo
// Função create-identification(): Cria área de identificação
// Argumentos:
// - detalhes: o banco de dados de Lattes (TOML)
#let create-identification(detalhes) = {

    let identificacao = detalhes.DADOS-GERAIS

    // criando variáveis
    let author = identificacao.NOME-COMPLETO
    
    // criando filiação
    let filiacao = content
    
    // criando content
    if identificacao.NOME-DO-PAI != "" {
        if identificacao.NOME-DA-MAE != "" {
            filiacao = [#identificacao.NOME-DA-MAE, #identificacao.NOME-DO-PAI]
        } else {
            filiacao = [#identificacao.NOME-DO-PAI]
        }
    } else if identificacao.NOME-DO-PAI == "" {
        if identificacao.NOME-DA-MAE != "" {
            filiacao = [#identificacao.NOME-DA-MAE]
        }
    }

    // criando nascimento
    let birth = identificacao.DATA-NASCIMENTO
    let date_birth = datetime(
        year: int(birth.slice(4, 8)), 
        month: int(birth.slice(2, 4)), 
        day: int(birth.slice(0, 2))
    )

    // criando endereço (depende de FLAG)
    let endereco = []
    
    if identificacao.ENDERECO.FLAG-DE-PREFERENCIA == "ENDERECO_RESIDENCIAL" {
        // corrigindo formato de CEP
        let cep = identificacao.ENDERECO.ENDERECO-RESIDENCIAL.CEP
        cep = cep.slice(0, 5) + "-" + cep.slice(5)
        endereco = [
            #identificacao.ENDERECO.ENDERECO-RESIDENCIAL.LOGRADOURO,
            #identificacao.ENDERECO.ENDERECO-RESIDENCIAL.BAIRRO - #identificacao.ENDERECO.ENDERECO-RESIDENCIAL.CIDADE,
            #cep
        ]
    } else if identificacao.ENDERECO.FLAG-DE-PREFERENCIA == "ENDERECO_PROFISSIONAL" {
        // corrigindo formato de CEP
        let cep = identificacao.ENDERECO.ENDERECO-PROFISSIONAL.CEP
        cep = cep.slice(0, 5) + "-" + cep.slice(5)
        endereco = [
            #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.NOME-INSTITUICAO-EMPRESA, #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.NOME-ORGAO, #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.NOME-UNIDADE

            #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.LOGRADOURO,
            #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.BAIRRO - #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.CIDADE,
            #cep

            #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.HOME-PAGE
        ]
    }

    // create telefon and email
    let telefon = str
    let email = str
    if identificacao.ENDERECO.FLAG-DE-PREFERENCIA == "ENDERECO_RESIDENCIAL" {
        telefon = "(" + identificacao.ENDERECO.ENDERECO-RESIDENCIAL.DDD + ") " + identificacao.ENDERECO.ENDERECO-RESIDENCIAL.TELEFONE
        email = identificacao.ENDERECO.ENDERECO-RESIDENCIAL.E-MAIL 
    } else if identificacao.ENDERECO.FLAG-DE-PREFERENCIA == "ENDERECO_PROFISSIONAL" {
        telefon = "(" + identificacao.ENDERECO.ENDERECO-PROFISSIONAL.DDD + ") " + identificacao.ENDERECO.ENDERECO-PROFISSIONAL.TELEFONE
        email = identificacao.ENDERECO.ENDERECO-PROFISSIONAL.E-MAIL
    }

    // create lattes and orcid
    let lattes_id = detalhes.NUMERO-IDENTIFICADOR
    let orcid_id = identificacao.ORCID-ID

    // criando content
    [= Identificação]

    // criando nome
    _create-cols([*Nome*], identificacao.NOME-COMPLETO, "small")
    
    // criando filiação
    if filiacao != content {
        _create-cols([*Filiação*], filiacao, "small")
    }
     
    // criando nascimento
    _create-cols([*Nascimento*], custom-date-format(date_birth, "DD de Month de YYYY", "pt"), "small")
    
    // criando ID Lattes and ID ORCID
    _create-cols([*Lattes ID*], link("http://lattes.cnpq.br/" + lattes_id)[#lattes_id], "small")
    
    if orcid_id != "" {
        _create-cols([*Orcid ID*], link("https://orcid.org/" + orcid_id.slice(18))[#orcid_id.slice(18)], "small")
    }
    
    // criando citações
    _create-cols([*Nome em citações*], detalhes.DADOS-GERAIS.NOME-EM-CITACOES-BIBLIOGRAFICAS, "small")
    
    // criando endereço, telefone e e-mail
    if endereco != [] {
        _create-cols([*Endereço*], endereco, "small")
    }
        
    if telefon != "" {
        _create-cols([*Telefone*], telefon, "small")
    }
    
    if email != "" {
        _create-cols([*E-Mail*], link("mailto:" + email)[#email], "small")
    }
    

    linebreak()

    line(length: 100%)
}

