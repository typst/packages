#let apply-vlna(doc) = [

// Všechna písmena do dvou znaků:
#let short-words = regex("(\<\p{Lower}{1,2}\>)+ ")
// Kód pro vizualizaci
//#show short-words: it => box(stroke: purple, inset: 2pt)[#{it.text.match(short-words).captures; ([],)}.join[~]]
// Fuknční kód
#show short-words: it => text()[#{it.text.match(short-words).captures; ([],)}.join[~]]

// Work in progress
//#let short_word_pattern = regex("\\b([ksvzuoiaKSVZUOIA]|[Tt]o|[Jj]á|[Tt]y|[Mm]y|[Vv]y|[Oo]n|[Nn]a|[Dd]o|[Pp]o|[Pp]ro|[Pp]od|[Nn]ad|[Bb]ez|[Jj]en)\\s+")

// Seznamy
// Slova před 
#let before_list = (
  // === Oslovení ===
  "p.", "pan", "Pan", "pí.", "paní", "Paní", "sl.", // Česká
  "Mr.", "Mrs.", "Ms.", // Anglická

  // === Akademické tituly (před jménem) ===
  // Bakalářské
  "bc.", "Bc.", "BcA.",
  // Magisterské a inženýrské
  "mgr.", "Mgr.", "mga.", "MgA.",
  "ing.", "Ing.", "Ing. arch.",
  // Odborné / Specialista
  //"DiS.", // Pozn.: DiS. se píše za jménem, ale často se chybně uvádí před
  // Doktorské (tzv. "malé" a profesní)
  "dr.", "Dr.",       // Obecný doktorát (historický, již se neuděluje)
  "mudr.", "MUDr.",   // Lékařství
  "mvdr.", "MVDr.",   // Veterinární lékařství
  "MDDr.",           // Zubní lékařství
  "judr.", "JUDr.",   // Právo
  "phdr.", "PhDr.",   // Filosofie
  "rndr.", "RNDr.",   // Přírodní vědy
  "PharmDr.",        // Farmacie
  "thdr.", "ThDr.",   // Teologie (starší doktorát)
  "ThLic.",          // Licenciát teologie

  // === Akademické hodnosti (vědecko-pedagogické) ===
  "doc.", "Doc.", // Docent
  "prof.", "Prof.", // Profesor
  "akad.",  // akademik (nejvyšší vědecká hodnost ČSAV, již se neuděluje)

  // === Čestné tituly ===
  "dr. h. c.", // Doctor honoris causa (obvykle před jménem osoby)

  // === Vojenské hodnosti ===
  // Mužstvo
  "voj.", "svob.",
  // Poddustojníci
  "des.", "čet.", "rtn.",
  // Praporčíci
  "rtm.", "nrtm.", "prap.", "nprap.", "šprap.",
  // Nižší důstojnící
  "por.", "npor.", "kpt.",
  // Vyšší důstojníci
  "mjr.", "pplk.", "pplk. gšt.", "plk", "plk. gšt.",
  // Generálové
  "brig.gen.", "genmjr.", "genpor.", "arm.gen.",
  // === Policejní hodnosti (mimo již zavedené)===
  "stržm.", "nstržm.", "pprap.", "ppor.",

    // === Zkratky ===
  "aj.", "apod.", "atd.", "atp.", "cca", "č.", "čj.", "kupř.", "mj.", "např.", "popř.", "pozn.", "př.", "příp.", "resp.", "s.", "str.", "sv.", "tj.", "tzv.", "tzn.", "viz", "zvl.",
)

// Slova po
#let after_list = (
  // === Akademické tituly (za jménem) ===
  "DiS.",
  "Ph.D.",  // Doktor (vědecký, standardní)
  "PhD.",   // Doktor zahraniční varianta
  "PhD",    // Doktor zahraniční varianta
  "Th.D.",  // Doktor teologie (vědecký)
  "CSc.",   // Kandidát věd (již se neuděluje, dobíhá)
  "DrSc.",  // Doktor věd (udělovala AV ČR, již se neuděluje, dobíhá)
  "DSc."   // Doktor věd (uděluje UK a AV ČR dle zákona č. 111/1998 Sb.)
  // Poznámka: DiS. patří také sem dle zákona, ale v praxi je to smíšené. Zde ho necháváme v `titles_before_list` kvůli běžnějšímu (i když technicky nesprávnému) použití.
  
)

// Funkce pro escapování teček v regulárních výrazech
#let escape_dot(t) = t.replace(".", "\\.")

// Vzory pro jednotlivé skupiny titulů
#let pattern_before = before_list.map(escape_dot).join("|")

// Pravidlo pro zvýraznění titulů PŘED jménem (např. "Ing. Novák")
// Kód pro vizualizaci
//#show regex("\\b(" + pattern_before + ")\\s+\\S+"): m => { box(stroke: green, inset:2pt, m)}
// Funkční kód
#show regex("\\b(" + pattern_before + ")\\s+\\S+"): m => {m}

#doc
]
