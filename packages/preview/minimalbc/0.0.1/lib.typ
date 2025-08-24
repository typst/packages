#let companytext(size, body, style: "normal") = text(
  size: size,
  style: style,
  weight: "medium",
)[#body]
#let nametext(size, body, style: "normal") = text(
  size: size,
  style: style,
  weight: "medium",
)[#body]
#let roletext(size, body, style: "normal") = text(
  size: size,
  style: style,
  weight: "light",
)[#body]

#let minimalbc(
  company_name: "Company Name",
  name: "First and Last Name",
  role: none,
  telephone_number: "+00 000 0000000",
  email_address: "me@me.com",
  website: "example.com",
  company_logo: none,
  qrcode_ws: none,
  bc_background: none,
  bg_color: "f2f2f2",
  geo_size: "eu",
  flip:true,
  body
) = {
    set text(font: "Lucida Sans")
    set text(9pt)
    let pz = geo_size+"-business-card"
    set page(paper:pz, flipped:flip, fill: rgb(bg_color))

    grid(columns:(100%),
        rows:(50%,10%,35%),
        gutter:0.5mm,
        grid(
    columns: (60%, 40%),
    rows: (40%, 15%, 20%,  20% ),
    gutter: 1mm,
    companytext(14pt,company_name),
    grid.cell(rowspan:2, company_logo, align:center),
    //
    [],
    grid.cell(colspan:2, nametext(11pt,name)),
    grid.cell(colspan:2, roletext(10pt,role)),
    ),
    [],
    if flip == false {
    grid(
            columns: (10%,60%,30%),
            rows: (30%, 30%, 30%),
            align: center,
            gutter: 0.5mm,
            grid.cell([#emoji.phone], align:center),
            grid.cell(telephone_number, align:left),
            grid.cell(
                rowspan: 3,
                align:center,
                qrcode_ws,
                ),
            grid.cell([#emoji.email], align:center),
            grid.cell(email_address, align:left),
            grid.cell([#emoji.globe.meridian], align:center),
            grid.cell(website, align:left),
        )}
   else {
    grid(
            columns: (10%,90%),
            rows: (15%, 15%, 15%, 55%),
            align: center,
            gutter: 0.5mm,
            grid.cell([#emoji.phone], align:center),
            grid.cell(telephone_number, align:center),
            grid.cell([#emoji.email], align:center),
            grid.cell(email_address, align:center),
            grid.cell([#emoji.globe.meridian], align:center),
            grid.cell(website, align:center),
            grid.cell(
                colspan: 2,
                align:center,
                qrcode_ws,
                )
        )}


)
}
