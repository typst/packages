#import "icons.typ": bulb-icon, messages-icon, flare-icon, spider-icon

/// Documentation template generation function
///
/// - doc (document): documentation website content
/// - name (str): package name
/// - toml (toml): package configuration file, gives data to display
/// - copyright (bool): display/hide Manifesto copyright
/// - version (str): package version
/// - notices (array): list of notices to display on the left
/// - links (array): list of links to display on the left
/// - description (str): package description
/// - repository (str): link to package repository (e.g. GitHub, Gitlab, Codeberg)
/// - license (str): package license
/// - font ("sans" | "serif"): website font
/// -> content
#let template(
    doc,
    name: none,
    toml: none,
    copyright: true,
    version: none,
    notices: (),
    links: (),
    description: none,
    repository: none,
    universe: none,
    license: none,
    disciplines: none,
    font: "sans",
    class: "",
    ..params,
) = context [
    #let name = if toml != none { toml.package.name } else { name }
    #let dfont = if font == "sans" { "Hanken Grotesk" } else { "Libertinus Serif" }
    #let version = if toml != none { toml.package.at("version", default: none) } else { version }
    #let universe = if toml != none { toml.package.at("name", default: none) } else { universe }
    #let license = if toml != none { toml.package.at("license", default: none) } else { license }
    #let repository = if toml != none { toml.package.at("repository", default: none) } else { repository }
    #let description = if toml != none { toml.package.at("description", default: none) } else { description }
    #let disciplines = if toml != none { toml.package.at("disciplines", default: none) } else { disciplines }
    #assert(description != none, message: "description must be set")
    #assert(repository != none, message: "repository URL must be set")
    #if (target() == "paged") { [This template is not meant for PDF, please switch to #underline(link("https://typst.app/docs/reference/html/")[HTML export]).] }
    #html.html(lang: "en", class: "scroll-smooth")[
        #html.head[
            #html.meta(charset: "utf-8")
            #html.meta(name: "viewport", content: "width=device-width, initial-scale=1.0")
            #html.title[#context document.title]
            // Styling sources
            #html.script(src: "https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4")
            #html.link(rel: "preconnect", href: "https://fonts.googleapis.com")
            #html.link(rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: "anonymous")
            #html.link(
                rel: "stylesheet",
                href: "https://fonts.googleapis.com/css2?family=" + dfont.replace(" ", "+") + ":ital,wght@0,400;0,600;0,800;1,400;1,600;1,800&display=swap",
            )
        ]
        #let text-size = if font == "sans" { "text-base" } else { "text-lg" }
        #let small-text-size = if font == "sans" { "text-[0.88rem]" } else { "text-base" }
        #html.body(
            style: "font-family: '" + dfont + "', serif",
            class: if font == "sans" { "[&_.schema-notes]:text-sm " } + "print:[zoom:0.8] print:bg-white [&_*]:border-mist-200 [&_:is(h1,h2,h3,h4,h5,h6)]:font-semibold [&_:is(h1,h2,h3,h4,h5,h6)]:scroll-mt-5 [&_h2]:text-3xl [&_h3]:text-2xl [&_h4]:text-lg [&_h3]:mt-6 [&_h2:nth-of-type(n+2)]:mt-10 [&_h2]:mb-4
            [&_:is(h3,h4)]:mb-3 [&_:is(h5,h6)]:mb-4 [&_h4]:text-xl [&_p]:mb-3 [&_:is(ol,ul)]:ps-9 [&_ol_li::marker]:text-mist-500 [&_:is(ol,ul)]:space-y-3 [&_ol]:list-decimal [&_ul]:list-disc antialiased [&_a]:underline [&_a]:underline-offset-2 [&_a]:font-semibold text-mist-800
            dark:text-mist-300 [&_strong]:text-black [&_strong]:font-semibold [&_:is(strong,a)]:dark:text-white! dark:text-white bg-mist-50 dark:bg-mist-950 [&_*]:dark:border-mist-800
            [&_td]:py-1.5 [&_thead+tbody_tr:first-child_td]:pt-1.5 [&_th]:pb-2 [&_:is(td,th)]:border-b [&_:is(td,th)]:px-2 [&_td]:py-1 [&_:is(td,th):first-child]:pl-0 [&_td:last-child]:pr-0 [&_tr:last-child_td]:border-none [&_tr:first-child_td]:pt-0 [&_tr:last-child_td]:pb-0
            [&_td:has(.typst-frame)]:py-3!"
                + class,
        )[
            // Configuration
            #set heading(numbering: none, ..params.at("heading", default: (:)))
            // Raw blocks styling
            #show raw.where(block: false): it => {
                html.span(class: "border-t px-1 py-0.5 border-none rounded dark:bg-mist-800 bg-mist-200/60 text-xs font-mono", it)
            }
            #show raw.where(block: true): it => {
                html.div(class: "mb-4 p-4 border bg-mist-100/30 dark:bg-mist-900/20 dark:border-mist-800 text-[.85rem] rounded-md", it)
            }
            // Article
            #html.main(class: "max-w-[95rem] mx-auto grid lg:grid-cols-[max-content_auto_max-content] print:grid-cols-1 relative gap-8 p-5")[
                // Navigation
                #html.div(class: "order-1 md:w-64 overflow-visible print:hidden")[
                    #html.div(class: "sticky top-5 " + text-size + " [&_table]:my-6 [&_table]:w-full dark:text-white [&_table]:" + small-text-size)[
                        #html.h1(
                            class: if version != none { "rounded-bl-none " } else { "" }
                                + "capitalize bg-mist-900 mb-0 text-white max-w-max rounded-md px-2 py-0.5 text-3xl font-semibold",
                            name,
                        )
                        #if version != none {
                            html.div(class: small-text-size + " px-2 max-w-max rounded-md rounded-t-none bg-mist-800 mb-8 text-white")[v#version]
                        }
                        #description
                        #if disciplines != none and disciplines.len() > 0 {
                            html.div(class: "flex flex-wrap gap-1.5 mt-4 mb-2")[
                                #for i in disciplines {
                                    html.span(class: small-text-size + " bg-mist-200/50 dark:bg-mist-800 rounded-full px-2.5", i)
                                }
                            ]
                        }
                        #let provider = if "github" in repository { "GitHub" } else if "gitlab" in repository { "Gitlab" } else { "Source" }
                        #table(
                            columns: 2,
                            if repository != none { [Repository] }, html.a(href: repository, target: "_blank", provider),
                            ..if license != none { ([License], [#license]) },
                            [Typst Universe], html.a(href: "https://typst.app/universe/package/" + name, target: "_blank", name),
                            ..if version != none { ([Version], version) },
                            [Last update], [#datetime.today().display("[day padding:none] [month repr:short] [year]")],
                        )
                        #html.div(class: "grid grid-cols-2 *:flex *:items-start gap-x-3 gap-y-5 *:gap-2 [&_p]:m-0! text-mist-800 dark:text-mist-200 lg:grid-cols-1 mt-8")[
                            #if "qa" in notices [
                                #html.div[
                                    #messages-icon
                                    #html.div(class: small-text-size)[
                                        Got a question? \
                                        Ask it on the #link(notices.qa)[community forum].
                                    ]
                                ]
                            ]
                            #if "bug" in notices [
                                #html.div[
                                    #spider-icon
                                    #html.div(class: small-text-size)[
                                        Experienced a bug? \
                                        Please #link(notices.bug)[report] it.
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
                #html.article(
                    class: "order-3 md:order-2 " + text-size + " flex-auto overflow-hidden [&_table]:w-full [&_th]:text-left",
                    doc,
                )
                #html.div(class: "order-2 print:hidden " + text-size + "! md:order-3 md:w-64 flex-none")[
                    #html.div(
                        class: "sticky top-5 max-h-[calc(100vh-2.5rem)] overflow-y-auto dark:text-white lg:mb-12 *:space-y-0 [&_a]:font-normal! [&_a]:text-current! [&_a]:hover:text-black! [&_a]:dark:hover:text-white! [&_a]:no-underline!",
                    )[
                        #context {
                            let headings = query(heading.where(outlined: true))
                            let sections = ()
                            let current-section = none
                            for h in headings {
                                if h.depth == 1 {
                                    if current-section != none {
                                        sections.push(current-section)
                                    }
                                    current-section = (heading: h, children: ())
                                } else if current-section != none {
                                    current-section.children.push(h)
                                }
                            }
                            if current-section != none {
                                sections.push(current-section)
                            }
                            html.nav(class: "flex flex-col gap-2 [&_p]:m-0!", for (i, section) in sections.enumerate() {
                                if section.children.len() == 0 {
                                    link(section.heading.location(), section.heading.body)
                                } else {
                                    html.details(name: "outline-accordion", class: "group [&_a]:block", {
                                        html.elem(
                                            "summary",
                                            attrs: (class: "cursor-pointer list-none flex items-center justify-between [&::-webkit-details-marker]:hidden"),
                                            {
                                                link(section.heading.location(), section.heading.body)
                                                html.elem("svg", attrs: (class: "size-5 transition-transform group-open:rotate-90 shrink-0 opacity-50", xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke-width: "1.6", stroke-linecap: "round", stroke-linejoin: "round"))[#html.elem("path", attrs: (stroke: "none", fill: "none", d: "M0 0h24v24H0z")) #html.elem("path", attrs: (d: "M9 6l6 6l-6 6"))]
                                            },
                                        )
                                        html.div(class: "pl-4 border-l border-mist-200 dark:border-mist-700 ml-1 mb-1", for child in section.children {
                                            html.div(class: if child.depth >= 3 { "ps-4" } else { "" }, link(child.location(), child.body))
                                        })
                                    })
                                }
                            })
                        }
                    ]
                ]
            ]

            #html.div(class: "border-t p-5 print:hidden")[
                #if copyright [
                    #html.span(class: small-text-size)[Made with #link("https:/github.com/l0uisgrange/manifesto")[Manifesto] from Typst Universe]
                ]
            ]
        ]
    ]
]

