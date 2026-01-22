#import "icons.typ": bug-icon, qa-icon

#let detoml = toml

#let template(doc, title: none, toml: none, copyright: true, version: none, notices: (), links: (), description: none, repository: none, universe: none, license: none) = [

    #let title = if toml != none { detoml(toml).package.name } else { title }
    #let version = if toml != none { detoml(toml).package.at("version", default: none) } else { version }
    #let universe = if toml != none { detoml(toml).package.at("name", default: none) } else { universe }
    #let license = if toml != none { detoml(toml).package.at("license", default: none) } else { license }
    #let repository = if toml != none { detoml(toml).package.at("repository", default: none) } else { repository }
    #let description = if toml != none { detoml(toml).package.at("description", default: none) } else { description }
    #html.elem("html", attrs: (lang: "en", class: "scroll-smooth"))[
        #html.elem("head")[
            #html.elem("meta", attrs: (charset: "UTF-8"))
            #html.elem("meta", attrs: (name: "viewport", content: "width=device-width, initial-scale=1.0"))
            #html.elem("title")[#context document.title]
            // Styling sources
            #html.elem("script", attrs: (src: "https://cdn.tailwindcss.com?plugins=forms,typography,aspect-ratio,container-queries"))
            #html.elem("link", attrs: (rel: "preconnect", href: "https://fonts.googleapis.com"))
            #html.elem("link", attrs: (rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: "anonymous"))
            #html.elem("link", attrs: (rel: "stylesheet", href: "https://fonts.googleapis.com/css2?family=Mona+Sans:ital,wght@0,200..900;1,200..900&display=swap"))
        ]
        #html.elem("body", attrs: (style: "font-family: 'Mona Sans', sans-serif", class: "bg-zinc-50 dark:bg-zinc-950"))[
            // Configuration
            #set heading(numbering: none)
            // Raw blocks styling
            #show raw.where(block: false): it => {
                html.elem("span", attrs: (class: "border-t px-1 py-0.5 border-none rounded dark:bg-zinc-800 bg-zinc-200/60 text-xs *:not-prose not-prose font-mono"), it)
            }
            #show raw.where(block: true): it => {
                html.elem("div", attrs: (class: "p-4 border bg-zinc-100/30 dark:bg-zinc-900/20 dark:border-zinc-800 not-prose text-[.85rem] rounded-md"), it)
            }
            // Article
            #html.elem(
                "article",
                attrs: (class: "max-w-[95rem] mx-auto grid md:grid-cols-[max-content_auto_max-content] relative gap-10 p-5 !antialised"),
            )[
                // Navigation
                #html.elem("div", attrs: (class: "order-1 md:w-60 prose overflow-visible"))[
                    #html.elem("div", attrs: (class: "sticky top-5"))[
                        #html.elem("div", attrs: (
                            class: "dark:prose-invert prose-zinc dark:text-white prose-li:first:mt-0 prose-ol:p-0 prose-a:underline-offset-2 prose-li:p-0 prose-ol:m-0",
                        ))[
                            #html.elem(
                                "h1",
                                attrs: (
                                    class: if version != none { "rounded-bl-none " } else { "" }
                                        + "capitalize bg-zinc-800 mb-0 text-white max-w-max rounded-md px-2 py-0.5 text-3xl font-medium mb-0",
                                ),
                                title,
                            )
                            #if version != none {
                                html.elem("div", attrs: (class: "text-xs py-0.5 px-2 max-w-max rounded-md rounded-t-none bg-zinc-700 mb-8 text-white"))[v#version]
                            }
                            #description
                            #let provider = if "github" in repository { "GitHub" } else if "gitlab" in repository { "Gitlab" } else { "Source" }
                            #table(
                                columns: 2,
                                if repository != none { [Repository] }, link(repository, provider),
                                [Typst Universe], link("https://typst.app/universe/package/"+ universe, title),
                                [License], [#license],
                                [Last update], [#datetime.today().display()]
                            )
                            #html.elem("div", attrs: (class: "grid grid-cols-2 lg:grid-cols-1 mt-8"))[
                                #if "qa" in notices [
                                    #html.elem("div")[
                                        #qa-icon
                                        #html.elem("div", attrs: (class: "prose-sm mb-6 mt-2.5"))[
                                            Got a question? \
                                            Ask it on the #link(notices.qa)[community forum].
                                        ]
                                    ]
                                ]
                                #if "bug" in notices [
                                    #html.elem("div")[
                                        #bug-icon
                                        #html.elem("div", attrs: (class: "prose-sm mt-2"))[
                                            Experienced a bug? \
                                            Please #link(notices.bug)[report] it.
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
                #html.elem("article", attrs: (
                    class: "order-3 md:order-2 flex-auto !max-w-4xl prose dark:prose-invert overflow-hidden prose-zinc prose-a:underline-offset-2 prose-td:align-middle prose-headings:scroll-my-7 prose-headings:font-medium prose-strong:font-medium",
                ))[
                    #doc
                ]
                #html.elem("div", attrs: (class: "order-2 md:order-3 w-60 flex-none prose overflow-visible"))[
                    #html.elem("div", attrs: (class: "sticky top-5"))[
                        #html.elem("div", attrs: (
                            class: "dark:prose-invert prose-zinc dark:text-white prose-li:first:mt-0 prose-ol:p-0 prose-a:underline-offset-2 prose-li:p-0 prose-ol:m-0",
                        ))[
                            #html.elem(
                                "div",
                                attrs: (
                                    class: "prose-a:text-current *:*:*:mb-0.5 prose-a:font-normal prose-a:decoration-0 mb-12",
                                ),
                                outline(depth: 1, title: none),
                            )
                        ]
                    ]
                ]
            ]

            #html.elem("div", attrs: (class: "border-t antialised"))[
                #html.elem("div", attrs: (class: "p-5"))[
                    #if copyright [
                        #html.elem("span", attrs: (class: "text-zinc-500 text-sm"))[Made with #link("https://github.com/l0uisgrange/manifesto")[Manifesto] from Typst Universe]
                    ]
                ]
            ]
        ]
    ]
]

