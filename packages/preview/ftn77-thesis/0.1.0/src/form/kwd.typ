#import "../components.typ": form-heading
#import "../common.typ": graph
#import "../../style.typ" as style


#let _dashed = (dash: "densely-dashed", thickness: 0.11em, paint: black)
#let _solid = 0.15em + black

#let count = (
  appendices: context query(metadata.where(value: "h:appendix")).len(),
  images: context query(figure.where(kind: image)).len(),
  tables: context query(figure.where(kind: table)).len(),
  graphs: context query(figure.where(kind: graph)).len(),
  citations: context query(cite).dedup().len(),
  chapters: context query(metadata.where(value: "h:chapter")).len(),
  pages: context (
    counter(page).final().first(),
    ..query(metadata.where(value: "page-count-reset"))
      .map(it => it.location())
      .map(loc => counter(page).at(loc).first() - 1),
  ).sum(),
  listings: context query(figure.where(kind: raw)).len(),
)

#let _kwd(
  accession-number: [],
  identification-number: [],
  document-type: [],
  type-of-record: [],
  contents-code: [],
  author: (name: ""),
  mentor: (name: ""),
  title: [],
  text-lang: [],
  abstract-lang: [],
  publication: (
    publisher: [],
    country: [],
    locality: [],
    place: [],
    year: [],
  ),
  physical: [],
  field: [],
  discipline: [],
  subject-keywords: [],
  uc: [],
  holding-data: [],
  note: [],
  abstract: [],
  accepted-date: [],
  defense: (
    date: [],
    president: [],
    member1: [],
    member2: [],
    mentor: [],
  ),
  style: style,
) = [
  #show: style.form
  #set text(lang: "sr", region: "RS")

  #form-heading(style: style)[Кључна документација информација]

  #set par(justify: true)

  #set text(size: 0.9em)

  #align(
    center,
  )[
    #block(
      stroke: (top: _solid, bottom: _solid),
      breakable: false,
      height: 1fr,
    )[
      #table(
        columns: (1fr, 1.5fr),
        align: left + top,
        rows: (auto,) * 22 + (0.9fr, auto),
        stroke: (
          (bottom: _dashed, right: _dashed),
          (bottom: _dashed),
        ),

        [Редни број, *РБР*:], [#accession-number],
        [Идентификациони број, *ИБР*:], [#identification-number],
        [Тип документације, *ТД*:], document-type,
        [Тип записа, *ТЗ*:], type-of-record,
        [Врста рада, *ВР*:], contents-code,
        [Аутор, *АУ*:], author.name,
        [Ментор, *МН*:], mentor.name,
        [Наслов рада, *НР*:], par[#title],
        [Језик публикације, *ЈП*:], text-lang,
        [Језик извода, *ЈИ*:], abstract-lang,
        [Земља публиковања, *ЗП*:], publication.country,
        [Уже географско подручје, *УГП*], publication.locality,
        [Година, *ГО*:], [#publication.year],
        [Издавач, *ИЗ*:], publication.publisher,
        [Место и адреса, *МА*:], publication.place,
        [
          #stack(
            dir: ttb,
            [Физички опис рада, *ФО*:],
            sub[
              (поглавља/страна/цитата/табела/слика/графика/прилога)
            ],
          )
        ],
        if physical == auto {
          context [
            #count.chapters/#count.pages/#count.citations/#count.tables/#count.images/#count.graphs/#count.appendices
          ]
        } else { physical },

        [Научна област, *НО*:], field,
        [Научна дисциплина, *НД*:], discipline,
        [Предметна одредница/Кључне речи, *ПО*:], subject-keywords,
        [*УДК*], uc,
        [Чува се, *ЧУ*:], holding-data,
        [Важна напомена, *ВН*:], note,
        [Извод, *ИЗ*:], par[#abstract],
        [Датум прихватања теме, *ДП*:], accepted-date,
        [Датум одбране, *ДО*:], defense.date,

        table.cell(rowspan: 4, inset: 0pt)[
          #table(
            columns: (1fr, auto),
            stroke: (none, (bottom: _dashed)),

            table.cell(rowspan: 4)[Чланови комисије, *КО*:],
            [Председник:],
            [Члан:],
            [Члан:],
            [Члан, ментор:],
          )
        ],
        defense.president + pdf.artifact(sym.zws),
        defense.member1 + pdf.artifact(sym.zws),
        defense.member2 + pdf.artifact(sym.zws),
        defense.mentor + pdf.artifact(sym.zws),
      )

      #place(
        bottom + end,
        float: false,
        // context {
        table(
          columns: 1,
          align: center,
          stroke: _solid,

          // table.cell(stroke: (top: white, left: none, right: none, bottom: none))[#sym.space], // or page.fill with context
          pad(left: 1.5em, right: 1.5em)[Потпис ментора],
          [#sym.space],
        ),
        // },
      )
    ]
  ]

  #align(right)[
    #text(size: 1em)[
      Образац *Q2.НА.04-05* - Издање 1
    ]
  ]
]

