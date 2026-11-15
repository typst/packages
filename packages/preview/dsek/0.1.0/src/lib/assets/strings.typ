#import "../utils/translate.typ": translate

// TODO: Prettify/regularise the keys.

// Governed by Riktlinje för internationalisering

#let guild = (
  "dsek": translate([D-sektionen], [The D-guild]),
  "dseklth": translate([D-sektionen inom TLTH], [The D-guild within TLTH]),
  "data": translate([Data-?teknik], [Computer Science and Engi-?neering]),
  "infocom": translate([Informations- och kommunikations-?teknik], [Information and Communi-?cation Engi-?neering]),
  "vrar": translate([Virtuell verk-?lighet och förstärkt verk-?lighet], [Virtual Reality and Aug-?mented Reality]),
)

#let styr = (
  "name": translate([Styrelsen], [The Board]),
  "ordf": translate([Ordförande], [President]),
  "sordf": translate([Sektions-?ordförande], [Guild President]),
  "vice_ordf": translate([Vice ordförande], [Vice President]),
  "vice_sordf": translate([Vice sektions-?ordförande], [Vice Guild President]),
)

#let aktu = (
  "name": translate([Aktivitets-?utskottet], [The Recreation Com-?mittee]),
  "ansv": translate([Aktivitets-?ansvarig], [Head of Recreation]),
  "vice_ansv": translate([Vice Aktivitets-?ansvarig], [Vice Head of Recreation]),
  "utedischoansv": translate([UtEDischo-?ansvarig], [UtEDischo Manager]),
  "idrottsfm": translate([Idrotts-?förman], [Head of Sports Events]),
  "dsportare": translate([D-sportare], [Tournament Organizer]),
  "karnevalsansv": translate([Karnevals-?ansvarig], [Lundakarnevalen Repre-?sentative]),
  "lanpartyansv": translate([LAN-party-?ansvarig], [LAN-party Coor-?dinator]),
  "semester": translate([Semester-?firare], [Holiday-?maker]),
  "sasfm": translate([Sångar-?strids-?förman], [TLTH Song Contest Team Captain]),
  "tandemgen": translate([Tandem-?general], [Tandem Relay Team Captain]),
  "nojesfm": translate([Nöjes-?förman], [Chief of Joy]),
  "coach": translate([Coach], [Coach]),
)

#let infu = (
  "name": translate([Informations-?utskottet], [The Communi-?cations Com-?mittee]),
  "ansv": translate([Informations-?ansvarig], [Head of Communi-?cations]),
  "vice_ansv": translate([Vice Informations-?ansvarig], [Vice Head of Communi-?cations]),
  "fotograf": translate([Fotograf], [Photographer]),
  "filmare": translate([Filmare], [Filmmaker]),
  "arkivarie": translate([Arkivarie], [Archivist]),
  "artist": translate([Artist], [Artist]),
  "influencer": translate([Influencer], [Influencer]),
  "journalist": translate([Journalist], [Journalist]),
  "redaktor": translate([Redaktör], [Editor]),
  "shopaholic": translate([Shopaholic], [Shopaholic]),
  "skald": translate([Skald], [Bard]),
  "markv": translate([Märkvärdig], [Patchy]),
)

#let cafe = (
  "name": translate([Café-?mästeriet], [The Café Com-?mittee]),
  "mastare": translate([Café-?mästare], [Head of the Café]),
  "vice_mastare": translate([Vice café-?mästare], [Vice Head of the Café]),
  "dagsansv": translate([Dags-?ansvarig], [Daycarer]),
  "inventarieansv": translate([Inventarie-?ansvarig], [Stockpiler]),
  "stekare": translate([Stekare], [Grillmaster]),
  "brunchm": translate([Brunch-?mästare], [Head of Brunch]),
  "bakis": translate([Bakis], [Baked]),
)

