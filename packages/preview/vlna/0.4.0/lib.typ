// vlna 0.4.0 — česká sazba: nezlomitelné mezery („vlna").
// Zachovává „skok do zdroje" (box místo přepisu textu na ~) a pokrývá
// pravidla ÚJČ (prirucka.ujc.cas.cz/?id=880) i příkazy luavlna.
//
// Pravidla:
//   1. Za jedno- a dvoupísmennými slovy řádek nekončí (k, s, v, z, a, i, …,
//      ale i „po", „do", „je", „se") — mezera za nimi je nezlomitelná.
//   2. Tituly a zkratky PŘED jménem/výrazem (Ing., doc., pplk. gšt., např.,
//      viz, s., …) se váží k následujícímu slovu.
//   3. Tituly ZA jménem (Ph.D., CSc., …) se váží k předchozímu slovu.
//   4. Iniciály (M. J. Hegel, Ch. Novák) se váží k následujícímu slovu.
//   5. Čísla: členění (2 500), značky (50 %, § 23), jednotky a měny
//      (10 kg, 19 °C, 1 000 000 Kč), telefonní čísla (+420 800 123 987).
//   6. Poměry a měřítka (1 : 50 000, 10 : 2 = 5), kalendářní data
//      (21. 6. | 2024, 16. ledna | 1972), pomlčky (slovo –, 1948–1989).
//   7. Složené zkratky a kódy (a. s., př. n. l., PS PČR, ČSN 01 6910).
//   8. Webové a e-mailové adresy v link(): zlom jen na místech dle ÚJČ.
//
// Volby: `bind-two-letter-words: false` váže jen jednopísmenná slova;
// `short-words: "vksuozVKSUOZAI"` (či pole slov, či slovník podle jazyka)
// váže přesně zadaná slova; `initials`/`compound-initials` řídí iniciály;
// `lang` vynutí jednu jazykovou sadu. Uprostřed dokumentu lze zpracování
// vypnout/zapnout `#vlna-off()`/`#vlna-on()` (a orámování zásahů
// `#vlna-debug-on()`/`#vlna-debug-off()`).
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
  "aj.", "apod.", "atd.", "atp.", "cca", "č.", "čj.", "kap.", "kupř.",
  "mj.", "např.", "obr.", "odst.", "popř.", "pozn.", "př.", "příp.",
  "resp.", "s.", "str.", "sv.", "tab.", "tj.", "tzv.", "tzn.", "viz", "zvl.",
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

// --- Jednotky a značky za číslem (ÚJČ: „5 str.", „10 kg", „19 °C", „250 €") --
// Výchozí seznam; vlastní: `units: vlna.default-units + ("µm",)` nebo úplně
// jiný. Řadí se nejdelší první, takže „m²" ani „km/h" neprohrají s „m".
#let default-units = (
  // procenta, stupně, měny
  "%", "‰", "°C", "°F", "°", "Kč", "€", "$", "£",
  // hmotnost, délka, plocha, objem
  "kg", "dag", "g", "mg", "t", "km", "m", "dm", "cm", "mm", "µm", "nm",
  "km²", "m²", "ha", "m³", "hl", "l", "dl", "ml",
  // čas a rychlost
  "h", "hod.", "min", "s", "ms", "km/h", "m/s",
  // fyzika a výpočetní technika
  "Hz", "kHz", "MHz", "GHz", "W", "kW", "MW", "kWh", "MWh",
  "J", "kJ", "MJ", "V", "mV", "kV", "A", "mA", "µA",
  "Pa", "hPa", "kPa", "MPa", "N", "kN",
  "kB", "MB", "GB", "TB", "KiB", "MiB", "GiB",
  // zkratky počítaného předmětu
  "str.", "s.", "č.", "obr.", "tab.", "tis.", "mil.", "mld.",
)

// Měsíce pro kalendářní data („16. ledna"); `months: (...)` je nahradí.
#let _czech-months = (
  "ledna", "února", "března", "dubna", "května", "června",
  "července", "srpna", "září", "října", "listopadu", "prosince",
)

// --- Sestavení vzorů ---------------------------------------------------------
#let escape-dot(t) = t.replace(".", "\\.")