#let warning(content, title: "Warning", ..params) = block(
    ..params,
    html.elem("div", attrs: (class: "px-3 py-2.5 rounded-md bg-orange-600/10"), {
        html.elem("span", attrs: (class: "flex items-center gap-2 not-prose"), {
            html.elem("svg", attrs: (class: "size-5", xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 640 640"), html.elem(
                "path",
                attrs: (
                    class: "fill-orange-600",
                    d: "M256.5 37.6C265.8 29.8 279.5 30.1 288.4 38.5C300.7 50.1 311.7 62.9 322.3 75.9C335.8 92.4 352 114.2 367.6 140.1C372.8 133.3 377.6 127.3 381.8 122.2C382.9 120.9 384 119.5 385.1 118.1C393 108.3 402.8 96 415.9 96C429.3 96 438.7 107.9 446.7 118.1C448 119.8 449.3 121.4 450.6 122.9C460.9 135.3 474.6 153.2 488.3 175.3C515.5 219.2 543.9 281.7 543.9 351.9C543.9 475.6 443.6 575.9 319.9 575.9C196.2 575.9 96 475.7 96 352C96 260.9 137.1 182 176.5 127C196.4 99.3 216.2 77.1 231.1 61.9C239.3 53.5 247.6 45.2 256.6 37.7zM321.7 480C347 480 369.4 473 390.5 459C432.6 429.6 443.9 370.8 418.6 324.6C414.1 315.6 402.6 315 396.1 322.6L370.9 351.9C364.3 359.5 352.4 359.3 346.2 351.4C328.9 329.3 297.1 289 280.9 268.4C275.5 261.5 265.7 260.4 259.4 266.5C241.1 284.3 207.9 323.3 207.9 370.8C207.9 439.4 258.5 480 321.6 480z",
                ),
            ))
            html.elem("span", attrs: (class: "font-medium text-orange-600 *:p-0  !*:m-0 "), title)
        })
        content
    }),
)