#let skattm = (
  "name": translate([Skatt-?mästeriet], [The Treasury]),
  "mastare": translate([Skatt-?mästare], [Treasurer]),
  "vice_mastare": translate([Vice Skatt-?mästare], [Vice Treasurer]),
  "fm": translate([Skatt-?förman], [Treasury Foreman]),
)

#let fram = (
  "name": translate([Framtids-?utskottet], [The Strategic Com-?mittee]),
  "ordf": translate([Framtids-?ordförande], [Head of the Strategic Com-?mittee]),
  "ledamot": translate([Framtids-?ledamot], [Member of the Strategic Com-?mittee]),
)

#let km = (
  "name": translate([Källar-?mästeriet], [The Facilities Com-?mittee]),
  "mastare": translate([Källar-?mästare], [Head of Facilities]),
  "vice_mastare": translate([Vice källar-?mästare], [Vice Head of Facilities]),
  "bilansv": translate([Bil-?ansvarig], [Guild Car Mechanic]),
  "ljudoljus": translate([Ljud- och ljus-?ansvarig], [Audiovisual Technician]),
  "tradgm": translate([Trädgårds-?mästare], [Gardener]),
)

#let nollu = (
  "name": translate([Nollnings-?utskottet], [The Intro-?ductions Com-?mittee]),
  "oph": translate([Øver-?phøs], [Head of the Intro-?ductions Com-?mittee]),
  "stab": translate([Stabs-?medlem], [Member of the Intro-?ductions Com-?mittee]),
  "opepp": translate([Øver-?peppare], [Head of Introduction Coor-?dinators]),
  "pepp": translate([Peppare], [Introduction Coor-?dinator]),
  "phadder": translate([Phadder], [Mentor]),
  "pluggphadder": translate([Plugg-?phadder], [Study Mentor]),
)

#let naru = (
  "name": translate([Näringslivs-?utskottet], [The Corpo-?rate Rela-?tions Com-?mittee]),
  "ansv": translate([Näringslivs-?ansvarig], [Head of Corpo-?rate Rela-?tions]),
  "vice_ansv": translate([Vice näringslivs-?ansvarig], [Vice Head of Corpo-?rate Rela-?tions]),
  "alumniansv": translate([Alumni-?grupps-?ansvarig], [Head of the Alumni Com-?mittee]),
  "aulmnimdlm": translate([Alumni-?grupps-?medlem], [Member of the Alumni Com-?mittee]),
  "koordinator": translate([Näringslivs-?koordinator], [Corpo-?rate Rela-?tions Coor-?dinator]),
  "deltag": translate([DELTA-general], [DELTA Project Manager]),
  "deltapr": translate([DELTA-projektledare], [Member of the DELTA Project Group]),
  "deltav": translate([DELTA-general], [DELTA Host]),
)

#let sexm = (
  "name": translate([Sex-?mästeriet], [The Festivities Com-?mittee]),
  "mastare": translate([Sex-?mästare], [Head of Festivities]),
  "vice_mastare": translate([Vice sex-?mästare], [Vice Head of Festivities]),
  "barm": translate([Bar-?mästare], [Bartender]),
  "vbarm": translate([Vice bar-?mästare], [Vice Bartender]),
  "pubm": translate([Pub-?mästare], [Head of Pubs]),
  "vpubm": translate([Vice pub-?mästare], [Vice Head of Pubs]),
  "hovm": translate([Hov-?mästare], [Maître D'guild]),
  "sangfm": translate([Sång-?förman], [Toastmaster]),
  "kokm": translate([Köks-?mästare], [Head chef]),
  "vkokm": translate([Vice köks-?mästare], [Sous chef]),
  "prefm": translate([Preferens-?mästare], [Preferences chef]),
  "olfm": translate([Öl-?förman], [Beer Boss]),
  "vinfm": translate([Vin-?förman], [Wine Warden]),
  "tappad": translate([TappaD], [Beer Boss in charge of Draft]),
  "sektkock": translate([Sektions-?kock], [Guild Cook]),
)

#let srd = (
  "name": translate([Studie-?rådet], [The Student Council]),
  "ordf": translate([Studie-?råds-?ordförande], [Head of the Student Council]),
  "vice_ordf": translate([Vice studie-?råds-?ordförande], [Vice Head of the Student Council]),
  "sekr": translate([Studie-?råds-?sekreterare], [Secretary of the Student Council]),
  "progledrep": translate([Program-?lednings-?representant], [Student Repre-?sentative of Program Manage-?ment]),
  "instledrep": translate([Institutions-?lednings-?representant], [Student Repre-?sentative of the Depart-?ment Board]),
  "husrep": translate([Hus-?representant], [Student Repre-?sentative of the House Board]),
  "arskursrep": translate([Års-?kurs-?representant], [Class Repre-?sentative]),
)

