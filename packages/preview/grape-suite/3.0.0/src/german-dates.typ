#let semester(short: false, date) = {
    let wise = (
        long: "Wintersemester",
        short: "WiSe"
    ).at(if short { "short" } else { "long" })

    let sose = (
        long: "Sommersemester",
        short: "SoSe"
    ).at(if short { "short" } else { "long" })

    let sem = if date.month() >= 4 and date.month() < 10 {
        sose
    } else {
        wise
    }

    let year = if date.month() < 4 {
        [#(date.year() - 1)/#date.year()]

    } else if date.month() >= 10 {
        [#date.year()/#(date.year() + 1)]

    } else if date.month() < 10 {
        date.year()
    }

    [#sem #year]
}

#let days = (
    "Montag",
    "Dienstag",
    "Mittwoch",
    "Donnerstag",
    "Freitag",
    "Samstag",
    "Sonntag"
)

#let weekday(short: false, daynr) = {
    let day = days.at(daynr - 1)

    if short {
        day = day.slice(0, 2)
    }

    day
}