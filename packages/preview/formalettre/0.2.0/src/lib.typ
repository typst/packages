// Known envelope formats
#let formats_enveloppe = (
    c4: (width: 32.4cm, height: 22.9cm),
    c5: (width: 22.9cm, height: 16.2cm),
    c6: (width: 16.2cm, height: 11.4cm),
    c56: (width: 22.9cm, height: 11.4cm),
    dl: (width: 22cm, height: 11cm))


// Parse an envelope format specification and return a format
// dictionary. The specification can be:
// * a string containing the name of a known format, e.g. "c4" or "dl";
// * a tuple (<width>, <height>);
// * a format dictionary (width: <width>, height: <height>).
#let parse_format(spec) = {
    let format = (:)
    if type(spec) == str {
        format = formats_enveloppe.at(
            lower(spec),
            default: none)
        if format == none {
            panic("unknown format " + spec)
        }
    }
    else if type(spec) == array {
        format.width = spec.at(0)
        format.height = spec.at(1)
    }
    else if type(spec) == dict {
        format.width = spec.width
        format.height = spec.height
    }
    else {
        panic("enveloppe spec should be a known format, (<width>, <height>) or (width: <width>, height: <height>")
    }
    return format
}


// (Small-)capitalize content if the capitalization level is above a minimum
// value
#let capitalise(cap_level, min_level, content) = {
    let cap = smallcaps
    if calc.fract(cap_level) != 0 {
        cap = upper
    }
    if cap_level >= min_level {
        return cap(content)
    }
    else {
        return content
    }
}


#let bloc_adresse(personne, capitalisation: 0) = {
    capitalise(capitalisation, 3, personne.nom)
    linebreak()
    // personne.adresse may be a simple string or content, convert it to a list
    if type(personne.adresse) == str or type(personne.adresse) == content {
        personne.adresse = (personne.adresse,)
    }
    for ligne in personne.adresse {
        capitalise(capitalisation, 2, ligne)
        linebreak()
    }
    capitalise(capitalisation, 1, personne.commune)
    linebreak()
    if "pays" in personne {
        capitalise(capitalisation, 1, personne.pays)
        linebreak()
    }
}