#let tip(content, title: "Tip", ..params) = block(
    ..params,
    html.elem("div", attrs: (class: "px-3 py-2.5 rounded-md bg-green-600/10"), {
        html.elem("span", attrs: (class: "flex items-center gap-2 not-prose"), {
            html.elem("svg", attrs: (class: "size-5", xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 640 640"), html.elem(
                "path",
                attrs: (
                    class: "fill-green-600",
                    d: "M420.9 448C428.2 425.7 442.8 405.5 459.3 388.1C492 353.7 512 307.2 512 256C512 150 426 64 320 64C214 64 128 150 128 256C128 307.2 148 353.7 180.7 388.1C197.2 405.5 211.9 425.7 219.1 448L420.8 448zM416 496L224 496L224 512C224 556.2 259.8 592 304 592L336 592C380.2 592 416 556.2 416 512L416 496zM312 176C272.2 176 240 208.2 240 248C240 261.3 229.3 272 216 272C202.7 272 192 261.3 192 248C192 181.7 245.7 128 312 128C325.3 128 336 138.7 336 152C336 165.3 325.3 176 312 176z",
                ),
            ))
            html.elem("span", attrs: (class: "font-medium text-green-600 *:p-0  !*:m-0 "), title)
        })
        content
    }),
)


#let info(content, title: "Info", ..params) = block(
    ..params,
    html.elem("div", attrs: (class: "px-3 py-2.5 rounded-md bg-blue-600/10"), {
        html.elem("span", attrs: (class: "flex items-center gap-2 not-prose"), {
            html.elem("svg", attrs: (class: "size-5", xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 640 640"), html.elem(
                "path",
                attrs: (
                    class: "fill-blue-600",
                    d: "M320 576C461.4 576 576 461.4 576 320C576 178.6 461.4 64 320 64C178.6 64 64 178.6 64 320C64 461.4 178.6 576 320 576zM288 224C288 206.3 302.3 192 320 192C337.7 192 352 206.3 352 224C352 241.7 337.7 256 320 256C302.3 256 288 241.7 288 224zM280 288L328 288C341.3 288 352 298.7 352 312L352 400L360 400C373.3 400 384 410.7 384 424C384 437.3 373.3 448 360 448L280 448C266.7 448 256 437.3 256 424C256 410.7 266.7 400 280 400L304 400L304 336L280 336C266.7 336 256 325.3 256 312C256 298.7 266.7 288 280 288z",
                ),
                [],
            ))
            html.elem("span", attrs: (class: "font-medium text-blue-600 *:p-0  !*:m-0 "), title)
        })
        content
    }),
)

#let circ(drawing) = html.elem("div", attrs: (class: "mb-7  rounded-md border dark:border-zinc-800 overflow-hidden flex-col flex *:m-0 *:block *:w-full *:even:rounded-t-none"), {
    html.elem("div", attrs: (class: "p-7 bg-white rounded-t-md dark:invert dark:hue-rotate-180"))[
        #html.frame[
            #eval(drawing.text, mode: "markup")
        ]
    ]
    html.elem("div", attrs: (class: "*:rounded-t-none *:border-none border-t dark:border-zinc-800 *:border-none overflow-x-scroll"), raw(
        drawing.text.split("\n").slice(2).join("\n"),
        block: true,
        lang: "typst",
    ))
})

#let schema(drawing) = html.elem("div", attrs: (class: "mb-7  rounded-md border dark:border-zinc-800 overflow-hidden flex-col flex *:m-0 *:block *:w-full *:even:rounded-t-none"), {
    html.elem("div", attrs: (class: "p-7 bg-white rounded-md dark:invert dark:hue-rotate-180"))[
        #html.frame(drawing)
    ]
})