// Obecné escapování pro položky, jež mohou nést regexové metaznaky ($, %, /).
#let escape-regex(t) = {
  let specials = ("\\", ".", "+", "*", "?", "(", ")", "[", "]", "{", "}", "|", "^", "$")
  t.clusters().map(c => if c in specials { "\\" + c } else { c }).join("")
}

// --- Zalomení webových a e-mailových adres ------------------------------------
// ÚJČ doporučuje vložit mezeru nulové šířky (U+200B) tam, kde adresa smí
// pokračovat na dalším řádku: za lomítkem (ne mezi znaky „//"), před tečkou,
// spojovníkem, @ (i za ním) a dalšími speciálními znaky. Znak se nevykresluje,
// jen dovolí zlom; cíl odkazu (dest) se nemění, odkaz zůstává funkční.
#let _zwsp = "\u{200B}"

// Vytáhne z těla odkazu prostý text. Tělo nemusí být jediný text element —
// „jan.novak\@seznam.cz" je SEKVENCE (escape rozdělí textové uzly), styly
// (kurziva adres) obalují. Cokoli jiného (mezery, obrázky, …) vrátí none
// a odkaz se nechá být — adresa mezery neobsahuje, takže none = ne-adresa.
#let _link-text(body) = {
  // has("text") místo func() == text: escapované znaky („\@") jsou element
  // `symbol`, jenž má také pole text.
  if body.has("text") {
    body.text
  } else if body.has("children") {
    let parts = body.children.map(_link-text)
    if parts.contains(none) { none } else { parts.join("") }
  } else if body.has("child") {
    _link-text(body.child)
  } else if body.has("body") {
    _link-text(body.body)
  } else {
    none
  }
}

#let _breakable-url(s) = {
  let break-before = (".", "-", "‑", "?", ",", "_", "%", "=", "#", "~", "&", "@")
  let cs = s.clusters()
  let out = ""
  for (i, c) in cs.enumerate() {
    if i > 0 and c in break-before { out += _zwsp }
    out += c
    // Za @ jen v e-mailech; účet na sociální síti („@SenatCZ", @ na
    // začátku) se za zavináčem nezalamuje.
    if c == "@" and i > 0 { out += _zwsp }
    if c == "/" and i + 1 < cs.len() and cs.at(i + 1) != "/" { out += _zwsp }
  }
  out
}

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

// Slovo + titul ZA jménem:  „Novák, Ph.D."
#let after-pattern = regex("\\S+ (?:" + alternation(after-list) + ")")

// --- Přepínače uprostřed dokumentu -------------------------------------------
// Obdoba luavlna \preventsingleon/off a \preventsingledebugon/off. Globální
// show pravidlo nejde zevnitř dokumentu „odstínit", proto stav: glue() ho
// čte a mimo aktivní úsek vrací obsah beze změny.
//
// Vše v JEDINÉM stavu: čtení stavu je nejdražší část práce na jeden nález
// (~13 µs) a nálezů je v běžném dokumentu desetitisíce. Tři stavy = tři
// čtení; jeden slovník = jedno čtení, tedy o třetinu méně režie.
//   active  — vkládat, či nevkládat (vlna-off/on)
//   debug   — none = řídí parametr debug (vlna-debug-on/off)
//   suspend — čítač potlačení uvnitř raw bloků: kód se typograficky
//             nezpracovává. Čítač (ne bool), aby se stav po raw bloku
//             obnovil bez ohledu na to, kolik jich je vnořených.
//   switches — počet přepnutí za celý dokument. Slouží jen k tomu, aby
//              apply-vlna poznalo, že se vůbec přepíná (samotné `active` se
//              po vlna-off + vlna-on vrátí na výchozí hodnotu, a tak by se
//              přepnutí nepoznalo).
#let _vlna-key = "vlna"
#let _vlna = state(_vlna-key, (active: true, debug: none, suspend: 0, switches: 0))

// Jeden přepínač: obě jeho povinnosti (změna pole a započtení do `switches`)
// jsou tak na jediném místě. Pole `suspend` se přes něj ZÁMĚRNĚ nemění: raw
// bloky se rozpoznávají samy (viz _needs-state a dotaz na `raw`), a tak
// nesmí zvyšovat `switches`.
#let _switch(patch) = _vlna.update(s => (..s, ..patch, switches: s.switches + 1))

