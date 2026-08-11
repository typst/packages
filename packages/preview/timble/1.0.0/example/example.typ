#import "@preview/timble:1.0.0": *
#set page(paper: "a4", margin: 1cm, flipped: true)

#timetable(title: "WiSe 25/26", font: "Liberation Sans", base-font-size: 13pt,
    start-hour: 9, end-hour: 16,
    monday: (
        (10.15, 11.45, red, [Sequential Music _R302_]),
        (12.15, 13.45, aqua, [Developmental diagnostics _F35_]),
        (13.45, 14.15, gray, [_Lunch_]),
        (14.15, 15.45, red, [Cultural reflections in MU _L212_]),
    ),
    tuesday: (
        (09.15, 11.45, red, [MU and climate change _L215_]),
        (12.00, 13.00, orange, [Singing _L518_],),
        (14.15, 15.45, red, [Dance in School _L102_]),
    ),
    wednesday: (
        (10.15, 11.45, aqua, [SP Security _A31_]),
        (14.30, 16.05, yellow, [CS Extracurricular _I118_]),
    ),
    thursday: (
        (09.15, 11.45, aqua, [EE Romik _KL16_]),
    ),
    asynchronous: (
        (10, 13, aqua, [VL PD Kisten]),
    ),
)
