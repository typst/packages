// Abreviacao de titulos de periodicos conforme NBR 6032:1989
// Abreviacao de titulos de periodicos e publicacoes seriadas

/// Dicionario de abreviaturas da NBR 6032:1989, lista brasileira (3.1): 799 entradas
/// Formato: chave (minuscula, sem acento) -> (substantivo, adjetivo)
/// - substantivo: abreviatura com a caixa da norma (substantivo em maiuscula, adjetivo em
///   minuscula, 2.2.2.2); para palavra so adjetiva a norma traz so a forma minuscula.
/// - adjetivo: abreviatura propria do adjetivo quando difere da do substantivo (ex.:
///   "Clinica": ("Clin.", "clin.")), ou none.
/// Conferido sem divergencia contra a lista da norma. Os acentos das abreviaturas sao
/// os da norma (Anal., Ind., Pag., Quim., Ser., Tecn., Mus., Med., Inf., Num., Industr.).
#let abbreviation-dict = (
  "abdominal": ("Abdom.", none),
  "academia": ("Acad.", none),
  "aclimatacao": ("Aclim.", none),
  "acucar": ("Açúc.", none),
  "acucareiro": ("Açuc.", "açuc."),
  "acustica": ("Acúst.", none),
  "administracao": ("Adm.", none),
  "advocacia": ("Adv.", none),
  "advogado": ("Adv.", none),
  "aeroespacial": ("aeroesp.", none),
  "aeronautica": ("Aeron.", none),
  "aeroplano": ("Aeropl.", none),
  "aglomeracao": ("Aglom.", none),
  "agraria": ("agr.", none),
  "agricola": ("agríc.", none),
  "agricultura": ("Agric.", none),
  "agrimensura": ("agrim.", none),
  "agropecuaria": ("agropec.", none),
  "alergia": ("Alerg.", none),
  "algebra": ("Álg.", none),
  "algebrico": ("alg.", none),
  "alimentacao": ("Alim.", none),
  "alimentos": ("Alim.", none),
  "almanaque": ("Alm.", none),
  "altitude": ("Alt.", none),
  "aluminio": ("Alum.", none),
  "anais": ("An.", none),
  "analgesico": ("Analg.", "analg."),
  "analise": ("Anál.", none),
  "analitico": ("anal.", none),
  "anatomia": ("Anat.", none),
  "anestesia": ("Anest.", none),
  "anestesico": ("Anest.", "anest."),
  "animal": ("Anim.", none),
  "anomalia": ("Anom.", none),
  "anormal": ("anorm.", none),
  "anotacao": ("Anot.", none),
  "antartico": ("antárt.", none),
  "antibiotico": ("Antib.", none),
  "antiquario": ("Antiq.", none),
  "anuario": ("Anu.", none),
  "aparelho": ("Apar.", none),
  "apendice": ("Apênd.", none),
  "apicultura": ("Apic.", none),
  "aplicacao": ("Apl.", none),
  "aplicado": ("apl.", none),
  "aquatico": ("aquát.", none),
  "arabico": ("aráb.", none),
  "arboricultura": ("Arboric.", none),
  "aromatico": ("arom.", none),
  "arquiteto": ("Arquit.", none),
  "arquitetura": ("Arquit.", none),
  "arquivo": ("Arq.", none),
  "artigo": ("Art.", none),
  "assembleia": ("Assemb.", none),
  "assinatura": ("Assin.", none),
  "assistencia": ("Assist.", none),
  "associacao": ("Assoc.", none),
  "assunto": ("Ass.", none),
  "astronautica": ("Astronáut.", none),
  "atividade": ("Ativ.", none),
  "atmosfera": ("Atm.", none),
  "atomico": ("atôm.", none),
  "atualidade": ("Atual.", none),
  "atualizado": ("atual.", none),
  "atuarial": ("Atuar.", none),
  "automacao": ("Aut.", none),
  "automatico": ("aut.", none),
  "automatismo": ("Aut.", none),
  "automatizacao": ("Aut.", none),
  "automobilismo": ("Autom.", none),
  "automobilistico": ("autom.", none),
  "automovel": ("Autom.", none),
  "auxiliar": ("Aux.", "aux."),
  "aviacao": ("Av.", none),
  "avicultura": ("Avic.", none),
  "balanco": ("Bal.", none),
  "balistica": ("Balíst.", none),
  "bancario": ("Banc.", "banc."),
  "barometro": ("Barôm.", none),
  "beneficencia": ("Benef.", none),
  "bibliofilia": ("Bibliof.", none),
  "biblioteca": ("Bibl.", none),
  "bibliotecario": ("Bibl.", "bibl."),
  "bienal": ("bien.", none),
  "bimensal": ("bimens.", none),
  "bimestral": ("bimest.", none),
  "boletim": ("B.", none),
  "botanica": ("Bot.", none),
  "brasileiro": ("bras.", none),
  "caderno": ("Cad.", none),
  "calculo": ("Cálc.", none),
  "calendario": ("Cal.", none),
  "camara": ("Câm.", none),
  "capital": ("Cap.", "cap."),
  "catalogo": ("Cat.", none),
  "catolicismo": ("Catol.", none),
  "celula": ("Cél.", none),
  "celulose": ("Celul.", none),
  "central": ("Cent.", "cent."),
  "centro": ("Cent.", none),
  "ceramica": ("Cerâm.", none),
  "cerebral": ("cereb.", none),
  "cibernetica": ("Cibern.", none),
  "cidade": ("Cid.", none),
  "ciencia": ("Ci.", none),
  "cimento": ("Cim.", none),
  "cinema": ("Cin.", none),
  "cinematica": ("Cinemát.", none),
  "cinetica": ("Cinét.", none),
  "circular": ("Circ.", "circ."),
  "circulo": ("Círc.", none),
  "cirurgia": ("Cir.", none),
  "civico": ("cív.", none),
  "civil": ("Civ.", "civ."),
  "civilizacao": ("Civiliz.", none),
  "classe": ("Cl.", none),
  "classificacao": ("Classif.", none),
  "clinica": ("Clín.", "clín."),
  "codigo": ("Cód.", none),
  "colaboracao": ("Colab.", none),
  "colaborador": ("Colab.", "colab."),
  "colecao": ("Col.", none),
  "colegio": ("Col.", none),
  "coletanea": ("Col.", none),
  "coletivo": ("Col.", "col."),
  "colonia": ("Colon.", none),
  "coloquio": ("Colóq.", none),
  "combinacao": ("Comb.", none),
  "combustivel": ("Combust.", "combust."),
  "comemoracao": ("Comem.", none),
  "comentario": ("Coment.", none),
  "comercio": ("Com.", none),
  "comissao": ("Comis.", none),
  "companhia": ("Cia.", none),
  "comparacao": ("Compar.", none),
  "comparativo": ("compar.", none),
  "compendio": ("Compênd.", none),
  "compensacao": ("Compens.", none),
  "compilacao": ("Comp.", none),
  "compilador": ("Comp.", none),
  "computacao": ("Comput.", none),
  "comunicacao": ("Comun.", none),
  "concentracao": ("Conc.", none),
  "concreto": ("Concr.", none),
  "condensacao": ("Condens.", none),
  "condicao": ("Cond.", none),
  "confederacao": ("Confed.", none),
  "conferencia": ("Conf.", none),
  "congresso": ("Congr.", none),
  "conjuntura": ("Conj.", none),
  "conselho": ("Cons.", none),
  "conservacao": ("Conserv.", none),
  "conservatorio": ("Conserv.", "conserv."),
  "constituicao": ("Const.", none),
  "construcao": ("Constr.", none),
  "consultoria": ("Consult.", none),
  "contabilidade": ("Contab.", none),
  "contadoria": ("Contad.", none),
  "contemporanea": ("Contemp.", none),
  "continental": ("cont.", none),
  "contribuicao": ("Contr.", none),
  "convencao": ("Conv.", none),
  "convenio": ("Conv.", none),
  "cooperacao": ("Coop.", none),
  "cooperativa": ("Coop.", none),
  "coordenacao": ("Coord.", none),
  "corporacao": ("Corp.", none),
  "correio": ("C.", none),
  "corrente": ("Corr.", "corr."),
  "correspondencia": ("Corresp.", none),
  "cosmetico": ("Comést.", none),
  "credito": ("Créd.", none),
  "criacao": ("Criaç.", none),
  "crianca": ("Crian.", none),
  "criminal": ("crim.", none),
  "cristianismo": ("Crist.", none),
  "critica": ("Crít.", none),
  "cronica": ("Crôn.", none),
  "cultura": ("Cult.", none),
  "curticao": ("Curt.", none),
  "decisao": ("Decis.", none),
  "decoracao": ("Decor.", none),
  "decreto": ("Dec.", none),
  "defesa": ("Def.", none),
  "deficiencia": ("Defic.", none),
  "deformacao": ("Deform.", none),
  "delegacao": ("Deleg.", none),
  "democracia": ("Democr.", none),
  "demonstracao": ("Demonstr.", none),
  "departamento": ("Depto.", none),
  "derivacao": ("Deriv.", none),
  "descricao": ("Descr.", none),
  "desenho": ("Des.", none),
  "desenvolvimento": ("Desenv.", none),
  "destilaria": ("Dest.", none),
  "detergente": ("Deterg.", "deterg."),
  "diagnostico": ("Diag.", "diag."),
  "diario": ("D.", none),
  "diario oficial": ("D.O.", none),
  "didatica": ("Didát.", "didát."),
  "dietetica": ("Diet.", "diet."),
  "difusao": ("Dif.", none),
  "digesto": ("Dig.", "dig."),
  "dinamica": ("Din.", "din."),
  "diplomacia": ("Dipl.", none),
  "direcao": ("Dir.", none),
  "direito": ("Dir.", none),
  "diretoria": ("Diret.", none),
  "diretriz": ("Diretr.", none),
  "dirigente": ("Dirig.", "dirig."),
  "discriminacao": ("Discr.", none),
  "discurso": ("Disc.", none),
  "dissertacao": ("Diss.", none),
  "distrito": ("Dist.", none),
  "divisao": ("Div.", none),
  "divulgacao": ("Divulg.", none),
  "documentacao": ("Doc.", none),
  "domestica": ("Dom.", "dom."),
  "doutor": ("Dr.", none),
  "eclesiastico": ("Ecles.", "ecles."),
  "ecletico": ("ecl.", none),
  "edicao": ("Ed.", none),
  "editora": ("Ed.", none),
  "educacao": ("Educ.", none),
  "efemerides": ("Efem.", none),
  "eletricidade": ("Eletr.", none),
  "eletrico": ("elétr.", none),
  "eletronica": ("Eletr.", none),
  "eletrotecnica": ("Eletrotéc.", none),
  "emigracao": ("Emigr.", none),
  "empresa": ("Emp.", none),
  "enciclopedia": ("Encicl.", none),
  "energia": ("Energ.", none),
  "enfermagem": ("Enferm.", none),
  "engenharia": ("Eng.", none),
  "ensino": ("Ens.", none),
  "equatorial": ("equat.", none),
  "equipamento": ("Equip.", none),
  "escola": ("Esc.", none),
  "escrita": ("Escr.", none),
  "escritorio": ("Escr.", none),
  "escritura": ("Escr.", none),
  "escultura": ("Escult.", none),
  "especial": ("esp.", none),
  "especializacao": ("Esp.", none),
  "especificacao": ("Espec.", none),
  "esperanto": ("Esper.", none),
  "espiritismo": ("Espir.", none),
  "estado": ("Est.", none),
  "estatistica": ("Estat.", "estat."),
  "estetica": ("Estét.", none),
  "estrada": ("Estr.", none),
  "estrangeiro": ("estrang.", none),
  "estudante": ("Est.", none),
  "estudo": ("Est.", none),
  "evangelico": ("evang.", none),
  "evolucao": ("Evol.", none),
  "excepcional": ("Excep.", none),
  "exemplar": ("Ex.", "ex."),
  "exemplo": ("Ex.", none),
  "exercicio": ("Exerc.", none),
  "existencia": ("Exist.", none),
  "existencialismo": ("Exist.", none),
  "exotico": ("exót.", none),
  "expansao": ("Expans.", none),
  "expansionismo": ("Expans.", none),
  "expedicao": ("Exped.", none),
  "experiencia": ("Exper.", none),
  "experimental": ("exper.", none),
  "explanacao": ("Explan.", none),
  "exploracao": ("Explor.", none),
  "exportacao": ("Exp.", none),
  "exposicao": ("Expo.", none),
  "extensao": ("Exten.", none),
  "exterior": ("Ext.", "ext."),
  "extrato": ("Ext.", none),
  "fabrica": ("Fáb.", none),
  "faculdade": ("Fac.", none),
  "familia": ("Fam.", none),
  "farmacia": ("Farm.", none),
  "fasciculo": ("Fasc.", none),
  "fazenda": ("Faz.", none),
  "federacao": ("Fed.", none),
  "federal": ("fed.", none),
  "fermentacao": ("Ferm.", none),
  "ferroviario": ("Ferrov.", "ferrov."),
  "filatelia": ("Filat.", none),
  "filosofia": ("Fil.", none),
  "financas": ("Fin.", none),
  "financeiro": ("fin.", none),
  "fisica": ("Fís.", none),
  "fisico": ("Fís.", "fís."),
  "floresta": ("Fl.", none),
  "floricultura": ("Floric.", none),
  "fluorizacao": ("Fluoriz.", none),
  "folclore": ("Folc.", none),
  "folha": ("F.", none),
  "fomento": ("Fom.", none),
  "forense": ("For.", "for."),
  "formulario": ("Form.", none),
  "fragmento": ("Frag.", none),
  "fronteira": ("Front.", none),
  "funcionario": ("Func.", none),
  "fundacao": ("Fund.", none),
  "fundamento": ("Fundam.", none),
  "fungicida": ("Fung.", none),
  "gaseificacao": ("Gaseif.", none),
  "gastrintestinal": ("gastrint.", none),
  "gazeta": ("G.", none),
  "generalidade": ("Gen.", none),
  "generalizacao": ("Gen.", none),
  "genetica": ("Genét.", none),
  "geodesia": ("Geod.", none),
  "geometria": ("Geom.", none),
  "geriatria": ("Geriat.", none),
  "governo": ("Gov.", none),
  "grafica": ("Gráf.", "gráf."),
  "gramatica": ("Gram.", none),
  "hebdomadario": ("Hebd.", "hebd."),
  "herbicida": ("Herb.", none),
  "hereditariedade": ("Hered.", none),
  "hereditario": ("hered.", none),
  "hidraulica": ("Hidr.", "hidr."),
  "higiene": ("Hig.", none),
  "hipnose": ("Hip.", none),
  "historia": ("Hist.", none),
  "hospicio": ("Hosp.", none),
  "hospital": ("Hosp.", none),
  "humanidade": ("Hum.", none),
  "humano": ("hum.", none),
  "identificacao": ("Ident.", none),
  "ilustracao": ("Il.", none),
  "imigracao": ("Imigr.", none),
  "imobiliario": ("imob.", none),
  "imoveis": ("Imov.", none),
  "imperial": ("imp.", none),
  "importacao": ("Import.", none),
  "imprensa": ("Impr.", none),
  "imprenta": ("Impr.", none),
  "impressao": ("Impr.", none),
  "imunidade": ("Imun.", none),
  "imunizacao": ("Imun.", none),
  "inaugural": ("inaug.", none),
  "incorporacao": ("Inc.", none),
  "incremento": ("Incr.", none),
  "independente": ("Indep.", none),
  "indicador": ("Indic.", "indic."),
  "indice": ("Índ.", none),
  "indigena": ("Indíg.", "indíg."),
  "indigenista": ("Indig.", "indig."),
  "industria": ("Indústr.", none),
  "industrial": ("Industr.", "industr."),
  "infeccao": ("Infec.", none),
  "inferior": ("inf.", none),
  "informacao": ("Inf.", none),
  "informador": ("Inf.", none),
  "informatica": ("Inform.", none),
  "informativo": ("Inf.", "inf."),
  "informe": ("Inf.", none),
  "inscricao": ("Inscr.", none),
  "inseticida": ("Inset.", none),
  "inspecao": ("Insp.", none),
  "inspetoria": ("Insp.", none),
  "instabilidade": ("Instab.", none),
  "instalacao": ("Instal.", none),
  "instrucao": ("Instr.", none),
  "instrumento": ("Instrum.", none),
  "intelectual": ("Intelec.", "intelec."),
  "inteligencia": ("Intelig.", none),
  "intercambio": ("Interc.", none),
  "interior": ("Int.", "int."),
  "intermediario": ("Interm.", "interm."),
  "internacional": ("Inter.", none),
  "intestinal": ("intest.", none),
  "introducao": ("Introd.", none),
  "invencao": ("Inv.", none),
  "inventario": ("Invent.", none),
  "investigacao": ("Invest.", none),
  "investimento": ("Invest.", none),
  "ionizacao": ("Ioniz.", none),
  "ionosfera": ("Ionos.", none),
  "irradiacao": ("Irrad.", none),
  "irrigacao": ("Irrig.", none),
  "jardineiro": ("Jard.", none),
  "jornal": ("J.", none),
  "judiciario": ("Judic.", "judic."),
  "juridico": ("jur.", none),
  "jurisprudencia": ("Jurisp.", none),
  "justica": ("Just.", none),
  "juvenil": ("juv.", none),
  "juventude": ("Juv.", none),
  "laboratorio": ("Lab.", none),
  "laticinio": ("Latic.", none),
  "latim": ("Lat.", none),
  "lavoura": ("Lav.", none),
  "legalidade": ("Leg.", none),
  "legalizacao": ("Leg.", none),
  "legislacao": ("Legisl.", none),
  "legislativa": ("legisl.", none),
  "leguminosa": ("Legum.", none),
  "leitura": ("Leit.", none),
  "leste": ("L", none),
  "liberdade": ("Lib.", none),
  "limitado": ("Ltd.", none),
  "linguistica": ("Ling.", none),
  "liquido": ("Líq.", none),
  "literario": ("lit.", none),
  "literatura": ("Lit.", none),
  "livraria": ("Liv.", none),
  "livreiro": ("Liv.", none),
  "locomocao": ("Locom.", none),
  "locomotiva": ("Locom.", none),
  "logistica": ("Logíst.", none),
  "logopedia": ("Logop.", none),
  "lubrificante": ("Lubr.", "lubr."),
  "lucrativo": ("Lucr.", none),
  "madeira": ("Mad.", none),
  "magazine": ("Mag.", none),
  "magnetico": ("magn.", none),
  "manual": ("Man.", "man."),
  "manufatura": ("Manuf.", none),
  "manuscrito": ("Ms", none),
  "maquina": ("Máq.", none),
  "marinha": ("Mar.", none),
  "maritimo": ("marít.", none),
  "matematica": ("Mat.", none),
  "materia": ("Mater.", none),
  "maternidade": ("Matern.", none),
  "mecanica": ("Mec.", none),
  "mecanizacao": ("Mecaniz.", none),
  "medicina": ("Med.", none),
  "medico": ("Méd.", "méd."),
  "memento": ("Mem.", none),
  "memorando": ("Memo.", none),
  "memoria": ("Mem.", none),
  "mensageiro": ("Mensag.", "mensag."),
  "mensagem": ("Mensag.", none),
  "mensal": ("mens.", none),
  "mensario": ("Mens.", none),
  "mental": ("ment.", none),
  "mercado": ("Merc.", none),
  "mercadoria": ("Merc.", none),
  "mercante": ("merc.", none),
  "mercantil": ("merc.", none),
  "metabolismo": ("Metab.", none),
  "metalico": ("metal.", none),
  "metalurgia": ("Metal.", none),
  "metodico": ("met.", none),
  "metodo": ("Mét.", none),
  "metropolitano": ("metrop.", none),
  "migracao": ("Migr.", none),
  "militar": ("Mil.", "mil."),
  "mineracao": ("Min.", none),
  "mineral": ("Min.", "min."),
  "minerio": ("Min.", none),
  "ministerio": ("Minist.", none),
  "minuto": ("min.", none),
  "miscelanea": ("Misc.", none),
  "moderno": ("mod.", none),
  "modificacao": ("Modif.", none),
  "molecula": ("Mol.", none),
  "molecular": ("mol.", none),
  "momento": ("Mom.", none),
  "monitor": ("Mon.", none),
  "monopolio": ("Monop.", none),
  "montanha": ("Mont.", none),
  "monte": ("Mt.", none),
  "mortalidade": ("Mortal.", none),
  "mosquito": ("Mosq.", none),
  "motivacao": ("Motiv.", none),
  "movimento": ("Mov.", none),
  "mundial": ("mund.", none),
  "municipal": ("mun.", none),
  "municipio": ("Mun.", none),
  "musica": ("Mús.", none),
  "nacional": ("nac.", none),
  "natural": ("nat.", none),
  "natureza": ("Nat.", none),
  "nautica": ("Náut.", none),
  "nautico": ("náut.", none),
  "navegacao": ("Nav.", none),
  "negocio": ("Neg.", none),
  "nervoso": ("nerv.", none),
  "nomenclatura": ("Nomencl.", none),
  "nordeste": ("NE", none),
  "nordico": ("nórd.", none),
  "normalizacao": ("Norm.", none),
  "norte": ("N", none),
  "noticia": ("Not.", none),
  "noticiario": ("Notic.", none),
  "novidade": ("Nov.", none),
  "nuclear": ("Nucl.", none),
  "numerico": ("Num.", none),
  "numero": ("Núm.", none),
  "numismatica": ("Numism.", none),
  "nutricao": ("Nutr.", none),
  "nutritivo": ("nutr.", none),
  "observacao": ("Obs.", none),
  "observador": ("Obs.", "obs."),
  "obstetricia": ("Obst.", none),
  "ocasiao": ("Ocas.", none),
  "ocidente": ("Ocid.", none),
  "ocular": ("ocul.", none),
  "oculista": ("Ocul.", "ocul."),
  "ocupacao": ("Ocup.", none),
  "oeste": ("O", none),
  "oficio": ("Of.", none),
  "operacao": ("Oper.", none),
  "operario": ("Oper.", none),
  "opiniao": ("Opin.", none),
  "oposicao": ("Opos.", none),
  "optica": ("Ópt.", none),
  "opusculo": ("Opúsc.", none),
  "ordenacao": ("Ord.", none),
  "ordenanca": ("Orden.", none),
  "organismo": ("Org.", none),
  "organizacao": ("Org.", none),
  "organograma": ("Org.", none),
  "orientacao": ("Orient.", none),
  "orientador": ("Orient.", "orient."),
  "oriente": ("Or.", none),
  "original": ("Orig.", "orig."),
  "pacifico": ("Pac.", "pac."),
  "pagina": ("Pág.", none),
  "pan-americano": ("Panam.", none),
  "panfleto": ("Panfl.", none),
  "panorama": ("Panor.", none),
  "para-quedista": ("Paraq.", "paraq."),
  "parlamentar": ("Parl.", "parl."),
  "parnaso": ("Parn.", none),
  "paroquia": ("Paróq.", none),
  "particula": ("Part.", none),
  "partido": ("Part.", none),
  "passatempo": ("Passat.", none),
  "pastoral": ("past.", none),
  "pastoril": ("past.", none),
  "patente": ("Pat.", none),
  "patrimonio": ("Patrim.", none),
  "patriota": ("Patr.", "patr."),
  "patriotismo": ("Patr.", none),
  "patronato": ("Patron.", none),
  "pavilhao": ("Pav.", none),
  "pavimentacao": ("Pavim.", none),
  "pecuaria": ("Pec.", "pec."),
  "pedagio": ("Ped.", none),
  "pedagogia": ("Pedag.", none),
  "pediatria": ("Pediatr.", none),
  "pediatrico": ("pediátr.", none),
  "penitenciaria": ("Penit.", none),
  "pequeno": ("Peq.", none),
  "percentual": ("percent.", none),
  "percepcao": ("perc.", none),
  "perfumaria": ("Perfum.", none),
  "pergunta": ("Perg.", none),
  "periodico": ("Per.", none),
  "permanente": ("Perm.", none),
  "perspectiva": ("Perspec.", none),
  "pesquisa": ("Pesq.", none),
  "pessoal": ("Pes.", "pes."),
  "pesticida": ("Pest.", none),
  "petroleo": ("Petr.", none),
  "pigmento": ("Pigm.", none),
  "piloto": ("Pil.", none),
  "pintura": ("Pint.", none),
  "planejamento": ("Planej.", none),
  "planetario": ("Planet.", none),
  "planta": ("Pl.", none),
  "plastico": ("Plást.", "plást."),
  "polimero": ("Polím.", none),
  "politica": ("Pol.", "pol."),
  "pontificio": ("pontif.", none),
  "populacao": ("Pop.", none),
  "popular": ("Pop.", "pop."),
  "portugues": ("Port.", "port."),
  "positivismo": ("Posit.", none),
  "positivo": ("Posit.", none),
  "pratica": ("Prát.", "prát."),
  "precisao": ("Prec.", none),
  "preliminar": ("Prelim.", none),
  "preparacao": ("Prep.", none),
  "prescricao": ("Presc.", none),
  "preservacao": ("Preserv.", none),
  "presidencia": ("Pres.", none),
  "prevencao": ("Prev.", none),
  "previdencia": ("Prev.", none),
  "previsao": ("Prev.", none),
  "primario": ("Prim.", "prim."),
  "principal": ("Princ.", "princ."),
  "principio": ("Princ.", none),
  "privado": ("priv.", none),
  "probabilidade": ("Probab.", none),
  "problema": ("Probl.", none),
  "procedimento": ("Proced.", none),
  "processamento": ("Proc.", none),
  "processo": ("Proc.", none),
  "producao": ("Prod.", none),
  "produtividade": ("Produt.", none),
  "produto": ("Prod.", none),
  "produtor": ("Prod.", none),
  "professor": ("Prof.", none),
  "profissao": ("Prof.", none),
  "profissional": ("prof.", none),
  "programa": ("Progr.", none),
  "programacao": ("Progr.", none),
  "progresso": ("Prog.", none),
  "projeto": ("Proj.", none),
  "proletario": ("Prolet.", none),
  "promocao": ("Prom.", none),
  "prontuario": ("Pront.", none),
  "propagacao": ("Propag.", none),
  "propaganda": ("Propag.", none),
  "propriedade": ("Prop.", none),
  "publica": ("públ.", none),
  "publicacao": ("Publ.", none),
  "publicitario": ("Publ.", "publ."),
  "quadrienal": ("quadr.", none),
  "quadrimestral": ("quadrim.", none),
  "qualidade": ("Qual.", none),
  "qualificacao": ("Qualif.", none),
  "quantidade": ("Quant.", none),
  "quantificacao": ("Quantif.", none),
  "quarentena": ("Quar.", none),
  "questao": ("Qst.", none),
  "questionario": ("Quest.", none),
  "quimica": ("Quím.", "quím."),
  "quinquenal": ("qüinq.", none),
  "quinzenal": ("quinz.", none),
  "quotidiano": ("quot.", none),
  "racionalizacao": ("Racion.", none),
  "racismo": ("Rac.", none),
  "radialista": ("Radial.", none),
  "radical": ("Rad.", none),
  "radioativo": ("radiot.", none),
  "reabilitacao": ("Reab.", none),
  "realidade": ("Real.", none),
  "realismo": ("Real.", none),
  "receita": ("Rec.", none),
  "recensao": ("Recen.", none),
  "recenseamento": ("Recens.", none),
  "reclamacao": ("Recl.", none),
  "recomendacao": ("Recom.", none),
  "recreacao": ("Recr.", none),
  "recurso": ("Rec.", none),
  "redacao": ("Red.", none),
  "reducao": ("Reduç.", none),
  "referencia": ("Ref.", none),
  "refinacao": ("Refin.", none),
  "refinaria": ("Refin.", none),
  "reformatorio": ("Reform.", none),
  "refracao": ("Refr.", none),
  "refratario": ("refrat.", none),
  "refrigeracao": ("Refrig.", none),
  "registro": ("Reg.", none),
  "regulamento": ("Regul.", none),
  "regular": ("reg.", none),
  "relatividade": ("Relativ.", none),
  "relatorio": ("Rel.", none),
  "religiao": ("Relig.", none),
  "religioso": ("Relig.", "relig."),
  "remedio": ("Rem.", none),
  "renovacao": ("Renov.", none),
  "reparticao": ("Repart.", none),
  "repertorio": ("Repert.", none),
  "represa": ("Repr.", none),
  "representacao": ("Represent.", none),
  "republica": ("Rep.", none),
  "requerimento": ("Req.", none),
  "resenha": ("Res.", none),
  "resistencia": ("Resist.", none),
  "resolucao": ("Resol.", none),
  "resposta": ("Resp.", none),
  "resultado": ("Result.", none),
  "resumo": ("Res.", none),
  "retrospecto": ("Retrosp.", none),
  "reumatismo": ("Reum.", none),
  "reuniao": ("Reun.", none),
  "revista": ("R.", none),
  "rodovia": ("Rod.", none),
  "rodoviario": ("rod.", none),
  "roteiro": ("Rot.", none),
  "ruralismo": ("Rur.", none),
  "ruralista": ("Rur.", none),
  "salineiro": ("Sal.", none),
  "salubridade": ("Salub.", none),
  "sanitario": ("sanit.", none),
  "santa": ("Sta.", none),
  "santo": ("Sto.", none),
  "sao": ("S.", none),
  "secretaria": ("Secr.", none),
  "secundario": ("secund.", none),
  "sedimento": ("Sedim.", none),
  "seguranca": ("Segur.", none),
  "seguridade": ("Seg.", none),
  "seguro": ("Seg.", none),
  "selecao": ("Sel.", none),
  "semana": ("Sem.", none),
  "semanal": ("sem.", none),
  "semanario": ("Sem.", none),
  "semantica": ("Semânt.", none),
  "semestral": ("semest.", none),
  "semestre": ("Semest.", none),
  "seminario": ("Semin.", none),
  "semiotica": ("Semiót.", none),
  "sensorial": ("sens.", none),
  "sentenca": ("Sent.", none),
  "separacao": ("Sep.", none),
  "serie": ("Sér.", none),
  "servico": ("Serv.", none),
  "sessao": ("Ses.", none),
  "sexual": ("Sex.", none),
  "sexualidade": ("Sex.", none),
  "siderurgia": ("Sider.", none),
  "sifilis": ("Síf.", none),
  "sifilitico": ("sif.", none),
  "silicato": ("Silic.", none),
  "silicose": ("Silic.", none),
  "silvicultura": ("Silvic.", none),
  "simbolico": ("simb.", none),
  "simbolo": ("Símb.", none),
  "simposio": ("Simp.", none),
  "sindical": ("sind.", none),
  "sindicato": ("Sindi.", none),
  "sinopse": ("sin.", none),
  "sintese": ("Sínt.", none),
  "sistema": ("Sist.", none),
  "social": ("soc.", none),
  "socialismo": ("Social.", none),
  "socialista": ("social.", none),
  "sociedade": ("Soc.", none),
  "submarino": ("Submar.", "submar."),
  "subsistencia": ("Subsist.", none),
  "substancia": ("Subst.", none),
  "subterraneo": ("Subter.", none),
  "sudeste": ("SE", none),
  "sul": ("S", none),
  "sumario": ("Sum.", none),
  "superintendencia": ("Superint.", none),
  "superior": ("Sup.", "sup."),
  "supervisao": ("Superv.", none),
  "suplemento": ("Supl.", none),
  "supremo": ("supr.", none),
  "tabela": ("tab.", none),
  "tecnica": ("Técn.", "técn."),
  "telefone": ("Tel.", none),
  "televisao": ("TV", none),
  "temperatura": ("Temp.", none),
  "teoria": ("Teor.", none),
  "teorico": ("teór.", none),
  "termino": ("Térm.", none),
  "terrestre": ("terr.", none),
  "territorio": ("Territ.", none),
  "textil": ("têxt.", none),
  "tipografia": ("Tip.", none),
  "topico": ("Tóp.", none),
  "trabalho": ("Trab.", none),
  "traducao": ("Trad.", none),
  "trafego": ("Tráf.", none),
  "transferencia": ("Transf.", none),
  "transmissao": ("Transm.", none),
  "transporte": ("Transp.", none),
  "tratado": ("Trat.", none),
  "tribuna": ("Trib.", none),
  "tribunal": ("Trib.", none),
  "trienal": ("Trien.", none),
  "trimestral": ("trim.", none),
  "trimestre": ("Trim.", none),
  "tropical": ("trop.", none),
  "tropico": ("Tróp.", none),
  "tuberculose": ("Tuberc.", none),
  "turismo": ("Tur.", none),
  "ultimo": ("ult.", none),
  "ultramarino": ("ultramar.", none),
  "universal": ("univ.", none),
  "universidade": ("Univ.", none),
  "universitario": ("Univ.", "univ."),
  "universo": ("Univ.", none),
  "urbanismo": ("Urb.", none),
  "utilidade": ("Util.", none),
  "variacao": ("Var.", none),
  "variedade": ("Var.", none),
  "vascular": ("vasc.", none),
  "vegetacao": ("Veg.", "veg."),
  "vegetal": ("Veg.", none),
  "veiculo": ("Veíc.", none),
  "venerea": ("ven.", none),
  "ventilacao": ("Vent.", none),
  "vertebrado": ("Vert.", none),
  "vertical": ("vert.", none),
  "vespertino": ("vesp.", none),
  "veterinaria": ("Vet.", "vet."),
  "vibracao": ("Vibr.", none),
  "visual": ("vis.", none),
  "vitamina": ("Vit.", none),
  "vocabulario": ("Vocab.", none),
  "vocacao": ("Voc.", none),
  "volume": ("Vol.", none),
  "vulgarizacao": ("Vulg.", none),
  "zootecnia": ("Zoot.", none),
)