/// Od tohoto místa nezlomitelné mezery nevkládat.
#let vlna-off() = _switch((active: false))
/// Od tohoto místa vkládání obnovit.
#let vlna-on() = _switch((active: true))
/// Od tohoto místa orámovat slepené bloky (přebíjí parametr debug).
#let vlna-debug-on() = _switch((debug: true))
/// Od tohoto místa orámování vypnout.
#let vlna-debug-off() = _switch((debug: false))

// Prvek, jímž se přepínač v obsahu pozná: `state.update` nese klíč stavu.
// Rozpozná se srovnáním s vlastní ukázkou, protože jeho konstruktor není
// pojmenovaný. Do dokumentu se tak nic navíc nevkládá — dotaz uživatele na
// `metadata` zůstane bez cizích položek.
#let _update-func = _switch((:)).func()

// Potřebuje dokument čtení stavu u každého nálezu? Ano jen tehdy, obsahuje-li
// raw blok nebo přepínač. Prochází se obsah PŘED sazbou: rozhodnutí, jež
// by padlo až z hotového dokumentu (query), by znamenalo celou sazbu navíc.
// Průchod je lineární a levný (~0,2 s na 500 stran) a `fields()` pokrývá
// i obaly (styled, tabulky, figury, poznámky).
#let _needs-state(c) = {
  let t = type(c)
  if t == array {
    c.any(_needs-state)
  } else if t != content {
    false
  } else {
    let f = c.func()
    // Text tvoří většinu uzlů a nic v sobě neskrývá — odmítnout ho hned,
    // ještě před sestavením slovníku polí, ušetří většinu práce průchodu.
    if f == text { false } else if f == raw { true } else if f == _update-func {
      c.at("key", default: none) == _vlna-key
    } else {
      c.fields().values().any(_needs-state)
    }
  }
}

