// High-symmetry k-points and recommended k-paths per Setyawan & Curtarolo,
// Comp. Mater. Sci. 49, 299 (2010) ("SC-2010"), with the parameter-dependent
// extended-Bravais variant selection.
//
// Ground truth & provenance
// --------------------------
// The coordinate FORMULAS and the variant conditions are SC-2010's. We adopt the
// label/path *standardization* of HPKOT (Hinuma et al., Comp. Mater. Sci. 128,
// 140 (2017)), which the `seekpath` library implements verbatim and which the
// fixtures (tools/gen_kpath_fixtures.py -> tests/fixtures/kpath.json) pin to
// machine precision. HPKOT reproduces SC-2010's primitive-cell choice for every
// Bravais type, so these fractional coordinates (in the primitive reciprocal
// basis) equal SC-2010's. Where HPKOT and the SC-2010 *paper* differ -- interior
// free-point LABELS of centered lattices (HPKOT SIGMA_0/U_0/... vs SC-2010
// X/X1/A/A1) and a few recommended PATH segments -- the fixtures carry a per-case
// `notes` field documenting it.
//
// Coordinate basis
// ----------------
// Every point is FRACTIONAL in the primitive reciprocal basis (b1,b2,b3). Values
// are NOT wrapped into [0,1) (SC-2010 lists e.g. ORCF's T=(1,1/2,1/2)); Gamma is
// always (0,0,0).
//
// Standardized parameters (IMPORTANT)
// -----------------------------------
// The formulas are evaluated on the *standardized conventional cell* parameters:
// orthorhombic a<=b<=c, monoclinic unique axis b with beta>=90, hexagonal setting
// for hR (a=b, gamma=120). Callers must pass params in this setting (the fixtures
// feed exactly seekpath's standardized a,b,c,angles). Consequences: variants that
// only arise under a different axis assignment (oF2, oI2, oI3, oC2, oA1, oA2) are
// implemented below for completeness but are UNREACHABLE from a standardized cell
// and are therefore NOT covered by fixtures (a<=b<=c forces the largest edge to c
// and 1/c^2 to be the smallest). The non-centrosymmetric point-group variants
// (cP1, cF1, hP1 -- which add one extra path segment) are not selected here since
// the API takes only a Bravais symbol; we return the centrosymmetric cP2/cF2/hP2.
//
// aP (triclinic): variant selection assumes the cell is already reduced (its
// reciprocal cell is all-acute or all-obtuse). We do NOT run Niggli reduction; a
// non-reduced triclinic cell raises an error. The fixtures feed reduced cells.

#let _deg(x) = if type(x) == angle { x / 1deg } else { float(x) }

#let _bases = (
  "cP", "cF", "cI", "tP", "tI", "oP", "oF", "oI", "oC",
  "hP", "hR", "mP", "mC", "aP",
)

// Fill params to (a,b,c, alpha,beta,gamma) in degrees; b,c default to a, angles 90.
#let _fill(p) = {
  let a = _deg(p.at("a"))
  (
    a: a,
    b: if "b" in p { _deg(p.at("b")) } else { a },
    c: if "c" in p { _deg(p.at("c")) } else { a },
    alpha: if "alpha" in p { _deg(p.at("alpha")) } else { 90.0 },
    beta: if "beta" in p { _deg(p.at("beta")) } else { 90.0 },
    gamma: if "gamma" in p { _deg(p.at("gamma")) } else { 90.0 },
  )
}

#let _approx(x, y, tol) = calc.abs(x - y) < tol

