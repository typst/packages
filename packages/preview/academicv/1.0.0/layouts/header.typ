// Job titles
#let jobtitle-text(data, settings) = {
    if ("titles" in data.personal and data.personal.titles != none) {
        block(width: 100%)[
            #text(weight: "semibold", data.personal.titles.join("  /  "))
            #v(-4pt)
        ]
    } else {none}
}

// Address
#let address-text(data, settings) = {
    if ("location" in data.personal and data.personal.location != none) {
        // Filter out empty address fields
        let address = data.personal.location.pairs().filter(it => it.at(1) != none and str(it.at(1)) != "")
        // Join non-empty address fields with commas
        let location = address.map(it => str(it.at(1))).join(", ")

        block(width: 100%)[
            #location
            #v(-4pt)
        ]
    } else {none}
}

#let contact-text(data, settings) = block(width: 100%)[
    #let profiles = (
        if "email" in data.personal.contact and data.personal.contact.email != none { box(link("mailto:" + data.personal.contact.email)) },
        if ("phone" in data.personal.contact and data.personal.contact.phone != none) {box(link("tel:" + data.personal.contact.phone))} else {none},
        if ("website" in data.personal.contact) and (data.personal.contact.website != none) {
            box(link(data.personal.contact.website)[#data.personal.contact.website.split("//").at(1)])
        }
    ).filter(it => it != none) // Filter out none elements from the profile array

    #if ("profiles" in data.personal) and (data.personal.profiles.len() > 0) {
        for profile in data.personal.profiles {
            profiles.push(
                box(link(profile.url)[#profile.url.split("//").at(1)])
            )
        }
    }

    #set text(font: settings.font-body, weight: "medium", size: settings.fontsize)
    #pad(x: 0em)[
        #profiles.join([#sym.space.en | #sym.space.en])
    ]
]


#let layout-header(data, settings, isbreakable: true) = {

    align(center)[
        = #data.personal.name

        #for section in data.sections.filter(s => s.layout == "header" and s.show == true) {
            if "include" in section {
                for item in section.include {
                    if item == "titles" {
                        jobtitle-text(data, settings)
                    }
                    
                    if item == "location" {
                        address-text(data, settings)
                    }
                    
                    if item == "contact" {
                        contact-text(data, settings)
                    }
                }
            }
        }
    ]
}