/// Warning (orange) notice with attached icon
///
/// - content (content): notice content
/// - title (str): notice title, defaults to "Warning"
/// -> content
#let warning(content, title: "Warning", ..params) = block(
    ..params,
    html.div(class: "px-3 py-2.5 rounded-md bg-orange-600/10 mb-4", {
        html.span(class: "flex items-center gap-2 *:m-0!", {
            html.elem("svg", attrs: (class: "size-5", xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24"), html.elem(
                "path",
                attrs: (
                    class: "fill-orange-600",
                    d: "M10 2c0 -.88 1.056 -1.331 1.692 -.722c1.958 1.876 3.096 5.995 1.75 9.12l-.08 .174l.012 .003c.625 .133 1.203 -.43 2.303 -2.173l.14 -.224a1 1 0 0 1 1.582 -.153c1.334 1.435 2.601 4.377 2.601 6.27c0 4.265 -3.591 7.705 -8 7.705s-8 -3.44 -8 -7.706c0 -2.252 1.022 -4.716 2.632 -6.301l.605 -.589c.241 -.236 .434 -.43 .618 -.624c1.43 -1.512 2.145 -2.924 2.145 -4.78",
                ),
            ))
            html.span(class: "font-semibold text-orange-600", title)
        })
        content
    }),
)