// Validate that params are consistent with the Bravais symbol. Angles in deg.
#let _validate(bravais, q) = {
  let (a, b, c, al, be, ga) = (q.a, q.b, q.c, q.alpha, q.beta, q.gamma)
  let atol = 1e-4          // angle tolerance (degrees)
  let ltol = 1e-6 * calc.max(a, 1.0)
  let ang90 = (n, v) => if not _approx(v, 90.0, atol) {
    panic("materia: " + bravais + " angle " + n + " must be 90 deg (got " + repr(v) + ")")
  }
  let eqlen = (n, v, ref) => if not _approx(v, ref, ltol) {
    panic("materia: " + bravais + " length " + n + " must equal " + repr(ref) + " (got " + repr(v) + ")")
  }
  if bravais in ("cP", "cF", "cI") {
    ang90("alpha", al); ang90("beta", be); ang90("gamma", ga)
    eqlen("b", b, a); eqlen("c", c, a)
  } else if bravais in ("tP", "tI") {
    ang90("alpha", al); ang90("beta", be); ang90("gamma", ga)
    eqlen("b", b, a)
  } else if bravais in ("oP", "oF", "oI", "oC") {
    ang90("alpha", al); ang90("beta", be); ang90("gamma", ga)
  } else if bravais in ("hP", "hR") {
    ang90("alpha", al); ang90("beta", be)
    if not _approx(ga, 120.0, atol) {
      panic("materia: " + bravais + " gamma must be 120 deg (hexagonal setting; got " + repr(ga) + ")")
    }
    eqlen("b", b, a)
  } else if bravais in ("mP", "mC") {
    ang90("alpha", al); ang90("gamma", ga)
    if _approx(be, 90.0, atol) {
      panic("materia: " + bravais + " beta must differ from 90 deg for a monoclinic cell")
    }
  } else if bravais == "aP" {
    // no constraint; reduced-cell requirement checked during selection
  } else {
    panic("materia: unknown Bravais symbol '" + bravais + "' (expected one of " + repr(_bases) + ")")
  }
}

// cos of the three reciprocal-cell angles from a real cell (a,b,c cancel out).
#let _recip-cos(al, be, ga) = {
  let (ca, cb, cg) = (calc.cos(al * 1deg), calc.cos(be * 1deg), calc.cos(ga * 1deg))
  let (sa, sb, sg) = (calc.sin(al * 1deg), calc.sin(be * 1deg), calc.sin(ga * 1deg))
  (
    (cb * cg - ca) / (sb * sg),
    (cg * ca - cb) / (sg * sa),
    (ca * cb - cg) / (sa * sb),
  )
}

// Resolve the extended-Bravais variant symbol from standardized params.
#let _variant(bravais, q) = {
  let (a, b, c, al, be, ga) = (q.a, q.b, q.c, q.alpha, q.beta, q.gamma)
  if bravais == "cP" { "cP2" }
  else if bravais == "cF" { "cF2" }
  else if bravais == "cI" { "cI1" }
  else if bravais == "tP" { "tP1" }
  else if bravais == "tI" { if c <= a { "tI1" } else { "tI2" } }
  else if bravais == "oP" { "oP1" }
  else if bravais == "oF" {
    if 1.0 / (a * a) > 1.0 / (b * b) + 1.0 / (c * c) { "oF1" }
    else if 1.0 / (c * c) > 1.0 / (a * a) + 1.0 / (b * b) { "oF2" }
    else { "oF3" }
  } else if bravais == "oI" {
    // variant = index of the LONGEST edge: c->1, a->2, b->3
    if c >= a and c >= b { "oI1" } else if a >= b { "oI2" } else { "oI3" }
  } else if bravais == "oC" {
    if a <= b { "oC1" } else { "oC2" }
  } else if bravais == "hP" { "hP2" }
  else if bravais == "hR" {
    if calc.sqrt(3.0) * a <= calc.sqrt(2.0) * c { "hR1" } else { "hR2" }
  } else if bravais == "mP" { "mP1" }
  else if bravais == "mC" {
    let cb = calc.cos(be * 1deg)
    let sb = calc.sin(be * 1deg)
    if b < a * sb { "mC1" }
    else if (-a * cb / c + a * a * sb * sb / (b * b)) <= 1.0 { "mC2" }
    else { "mC3" }
  } else if bravais == "aP" {
    let (cka, ckb, ckg) = _recip-cos(al, be, ga)
    let tol = 1e-9
    if cka <= tol and ckb <= tol and ckg <= tol { "aP2" }
    else if cka >= -tol and ckb >= -tol and ckg >= -tol { "aP3" }
    else {
      panic("materia: aP cell is not reduced (reciprocal cell neither all-acute nor "
        + "all-obtuse); pass a reduced triclinic cell")
    }
  } else { panic("materia: unreachable triclinic k-path branch") }
}