/// EXTENSOES do pacote: abreviaturas que NAO constam da lista da NBR 6032:1989,
/// mantidas das versoes anteriores do pacote (decisao do dono do projeto). Entram
/// na busca depois do dicionario da norma e nunca o substituem.
/// Mesmo formato de `abbreviation-dict`.
#let abbreviation-extensions = (
  // Da propria norma, mas fora da lista: exemplo 2.2.3.1 b ("centro-amer.") e exemplo 2.3 ("Inst.")
  "americano": ("amer.", none),
  "instituto": ("Inst.", none),
  // Das versoes anteriores do pacote, sem base na lista da norma
  "museu": ("Mus.", none),
  "observatorio": ("Obs.", none),
  "cientifico": ("cient.", none),
  "cientifica": ("cient.", none),
  "comercial": ("com.", none),
  "cultural": ("cult.", none),
  "educacional": ("educ.", none),
  "escolar": ("esc.", none),
  "filosofico": ("filos.", none),
  "filosofica": ("filos.", none),
  "historico": ("hist.", none),
  "historica": ("hist.", none),
  "hospitalar": ("hosp.", none),
  "ilustrado": ("il.", none),
  "ilustrada": ("il.", none),
  "ministerial": ("minist.", none),
  "musical": ("mus.", none),
  "oficial": ("of.", none),
  "paulista": ("paul.", none),
  "regional": ("reg.", none),
)

