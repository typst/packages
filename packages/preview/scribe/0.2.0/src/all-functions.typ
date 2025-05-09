#import "utils.typ": *


/* OPERATIONS */
#let w(function-name, content) = {
  safe-wrap("operation", did-load-operations, function-name, content)
}

#let prod = w("prod", $product$)
#let ox = w("ox", $times.circle$)
#let xx = w("xx", $times$)
#let vv = w("vv", $or$)
#let vvv = w("vvv", $or.big$)
#let nn = w("nn", $inter$)
#let nnn = w("nnn", $inter.big$)
#let uu = w("uu", $union$)
#let uuu = w("uuu", $union.big$)

/* CALIGRAPHICS */
#let w(function-name, letter) = {
  safe-wrap("caligraphics", did-load-caligraphics, function-name, math.cal(letter))
}
#let Aa = w("Aa","A")
#let Bb = w("Bb","B")
#let Cc = w("Cc","C")
#let Dd = w("Dd","D")
#let Ee = w("Ee","E")
#let Ff = w("Ff","F")
#let Gg = w("Gg","G")
#let Hh = w("Hh","H")
#let Ii = w("Ii","I")
#let Jj = w("Jj","J")
#let Kk = w("Kk","K")
#let Ll = w("Ll","L")
#let Mm = w("Mm","M")
#let Nn = w("Nn","N")
#let Oo = w("Oo","O")
#let Pp = w("Pp","P")
#let Qq = w("Qq","Q")
#let Rr = w("Rr","R")
#let Ss = w("Ss","S")
#let Tt = w("Tt","T")
#let Uu = w("Uu","U")
#let Vv = w("Vv","V")
#let Ww = w("Ww","W")
#let Xx = w("Xx","X")
#let Yy = w("Yy","Y")
#let Zz = w("Zz","Z")
  
#let aA = w("aA","a")
#let bB = w("bB","b")
#let cC = w("cC","c")
#let dD = w("dD","d")
#let eE = w("eE","e")
#let fF = w("fF","f")
#let gG = w("gG","g")
#let hH = w("hH","h")
#let iI = w("iI","i")
#let jJ = w("jJ","j")
#let kK = w("kK","k")
#let lL = w("lL","l")
#let mM = w("mM","m")
#let nN = w("nN","n")
#let oO = w("oO","o")
#let pP = w("pP","p")
#let qQ = w("qQ","q")
#let rR = w("rR","r")
#let sS = w("sS","s")
#let tT = w("tT","t")
#let uU = w("uU","u")
#let vV = w("vV","v")
#let wW = w("wW","w")
#let xX = w("xX","x")
#let yY = w("yY","y")
#let zZ = w("zZ","z")

/* MISCELLANEOUS*/
#let w(function-name, content) = {
  safe-wrap("miscellaneous", did-load-miscellaneous, function-name, content)
}
#let int = w("int", $integral$)
#let oint = w("oint", $integral.cont$)
#let del = w("del", $partial$)
#let grad = w("grad", $gradient$)
#let aleph = w("aleph", $alef$)
#let vdots = w("vdots", $dots.v$)
#let ddots = w("ddots", $dots.down$)
#let ldots = w("ldots", $dots.h$)

/* RELATIONS */
#let w(function-name, content) = {
  safe-wrap("relations", did-load-relations, function-name, content)
}
#let ll = w("ll", $<$)
#let gg = w("gg", $>$)
#let sub = w("sub", $subset$)
#let sup = w("sup", $supset$)
#let sube = w("sube", $subset.eq$)
#let supe = w("sub", $supset.eq$)


/* LOGICALS */
#let w(function-name, content) = {
  safe-wrap("logicals", did-load-logicals, function-name, content)
}
#let AA = w("AA", $forall$)
#let EE = w("AA", $exists$)
#let TT = w("TT", $tack.b$)
