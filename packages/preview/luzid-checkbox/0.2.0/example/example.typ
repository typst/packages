#set page(width: auto, height: auto, margin: 1em, columns: 2)

#[
    #import "../luzid-checkbox.typ": luzid

    #show: luzid.with(
        style-map: (
            important: it => text(weight: "bold")[#it],
        ),
    )

    #grid(
        columns: 2,
        gutter: 1em,
        [- [ ] task], [- [x] done],
        [- [>] rescheduled], [- [<] scheduled],
        [- [!] important], [- [-] cancelled],
        [- [/] progress], [- [?] question],
        [- [\*] star], [- [n] note],
        [- [l] location], [- [i] information],
        [- [I] idea], [- [S] amount],
        [- [p] pro], [- [c] contra],
        [- [b] bookmark], [- [\"] quote],
        [- [u] up], [- [d] down],
        [- [w] win], [- [k] key],
        [- [f] fire],
    )
]

#pagebreak()


#[
    #import "../luzid-checkbox.typ": luzid

    #show: luzid.with(
        color-map: (
            task: rgb("#0000ff"),
        ),
        marker-map: (
            done: "icons/pin.svg", // path to a different icon
        ),
        style-map: (
            important: it => text(weight: "bold")[#it], // wrapping function
        ),
    )

    - [ ] Icon color
    - [x] Icon
    - [!] Styling
]