// ---------------------------------------------------------------------------
// Per-variant point tables + recommended paths, ported from SC-2010 / HPKOT.
// kparam locals are prefixed `k` to avoid clashing with point names (e.g. mC2
// has both a k-parameter M and a k-point "M"). Point key "Γ" == HPKOT GAMMA.
// ---------------------------------------------------------------------------
#let _table(variant, q) = {
  let (a, b, c) = (q.a, q.b, q.c)
  let cb = calc.cos(q.beta * 1deg)
  let sb = calc.sin(q.beta * 1deg)

  if variant in ("cP1", "cP2") {
    let pts = (
      "Γ": (0, 0, 0), "R": (0.5, 0.5, 0.5), "M": (0.5, 0.5, 0),
      "X": (0, 0.5, 0), "X_1": (0.5, 0, 0),
    )
    let path = (("Γ", "X"), ("X", "M"), ("M", "Γ"), ("Γ", "R"), ("R", "X"), ("R", "M"))
    if variant == "cP1" { path = path + (("M", "X_1"),) }
    (points: pts, path: path)
  } else if variant in ("cF1", "cF2") {
    let pts = (
      "Γ": (0, 0, 0), "X": (0.5, 0, 0.5), "L": (0.5, 0.5, 0.5),
      "W": (0.5, 0.25, 0.75), "W_2": (0.75, 0.25, 0.5),
      "K": (3 / 8, 3 / 8, 0.75), "U": (5 / 8, 0.25, 5 / 8),
    )
    let path = (("Γ", "X"), ("X", "U"), ("K", "Γ"), ("Γ", "L"), ("L", "W"), ("W", "X"))
    if variant == "cF1" { path = path + (("X", "W_2"),) }
    (points: pts, path: path)
  } else if variant == "cI1" {
    (
      points: ("Γ": (0, 0, 0), "H": (0.5, -0.5, 0.5), "P": (0.25, 0.25, 0.25), "N": (0, 0, 0.5)),
      path: (("Γ", "H"), ("H", "N"), ("N", "Γ"), ("Γ", "P"), ("P", "H"), ("P", "N")),
    )
  } else if variant == "tP1" {
    (
      points: (
        "Γ": (0, 0, 0), "Z": (0, 0, 0.5), "M": (0.5, 0.5, 0), "A": (0.5, 0.5, 0.5),
        "R": (0, 0.5, 0.5), "X": (0, 0.5, 0),
      ),
      path: (("Γ", "X"), ("X", "M"), ("M", "Γ"), ("Γ", "Z"), ("Z", "R"), ("R", "A"),
             ("A", "Z"), ("X", "R"), ("M", "A")),
    )
  } else if variant == "tI1" {
    let kH = (1 + c * c / (a * a)) / 4
    (
      points: (
        "Γ": (0, 0, 0), "M": (-0.5, 0.5, 0.5), "X": (0, 0, 0.5), "P": (0.25, 0.25, 0.25),
        "Z": (kH, kH, -kH), "Z_0": (-kH, 1 - kH, kH), "N": (0, 0.5, 0),
      ),
      path: (("Γ", "X"), ("X", "M"), ("M", "Γ"), ("Γ", "Z"), ("Z_0", "M"),
             ("X", "P"), ("P", "N"), ("N", "Γ")),
    )
  } else if variant == "tI2" {
    let kH = (1 + a * a / (c * c)) / 4
    let kZ = a * a / (2 * c * c)
    (
      points: (
        "Γ": (0, 0, 0), "M": (0.5, 0.5, -0.5), "X": (0, 0, 0.5), "P": (0.25, 0.25, 0.25),
        "N": (0, 0.5, 0), "S_0": (-kH, kH, kH), "S": (kH, 1 - kH, -kH),
        "R": (-kZ, kZ, 0.5), "G": (0.5, 0.5, -kZ),
      ),
      path: (("Γ", "X"), ("X", "P"), ("P", "N"), ("N", "Γ"), ("Γ", "M"),
             ("M", "S"), ("S_0", "Γ"), ("X", "R"), ("G", "M")),
    )
  } else if variant == "oP1" {
    (
      points: (
        "Γ": (0, 0, 0), "X": (0.5, 0, 0), "Z": (0, 0, 0.5), "U": (0.5, 0, 0.5),
        "Y": (0, 0.5, 0), "S": (0.5, 0.5, 0), "T": (0, 0.5, 0.5), "R": (0.5, 0.5, 0.5),
      ),
      path: (("Γ", "X"), ("X", "S"), ("S", "Y"), ("Y", "Γ"), ("Γ", "Z"), ("Z", "U"),
             ("U", "R"), ("R", "T"), ("T", "Z"), ("X", "U"), ("Y", "T"), ("S", "R")),
    )
  } else if variant == "oF1" {
    let kJ = (1 + a * a / (b * b) - a * a / (c * c)) / 4
    let kH = (1 + a * a / (b * b) + a * a / (c * c)) / 4
    (
      points: (
        "Γ": (0, 0, 0), "T": (1, 0.5, 0.5), "Z": (0.5, 0.5, 0), "Y": (0.5, 0, 0.5),
        "SIGMA_0": (0, kH, kH), "U_0": (1, 1 - kH, 1 - kH),
        "A_0": (0.5, 0.5 + kJ, kJ), "C_0": (0.5, 0.5 - kJ, 1 - kJ), "L": (0.5, 0.5, 0.5),
      ),
      path: (("Γ", "Y"), ("Y", "T"), ("T", "Z"), ("Z", "Γ"), ("Γ", "SIGMA_0"),
             ("U_0", "T"), ("Y", "C_0"), ("A_0", "Z"), ("Γ", "L")),
    )
  } else if variant == "oF2" {
    let kJ = (1 + c * c / (a * a) - c * c / (b * b)) / 4
    let kK = (1 + c * c / (a * a) + c * c / (b * b)) / 4
    (
      points: (
        "Γ": (0, 0, 0), "T": (0, 0.5, 0.5), "Z": (0.5, 0.5, 1), "Y": (0.5, 0, 0.5),
        "LAMBDA_0": (kK, kK, 0), "Q_0": (1 - kK, 1 - kK, 1),
        "G_0": (0.5 - kJ, 1 - kJ, 0.5), "H_0": (0.5 + kJ, kJ, 0.5), "L": (0.5, 0.5, 0.5),
      ),
      path: (("Γ", "T"), ("T", "Z"), ("Z", "Y"), ("Y", "Γ"), ("Γ", "LAMBDA_0"),
             ("Q_0", "Z"), ("T", "G_0"), ("H_0", "Y"), ("Γ", "L")),
    )
  } else if variant == "oF3" {
    let kH = (1 + a * a / (b * b) - a * a / (c * c)) / 4
    let kK = (1 + b * b / (a * a) - b * b / (c * c)) / 4
    let kP = (1 + c * c / (b * b) - c * c / (a * a)) / 4
    (
      points: (
        "Γ": (0, 0, 0), "T": (0, 0.5, 0.5), "Z": (0.5, 0.5, 0), "Y": (0.5, 0, 0.5),
        "A_0": (0.5, 0.5 + kH, kH), "C_0": (0.5, 0.5 - kH, 1 - kH),
        "B_0": (0.5 + kK, 0.5, kK), "D_0": (0.5 - kK, 0.5, 1 - kK),
        "G_0": (kP, 0.5 + kP, 0.5), "H_0": (1 - kP, 0.5 - kP, 0.5), "L": (0.5, 0.5, 0.5),
      ),
      path: (("Γ", "Y"), ("Y", "C_0"), ("A_0", "Z"), ("Z", "B_0"), ("D_0", "T"),
             ("T", "G_0"), ("H_0", "Y"), ("T", "Γ"), ("Γ", "Z"), ("Γ", "L")),
    )
  } else if variant == "oI1" {
    let kZ = (1 + a * a / (c * c)) / 4
    let kH = (1 + b * b / (c * c)) / 4
    let kD = (b * b - a * a) / (4 * c * c)
    let kN = (a * a + b * b) / (4 * c * c)
    (
      points: (
        "Γ": (0, 0, 0), "X": (0.5, 0.5, -0.5), "S": (0.5, 0, 0), "R": (0, 0.5, 0),
        "T": (0, 0, 0.5), "W": (0.25, 0.25, 0.25),
        "SIGMA_0": (-kZ, kZ, kZ), "F_2": (kZ, 1 - kZ, -kZ),
        "Y_0": (kH, -kH, kH), "U_0": (1 - kH, kH, -kH),
        "L_0": (-kN, kN, 0.5 - kD), "M_0": (kN, -kN, 0.5 + kD), "J_0": (0.5 - kD, 0.5 + kD, -kN),
      ),
      path: (("Γ", "X"), ("X", "F_2"), ("SIGMA_0", "Γ"), ("Γ", "Y_0"), ("U_0", "X"),
             ("Γ", "R"), ("R", "W"), ("W", "S"), ("S", "Γ"), ("Γ", "T"), ("T", "W")),
    )
  } else if variant == "oI2" {
    let kZ = (1 + b * b / (a * a)) / 4
    let kH = (1 + c * c / (a * a)) / 4
    let kD = (c * c - b * b) / (4 * a * a)
    let kN = (b * b + c * c) / (4 * a * a)
    (
      points: (
        "Γ": (0, 0, 0), "X": (-0.5, 0.5, 0.5), "S": (0.5, 0, 0), "R": (0, 0.5, 0),
        "T": (0, 0, 0.5), "W": (0.25, 0.25, 0.25),
        "Y_0": (kZ, -kZ, kZ), "U_2": (-kZ, kZ, 1 - kZ),
        "LAMBDA_0": (kH, kH, -kH), "G_2": (-kH, 1 - kH, kH),
        "K": (0.5 - kD, -kN, kN), "K_2": (0.5 + kD, kN, -kN), "K_4": (-kN, 0.5 - kD, 0.5 + kD),
      ),
      path: (("Γ", "X"), ("X", "U_2"), ("Y_0", "Γ"), ("Γ", "LAMBDA_0"), ("G_2", "X"),
             ("Γ", "R"), ("R", "W"), ("W", "S"), ("S", "Γ"), ("Γ", "T"), ("T", "W")),
    )
  } else if variant == "oI3" {
    let kZ = (1 + c * c / (b * b)) / 4
    let kY = (1 + a * a / (b * b)) / 4
    let kD = (a * a - c * c) / (4 * b * b)
    let kM = (c * c + a * a) / (4 * b * b)
    (
      points: (
        "Γ": (0, 0, 0), "X": (0.5, -0.5, 0.5), "S": (0.5, 0, 0), "R": (0, 0.5, 0),
        "T": (0, 0, 0.5), "W": (0.25, 0.25, 0.25),
        "SIGMA_0": (-kY, kY, kY), "F_0": (kY, -kY, 1 - kY),
        "LAMBDA_0": (kZ, kZ, -kZ), "G_0": (1 - kZ, -kZ, kZ),
        "V_0": (kM, 0.5 - kD, -kM), "H_0": (-kM, 0.5 + kD, kM), "H_2": (0.5 + kD, -kM, 0.5 - kD),
      ),
      path: (("Γ", "X"), ("X", "F_0"), ("SIGMA_0", "Γ"), ("Γ", "LAMBDA_0"), ("G_0", "X"),
             ("Γ", "R"), ("R", "W"), ("W", "S"), ("S", "Γ"), ("Γ", "T"), ("T", "W")),
    )
  } else if variant in ("oC1", "oA1") {
    let kX = if variant == "oC1" { (1 + a * a / (b * b)) / 4 } else { (1 + b * b / (c * c)) / 4 }
    (
      points: (
        "Γ": (0, 0, 0), "Y": (-0.5, 0.5, 0), "T": (-0.5, 0.5, 0.5), "Z": (0, 0, 0.5),
        "S": (0, 0.5, 0), "R": (0, 0.5, 0.5),
        "SIGMA_0": (kX, kX, 0), "C_0": (-kX, 1 - kX, 0),
        "A_0": (kX, kX, 0.5), "E_0": (-kX, 1 - kX, 0.5),
      ),
      path: (("Γ", "Y"), ("Y", "C_0"), ("SIGMA_0", "Γ"), ("Γ", "Z"), ("Z", "A_0"),
             ("E_0", "T"), ("T", "Y"), ("Γ", "S"), ("S", "R"), ("R", "Z"), ("Z", "T")),
    )
  } else if variant in ("oC2", "oA2") {
    let kX = if variant == "oC2" { (1 + b * b / (a * a)) / 4 } else { (1 + c * c / (b * b)) / 4 }
    (
      points: (
        "Γ": (0, 0, 0), "Y": (0.5, 0.5, 0), "T": (0.5, 0.5, 0.5), "T_2": (0.5, 0.5, -0.5),
        "Z": (0, 0, 0.5), "Z_2": (0, 0, -0.5), "S": (0, 0.5, 0), "R": (0, 0.5, 0.5),
        "R_2": (0, 0.5, -0.5),
        "DELTA_0": (-kX, kX, 0), "F_0": (kX, 1 - kX, 0),
        "B_0": (-kX, kX, 0.5), "B_2": (-kX, kX, -0.5),
        "G_0": (kX, 1 - kX, 0.5), "G_2": (kX, 1 - kX, -0.5),
      ),
      path: (("Γ", "Y"), ("Y", "F_0"), ("DELTA_0", "Γ"), ("Γ", "Z"), ("Z", "B_0"),
             ("G_0", "T"), ("T", "Y"), ("Γ", "S"), ("S", "R"), ("R", "Z"), ("Z", "T")),
    )
  } else if variant in ("hP1", "hP2") {
    let pts = (
      "Γ": (0, 0, 0), "A": (0, 0, 0.5), "K": (1 / 3, 1 / 3, 0), "H": (1 / 3, 1 / 3, 0.5),
      "H_2": (1 / 3, 1 / 3, -0.5), "M": (0.5, 0, 0), "L": (0.5, 0, 0.5),
    )
    let path = (("Γ", "M"), ("M", "K"), ("K", "Γ"), ("Γ", "A"), ("A", "L"), ("L", "H"),
                ("H", "A"), ("L", "M"), ("H", "K"))
    if variant == "hP1" { path = path + (("K", "H_2"),) }
    (points: pts, path: path)
  } else if variant == "hR1" {
    let kD = a * a / (4 * c * c)
    let kY = 5 / 6 - 2 * kD
    let kN = 1 / 3 + kD
    (
      points: (
        "Γ": (0, 0, 0), "T": (0.5, 0.5, 0.5), "L": (0.5, 0, 0), "L_2": (0, -0.5, 0),
        "L_4": (0, 0, -0.5), "F": (0.5, 0, 0.5), "F_2": (0.5, 0.5, 0),
        "S_0": (kN, -kN, 0), "S_2": (1 - kN, 0, kN), "S_4": (kN, 0, -kN), "S_6": (1 - kN, kN, 0),
        "H_0": (0.5, -1 + kY, 1 - kY), "H_2": (kY, 1 - kY, 0.5), "H_4": (kY, 0.5, 1 - kY),
        "H_6": (0.5, 1 - kY, -1 + kY),
        "M_0": (kN, -1 + kY, kN), "M_2": (1 - kN, 1 - kY, 1 - kN), "M_4": (kY, kN, kN),
        "M_6": (1 - kN, 1 - kN, 1 - kY), "M_8": (kN, kN, -1 + kY),
      ),
      path: (("Γ", "T"), ("T", "H_2"), ("H_0", "L"), ("L", "Γ"), ("Γ", "S_0"),
             ("S_2", "F"), ("F", "Γ")),
    )
  } else if variant == "hR2" {
    let kZ = 1 / 6 - c * c / (9 * a * a)
    let kH = 0.5 - 2 * kZ
    let kN = 0.5 + kZ
    (
      points: (
        "Γ": (0, 0, 0), "T": (0.5, -0.5, 0.5),
        "P_0": (kH, -1 + kH, kH), "P_2": (kH, kH, kH), "R_0": (1 - kH, -kH, -kH),
        "M": (1 - kN, -kN, 1 - kN), "M_2": (kN, -1 + kN, -1 + kN),
        "L": (0.5, 0, 0), "F": (0.5, -0.5, 0),
      ),
      path: (("Γ", "L"), ("L", "T"), ("T", "P_0"), ("P_2", "Γ"), ("Γ", "F")),
    )
  } else if variant == "mP1" {
    let kY = (1 + a / c * cb) / (2 * sb * sb)
    let kN = 0.5 + kY * c * cb / a
    (
      points: (
        "Γ": (0, 0, 0), "Z": (0, 0.5, 0), "B": (0, 0, 0.5), "B_2": (0, 0, -0.5),
        "Y": (0.5, 0, 0), "Y_2": (-0.5, 0, 0), "C": (0.5, 0.5, 0), "C_2": (-0.5, 0.5, 0),
        "D": (0, 0.5, 0.5), "D_2": (0, 0.5, -0.5), "A": (-0.5, 0, 0.5), "E": (-0.5, 0.5, 0.5),
        "H": (-kY, 0, 1 - kN), "H_2": (-1 + kY, 0, kN), "H_4": (-kY, 0, -kN),
        "M": (-kY, 0.5, 1 - kN), "M_2": (-1 + kY, 0.5, kN), "M_4": (-kY, 0.5, -kN),
      ),
      path: (("Γ", "Z"), ("Z", "D"), ("D", "B"), ("B", "Γ"), ("Γ", "A"), ("A", "E"),
             ("E", "Z"), ("Z", "C_2"), ("C_2", "Y_2"), ("Y_2", "Γ")),
    )
  } else if variant == "mC1" {
    let kZ = (2 + a / c * cb) / (4 * sb * sb)
    let kH = 0.5 - 2 * kZ * c * cb / a
    let kS = 0.75 - b * b / (4 * a * a * sb * sb)
    let kP = kS - (0.75 - kS) * a * cb / c
    (
      points: (
        "Γ": (0, 0, 0), "Y_2": (-0.5, 0.5, 0), "Y_4": (0.5, -0.5, 0), "A": (0, 0, 0.5),
        "M_2": (-0.5, 0.5, 0.5), "V": (0.5, 0, 0), "V_2": (0, 0.5, 0), "L_2": (0, 0.5, 0.5),
        "C": (1 - kS, 1 - kS, 0), "C_2": (-1 + kS, kS, 0), "C_4": (kS, -1 + kS, 0),
        "D": (-1 + kP, kP, 0.5), "D_2": (1 - kP, 1 - kP, 0.5),
        "E": (-1 + kZ, 1 - kZ, 1 - kH), "E_2": (-kZ, kZ, kH), "E_4": (kZ, -kZ, 1 - kH),
      ),
      path: (("Γ", "C"), ("C_2", "Y_2"), ("Y_2", "Γ"), ("Γ", "M_2"), ("M_2", "D"),
             ("D_2", "A"), ("A", "Γ"), ("L_2", "Γ"), ("Γ", "V_2")),
    )
  } else if variant == "mC2" {
    let kZ = (a * a / (b * b) + (1 + a / c * cb) / (sb * sb)) / 4
    let kM = (1 + a * a / (b * b)) / 4
    let kD = -a * c * cb / (2 * b * b)
    let kX = 0.5 - 2 * kZ * c * cb / a
    let kP = 1 + kZ - 2 * kM
    let kS = kX - 2 * kD
    (
      points: (
        "Γ": (0, 0, 0), "Y": (0.5, 0.5, 0), "A": (0, 0, 0.5), "M": (0.5, 0.5, 0.5),
        "V_2": (0, 0.5, 0), "L_2": (0, 0.5, 0.5),
        "F": (-1 + kP, 1 - kP, 1 - kS), "F_2": (1 - kP, kP, kS), "F_4": (kP, 1 - kP, 1 - kS),
        "H": (-kZ, kZ, kX), "H_2": (kZ, 1 - kZ, 1 - kX), "H_4": (kZ, -kZ, 1 - kX),
        "G": (-kM, kM, kD), "G_2": (kM, 1 - kM, -kD), "G_4": (kM, -kM, -kD), "G_6": (1 - kM, kM, kD),
      ),
      path: (("Γ", "Y"), ("Y", "M"), ("M", "A"), ("A", "Γ"), ("L_2", "Γ"), ("Γ", "V_2")),
    )
  } else if variant == "mC3" {
    let kZ = (a * a / (b * b) + (1 + a / c * cb) / (sb * sb)) / 4
    let kR = 1 - kZ * b * b / (a * a)
    let kE = 0.5 - 2 * kZ * c * cb / a
    let kF = kE / 2 + a * a / (4 * b * b) + a * c * cb / (2 * b * b)
    let kU = 2 * kF - kZ
    let kW = c / (2 * a * cb) * (1 - 4 * kU + a * a * sb * sb / (b * b))
    let kD = -0.25 + kW / 2 - kZ * c * cb / a
    (
      points: (
        "Γ": (0, 0, 0), "Y": (0.5, 0.5, 0), "A": (0, 0, 0.5), "M_2": (-0.5, 0.5, 0.5),
        "V": (0.5, 0, 0), "V_2": (0, 0.5, 0), "L_2": (0, 0.5, 0.5),
        "I": (-1 + kR, kR, 0.5), "I_2": (1 - kR, 1 - kR, 0.5),
        "K": (-kU, kU, kW), "K_2": (-1 + kU, 1 - kU, 1 - kW), "K_4": (1 - kU, kU, kW),
        "H": (-kZ, kZ, kE), "H_2": (kZ, 1 - kZ, 1 - kE), "H_4": (kZ, -kZ, 1 - kE),
        "N": (-kF, kF, kD), "N_2": (kF, 1 - kF, -kD), "N_4": (kF, -kF, -kD), "N_6": (1 - kF, kF, kD),
      ),
      path: (("Γ", "A"), ("A", "I_2"), ("I", "M_2"), ("M_2", "Γ"), ("Γ", "Y"),
             ("L_2", "Γ"), ("Γ", "V_2")),
    )
  } else if variant == "aP2" {
    (
      points: (
        "Γ": (0, 0, 0), "Z": (0, 0, 0.5), "Y": (0, 0.5, 0), "X": (0.5, 0, 0),
        "V": (0.5, 0.5, 0), "U": (0.5, 0, 0.5), "T": (0, 0.5, 0.5), "R": (0.5, 0.5, 0.5),
      ),
      path: (("Γ", "X"), ("Y", "Γ"), ("Γ", "Z"), ("R", "Γ"), ("Γ", "T"), ("U", "Γ"), ("Γ", "V")),
    )
  } else if variant == "aP3" {
    (
      points: (
        "Γ": (0, 0, 0), "Z": (0, 0, 0.5), "Y": (0, 0.5, 0), "Y_2": (0, -0.5, 0),
        "X": (0.5, 0, 0), "V_2": (0.5, -0.5, 0), "U_2": (-0.5, 0, 0.5),
        "T_2": (0, -0.5, 0.5), "R_2": (-0.5, -0.5, 0.5),
      ),
      path: (("Γ", "X"), ("Y", "Γ"), ("Γ", "Z"), ("R_2", "Γ"), ("Γ", "T_2"),
             ("U_2", "Γ"), ("Γ", "V_2")),
    )
  } else {
    panic("materia: k-path variant '" + variant + "' not implemented")
  }
}

