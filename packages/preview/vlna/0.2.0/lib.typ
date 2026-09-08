// vlna 0.2.0 — česká sazba: nezlomitelné mezery („vlna").
// Oproti 0.1.1 zachovává „skok do zdroje" (box místo přepisu textu na ~),
// navíc řeší dvoupísmenná slova, řetězení, tituly před i za jménem a zkratky.
//
// Pravidla:
//   1. Za jedno- a dvoupísmennými slovy řádek nekončí (k, s, v, z, a, i, …,
//      ale i „po", „do", „je", „se") — mezera za nimi je nezlomitelná.
//   2. Tituly a zkratky PŘED jménem/výrazem (Ing., doc., pplk. gšt., např.,
//      viz, s., …) se váží k následujícímu slovu.
//   3. Tituly ZA jménem (Ph.D., CSc., …) se váží k předchozímu slovu.
//
// Ladění: `#show: apply-vlna.with(debug: true)` orámuje všechny zásahy.

// Vzor krátkého slova (1–2 písmena): první písmeno libovolné (věta smí začínat
// „V lese…"), druhé jen malé — pravidlo se tak nedotkne zkratek typu EU, AI,
// OSN. Sestavení do běhu s navazujícím slovem je níže (short-run).

// --- Tituly a zkratky PŘED jménem -------------------------------------------
#let before-list = (
  // === Oslovení ===
  "p.", "pan", "Pan", "pí.", "paní", "Paní", "sl.", // Česká
  "Mr.", "Mrs.", "Ms.", // Anglická

  // === Akademické tituly (před jménem) ===
  // Bakalářské
  "bc.", "Bc.", "BcA.",
  // Magisterské a inženýrské
  "mgr.", "Mgr.", "mga.", "MgA.",
  "ing.", "Ing.", "Ing. arch.",
  // Doktorské (tzv. „malé" a profesní)
  "dr.", "Dr.", // Obecný doktorát (historický, již se neuděluje)
  "mudr.", "MUDr.", // Lékařství
  "mvdr.", "MVDr.", // Veterinární lékařství
  "MDDr.", // Zubní lékařství
  "judr.", "JUDr.", // Právo
  "phdr.", "PhDr.", // Filosofie
  "rndr.", "RNDr.", // Přírodní vědy
  "PharmDr.", // Farmacie
  "thdr.", "ThDr.", // Teologie (starší doktorát)
  "ThLic.", // Licenciát teologie

  // === Akademické hodnosti (vědecko-pedagogické) ===
  "doc.", "Doc.", // Docent
  "prof.", "Prof.", // Profesor
  "akad.", // akademik (nejvyšší vědecká hodnost ČSAV, již se neuděluje)

  // === Čestné tituly ===
  "dr. h. c.", // Doctor honoris causa

  // === Vojenské hodnosti ===
  // Mužstvo
  "voj.", "svob.",
  // Poddůstojníci
  "des.", "čet.", "rtn.",
  // Praporčíci
  "rtm.", "nrtm.", "prap.", "nprap.", "šprap.",
  // Nižší důstojníci
  "por.", "npor.", "kpt.",
  // Vyšší důstojníci
  "mjr.", "pplk.", "pplk. gšt.", "plk.", "plk. gšt.",
  // Generálové
  "brig.gen.", "genmjr.", "genpor.", "arm.gen.",
  // === Policejní hodnosti (mimo již zavedené) ===
  "stržm.", "nstržm.", "pprap.", "ppor.",

  // === Zkratky ===
  "aj.", "apod.", "atd.", "atp.", "cca", "č.", "čj.", "kupř.", "mj.",
  "např.", "popř.", "pozn.", "př.", "příp.", "resp.", "s.", "str.", "sv.",
  "tj.", "tzv.", "tzn.", "viz", "zvl.",
)

// --- Tituly ZA jménem --------------------------------------------------------
#let after-list = (
  "DiS.",
  "Ph.D.", // Doktor (vědecký, standardní)
  "PhD.", // zahraniční varianta
  "PhD", // zahraniční varianta bez teček
  "Th.D.", // Doktor teologie (vědecký)
  "CSc.", // Kandidát věd (dobíhá)
  "DrSc.", // Doktor věd (dobíhá)
  "DSc.", // Doktor věd (UK a AV ČR)
  "MBA", "LL.M.", "MSc.",
)

// --- Sestavení vzorů ---------------------------------------------------------
#let escape-dot(t) = t.replace(".", "\\.")

// Alternace: delší varianty první (jinak by „pplk." vyhrálo nad „pplk. gšt."
// a „Ing." nad „Ing. arch."). Položky NEkončící tečkou dostanou koncovou
// hranici slova, aby „PhD" nechytalo začátek „PhDr." ani „viz" slovo „vize".
#let alternation(list) = {
  list
    .sorted(key: t => -t.len())
    .map(t => escape-dot(t) + if not t.ends-with(".") { "\\>" } else { "" })
    .join("|")
}

// Pravidla matchují CELÝ blok (krátká slova + jejich slovo / titul + jméno),
// aby ho šlo obalit do #box a tím zamezit zlomu. Klíčové pro zachování
// „skoku do zdroje": box propouští PŮVODNÍ `it` beze změny, takže glyfy si
// drží zdrojovou pozici. (Kdybychom místo toho přepisovali `it.text`, nový
// text by dostal pozici tohoto modulu a klik v PDF by mířil sem, ne do textu.)
//
// Kompromis oproti přepisu na ~: uvnitř boxu se mezery při justify nenatahují
// a slovo v boxu se nezlomí dělením (u velmi dlouhých slov za předložkou proto
// může vzniknout volnější řádek).

// Předpona = jeden „lepivý" prvek: krátké slovo NEBO titul/zkratka před jménem.
// Sloučení do jednoho vzoru je nutné kvůli řetězení — jinak by u „za tzv. X"
// krátké slovo „za" pohltilo titul „tzv." jako své cílové slovo a titul by se
// pak od „X" oddělil (a stejně u „Mgr. et Mgr. Ing. Novák").
#let short-word = "\\<\\p{L}\\p{Ll}?\\>"
#let prefix = "(?:" + short-word + "|\\<(?:" + alternation(before-list) + "))"

// Běh předpon + cílové slovo:  „k s bratrem", „V současném", „za tzv. postup",
// „prof. Ing. arch. Novák".
#let prefix-run = regex("(?:" + prefix + " )+\\S+")
// Slovo + titul ZA jménem:  „Novák, Ph.D."
#let after-pattern = regex("\\S+ (?:" + alternation(after-list) + ")")

// --- Aplikace ----------------------------------------------------------------
#let apply-vlna(doc, debug: false) = {
  // box(it) = nezlomitelný blok se zachovanou zdrojovou pozicí glyfů.
  let glue(color) = if debug {
    it => box(stroke: .5pt + color, outset: 1.5pt, it)
  } else {
    it => box(it)
  }

  show prefix-run: glue(purple)
  show after-pattern: glue(blue)

  doc
}