/// Palavras que nao devem ser abreviadas (menos de 5 letras ou excecoes)
#let no-abbreviate = (
  "de", "da", "do", "das", "dos",
  "e", "ou", "para", "por", "com", "sem",
  "a", "o", "as", "os", "um", "uma", "uns", "umas",
  "em", "no", "na", "nos", "nas",
  "ao", "aos",
  "lei", "ato", "art",
)

/// Minúsculas e sem acentos, para buscar no dicionário (cujas chaves não têm
/// acento): "Administração" e "administracao" encontram a mesma entrada.
#let _normalizar(palavra) = {
  let mapa = (
    "á": "a", "à": "a", "â": "a", "ã": "a", "ä": "a",
    "é": "e", "è": "e", "ê": "e", "ë": "e",
    "í": "i", "ì": "i", "î": "i", "ï": "i",
    "ó": "o", "ò": "o", "ô": "o", "õ": "o", "ö": "o",
    "ú": "u", "ù": "u", "û": "u", "ü": "u",
    "ç": "c",
  )
  lower(palavra).clusters().map(c => mapa.at(c, default: c)).join()
}

/// Artigos, preposicoes e conjuncoes a suprimir (exceto quando necessarios)
#let suppressible-words = (
  "de", "da", "do", "das", "dos",
  "a", "o", "as", "os",
  "um", "uma", "uns", "umas",
  "para", "por", "com", "sem",
  "em", "no", "na", "nos", "nas",
  "ao", "aos",
)

