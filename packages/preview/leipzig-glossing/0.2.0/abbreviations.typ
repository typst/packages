// See https://www.eva.mpg.de/lingua/resources/glossing-rules.php
#let standard-abbreviations = (
  "1": "first person",
  "2": "second person",
  "3": "third person",
  "A": "agent-like argument of canonical transitive verb",
  "ABL": "ablative",
  "ABS": "absolutive",
  "ACC": "accusative",
  "ADJ": "adjective",
  "ADV": "adverb(ial)",
  "AGR": "agreement",
  "ALL": "allative",
  "ANTIP": "antipassive",
  "APPL": "applicative",
  "ART": "article",
  "AUX": "auxiliary",
  "BEN": "benefactive",
  "CAUS": "causative",
  "CLF": "classifier",
  "COM": "comitative",
  "COMP": "complementizer",
  "COMPL": "completive",
  "COND": "conditional",
  "COP": "copula",
  "CVB": "converb",
  "DAT": "dative",
  "DECL": "declarative",
  "DEF": "definite",
  "DEM": "demonstrative",
  "DET": "determiner",
  "DIST": "distal",
  "DISTR": "distributive",
  "DU": "dual",
  "DUR": "durative",
  "ERG": "ergative",
  "EXCL": "exclusive",
  "F": "feminine",
  "FOC": "focus",
  "FUT": "future",
  "GEN": "genitive",
  "IMP": "imperative",
  "INCL": "inclusive",
  "IND": "indicative",
  "INDF": "indefinite",
  "INF": "infinitive",
  "INS": "instrumental",
  "INTR": "intransitive",
  "IPFV": "imperfective",
  "IRR": "irrealis",
  "LOC": "locative",
  "M": "masculine",
  "N": "neuter",
  "N-": [non- (e.g. #smallcaps[nsg] nonsingular, #smallcaps[npst] nonpast)],
  "NEG": "negation, negative",
  "NMLZ": "nominalizer/nominalization",
  "NOM": "nominative",
  "OBJ": "object",
  "OBL": "oblique",
  "P": "patient-like argument of canonical transitive verb",
  "PASS": "passive",
  "PFV": "perfective",
  "PL": "plural",
  "POSS": "possessive",
  "PRED": "predicative",
  "PRF": "perfect",
  "PRS": "present",
  "PROG": "progressive",
  "PROH": "prohibitive",
  "PROX": "proximal/proximate",
  "PST": "past",
  "PTCP": "participle",
  "PURP": "purposive",
  "Q": "question particle/marker",
  "QUOT": "quotative",
  "RECP": "reciprocal",
  "REFL": "reflexive",
  "REL": "relative",
  "RES": "resultative",
  "S": "single argument of canonical intransitive verb",
  "SBJ": "subject",
  "SBJV": "subjunctive",
  "SG": "singular",
  "TOP": "topic",
  "TR": "transitive",
  "VOC": "vocative",
)

// A dictionary used as a set to mark which abbreviations have been used by a call to
// `emit-abbreviation`. Each key in the dictionary is the string symbol of that abbreviation,
// and the value is always `true`.
#let used-abbreviations = state("leipzig-gloss-used-abbreviations", (:))

// Accepts a callback that accepts the state of the `used-abbreviations`
// dictionary at the end of the document. Also an additional debug parameter
#let with-used-abbreviations(callback) = {
locate(loc => {
    let final_used-abbreviations = used-abbreviations.final(loc)
    callback(final_used-abbreviations)
  })
}

#let render-abbreviation(symbol) = smallcaps(lower(symbol))

// Public function. Given a symbol that is a string, emits
// the lowercase version of that string in smallcaps format, and adds
// its use to the `used-abbreviations` table
#let emit-abbreviation(symbol) = {
  let mark_used(symbol) = {
    used-abbreviations.update(cur => {
      cur.insert(symbol, true)
      cur
    })
  }

  mark_used(symbol)
  render-abbreviation(symbol)
}