#let _kwd-en(
  accession-number: [],
  identification-number: [],
  document-type: [],
  type-of-record: [],
  contents-code: [],
  author: (name: ""),
  mentor: (name: ""),
  title: [],
  text-lang: [],
  abstract-lang: [],
  publication: (
    publisher: [],
    country: [],
    locality: [],
    place: [],
    year: [],
  ),
  physical: [],
  field: [],
  discipline: [],
  subject-keywords: [],
  uc: [],
  holding-data: [],
  note: [],
  abstract: [],
  accepted-date: [],
  defense: (
    date: [],
    president: [],
    member1: [],
    member2: [],
    mentor: [],
  ),
  style: style,
) = [
  #show: style.form
  #set text(lang: "en", region: "UK")

  #form-heading(style: style)[Key Words Documentation]

  #set par(justify: true)

  #set text(size: 0.9em)

  #align(
    center,
  )[
    #block(
      stroke: (top: _solid, bottom: _solid),
      breakable: false,
      height: 1fr,
    )[
      #table(
        columns: (1fr, 1.5fr),
        align: left + top,
        rows: (auto,) * 22 + (0.9fr, auto),
        stroke: (
          (bottom: _dashed, right: _dashed),
          (bottom: _dashed),
        ),

        [Accession number, *ANO*:], [#accession-number],
        [Identification number, *INO*:], [#identification-number],
        [Document type, *DT*:], document-type,
        [Type of record, *TR*:], type-of-record,
        [Contents code, *CC*:], contents-code,
        [Author, *AU*:], author.name,
        [Mentor, *MN*:], mentor.name,
        [Title, *TI*:], par[#title],
        [Language of text, *LT*:], text-lang,
        [Language of abstract, *LA*:], abstract-lang,
        [Country of publication, *CP*:], publication.country,
        [Locality of publication, *LP*], publication.locality,
        [Publication year, *PY*:], [#publication.year],
        [Publisher, *PB*:], publication.publisher,
        [Publication place, *PP*:], publication.place,
        [
          #stack(
            dir: ttb,
            [Physical description, *PD*:],
            sub[
              (chapters/pages/ref./tables/pictures/graphs/appendixes)
            ],
          )
        ],
        if physical == auto {
          context [
            #count.chapters/#count.pages/#count.citations/#count.tables/#count.images/#count.graphs/#count.appendices
          ]
        } else { physical },

        [Scientific field, *SF*:], field,
        [Scientific discipline, *SD*:], discipline,
        [Subject/Key words, *S/KW*:], subject-keywords,
        [*UC*], uc,
        [Holding data, *HD*:], holding-data,
        [Note, *N*:], note,
        [Abstract, *AB*:], par[#abstract],
        [Accepted by the Scientific Board on, *ASB*:], accepted-date,
        [Defended on, *DE*:], defense.date,

        table.cell(rowspan: 4, inset: 0pt)[
          #table(
            columns: (1fr, auto),
            stroke: (none, (bottom: _dashed)),

            table.cell(rowspan: 4)[Defended Board, *DB*:],
            [President:],
            [Member:],
            [Member:],
            [Member, Mentor:],
          )
        ],
        defense.president + pdf.artifact(sym.zws),
        defense.member1 + pdf.artifact(sym.zws),
        defense.member2 + pdf.artifact(sym.zws),
        defense.mentor + pdf.artifact(sym.zws),
      )

      #place(
        bottom + end,
        float: false,

        table(
          columns: 1,
          align: center,
          stroke: _solid,

          // table.cell(stroke: (top: page.fill, left: none, right: none))[#sym.space],
          pad(left: 1.5em, right: 1.5em)[Mentor's sign],
          sym.space,
        ),
      )
    ]
  ]

  #align(right)[
    #text(size: 1em)[
      Obrazac *Q2.НА.04-05* - Izdanje 1
    ]
  ]
]

#let kwd(
  lang: auto,
  accession-number: [], //here also
  identification-number: [],
  document-type: [],
  type-of-record: [],
  contents-code: [],
  author: (name: ""),
  mentor: (name: ""),
  title: [],
  text-lang: [],
  abstract-lang: [],
  publication: (
    publisher: [],
    country: [],
    locality: [],
    place: [],
    year: [],
  ),
  physical: auto,
  field: [],
  discipline: [],
  subject-keywords: [],
  uc: [],
  holding-data: [],
  note: [],
  abstract: [],
  accepted-date: [],
  defense: (
    date: [],
    president: [],
    member1: [],
    member2: [],
    mentor: [],
  ),
  style: style,
  ..sink,
) = (if lang in ("sr", "bs") { _kwd } else { _kwd-en })(
  accession-number: accession-number,
  identification-number: identification-number,
  document-type: document-type,
  type-of-record: type-of-record,
  contents-code: contents-code,
  author: author,
  mentor: mentor,
  title: title,
  text-lang: text-lang,
  abstract-lang: abstract-lang,
  publication: publication,
  physical: physical,
  field: field,
  discipline: discipline,
  subject-keywords: subject-keywords,
  uc: uc,
  holding-data: holding-data,
  note: note,
  abstract: abstract,
  accepted-date: accepted-date,
  defense: defense,
  style: style,
)

#kwd()
