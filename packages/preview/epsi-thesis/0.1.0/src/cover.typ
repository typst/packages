#let cover(
  thesis-title: "", 
  author: "", 
  degree-type: "", 
  document-type: "",
  degree-name: "",  
  school-id: "", 
  supervisors: (),
  supervisor-gender: "",
  month: "",
  year
) = {

  // Caminhos para os assets - relativos ao template
  // Quando usado como pacote, os assets devem estar em template/assets/
  let logo_university_black = "../assets/UMinho/UMinho-PB.png"
  let logo_university_white = "../assets/UMinho/UMinho-B.png"
  let logo_university_base = "../assets/UMinho/UMinho-C.png"
  let logo_university_simple = "../assets/UMinho/UM.jpg"

  let logo_school_base_path = "../assets/schools/" + school-id + "/"
  let logo_school_black = logo_school_base_path + school-id + "-PB.png"
  let logo_school_white = logo_school_base_path + school-id + "-B.png"
  let logo_school_base = logo_school_base_path + school-id + "-C.png"
  let logo_school_simple = logo_school_base_path + school-id + ".jpg"
  
  // Calcular o estilo baseado no grau
  let degree-style = if degree-type == "mestrado" {
    (
      cover-color: rgb("#FFFFFF"), // White
      inner-color: rgb("#97999B"), // PANTONE Cool Gray 7 C
      letter-color: rgb("#97999B") // PANTONE Cool Gray 7 C
      
    )
  } else {
    (
      cover-color: rgb("#97999B"), // PANTONE Cool Gray 7 C
      inner-color: rgb("#A4343A"), // PANTONE 1807 C
      letter-color: rgb("#FFFFFF") // White
    )
  }

  let second-cover-color = rgb("#FFFFFF") // White
  let second-cover-letter = rgb("#97999B") // PANTONE Cool Gray 7 C
  
  
  set page(
    paper: "a4",
    margin: 0cm,
    numbering: none
  )

  // Fundo principal com a cor da capa
  rect(
    width: 100%,
    height: 100%,
    fill: degree-style.cover-color
  )

  // Coluna lateral à direita (13mm de largura)
  // A4 tem 297mm de altura
  let page_height = 297mm

  // Logos no canto superior direito
  place(
    right + top,
    stack(
      dir: ttb,
      image(logo_university_simple, width: 13mm, height: 13mm, fit: "contain"),
      image(logo_school_simple, width: 13mm, height: 13mm, fit: "contain")
    )
  )

  //Título da Tese
  place(
    right + top,
    dx: -13mm,
    dy: 90mm,
    rotate(-90deg, origin: right + top,
      block(
        width: 100mm,
        height: 13mm,
        align(horizon +left,
          {
            text(
              thesis-title,
              size: 12pt,
              weight: "bold",
              fill: degree-style.letter-color
            )
          }
        )
      )
    )
  )

  // Nome do Autor
  place(
    right + top,
    dx: -7mm,
    dy: 187mm,
    rotate(-90deg, origin: right,
      block(
        height: 13mm,
        align(left + horizon,
          {
            text(
              author,
              size: 12pt,
              fill: degree-style.letter-color
            )
          }
        )
      )
    )
  )

  // UMinho | Ano
  place(
    right + bottom,
    dx: -7mm, 
    dy: -29mm, 
    rotate(-90deg, origin: right, 
      block(
        width: 21mm, 
        align(right, 
          text("UMinho | " + str(year), size: 10pt, fill: degree-style.letter-color)
        )
      )
    )
  )
 
  pagebreak() // Frente da Capa (página interna)
  
  // Fundo da página
  rect(
    width: 100%,
    height: 100%,
    fill: degree-style.cover-color
  )
  
  // Parâmetros de layout
  let left_margin = 79mm
  let image_width = 131mm - 79mm  // 52.5mm
  let author_top = 90mm
  let title_spacing = 15mm
  let degree_info_top = 180mm
  
  // Imagem no topo (79mm até 131.5mm)
  place(
    left + top,
    dx: left_margin,
    dy: 0mm,
    image(
      logo_school_base,
      width: image_width,
      fit: "contain"
    )
  )
  
  // Nome do autor (90mm do topo)
  place(
    left + top,
    dx: left_margin,
    dy: author_top,
    {
      set par(leading: 20.4pt) 
      text(
        author,
        size: 17pt,
        fill: degree-style.letter-color
      )
    }
  )
  
  // Título da tese (15mm abaixo do autor)
  place(
    left + top,
    dx: left_margin,
    dy: author_top + title_spacing,
    box(
      width: 111mm,  // Largura disponível com margem direita
      {
      
        text(
          thesis-title,
          size: 17pt,
          weight: "bold",
          fill: degree-style.letter-color
        )
      }
    )
  )

  place(
    left + bottom,
    dx: left_margin,
    dy: -10mm,
    box(
      width: 111mm,  // Largura disponível com margem direita
      text(
        month + " de "+ str(year),
        size: 10pt,
        fill: degree-style.letter-color
      )
    )
  )
  

  pagebreak() // Interior da Contra-Capa
  rect(
    width: 100%,
    height: 100%,
    fill: degree-style.inner-color
  )

  pagebreak() // Interior da Capa
  rect(
    width: 100%,
    height: 100%,
    fill: degree-style.inner-color
  )

  pagebreak() // Folha de Rosto

  // Fundo da página
  rect(
    width: 100%,
    height: 100%,
    fill: second-cover-color
  )
  
  // Parâmetros de layout
  let left_margin = 79mm
  let image_width = 131.5mm - 79mm  // 52.5mm
  let author_top = 90mm
  let title_spacing = 15mm
  let degree_info_top = 180mm
  
  // Imagem no topo (79mm até 131.5mm)
  place(
    left + top,
    dx: left_margin,
    dy: 0mm,
    image(
      logo_school_black,
      width: image_width,
      fit: "contain"
    )
  )
  
  // Nome do autor (90mm do topo)
  place(
    left + top,
    dx: left_margin,
    dy: author_top,
    {
      text(
        author,
        size: 17pt,
        fill: second-cover-letter
      )
    }
  )
  
  // Título da tese (15mm abaixo do autor)
  place(
    left + top,
    dx: left_margin,
    dy: author_top + title_spacing,
    box(
      width: 111mm,  // Largura disponível com margem direita
      {
        text(
          thesis-title,
          size: 17pt,
          weight: "bold",
          fill: second-cover-letter
        )
      }
    )
  )

  place(
    left + top,
    dx: left_margin,
    dy: degree_info_top,
    stack(
      dir: ttb,
      spacing: 2mm,
      
      text(
        size: 14pt,
        fill: second-cover-letter,
        document-type,
      ),
      
      text(
        size: 14pt,
        fill: second-cover-letter,
        degree-name
      ),
      
      v(10mm),
      
      // Lógica refinada de preposição
      text(
        size: 14pt,
        fill: second-cover-letter,
        if supervisors.len() > 1 {
          "Trabalho efetuado sob a orientação de"
        } else {
          if supervisor-gender == "M" { "Trabalho efetuado sob a orientação do" } 
          else { "Trabalho efetuado sob a orientação da" }
        }
      ),
      
      // Listagem dos nomes
      stack(
        dir: ttb,
        spacing: 3mm, 
        ..supervisors.map(name => text(
          name,
          size: 14pt,
          weight: "bold",
          fill: second-cover-letter
        ))
      )
    )
  )


  place(
    left + bottom,
    dx: left_margin,
    dy: -10mm,
    box(
      width: 111mm,  // Largura disponível com margem direita
      text(
        month + " de "+ str(year),
        size: 10pt,
        fill: second-cover-letter
      )
    )
  )
  
}

