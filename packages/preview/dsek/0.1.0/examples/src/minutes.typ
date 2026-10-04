#import "@preview/dsek:0.1.0": *
#import strings: infu, styr

#show: protokoll.with(
  meeting: "S06",
  attendees: (
    ("Truls Teknolog", styr.ordf),
    ("Trula Teknolog", infu.ansv),
    ("Råsa Pantern", "Sektionsmaskot", (from: [@tid-och-sätt], to: [@val-av-justerare])),
    "Pelle Postlös", // name only, no position
  ),
  attested: false, // default; set to true to remove watermark
  chair: [@trulsteknolog],
  secretary: [@trulateknolog],
  reviewers: ([@pellepostlös],), // one or more
)

/ OFMÖ:
  @trulsteknolog[] förklarade mötet öppnat 12:15. // Ordförande Truls Teknolog förklarade...

/ Tid och sätt:
  Tid och sätt godkändes.

/ Val av justerare:
  Mötet beslöt
  - att välja @pellepostlös till justerare // *att* välja Pelle Postlös till...

/ Information från kollegierna:
  / InfoK: Ingen ny information. // normal terms

/ Veckans roliga punkt:
  @trulateknolog drog en ordvits.

/ Uppföljning\: Veckans roliga punkt:

  @pellepostlös yrkade på
  - att stryka @veckans-roliga-punkt från protokollet
  Mötet avslog yrkandet.

  @trulateknolog yrkade på
  - att åligga @pellepostlös att "komma på något bättre själv då" med uppföljning till nästa styrelsemöte.
  Mötet biföll yrkandet.

/ OFMA:
  @trulsteknolog förklarade mötet avslutat 12:18

Efter mötet såg beslutsuppföljningslistan ut enligt följande:

#followup(
  ("S03", [Hitta den försvunna sektionsdiamanten], [Råsa Pantern], "HTM1"),
  ("S06", [Kom på en bättre ordvits än Trula], [@pellepostlös], "S07"),
)