/// Tip (green) notice with attached icon
///
/// - content (content): notice content
/// - title (str): notice title, defaults to "Tip"
/// -> content
#let tip(content, title: "Tip", ..params) = block(
    ..params,
    html.div(class: "px-3 py-2.5 rounded-md bg-green-700/10 mb-4", {
        html.span(class: "flex items-center gap-2 *:m-0!", {
            html.elem("svg", attrs: (class: "size-5", xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24"), {
                html.elem("path", attrs: (class: "fill-green-700", d: "M4 11a1 1 0 0 1 .117 1.993l-.117 .007h-1a1 1 0 0 1 -.117 -1.993l.117 -.007h1z"))
                html.elem("path", attrs: (class: "fill-green-700", d: "M12 2a1 1 0 0 1 .993 .883l.007 .117v1a1 1 0 0 1 -1.993 .117l-.007 -.117v-1a1 1 0 0 1 1 -1z"))
                html.elem("path", attrs: (class: "fill-green-700", d: "M21 11a1 1 0 0 1 .117 1.993l-.117 .007h-1a1 1 0 0 1 -.117 -1.993l.117 -.007h1z"))
                html.elem("path", attrs: (
                    class: "fill-green-700",
                    d: "M4.893 4.893a1 1 0 0 1 1.32 -.083l.094 .083l.7 .7a1 1 0 0 1 -1.32 1.497l-.094 -.083l-.7 -.7a1 1 0 0 1 0 -1.414z",
                ))
                html.elem("path", attrs: (class: "fill-green-700", d: "M17.693 4.893a1 1 0 0 1 1.497 1.32l-.083 .094l-.7 .7a1 1 0 0 1 -1.497 -1.32l.083 -.094l.7 -.7z"))
                html.elem("path", attrs: (class: "fill-green-700", d: "M14 18a1 1 0 0 1 1 1a3 3 0 0 1 -6 0a1 1 0 0 1 .883 -.993l.117 -.007h4z"))
                html.elem("path", attrs: (class: "fill-green-700", d: "M12 6a6 6 0 0 1 3.6 10.8a1 1 0 0 1 -.471 .192l-.129 .008h-6a1 1 0 0 1 -.6 -.2a6 6 0 0 1 3.6 -10.8z"))
            })
            html.span(class: "font-semibold text-green-700", title)
        })
        content
    }),
)

