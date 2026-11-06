#import "@preview/quati-curriculum:0.1.0": (
  components.header, components.heading_icon, components.section, packages.icons.icon, packages.icons.provide-icons,
  style.theme_colors, template,
)


// ## Template. Modelo.

#set text(
  font: "Atkinson Hyperlegible Next",
  lang: "pt",
  region: "BR",
)

// ## Icons. Ícones.

#block()[
  In order to render icons properly, you must *download* the most recent set of Tabler Icons from the project #link("https://iconify.design/", [*Iconify*]).

  Access the #link("https://ecstrema.github.io/iconify-typst/", [*downloads*]) page from #link("https://typst.app/universe/package/iconify", [Iconify Typst]) project, and download the *Tabler* set.

  It will download a JSON file named *`tabler.json`*.

  Then, *replace* this file for the one with the same name in the *`/assets`* folder in this project.

  When you do that, remove this block.
]

#provide-icons(
  json("assets/tabler.json"),
)

#show: template.with(
  // You can customize the color palette.
  colors: (
    // primary: blue,
    // secondary: white,
    // dark: black,
  ),
  // You can customize the icon that is displayed at the bottom of the page.
  //   background_detail: icon(
  //     width: 20em,
  //     "tabler:trees",
  //   ),
  // If you do not want to display any icon, use this definition instead.
  //   background_detail: none
)


// ## Content. Conteúdo.

#header(
  first_name: "Gabriel",
  last_name: "Gonçalves",
  picture: image("assets/person.jpg"),
  contact_information: (
    (
      icon: "tabler:mail",
      info: "gabrielgoncalves@email.com",
      url: "mailto:gabrielgoncalves@email.com",
    ),
    (
      icon: "tabler:phone",
      info: "+55 11 91234-5678",
      url: "tel:+5511912345678",
    ),
    (
      icon: "tabler:brand-linkedin",
      info: "gabrielgoncalves",
      url: "https://www.linkedin.com/in/gabrielgoncalves",
    ),
    (
      icon: "tabler:brand-github",
      info: "gabrielgoncalves",
      url: "https://github.com/gabrielgoncalves",
    ),
    // (
    //   icon: "tabler:world",
    //   info: "gabrielgoncalves.dev",
    //   url: "https://gabrielgoncalves.dev",
    // ),
    (
      icon: "tabler:map-pin",
      info: "São Paulo",
    ),
    (
      icon: "tabler:cake",
      info: "30 anos",
    ),
    (
      icon: "tabler:school",
      info: "Sistemas de Informação",
    ),
  ),
)


= #heading_icon("tabler:books") Educação

#section(
  r1c1: "Mestrado em Ciência da Computação",
  r1c2: [2017 #sym.dash.en 2019],
  r2c1: "Universidade Estadual de Campinas (Unicamp)",
  r2c2: "Campinas, SP",
  r3: [
    - Pesquisa em algoritmos de aprendizado de máquina.
    - Desenvolvimento de projetos de software para análise de dados.
  ],
)

#section(
  r1c1: "Bacharelado em Sistemas de Informação",
  r1c2: [2012 #sym.dash.en 2016],
  r2c1: "Universidade de São Paulo (USP)",
  r2c2: "São Paulo, SP",
  r3: [
    Curso focado em desenvolvimento de software, banco de dados e redes de computadores,\
    alinhado com as melhores práticas de mercado.
  ],
)


= #heading_icon("tabler:briefcase") Profissional

#section(
  r1c1: "Desenvolvedor de Software Sênior",
  r1c2: [2020 #sym.dash.en presente],
  r2c1: "Tech Solutions Ltda.",
  r2c2: "São Paulo, SP",
  r3: [
    - Desenvolvimento de aplicações web utilizando React e Node.js.
    - Implementação de APIs RESTful e GraphQL.
    - Colaboração em equipe ágil com foco em entrega contínua.
  ],
)

#section(
  r1c1: "Engenheiro de Software",
  r1c2: [2016 #sym.dash.en 2020],
  r2c1: "InovaTech S.A.",
  r2c2: "São Paulo, SP",
  r3: [
    - Desenvolvimento de sistemas distribuídos em Java e Python.
    - Otimização de performance de aplicações existentes.
    - Participação em projetos de migração para a nuvem (AWS).
  ],
)


= #heading_icon("tabler:directions") Projetos

#section(
  r1c2: "2018",
  r1c1: "Pesquisa em Modelagem Analítica",
  r2c1: "Universidade Estadual de Campinas (Unicamp)",
  r2c2: "Campinas, SP",
  r3: [
    - Desenvolvimento de modelos preditivos para análise de grandes volumes de dados.
    - Publicação de artigos em conferências internacionais.
    - Colaboração com equipes multidisciplinares para aplicação prática dos modelos.
  ],
)


= #heading_icon("tabler:sparkles") Habilidades

== #heading_icon("tabler:device-desktop-code") Programação

- *Linguagens de Programação:* Python, JavaScript, Java, C#sym.hash
- *Frameworks:* React, Node.js, Django, Spring Boot

== #heading_icon("tabler:tools") Ferramentas

- *Controle de Versão:* Git, GitHub, GitLab
- *Plataformas de Nuvem:* AWS, Azure, Google Cloud
- *Outras:* Docker, Kubernetes, Jenkins

== #heading_icon("tabler:language") Idiomas

- *Inglês:* Fluente. Curso #link("https://www.gov.br/mec/pt-br/mec-idiomas", "MEC Idiomas").