#let cpu = (
  "name": translate([Central-?process-?utskottet], [The Central Process-?ing Unit]),
  "mastare": translate([Process-?mästare], [Head Processor]),
  "vice_mastare": translate([Vice Process-?mästare], [Subprocessor]),
  "dwwwansv": translate([DWWW-ansvarig], [Head of DWWW]),
  "root": translate([root], [root]),
  "utvecklare": translate([Utvecklare], [Developer]),
)

#let medalj = (
  "name": translate([Medeljelele-?kommitén], [The Honours Com-?mittee]),
  "omslk": translate([Øver-?marskalk], [Master of Ceremonies]),
  "mdlm": translate([Medaljelele-?kommité-?medlem], [Member of the Honours Com-?mittee]),
)

#let valb = (
  "name": translate([Val-?beredningen], [The Nomination Com-?mittee]),
  "ordf": translate([Val-?beredningens ordförande], [Head of the Nomination Com-?mittee]),
  "rep": translate([Val-?berednings-?representant], [Member of the Nomination Com-?mittee]),
)

#let tackm = (
  "name": translate([Tack-?mästeriet], [The Thanks-?giving Com-?mittee]),
  "mastare": translate([Tack-?mästare], [Head of the Thanks-?giving Com-?mittee]),
  "mdlm": translate([Tack-?mästerist], [Member of the Thanks-?giving Com-?mittee]),
)

#let triv = (
  "name": translate([Trivsel-?rådet], [The Student Well-being Com-?mittee]),
  "mastare": translate([Trivsel-?mästare], [Head of Student Well-being]),
  "likbehombud": translate([Lika-?behandlings-?ombud], [Equal Opportunities Repre-?sentative]),
  "skyddsombud": translate([Skydds-?ombud], [Student Safety Repre-?sentative]),
  "varldsm": translate([Världs-?mästare], [World Master]),
)

#let otherpos = (
  "inspektor": translate([Inspektor], [Inspector]),
  "revisor": translate([Revisor], [Auditor]),
  "talman": translate([Talman], [Assembly speaker]),
  "jublegeneral": translate([Jubileums-?general], [Head of the Anniversary Com-?mittee]),
  "jubleansv": translate([Jubileums-?ansvarig], [Member of the Anniversary Com-?mittee]),
)

#let lth-symbols = (
  "asek": text(font: "LTH symbols", "A"),
  "dsek": text(font: "LTH symbols", "D"),
  "esek": text(font: "LTH symbols", "E"),
  "fsek": text(font: "LTH symbols", "F"),
  "ing": text(font: "LTH symbols", "H"),
  "isek": text(font: "LTH symbols", "I"),
  "ksek": text(font: "LTH symbols", "K"),
  "msek": text(font: "LTH symbols", "M"),
  "dokt": text(font: "LTH symbols", "O"),
  "tlth": text(font: "LTH symbols", "T"),
  "vsek": text(font: "LTH symbols", "V"),
  "wsek": text(font: "LTH symbols", "W"),
  "biif": text(font: "LTH symbols", "b"),
  "infocom": text(font: "LTH symbols", "C"),
  "helge": text(font: "LTH symbols", "h"),
  "lant": text(font: "LTH symbols", "l"),
  "td": text(font: "LTH symbols", "t"),
)