// --- Aplikace ----------------------------------------------------------------
// Každá skupina pravidel ÚJČ (prirucka.ujc.cas.cz/?id=880) má svůj přepínač:
//
//   bind-two-letter-words: false → váže jen jednopísmenná slova (dvoupísmenné
//     předložky „na", „do", „se" … smí zůstat na konci řádku — v úzké sazbě
//     dává řádkovému zlomu víc volnosti).
//   short-words: řetězec písmen ("vksuozVKSUOZAI") nebo pole slov
//     (("v", "k", "na", "Na")) → váže se PŘESNĚ tato slova (case-sensitive);
//     má přednost před bind-two-letter-words; `none` krátká slova vypne.
//   short-words jako slovník (cs: "AIiVvOoUuSsZzKk", sk: "…") → sady podle
//     jazyka textu (text.lang); obdoba luavlna \singlechars. Jazyky mimo
//     slovník se NEzpracovávají (krátká slova ani tituly před jménem) —
//     stejně jako v luavlna. Vyžaduje #set text(lang: "cs")!
//   lang: "cs" → ignoruje text.lang a všude použije zadanou sadu; obdoba
//     luavlna \preventsinglelang. Bez slovníku nemá účinek.
//   initials + compound-initials: iniciály „M. J. Hegel", „Ž. Zíbrt",
//     „Ch. Novák" (řetězí se s tituly: „Ing. B. Novák").
//   titles: tituly a zkratky před jménem (Ing., např., viz) i za ním (Ph.D.).
//   numbers + units: členění čísel (2 500, 25,325 23, +420 800 123 987),
//     číslo se značkou (50 %, § 23, * 1921, † 2000) a s jednotkou, zkratkou
//     či měnou (10 kg, 19 °C, 5 str., 1 000 000 Kč, 250 €).
//   ratios: měřítka, poměry a dělení (1 : 50 000, 10 : 2 = 5).
//   dates: den + měsíc v datech — „21. 6. | 2024", „16. ledna | 1972";
//     rok se oddělit smí. months: vlastní seznam názvů měsíců.
//   number-word: číslo + název počítaného jevu (500 lidí, strana 2, 5. pluk,
//     Karel IV.) — výrazně ubírá místa zlomu, implicitně vypnuto.
//   abbreviations: složené zkratky, ustálená spojení a kódy (a. s., s. r. o.,
//     př. n. l., PS PČR, FF UK, ČSN 01 6910).
//   dashes: pomlčka s mezerami se neodděluje od předchozího slova (zůstává
//     na konci řádku); pomlčka bez mezer (1948–1989) se nezalamuje vůbec.
//   links: do adres v link() vloží mezery nulové šířky na místech, kde ÚJČ
//     zalomení doporučuje (za lomítkem, před tečkou a spojovníkem, kolem @).
#let apply-vlna(
  doc,
  // krátká slova
  bind-two-letter-words: true,
  short-words: auto,
  // iniciály
  initials: true,
  compound-initials: ("Ch",),
  // tituly a zkratky před/za jménem
  titles: true,
  // čísla, jednotky, poměry, data
  numbers: true,
  units: default-units,
  ratios: true,
  dates: true,
  months: auto,
  number-word: false,
  // složené zkratky a kódy
  abbreviations: true,
  // pomlčky
  dashes: true,
  // webové a e-mailové adresy
  links: true,
  // jazyk a ladění
  lang: auto,
  debug: false,
) = {
  // -- stavební kameny číselných vzorů --
  let unit-alt = if units.len() == 0 { none } else {
    units
      .sorted(key: u => -u.len())
      .map(u => {
        let e = escape-regex(u)
        // Jednotky končící písmenem/číslicí dostanou hranici slova,
        // aby „16 h" nechytalo začátek „16 hodin".
        if u.clusters().last().match(regex("[\\p{L}\\d]")) != none { e + "\\>" } else { e }
      })
      .join("|")
  }
  // Číslo: celá část, desetinná část a skupiny po 1–3 číslicích
  // („2 500", „25,325 23", „+420 800 123 987", „100.5").
  let num-group = " \\d{1,3}(?:[,.]\\d+)?\\>"
  let num-core = "\\+?\\<\\d+(?:[,.]\\d+)?"
  let num-any = num-core + "(?:" + num-group + ")*"
  let num-grouped = num-core + "(?:" + num-group + ")+"
  let month-alt = {
    let list = if months == auto { _czech-months } else { months }
    "\\<(?:" + list.join("|") + ")\\>"
  }

  // -- krátká slova, iniciály a tituly: společný běh předpon --
  let short-pattern(spec) = if spec == none { none } else if spec == auto {
    if bind-two-letter-words { short-word } else { "\\<\\p{L}\\>" }
  } else {
    let words = if type(spec) == str { spec.clusters() } else { spec }
    // Delší slova první — stejný důvod jako u alternation().
    "\\<(?:" + words.sorted(key: w => -w.len()).map(escape-dot).join("|") + ")\\>"
  }

  // Iniciála = velké písmeno s tečkou, včetně zkráceného rodného jména
  // („Fr. Daneš", „M. Těšitelová" — ÚJČ) a složených písmen („Ch").
  // Vstupuje mezi předpony, takže se řetězí: „M. J. Hegel", „Ing. B. Novák".
  let initial = if initials {
    let alts = compound-initials.sorted(key: t => -t.len()).map(escape-dot)
    "\\<(?:" + (alts + ("\\p{Lu}\\p{Ll}?",)).join("|") + ")\\."
  } else { none }

  // Cílové slovo běhu: přednostně celé datum, složená zkratka nebo číselný
  // výraz (i s poměrem a jednotkou), teprve pak obyčejné slovo. Nález běhu
  // předpon začíná v textu dřív než vzory čísel/dat/zkratek, a protože
  // dřívější začátek vyhrává, bez tohoto by je běh rozbil („od 21. 6.",
  // „o 2 500 Kč", „i s. r. o.", „zápas o 5 : 3").
  let target = {
    let alts = ()
    if dates { alts.push("\\d{1,2}\\.(?: \\d{1,2}\\.| " + month-alt + ")?") }
    if abbreviations {
      alts.push("(?:\\p{Ll}{1,2}\\. )+\\p{Ll}{1,2}\\.")
      alts.push("\\p{Lu}{2,4}(?: (?:\\p{Lu}{2,4}\\>|\\d+(?: \\d+)*\\>))+")
    }
    if numbers {
      let numeric = num-any
      if ratios { numeric += "(?: : " + num-any + ")*(?: = " + num-any + ")?" }
      if unit-alt != none { numeric += "(?: (?:" + unit-alt + "))?" }
      if number-word { numeric += "(?: \\p{L}\\S*)?" }
      alts.push(numeric)
    }
    // number-word: i obyčejné cílové slovo smí pokračovat číslem
    // („viz strana 2").
    alts.push("\\S+" + if number-word { "(?: \\d+\\>\\.?)?" } else { "" })
    let t = "(?:" + alts.join("|") + ")"
    // „s mezerami –" — pomlčka s mezerami drží u předchozího slova.
    if dashes { t += "(?: [–—])?" }
    t
  }

  // Běh předpon + cílové slovo:  „k s bratrem", „V současném", „za tzv. postup",
  // „prof. Ing. arch. Novák", „M. J. Hegel".
  let run-of(short) = {
    let alts = ()
    if short != none { alts.push(short) }
    if initial != none { alts.push(initial) }
    if titles { alts.push("\\<(?:" + alternation(before-list) + ")") }
    if alts.len() == 0 { none } else {
      "(?:(?:" + alts.join("|") + ") )+" + target
    }
  }

  // Slovník = jazykové sady. Regex neumí větvit podle jazyka, proto jedno
  // pravidlo se SJEDNOCENÍM všech sad; teprve glue() v místě nálezu zjistí
  // jazyk (text.lang, příp. vynucený `lang`) a ukotveným vzorem ověří, že
  // celý nález patří do sady tohoto jazyka — jinak ho nechá být.
  let (run-pattern, recheck) = if type(short-words) == dictionary {
    let per-lang = (:)
    let union = ()
    for (code, spec) in short-words {
      let run = run-of(short-pattern(spec))
      if run != none {
        per-lang.insert(code, regex("^(?:" + run + ")$"))
        if run not in union { union.push(run) }
      }
    }
    if union.len() == 0 { (none, none) } else { (regex(union.join("|")), per-lang) }
  } else {
    let run = run-of(short-pattern(short-words))
    (if run == none { none } else { regex(run) }, none)
  }

  // box(it) = nezlomitelný blok se zachovanou zdrojovou pozicí glyfů.
  //
  // Dvě podoby. Rozhoduje `dynamic`, tedy obsah dokumentu (viz _needs-state
  // a instalace pravidel na konci):
  //   dynamic: false → jen obal. Žádný context blok, žádné čtení stavu; na
  //     desetitisících nálezů je čtení stavu nejdražší položka celé sazby.
  //   dynamic: true  → čtení stavu u každého nálezu (přepínače, raw).
  // Jazykové sady (`recheck`) potřebují context vždy: sadu vybírá text.lang
  // v místě nálezu, a ten se bez contextu přečíst nedá.
  let glue(color, recheck: none, dynamic: true) = {
    let wrap(it, dbg) = if dbg {
      box(stroke: .5pt + color, outset: 1.5pt, it)
    } else {
      box(it)
    }
    if recheck == none and not dynamic {
      it => wrap(it, debug)
    } else {
      it => context {
        let (active, dbg) = if dynamic {
          let s = _vlna.get()
          (s.active and s.suspend == 0, s.debug)
        } else {
          (true, none)
        }
        if active and recheck != none {
          let code = if lang == auto { text.lang } else { lang }
          let pattern = recheck.at(code, default: none)
          active = pattern != none and it.text.match(pattern) != none
        }
        if dbg == none { dbg = debug }
        if active { wrap(it, dbg) } else { it }
      }
    }
  }

  // -- pravidla --
  // Nález s dřívějším začátkem vyhrává vždy; při shodném začátku vyhrává
  // pravidlo uvedené v tomto poli DŘÍV (obaluje se blíž obsahu). Proto jsou
  // specifické vzory (poměry, data, složené zkratky) před během předpon.
  //
  // Pravidla ZÁMĚRNĚ zůstávají samostatná, ač jedno sloučené by text
  // procházelo jen jednou: samostatná pravidla se vzájemně vnořují, takže
  // uvnitř bloku „o 1 000 000 Kč" drží další blok „1 000 000". V úzké sazbě,
  // kde se vnější blok na řádek nevejde, se pak zalomí jen v jeho vnějších
  // mezerách a členění čísla či datum zůstanou celé. Sloučené pravidlo umí
  // jen jeden nález, a číslo by se rozpadlo („1 000 | 000").
  // Vzor, barva ladicího rámečku a případná jazyková sada (jen běh předpon).
  let rule(pattern, color, recheck: none) = (
    pattern: pattern,
    color: color,
    recheck: recheck,
  )
  let rules = ()
  if ratios {
    let pattern = num-any + "(?: : " + num-any + ")+(?: = " + num-any + ")?"
    rules.push(rule(regex(pattern), eastern))
  }
  if dates {
    rules.push(rule(regex("\\<\\d{1,2}\\. (?:\\d{1,2}\\.|" + month-alt + ")"), orange))
  }
  if abbreviations {
    // a. s., s. r. o., mn. č., př. n. l.  |  PS PČR, FF UK, ČSN 01 6910.
    // Velká část je omezena na 2–4 písmena, aby se neslepovaly VERZÁLKOVÉ
    // NADPISY slovo po slovu.
    rules.push(rule(
      regex(
        "(?:\\<(?:\\p{Ll}{1,2}\\. )+\\p{Ll}{1,2}\\."
          + "|\\<\\p{Lu}{2,4}(?: (?:\\p{Lu}{2,4}\\>|\\d+(?: \\d+)*\\>))+)",
      ),
      maroon,
    ))
  }
  if run-pattern != none { rules.push(rule(run-pattern, purple, recheck: recheck)) }
  if titles { rules.push(rule(after-pattern, blue)) }
  if numbers {
    // 50 %, § 23, * 1921 | 10 kg, 19 °C, 1 000 000 Kč | 2 500, 800 11 22 33
    let alts = ("[§#\\*†] " + num-any,)
    if unit-alt != none { alts.push(num-any + " (?:" + unit-alt + ")") }
    alts.push(num-grouped)
    rules.push(rule(regex("(?:" + alts.join("|") + ")"), green))
  }
  if number-word {
    // 500 lidí, 5. pluk, II. patro | strana 2, tabulka 3 | Karel IV.
    // První větev řetězí i „Přišlo 500 lidí" (slovo + číslo + slovo).
    rules.push(rule(
      regex(
        "(?:\\<\\p{L}{2,} \\d+\\>\\.?(?: \\p{L}\\S*)?"
          + "|\\<\\d+\\.? \\p{L}\\S*"
          + "|\\<[IVXLCDM]+\\. \\p{L}\\S*"
          + "|\\<\\p{Lu}\\p{L}+ [IVXLCDM]+\\>\\.?)",
      ),
      red,
    ))
  }
  if dashes {
    // „slovo –" drží pomlčku na konci řádku; „1948–1989" se nezalomí vůbec.
    rules.push(rule(regex("\\S+ ?[–—]\\S*"), olive))
  }

  let out = doc
  // Raw bloky se nezpracovávají — kód není české souvislé sazby.
  out = {
    show raw: it => {
      _vlna.update(s => (..s, suspend: s.suspend + 1))
      it
      _vlna.update(s => (..s, suspend: s.suspend - 1))
    }
    out
  }
  if links {
    out = {
      show link: it => context {
        let plain = _link-text(it.body)
        let broken = if (
          _vlna.get().active
            and plain != none
            and not plain.contains(_zwsp)
            and (plain.contains("/") or plain.contains("@") or plain.contains("."))
        ) { _breakable-url(plain) } else { none }
        // broken == plain: beze změny („@SenatCZ") — vrátit `it`, jinak by
        // pravidlo donekonečna přestavovalo tentýž odkaz.
        if broken == none or broken == plain { it } else { link(it.dest, broken) }
      }
      out
    }
  }
  let install(dynamic) = {
    let acc = out
    for r in rules {
      acc = { show r.pattern: glue(r.color, recheck: r.recheck, dynamic: dynamic); acc }
    }
    acc
  }

  // Přepínače a raw bloky jsou to jediné, co nutí čtení stavu u každého
  // nálezu; bez nich se lepí bez contextu (na 500 stranách třetina času).
  // Rozhoduje průchod obsahem PŘED sazbou. Nenajde jen raw vyrobené až za
  // sazby (uvnitř context bloku či cizího show pravidla) — na to je dotaz na
  // hotový dokument. Ten ovšem rozhodnutí mění až po prvním průchodu sazbou,
  // takže se sází dvakrát; proto se používá jen jako záchranná síť tam, kde
  // průchod obsahem nic nenašel.
  if _needs-state(doc) {
    install(true)
  } else {
    context install(_vlna.final().switches > 0 or query(raw).len() > 0)
  }
}