/// Verifica se uma palavra deve ser suprimida
/// - word: palavra a verificar
#let should-suppress(word) = {
  let lower-word = _normalizar(word)
  // Suprimir se for a primeira palavra (artigo inicial)
  lower-word in suppressible-words
}

/// Procura a palavra no dicionario da norma e nas extensoes (sem acento nem caixa),
/// tentando tambem as flexoes de genero (aplicada -> aplicado) e de plural
/// (academias -> academia, comunicacoes -> comunicacao). A lista da norma traz
/// so o singular (e, em geral, so uma forma de genero).
/// Devolve (entry: (substantivo, adjetivo), plural: bool) ou none.
#let _entry(word) = {
  let find(k) = if k in abbreviation-dict {
    abbreviation-dict.at(k)
  } else if k in abbreviation-extensions {
    abbreviation-extensions.at(k)
  } else {
    none
  }
  // Troca a vogal final a <-> o
  let gender(k) = if k.ends-with("a") {
    (k.slice(0, k.len() - 1) + "o",)
  } else if k.ends-with("o") {
    (k.slice(0, k.len() - 1) + "a",)
  } else {
    ()
  }
  // Singulares possiveis de uma forma no plural
  let singulars(k) = {
    let c = ()
    if k.ends-with("oes") or k.ends-with("aes") { c.push(k.slice(0, k.len() - 3) + "ao") }
    if k.ends-with("ais") { c.push(k.slice(0, k.len() - 3) + "al") }
    if k.ends-with("eis") { c.push(k.slice(0, k.len() - 3) + "el") }
    if k.ends-with("ns") { c.push(k.slice(0, k.len() - 2) + "m") }
    if k.ends-with("res") { c.push(k.slice(0, k.len() - 2)) }
    if k.ends-with("s") { c.push(k.slice(0, k.len() - 1)) }
    c
  }

  let key = _normalizar(word)
  let found = find(key)
  if found != none { return (entry: found, plural: false) }
  for k in gender(key) {
    let found = find(k)
    if found != none { return (entry: found, plural: false) }
  }
  for singular in singulars(key) {
    let found = find(singular)
    if found != none { return (entry: found, plural: true) }
    for k in gender(singular) {
      let found = find(k)
      if found != none { return (entry: found, plural: true) }
    }
  }
  none
}

