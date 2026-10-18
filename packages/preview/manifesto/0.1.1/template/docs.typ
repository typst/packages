#import "@preview/manifesto:0.1.1": info, schema, template, tip, warning
#import "@preview/zap:0.5.0"

#show: it => template(it, title: "MyPackage", version: "0.1.0", description: "My package is awesome", repository: "https://github.com/username/mypackage")

= My first title

This manifesto respresent the next generation of Typst writing, with a dedicated and modern documentation template written in Typst.

== My first subtitle

Feel free to use the builtin blocks below.

#info[Some information to show]
#tip[Give some useful tip]
#warning[Warn your users about something]

== My second subtitle

You can also make a drawing as you wish.

#schema[
    #zap.circuit({
        import zap: *

        zap.resistor("r1", (0, 0), (3, 0))
    })
]
