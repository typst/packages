// See https://www.eva.mpg.de/lingua/resources/glossing-rules.php


// a dictionary of the form "abbr: description"
#let used-abbreviations = state("used-abbreviations", (:))

/// Returns the dictionary of abbreviations and their descriptions
/// used in the document.
/// Requires context.
///
/// -> dictionary
#let get-abbreviations() = {
  used-abbreviations.final()
}

/// Prettily prints the list of abbreviations used in the document.
/// Accesses the state, turns it into a list of pairs, sorts it on abbreviation names by `sorted-by`,
/// wraps every pair in `wrapper`, then joins with `separator`.
///
/// - sorted-by (function): A callback function to sort abbreviations by.
///   Takes in a left and a right abbreviation and returns a boolean.
///   To sort by order of use, pass `(_, _) => true`.
///
///   *Default*: Alphabetical. `(l, r) => l <= r`
///
/// - wrapper (function): A callback function to wrap every abbreviation.
///   Takes an abbreviation and a description and returns content.
///
///   *Default*: A terms item with abbr in small caps. `(abbr, desc) => terms.item(smallcaps(abbr), desc)`
///
/// - separator (any | none): A separator to use when abbreviations are joined.
///   Useful if you need an inline abbreviation list.
///
///   *Default*: none
///
/// -> content
#let print-abbreviations(
  sorted-by: (l, r) => l <= r,
  wrapper: (abbr, desc) => terms.item(smallcaps(abbr), desc),
  separator: none,
) = {
  context {
    let used = used-abbreviations.final()
    used.pairs()
    .sorted(key: k => k.at(0), by: sorted-by)
    .map(((abbr, desc)) => wrapper(abbr, desc))
    .join(separator)
  }
}

/// Prints the symbol in smallcaps
/// and adds it to the list of used abbreviations.
///
/// - symbol (str): The abbreviation
///
///   *Required*
///
/// - description (str): The abbreviation description for the list of used abbreviations.
///
///   *Required*
///
/// -> content
#let abbreviation(
  symbol,
  description
) = {

  used-abbreviations.update(it => {
    it.insert(symbol, description)
    it
  })

  smallcaps(symbol)
}

// The standard Leipzig glossing abbreviations
// (https://www.eva.mpg.de/lingua/pdf/Glossing-Rules.pdf)
// and several others:
// an, inan, dir, inv, fam, obv, conj, cont, inch, int, mir, opt, pot, pro
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
#let an    = abbreviation("an",    "animate")
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
#let conj  = abbreviation("conj",  "conjunctive")
#let cont  = abbreviation("cont",  "continuative")
#let cop   = abbreviation("cop",   "copula")
#let cvb   = abbreviation("cvb",   "converb")
#let dat   = abbreviation("dat",   "dative")
#let decl  = abbreviation("decl",  "declarative")
#let def   = abbreviation("def",   "definite")
#let dem   = abbreviation("dem",   "demonstrative")
#let det   = abbreviation("det",   "determiner")
#let dir   = abbreviation("dir",   "direct")
#let dist  = abbreviation("dist",  "distal")
#let distr = abbreviation("distr", "distributive")
#let du    = abbreviation("du",    "dual")
#let dur   = abbreviation("dur",   "durative")
#let erg   = abbreviation("erg",   "ergative")
#let excl  = abbreviation("excl",  "exclusive")
#let f     = abbreviation("f",     "feminine")
#let fam   = abbreviation("fam",   "familiar")
#let foc   = abbreviation("foc",   "focus")
#let fut   = abbreviation("fut",   "future")
#let gen   = abbreviation("gen",   "genitive")
#let imp   = abbreviation("imp",   "imperative")
#let inan  = abbreviation("inan",  "inanimate")
#let inch  = abbreviation("inch",  "inchoative")
#let incl  = abbreviation("incl",  "inclusive")
#let ind   = abbreviation("ind",   "indicative")
#let indf  = abbreviation("indf",  "indefinite")
#let inf   = abbreviation("inf",   "infinitive")
#let ins   = abbreviation("ins",   "instrumental")
// The `int` binding conflicts with the built-in `int` type.
#let int_  = abbreviation("int",   "interrogative")
#let intr  = abbreviation("intr",  "intransitive")
#let inv   = abbreviation("inv",   "inverse")
#let ipfv  = abbreviation("ipfv",  "imperfective")
#let irr   = abbreviation("irr",   "irrealis")
#let loc   = abbreviation("loc",   "locative")
#let m     = abbreviation("m",     "masculine")
#let mir   = abbreviation("mir",   "mirative")
#let n     = abbreviation("n",     "neuter")
#let non   = abbreviation("n",     [non- (e.g. #smallcaps[nsg] nonsingular, #smallcaps[npst] nonpast)])
#let neg   = abbreviation("neg",   "negation, negative")
#let nmlz  = abbreviation("nmlz",  "nominalizer/nominalization")
#let nom   = abbreviation("nom",   "nominative")
#let obj   = abbreviation("obj",   "object")
#let obl   = abbreviation("obl",   "oblique")
#let obv   = abbreviation("obv",   "obviative")
#let opt   = abbreviation("opt",   "optative")
#let p     = abbreviation("p",     "patient-like argument of canonical transitive verb")
#let pass  = abbreviation("pass",  "passive")
#let pfv   = abbreviation("pfv",   "perfective")
#let pl    = abbreviation("pl",    "plural")
#let poss  = abbreviation("poss",  "possessive")
#let pot   = abbreviation("pot",   "potential")
#let pred  = abbreviation("pred",  "predicative")
#let prf   = abbreviation("prf",   "perfect")
#let pro   = abbreviation("pro",   "pronoun")
#let prog  = abbreviation("prog",  "progressive")
#let proh  = abbreviation("proh",  "prohibitive")
#let prox  = abbreviation("prox",  "proximal/proximate")
#let prs   = abbreviation("prs",   "present")
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
// The `top` binding conflicts with the built-in `top` alignment.
#let top_  = abbreviation("top",   "topic")
#let tr    = abbreviation("tr",    "transitive")
#let voc   = abbreviation("voc",   "vocative")