/// Verifica se uma palavra pode ser abreviada
/// - word: palavra a verificar
#let can-abbreviate(word) = {
  let lower-word = _normalizar(word)

  // Nao abreviar palavras curtas (menos de 5 letras, contadas em caracteres), salvo as da lista
  if word.clusters().len() < 5 and _entry(word) == none {
    return false
  }

  // Nao abreviar se estiver na lista de excecoes
  if lower-word in no-abbreviate {
    return false
  }

  true
}

/// Obtem a abreviatura de uma palavra (forma de substantivo, com a caixa da norma)
/// Palavra fora da lista: sufixos "logia", "grafia", "nomia" e derivados (2.1.4) sao
/// abreviados ate l, gr e n; as demais voltam inteiras.
/// - word: palavra a abreviar
/// - preserve-case: se true, poe em maiuscula a inicial da abreviatura quando a
///   palavra original comecava com maiuscula (padrao false: vale a caixa da norma,
///   independente de como o titulo foi digitado)
#let get-abbreviation(word, preserve-case: false) = {
  let found = _entry(word)

  if found != none {
    let abbrev = found.entry.at(0)

    // Preservar maiuscula inicial se a palavra original tinha
    if preserve-case and word.len() > 0 {
      let first-char = word.clusters().at(0)
      if first-char == upper(first-char) {
        abbrev = abbrev.replace(regex("^."), m => upper(m.text))
      }
    }

    return abbrev
  }

  // Palavra nao encontrada no dicionario
  // Verificar sufixos especiais (2.1.4): substantivo em maiuscula, derivado adjetivo em minuscula
  if word.clusters().len() >= 5 {
    let lower-word = _normalizar(word)
    let rules = (
      ("logia", 4, true), ("logico", 5, false), ("logica", 5, false), // Biologia -> Biol.
      ("grafia", 4, true), ("grafico", 5, false), ("grafica", 5, false), // Geografia -> Geogr.
      ("nomia", 4, true), ("nomico", 5, false), ("nomica", 5, false), // Economia -> Econ.
    )
    // O plural (geograficas) e abreviado como o singular
    let letters = word.clusters()
    if lower-word.ends-with("s") {
      lower-word = lower-word.slice(0, lower-word.len() - 1)
      letters = letters.slice(0, -1)
    }
    for (suffix, cut, noun) in rules {
      if lower-word.ends-with(suffix) {
        let base = lower(letters.slice(0, letters.len() - cut).join()) + "."
        return if noun { base.replace(regex("^."), m => upper(m.text)) } else { base }
      }
    }
  }

  // Retornar palavra original se nao puder abreviar
  word
}