#let p1 = emit-abbreviation("1")
#let p2 = emit-abbreviation("2")
#let p3 = emit-abbreviation("3")
#let A = emit-abbreviation("A")
#let abl = emit-abbreviation("ABL")
#let abs = emit-abbreviation("ABS")
#let acc = emit-abbreviation("ACC")
#let adj = emit-abbreviation("ADJ")
#let adv = emit-abbreviation("ADV")
#let agr = emit-abbreviation("AGR")
#let all = emit-abbreviation("ALL")
#let antip = emit-abbreviation("ANTIP")
#let appl = emit-abbreviation("APPL")
#let art = emit-abbreviation("ART")
#let aux = emit-abbreviation("AUX")
#let ben = emit-abbreviation("BEN")
#let caus = emit-abbreviation("CAUS")
#let clf = emit-abbreviation("CLF")
#let com = emit-abbreviation("COM")
#let comp = emit-abbreviation("COMP")
#let compl = emit-abbreviation("COMPL")
#let cond = emit-abbreviation("COND")
#let cop = emit-abbreviation("COP")
#let cvb = emit-abbreviation("CVB")
#let dat = emit-abbreviation("DAT")
#let decl = emit-abbreviation("DECL")
#let def = emit-abbreviation("DEF")
#let dem = emit-abbreviation("DEM")
#let det = emit-abbreviation("DET")
#let dist = emit-abbreviation("DIST")
#let distr = emit-abbreviation("DISTR")
#let du = emit-abbreviation("DU")
#let dur = emit-abbreviation("DUR")
#let erg = emit-abbreviation("ERG")
#let excl = emit-abbreviation("EXCL")
#let F = emit-abbreviation("F")
#let foc = emit-abbreviation("FOC")
#let fut = emit-abbreviation("FUT")
#let gen = emit-abbreviation("GEN")
#let imp = emit-abbreviation("IMP")
#let incl = emit-abbreviation("INCL")
#let ind = emit-abbreviation("IND")
#let indf = emit-abbreviation("INDF")
#let inf = emit-abbreviation("INF")
#let ins = emit-abbreviation("INS")
#let intr = emit-abbreviation("INTR")
#let ipfv = emit-abbreviation("IPFV")
#let irr = emit-abbreviation("IRR")
#let loc = emit-abbreviation("LOC")
#let M = emit-abbreviation("M")
#let N = emit-abbreviation("N")
#let non = emit-abbreviation("N-")
#let neg = emit-abbreviation("NEG")
#let nmlz = emit-abbreviation("NMLZ")
#let nom = emit-abbreviation("NOM")
#let obj = emit-abbreviation("OBJ")
#let obl = emit-abbreviation("OBL")
#let P = emit-abbreviation("P")
#let pass = emit-abbreviation("PASS")
#let pfv = emit-abbreviation("PFV")
#let pl = emit-abbreviation("PL")
#let poss = emit-abbreviation("POSS")
#let pred = emit-abbreviation("PRED")
#let prf = emit-abbreviation("PRF")
#let prs = emit-abbreviation("PRS")
#let prog = emit-abbreviation("PROG")
#let proh = emit-abbreviation("PROH")
#let prox = emit-abbreviation("PROX")
#let pst = emit-abbreviation("PST")
#let ptcp = emit-abbreviation("PTCP")
#let purp = emit-abbreviation("PURP")
#let Q = emit-abbreviation("Q")
#let quot = emit-abbreviation("QUOT")
#let recp = emit-abbreviation("RECP")
#let refl = emit-abbreviation("REFL")
#let rel = emit-abbreviation("REL")
#let res = emit-abbreviation("RES")
#let S = emit-abbreviation("S")
#let sbj = emit-abbreviation("SBJ")
#let sbjv = emit-abbreviation("SBJV")
#let sg = emit-abbreviation("SG")
#let top = emit-abbreviation("TOP")
#let tr = emit-abbreviation("TR")
#let voc = emit-abbreviation("VOC")