/// High-symmetry k-points, recommended path, and resolved variant for a Bravais
/// lattice, per Setyawan-Curtarolo (2010) with HPKOT standardization.
///
/// - bravais (string): extended Bravais base symbol -- one of cP, cF, cI, tP, tI,
///   oP, oF, oI, oC, hP, hR, mP, mC, aP.
/// - params (dictionary): standardized conventional-cell parameters with keys
///   `a`, `b`, `c` (lengths; b,c default to a) and `alpha`, `beta`, `gamma`
///   (angles or degrees; default 90). Must be in the SC-2010 standard setting
///   (orthorhombic a<=b<=c, monoclinic beta>=90, hexagonal setting for hR).
/// -> dictionary
/// Returns `(points: (Γ: (0,0,0), ..), path: ((a, b), ..), variant: "..")`, all
/// k-points FRACTIONAL in the primitive reciprocal basis.
#let kpath-data(bravais, params) = {
  if bravais not in _bases {
    panic("materia: unknown Bravais symbol '" + bravais + "' (expected one of " + repr(_bases) + ")")
  }
  let q = _fill(params)
  _validate(bravais, q)
  let variant = _variant(bravais, q)
  let t = _table(variant, q)
  (points: t.points, path: t.path, variant: variant)
}

/// Named high-symmetry k-points (fractional, primitive reciprocal basis).
/// See `kpath-data`. -> dictionary
#let kpoints(bravais, params) = kpath-data(bravais, params).points

/// Recommended k-path as an ordered array of (name-a, name-b) segments.
/// See `kpath-data`. -> array
#let kpath(bravais, params) = kpath-data(bravais, params).path