/// Formata plural de abreviatura com traco-de-uniao
/// Conforme NBR 6032: acrescentar traco + ultima letra do plural
/// Exemplo: Academias -> Acad-s
/// - singular-abbrev: abreviatura no singular
/// - plural-suffix: sufixo do plural (default: "s")
#let abbreviate-plural(singular-abbrev, plural-suffix: "s") = {
  // Remover ponto final se houver
  let abbrev = singular-abbrev
  if abbrev.ends-with(".") {
    abbrev = abbrev.slice(0, abbrev.len() - 1)
  }

  // Adicionar traco e sufixo (sem ponto)
  abbrev + "-" + plural-suffix
}

/// Abreviatura de uma parte de palavra composta (2.1.7): adjetivo em minuscula;
/// "und" e "och" viram "u." e "o" (2.2.3.1 a)
#let _abbrev-part(part) = {
  let key = _normalizar(part)
  if key == "und" { return "u." }
  if key == "och" { return "o" }
  let found = _entry(part)
  if found != none {
    let entry = found.entry
    if entry.at(1) != none { entry.at(1) } else { entry.at(0) }
  } else {
    get-abbreviation(part)
  }
}

/// Formata abreviatura de palavra composta (2.1.7): abrevia cada elemento como se
/// estivesse isolado e une com traco-de-uniao
/// Exemplo: medico-sanitarias -> med.-sanit. (Atualidades medico-sanitarias:
/// Atual. med.-sanit.); Land-und -> Land-u.
/// - compound-word: palavra composta com hifen
#let abbreviate-compound(compound-word) = {
  compound-word.split("-").map(_abbrev-part).join("-")
}

