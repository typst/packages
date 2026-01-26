// See https://www.eva.mpg.de/lingua/resources/glossing-rules.php


// a dictionary of the form "abbr: description"
#let used-abbreviations = state("used-abbreviations", (:))

/// Prints the list of abbreviations used in the document
/// as a term list. -> content
#let print-abbreviations() = {
  context {
    let used = used-abbreviations.final()
    for (abbr, desc) in used {
      [/ #smallcaps(abbr): #desc]
    }
  }
}

/// Prints the symbol in smallcaps
/// and adds it to the list of used abbreviations. -> content
#let abbreviation(
  /// The abbreviation. -> str
  symbol,
  /// The abbreviation description
  /// for the list of used abbreviations. -> str
  description) = {

  used-abbreviations.update(it => {
    it.insert(symbol, description)
    it
  })

  smallcaps(symbol)
}


#let p1    = abbreviation("1",     "first person")
#let p2    = abbreviation("2",     "second person")
#let p3    = abbreviation("3",     "third person")
#let a     = abbreviation("a",     "agent-like argument of canonical transitive verb")
#let abl   = abbreviation("abl",   "ablative")
#let abs   = abbreviation("abs",   "absolutive")
#let acc   = abbreviation("acc",   "accusative")
#let adj   = abbreviation("adj",   "adjective")
#let adv   = abbreviation("adv",   "adverb(ial)")
#let agr   = abbreviation("agr",   "agreement")
#let all   = abbreviation("all",   "allative")
#let antip = abbreviation("antip", "antipassive")
#let appl  = abbreviation("appl",  "applicative")
#let art   = abbreviation("art",   "article")
#let aux   = abbreviation("aux",   "auxiliary")
#let ben   = abbreviation("ben",   "benefactive")
#let caus  = abbreviation("caus",  "causative")
#let clf   = abbreviation("clf",   "classifier")
#let com   = abbreviation("com",   "comitative")
#let comp  = abbreviation("comp",  "complementizer")
#let compl = abbreviation("compl", "completive")
#let cond  = abbreviation("cond",  "conditional")
#let cop   = abbreviation("cop",   "copula")
#let cvb   = abbreviation("cvb",   "converb")
#let dat   = abbreviation("dat",   "dative")
#let decl  = abbreviation("decl",  "declarative")
#let def   = abbreviation("def",   "definite")
#let dem   = abbreviation("dem",   "demonstrative")
#let det   = abbreviation("det",   "determiner")
#let dist  = abbreviation("dist",  "distal")
#let distr = abbreviation("distr", "distributive")
#let du    = abbreviation("du",    "dual")
#let dur   = abbreviation("dur",   "durative")
#let erg   = abbreviation("erg",   "ergative")
#let excl  = abbreviation("excl",  "exclusive")
#let f     = abbreviation("f",     "feminine")
#let foc   = abbreviation("foc",   "focus")
#let fut   = abbreviation("fut",   "future")
#let gen   = abbreviation("gen",   "genitive")
#let imp   = abbreviation("imp",   "imperative")
#let incl  = abbreviation("incl",  "inclusive")
#let ind   = abbreviation("ind",   "indicative")
#let indf  = abbreviation("indf",  "indefinite")
#let inf   = abbreviation("inf",   "infinitive")
#let ins   = abbreviation("ins",   "instrumental")
#let intr  = abbreviation("intr",  "intransitive")
#let ipfv  = abbreviation("ipfv",  "imperfective")
#let irr   = abbreviation("irr",   "irrealis")
#let loc   = abbreviation("loc",   "locative")
#let m     = abbreviation("m",     "masculine")
#let n     = abbreviation("n",     "neuter")
#let non   = abbreviation("n",     [non- (e.g. #smallcaps[nsg] nonsingular, #smallcaps[npst] nonpast)])
#let neg   = abbreviation("neg",   "negation, negative")
#let nmlz  = abbreviation("nmlz",  "nominalizer/nominalization")
#let nom   = abbreviation("nom",   "nominative")
#let obj   = abbreviation("obj",   "object")
#let obl   = abbreviation("obl",   "oblique")
#let p     = abbreviation("p",     "patient-like argument of canonical transitive verb")
#let pass  = abbreviation("pass",  "passive")
#let pfv   = abbreviation("pfv",   "perfective")
#let pl    = abbreviation("pl",    "plural")
#let poss  = abbreviation("poss",  "possessive")
#let pred  = abbreviation("pred",  "predicative")
#let prf   = abbreviation("prf",   "perfect")
#let prs   = abbreviation("prs",   "present")
#let prog  = abbreviation("prog",  "progressive")
#let proh  = abbreviation("proh",  "prohibitive")
#let prox  = abbreviation("prox",  "proximal/proximate")
#let pst   = abbreviation("pst",   "past")
#let ptcp  = abbreviation("ptcp",  "participle")
#let purp  = abbreviation("purp",  "purposive")
#let q     = abbreviation("q",     "question particle/marker")
#let quot  = abbreviation("quot",  "quotative")
#let recp  = abbreviation("recp",  "reciprocal")
#let refl  = abbreviation("refl",  "reflexive")
#let rel   = abbreviation("rel",   "relative")
#let res   = abbreviation("res",   "resultative")
#let s     = abbreviation("s",     "single argument of canonical intransitive verb")
#let sbj   = abbreviation("sbj",   "subject")
#let sbjv  = abbreviation("sbjv",  "subjunctive")
#let sg    = abbreviation("sg",    "singular")
#let top   = abbreviation("top",   "topic")
#let tr    = abbreviation("tr",    "transitive")
#let voc   = abbreviation("VOC", "vocative")