/// Example (purple) notice with attached icon
///
/// - content (content): notice content
/// - title (str): notice title, defaults to "Example"
/// -> content
#let example(content, title: "Example", ..params) = block(
    ..params,
    html.div(class: "px-3 py-2.5 rounded-md bg-purple-600/10 mb-4", {
        html.span(class: "flex items-center gap-2 *:m-0!", {
            html.elem("svg", attrs: (class: "size-5", xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24"), html.elem(
                "path",
                attrs: (
                    class: "fill-purple-600",
                    d: "M11.106 2.553a1 1 0 0 1 1.788 0l2.851 5.701l5.702 2.852a1 1 0 0 1 .11 1.725l-.11 .063l-5.702 2.851l-2.85 5.702a1 1 0 0 1 -1.726 .11l-.063 -.11l-2.852 -5.702l-5.701 -2.85a1 1 0 0 1 -.11 -1.726l.11 -.063l5.701 -2.852z",
                ),
            ))
            html.span(class: "font-semibold text-purple-600", title)
        })
        content
    }),
)

/// Info (blue) notice with attached icon
///
/// - content (content): notice content
/// - title (str): notice title, defaults to "Info"
/// -> content
#let info(content, title: "Info", ..params) = block(
    ..params,
    html.div(class: "px-3 py-2.5 rounded-md bg-blue-600/10 mb-4", {
        html.span(class: "flex items-center gap-2 *:m-0!", {
            html.elem("svg", attrs: (class: "size-5", xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24"), html.elem(
                "path",
                attrs: (
                    class: "fill-blue-600",
                    d: "M12 2c5.523 0 10 4.477 10 10a10 10 0 0 1 -19.995 .324l-.005 -.324l.004 -.28c.148 -5.393 4.566 -9.72 9.996 -9.72zm0 9h-1l-.117 .007a1 1 0 0 0 0 1.986l.117 .007v3l.007 .117a1 1 0 0 0 .876 .876l.117 .007h1l.117 -.007a1 1 0 0 0 .876 -.876l.007 -.117l-.007 -.117a1 1 0 0 0 -.764 -.857l-.112 -.02l-.117 -.006v-3l-.007 -.117a1 1 0 0 0 -.876 -.876l-.117 -.007zm.01 -3l-.127 .007a1 1 0 0 0 0 1.986l.117 .007l.127 -.007a1 1 0 0 0 0 -1.986l-.117 -.007z",
                ),
            ))
            html.span(class: "font-semibold text-blue-600", title)
        })
        content
    }),
)

/// Wrapper for `html.frame`, with background and border
///
/// - drawing (content): CeTZ canvas or any content
/// - code (content): raw content (e.g. code) to display below the schema
/// - leftnote (content): raw content (e.g. source text) to display left under the schema
/// - rightnote (content): raw content (e.g. source text) to display right under the schema
/// -> content
#let schema(drawing, code: none, lang: "typst", leftnote: none, rightnote: none) = html.div(
    class: "mb-7 rounded-md text-base border mb-4 flex-col flex *:m-0 *:block *:w-full *:even:rounded-t-none",
    {
        html.div(class: "bg-white rounded-md overflow-x-auto print:p-4 p-7 *:mr-7" + if code != none or leftnote != none or rightnote != none { " rounded-b-none" } else { "" })[
            #html.frame(drawing)
        ]
        if leftnote != none {
            html.div(class: "schema-notes flex! justify-between flex-row items-center px-4 pb-3 rounded-md bg-white dark:text-black [&_a]:text-black!", {
                if leftnote != none {
                    html.div(leftnote)
                }
                if rightnote != none {
                    html.div(class: "", rightnote)
                }
            })
        }
        if code != none {
            html.div(class: "*:rounded-t-none *:border-none border-t *:m-0 dark:border-mist-800 *:border-none overflow-x-scroll", code)
        }
    },
)