#let lettre(
    // expediteur is actually required, see panic below
    // expected content:
    // (
    //     nom: [Prénom Nom],
    //     adresse: ([Première ligne], [Deuxième ligne], …),
    //     commune: [4212 Ville],
    //     pays: [France],                           // optional
    //     telephone: "01 99 00 67 89",              // optional
    //     email: "untel@example.com",               // optional
    //     signature: [Prénom],                      // optional
    //     image_signature: image("signature.png"),  // optional
    // )
    expediteur: none,    // actually required, see panic below
    // destinataire is actually required, see panic below
    // expected content:
    // (
    //     nom: [Prénom Nom ou Titre],
    //     adresse: ([Première ligne], [Deuxième ligne], …),
    //     commune: [4212 Ville],
    //     pays: [France],  // optional
    // )
    destinataire: none,  // actually required, see panic below
    // intermediaire is really optional
    // expected content:
    // (
    //     nom: [Prénom Nom ou Titre],
    //     adresse: ([Première ligne], [Deuxième ligne], …),
    //     commune: [4212 Ville],
    //     pays: [France],  // optional
    // )
    intermediaire: none,
    envoi: none,
    objet: none,
    date: none,  // actually required, see panic below
    lieu: none,  // actually required, see panic below
    ref: none,
    vref: none,
    nref: none,
    appel: none,
    salutation: none,
    ps: none,
    pj: none,
    cc: none,
    marges: (1cm, 1cm),
    marque_pliage: false,
    enveloppe: none,
    affranchissement: none,
    capitalisation: 0,
    doc,
) = {
    // expediteur and destinataire are actually required
    if expediteur == none {
        panic("you need to specify a sender (argument 'expediteur')")
    }
    if destinataire == none {
        panic("you need to specify a sender (argument 'destinataire')")
    }
    if date == none {
        panic("you need to specify a date (argument 'date')")
    }
    if lieu == none {
        panic("you need to specify a location (argument 'lieu')")
    }

    // Set default values for sender optional fields
    // expediteur.nom is required
    // expediteur.adresse is required (but may be an empty list as there exist
    //     organizations that only have a name and a locality)
    // expediteur.commune is required
    // expediteur.pays is optional and handled by bloc_adresse()
    expediteur.telephone = expediteur.at("telephone", default: none)
    expediteur.email = expediteur.at("email", default: none)
    expediteur.signature = expediteur.at(
        "signature",
        default: expediteur.nom)
    if type(expediteur.signature) == bool {
        expediteur.signature = [
            #v(-3cm)
            #expediteur.nom
        ]
    }
    expediteur.image_signature = expediteur.at("image_signature", default: none)

    // Set default values for recipient-specific optional fields
    // destinataire.nom is required
    // destinataire.adresse is required (but may be an empty list as there exist
    //     organization that only have a name and a locality)
    // destinataire.commune is required
    // destinataire.pays is optional and handled by bloc_adresse()

    // Bloc d'adresse de l'expéditeur, utilisable pour l'en-tête et l'enveloppe
    expediteur.bloc_adresse = bloc_adresse(expediteur, capitalisation: capitalisation)

    // Bloc de coordonnées de l'expéditeur, utilisées dans l'en-tête
    if expediteur.telephone == none and expediteur.email == none {
        expediteur.coordonnees = none
    }
    else {
        expediteur.coordonnees = {
            if expediteur.telephone != none [
                tél. : #link(
                    "tel:"+ expediteur.telephone.replace(" ", "-"),
                    expediteur.telephone) \
            ]
            if expediteur.email != none [
                email : #link(
                    "mailto:" + expediteur.email,
                    raw(expediteur.email)) \
            ]
        }
    }

    // Bloc d'adresse du destinataire, utilisable pour l'en-tête et l'enveloppe
    destinataire.bloc_adresse = [
        #bloc_adresse(destinataire, capitalisation: capitalisation)
    ]

    // An windowed enveloppe looks like this:
    //         20 mm 60 mm              140 mm
    //         ┌───┬───────┬───────────────────────────────┐
    //       ┌ ┌───────────────────────────────────────────┐ ┐
    // 20 mm │ │                                           │ │
    //       ├ │   ┌───────┐                               │ │ 45 mm
    // 40 mm │ │   │       │                               │ │
    //       │ │   │       │       ┌───────────────────┐   │ ┤
    //       ├ │   └───────┘       │                   │   │ │
    //       │ │                   │                   │   │ │ 45 mm
    // 50 mm │ │                   │                   │   │ │
    //       │ │                   └───────────────────┘   │ ┤
    //       │ │                                           │ │ 20 mm
    //       └ └───────────────────────────────────────────┘ ┘
    //         └───────────────────┴───────────────────┴───┘
    //                 100 mm              100 mm      20 mm
    //
    // The folded letter is 210 mm large and 99 mm high, and can
    // therefore more horizontally by 10 mm and vertically by 11 mm.
    // This results in the following safe zone for the recipient
    // address:
    //         20 mm 50 mm              140 mm
    //         ┌───┬───────┬───────────────────────────────┐
    //       ┌ ┌───────────────────────────────────────────┐ ┐
    // 20 mm │ │                                           │ │
    //       ├ │   ┌───────┐                               │ │ 45 mm
    // 29 mm │ │   │       │                               │ │
    //       ├ │   └───────┘       ┌───────────────────┐   │ ┤
    //       │ │                   │                   │   │ │ 34 mm
    // 50 mm │ │                   │                   │   │ │
    //       │ │                   └───────────────────┘   │ ┤
    //       │ │                                           │ │ 20 mm
    //       └ └─────────────── fold ── here ──────────────┘ ┘
    //         └───────────────────┴───────────────────┴───┘
    //                 100 mm              90 mm       20 mm
    //
    // We use a (width: 100%, height: 100mm) box containing a grid with
    // some merged cells to position sender, place and date, and
    // recipient. Filling rows and columns with fractional dimensions
    // are here to center the recipient address block within its
    // window, resulting in a much better-looking layout than just
    // positionning it statically.
    // ┌───────────────────────────────────────────┐ ┐
    // │                  margin                   │ │ 25 mm
    // │   ┌───────────────┬───────────────────┐   │ ┤ ──────┐
    // │   │ Sender        │       place, date │   │ │ 20 mm │
    // │   │ Address       ├───────────────────┤   │ ┤       │
    // │   │               │     filler #1     │   │ │ 1fr   │
    // │   │ Phone         ├───┬───────────┬───┤   │ ┤       │
    // │   │ Email         │f. │ Recipient │f. │   │ │ auto  │
    // │   │               │#2 │ Address   │#3 │   │ │       │ 75 mm
    // │   │               ├───┴───────────┴───┤   │ ┤       │
    // │   │               │     filler #4     │   │ │ 1fr   │
    // │   │               ├───┬───────────┬───┤   │ ┤       │
    // │   │               │f#5│    s/c    │f#6│   │ │ 20 mm │
    // └───┴───────────────┴───┴───────────┴───┴───┘ ┘ ──────┘
    // └───┴───────────────┴───┴───────────┴───┴───┘
    // 25mm│ 75mm = 46.875% 1fr     auto    1fr│25mm
    //     └───────────────────────────────────┘
    //                      100%
    //
    // For the sender column, we use a percentage instead of a fixed length.
    // That percentage has been computed to result in the same length with an
    // A4 page using standard Typst margins. This allows us to produce a
    // relevant layout even with page sizes othen than A4, e.g. letter or A5
    // (although there will be no compatibility with windowed enveloppe with
    // such a small format).
    //
    block(width: 100%, height: 75mm, spacing: 0pt,
        grid(
            columns: (46.875%, 1fr, auto, 1fr),
            rows: (20mm, 1fr, auto, 1fr, 20mm),
            grid.cell(rowspan: 5, {  // sender address and contact info
                if enveloppe == none {
                    bloc_adresse(expediteur, capitalisation: capitalisation)
                } else {
                    bloc_adresse(expediteur)
                }
                if expediteur.coordonnees != none {
                    par(expediteur.coordonnees)
                }
            }),
            grid.cell(colspan: 3,  // place and date
                [
                    #set align(right)
                    // place and date should be on second line
                    #linebreak()
                    #lieu, #date
                ]
            ),
            grid.cell(colspan: 3, []),  // filler #1
            grid.cell[],                // filler #2
            grid.cell(                  // sender address
                if enveloppe == none {
                    bloc_adresse(destinataire, capitalisation: capitalisation)
                } else {
                    bloc_adresse(destinataire)
                }
            ),
            grid.cell[],                // filler #3
            grid.cell(colspan: 3, []),  // filler #4
            grid.cell[],                // filler #5
            grid.cell(align(horizon,
                if intermediaire != none [
                    s/c de #intermediaire.nom
            ])),
            grid.cell[],                // filler #6
        )
    )

    if marque_pliage {
        place(
            top + left, dx: -25mm, dy: 74mm,
            line(length: 1cm, stroke: .1pt))
    }

    v(1em)

    pad(left: marges.at(0), right: marges.at(1), {

    if ref != none [
        Réf. #ref
    ]
    else if vref != none and nref != none [
        V/réf. #vref
        #h(1fr)
        N/réf. #nref
        #h(3fr)
    ]
    else if vref != none [
        V/réf. #vref
    ]
    else if nref != none [
        N/réf. #nref
    ]

    if envoi != none {
        par(envoi)
    }

    if ref != none or vref != none or nref != none or envoi != none {
        v(1em)
    }

    if objet != none [
        *Objet : #objet*
        #v(1.8em)
    ]

    set par(justify: true)

    if appel != none {
        appel
        v(1em)
    }

    doc

    block(
        breakable: false,
        {
            if salutation != none {
                v(1em)
                salutation
            }

            let hauteur_signature = 3cm
            if expediteur.image_signature != none {
                hauteur_signature = auto
            }

            if type(expediteur.signature) == array {
                let n = expediteur.signature.len()
                grid(
                    columns: expediteur.signature.map(_ => 1fr),
                    rows: (hauteur_signature, auto),
                    grid.cell(colspan: n, []),
                    ..expediteur.signature.map(
                        signature => grid.cell[
                            #set align(center + horizon)
                            #signature
                        ]
                    )
                )
            } else {
                grid(
                    columns: (1fr, 1fr),
                    rows: (hauteur_signature, auto),
                    grid.cell(rowspan: 2, []),
                    grid.cell[
                        #set align(center + horizon)
                        #expediteur.image_signature
                    ],
                    grid.cell[
                        #set align(center)
                        #expediteur.signature
                    ]
                )
            }
        }
    )

    if ps != none or ps != none or cc != none {
        let width = 2.5em
        let mentions = ()

        if type(ps) == content or type(ps) == str {
            mentions.push("P.-S.")
            mentions.push(ps)
        }
        else if type(ps) == array {
            width = 1.3em
            let prefix = "S."
            for item in ps {
                width += 1.2em
                prefix = "P.-" + prefix
                mentions.push(prefix)
                mentions.push(item)
            }
        }
        else if type(ps) == dictionary {
            for (prefix, item) in ps {
                mentions.push(prefix)
                mentions.push(item)
            }
        }

        if type(pj) == content or type(pj) == str {
            mentions.push("P. j.")
            mentions.push(pj)
        }
        else if type(pj) == array {
            mentions.push("P. j.")
            mentions.push(list(marker: [], body-indent: 0pt, ..pj))
        }

        if type(cc) == content or type(cc) == str {
            mentions.push("C. c.")
            mentions.push(cc)
        }
        else if type(cc) == array {
            mentions.push("C. c.")
            mentions.push(list(marker: [], body-indent: 0pt, ..cc))
        }

        v(2.5em)
        pad(left: -width,
            grid(
                columns: (width, 1fr),
                row-gutter: 1.5em,
                ..mentions
            )
        )
    }
    })

    if enveloppe != none {
        let format = parse_format(enveloppe)

        pagebreak()

        set page(
            width: format.width, height: format.height)

        // Set text size to an appropriate value for the chosen envelope
        // size. It must grow with the envelope size, but not too much
        // to avoid getting weirdly bit font with the largest formats.
        // Square root seems to give an appropriate growth rate. It has
        // been adjusted for using 11pt with the smallest, c6 envelope.
        set text(size: calc.sqrt(format.height.cm() / 11) * 11pt)

        // We use the following grid layout:
        //              1fr              auto
        //     ┌────────────────────┬─────────────┐
        // ┌──────────────────────────────────────────┐
        // │             default margin               │
        // │   ┌────────────────────┬─────────────┐   │ ┐
        // │   │ Sender             │             │   │ │
        // │   │ Address            │             │   │ │
        // │   │                    │             │   │ │ 6fr
        // │   │                    │             │   │ │
        // │   │                    │             │   │ │
        // │   ├──────────────┬─────┴────────┬────┤   │ ┤
        // │   │    filler    │ Recipient    │ f. │   │ │ auto
        // │   │    #1        │ Address      │ #2 │   │ │
        // │   ├──────────────┴──────────────┴────┤   │ ┘
        // │   │            filler #3             │   │
        // └───┴──────────────────────────────────┴───┘
        //     └──────────────┴──────────────┴────┘
        //            3fr           auto      1fr
        //
        grid(
            columns: (3fr, auto, 1fr),
            rows: (6fr, auto, 1fr),
            grid.cell(colspan: 3,      // sender + stamp line
                grid(
                    columns: (1fr, auto),
                    grid.cell[         // sender block
                        #set align(left + top)
                        Expéditeur :\
                        #bloc_adresse(expediteur, capitalisation: capitalisation)
                    ],
                    grid.cell[         // stamp block
                        #set align(right + top)
                        #if affranchissement != none {
                            affranchissement
                        }
                    ]
                )
            ),
            grid.cell[],               // filler #1
            grid.cell(                 // recipient block
                align(
                    left + horizon,
                    if intermediaire != none {
                        bloc_adresse(intermediaire, capitalisation: capitalisation)
                    } else {
                        bloc_adresse(destinataire, capitalisation: capitalisation)
                    }
                )
            ),
            grid.cell[],               // filler #2
            grid.cell(colspan: 3, [])  // filler #3
        )
    }
}