/// Abrevia um titulo de periodico conforme NBR 6032:1989
/// - title: titulo completo do periodico
/// - suppress-articles: suprimir artigos e preposicoes (default: true)
/// - plural: se true, marca o plural das palavras que estao no plural na lista (Academias
///   -> Acad-s, 2.1.5). Padrao false: a norma so indica o plural "em caso de necessidade"
///   e seus proprios exemplos nao o marcam ("Memorias do Instituto Oswaldo Cruz" ->
///   "Mem. Inst. Oswaldo Cruz"), entao a escolha e sua.
///
/// Regras aplicadas: titulo de uma so palavra, com ou sem artigo, nao se abrevia (2.2.1);
/// a palavra inicial comeca com maiuscula, substantivo em maiuscula e adjetivo em minuscula
/// (2.2.2); palavras compostas elemento a elemento (2.1.7); "und"/"och" -> "u."/"o"; compostas
/// de segunda parte comum ("norte-americanos e centro-americanos" -> "norte e centro-amer.");
/// siglas preservadas (2.2.4); nome de pessoa fica inteiro quando nao consta da lista (2.3).
/// Palavra de cinco letras ou mais fora da lista fica inteira: a norma manda cortar o final
/// (2.1.1), mas o ponto de corte e escolha de quem cataloga. Palavra que tem forma de
/// substantivo e de adjetivo na lista (ex.: Clinica) usa a de adjetivo quando segue direto
/// outra palavra, sem preposicao ("Medicina Veterinaria" -> "Med. vet."), e a de
/// substantivo nos demais casos.
///
/// Exemplo:
/// ```typst
/// #abbreviate-title("Revista Brasileira de Biologia")
/// // Resultado: "R. bras. Biol."
/// ```
#let abbreviate-title(title, suppress-articles: true, plural: false) = {
  let words = title.split(" ").filter(w => w != "")

  // 2.2.1: titulo de uma so palavra, com ou sem artigo, nao se abrevia
  let articles = ("o", "a", "os", "as", "um", "uma", "uns", "umas", "the", "der", "die", "das", "le", "la", "les", "el", "los", "las", "il")
  if words.len() == 1 or (words.len() == 2 and _normalizar(words.at(0)) in articles) {
    return title
  }

  let all-caps = title == upper(title)
  let result = ()
  // Verdadeiro no inicio e depois de preposicao, artigo ou conjuncao: a proxima palavra e substantivo
  let after-link = true
  let i = 0

  while i < words.len() {
    let word = words.at(i)
    let lower-word = _normalizar(word)
    i += 1

    // Verificar se deve suprimir
    if suppress-articles and lower-word in suppressible-words {
      after-link = true
      continue
    }

    // Siglas ficam como estao (2.2.4), a menos que o titulo inteiro esteja em maiusculas
    if not all-caps and word == upper(word) and word.clusters().filter(c => lower(c) != upper(c)).len() >= 2 {
      result.push(word)
      after-link = false
      continue
    }

    // "und" e "och" mantidos entre palavras: u. e o (2.2.3.1 a)
    if (lower-word == "und" or lower-word == "och") and result.len() > 0 {
      result.push(_abbrev-part(word))
      after-link = true
      continue
    }

    // Termo da lista com duas palavras (ex.: Diario Oficial)
    if i < words.len() and lower-word + " " + _normalizar(words.at(i)) in abbreviation-dict {
      result.push(abbreviation-dict.at(lower-word + " " + _normalizar(words.at(i))).at(0))
      i += 1
      after-link = false
      continue
    }

    // Duas palavras compostas de segunda parte comum ligadas por "e" (2.2.3.1 b):
    // norte-americanos e centro-americanos -> norte e centro-amer.
    if (
      word.contains("-") and i + 1 < words.len() and _normalizar(words.at(i)) == "e"
        and words.at(i + 1).contains("-") and _entry(word) == none
    ) {
      let first = word.split("-")
      let second = words.at(i + 1).split("-")
      if _normalizar(first.last()) == _normalizar(second.last()) {
        result.push(first.slice(0, -1).join("-"))
        result.push("e")
        result.push(second.slice(0, -1).join("-") + "-" + _abbrev-part(second.last()))
        i += 2
        after-link = false
        continue
      }
    }

    // Palavra composta: cada elemento abreviado isolado (2.1.7)
    if word.contains("-") and _entry(word) == none {
      result.push(abbreviate-compound(word))
      after-link = false
      continue
    }

    let found = _entry(word)
    if found != none {
      let entry = found.entry
      let abbrev = if entry.at(1) != none and not after-link { entry.at(1) } else { entry.at(0) }
      if plural and found.plural { abbrev = abbreviate-plural(abbrev) }
      result.push(abbrev)
    } else if can-abbreviate(word) {
      result.push(get-abbreviation(word))
    } else {
      result.push(word)
    }

    after-link = false
  }

  // 2.2.2.1: a palavra inicial comeca sempre com maiuscula
  if result.len() > 0 {
    result.at(0) = result.at(0).replace(regex("^."), m => upper(m.text))
  }

  result.join(" ")
}

/// Formata titulo generico com identificacao do editor (2.2.5)
/// Para quando dois periodicos tem o mesmo titulo generico
/// Exemplo: "Boletim Estatistico [IBGE]" -> "B. estat. IBGE"
/// - title: titulo do periodico
/// - editor: nome ou sigla do editor
#let abbreviate-with-editor(title, editor) = {
  let abbrev-title = abbreviate-title(title)
  [#abbrev-title #editor]
}

/// Lista de exemplos de abreviaturas conforme NBR 6032 (saida de `abbreviate-title`)
#let abbreviation-examples = (
  "Revista Brasileira de Biologia": "R. bras. Biol.",
  "Revista Brasileira de Geografia": "R. bras. Geogr.",
  "Revista Brasileira de Economia": "R. bras. Econ.",
  "Memórias do Instituto Oswaldo Cruz": "Mem. Inst. Oswaldo Cruz",
  "Boletim do INT": "B. INT",
  "Ciência e Cultura": "Ci. e Cult.",
  "Anais da Academia Brasileira de Ciências": "An. Acad. bras. Ci.",
)
