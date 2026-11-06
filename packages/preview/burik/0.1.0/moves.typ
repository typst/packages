#let x = ((u, d, f, b, r, l)) => (
  u : (f.at(0), f.at(1), f.at(2),  
   f.at(3), f.at(4), f.at(5),
   f.at(6), f.at(7), f.at(8)),
  
  d : (b.at(8), b.at(7), b.at(6),
   b.at(5), b.at(4), b.at(3),
   b.at(2), b.at(1), b.at(0)),
  
  f : (d.at(0), d.at(1), d.at(2),
   d.at(3), d.at(4), d.at(5),
   d.at(6), d.at(7), d.at(8)),

  b : (u.at(8), u.at(7), u.at(6),
   u.at(5), u.at(4), u.at(3),
   u.at(2), u.at(1), u.at(0)),

  r : (r.at(6), r.at(3), r.at(0),  
   r.at(7), r.at(4), r.at(1),
   r.at(8), r.at(5), r.at(2)),

  l : (l.at(2), l.at(5), l.at(8),  
   l.at(1), l.at(4), l.at(7),
   l.at(0), l.at(3), l.at(6))
)

#let x2 = (cube) => x(x(cube))
#let x3 = (cube) => x(x(x(cube)))

#let y = ((u, d, f, b, r, l)) => (
  u : (u.at(6), u.at(3), u.at(0),
   u.at(7), u.at(4), u.at(1),
   u.at(8), u.at(5), u.at(2)),
  
  d : (d.at(2), d.at(5), d.at(8),
   d.at(1), d.at(4), d.at(7),
   d.at(0), d.at(3), d.at(6)),
  
  f : (r.at(0), r.at(1), r.at(2),
   r.at(3), r.at(4), r.at(5),
   r.at(6), r.at(7), r.at(8)),

  b : (l.at(0), l.at(1), l.at(2),
   l.at(3), l.at(4), l.at(5),
   l.at(6), l.at(7), l.at(8)),

  r : (b.at(0), b.at(1), b.at(2),  
   b.at(3), b.at(4), b.at(5),
   b.at(6), b.at(7), b.at(8)),

  l : (f.at(0), f.at(1), f.at(2),  
   f.at(3), f.at(4), f.at(5),
   f.at(6), f.at(7), f.at(8))
)

#let y2 = (cube) => y(y(cube))
#let y3 = (cube) => y(y(y(cube)))

#let z = (cube) => x3(y(x(cube)))
#let z2 = (cube) => z(z(cube))
#let z3 = (cube) => z(z(z(cube)))


#let U = ((u, d, f, b, r, l)) => (
  u : (u.at(6), u.at(3), u.at(0),
   u.at(7), u.at(4), u.at(1),
   u.at(8), u.at(5), u.at(2)),
  
  d : (d.at(0), d.at(1), d.at(2),
   d.at(3), d.at(4), d.at(5),
   d.at(6), d.at(7), d.at(8)),
  
  f : (r.at(0), r.at(1), r.at(2),
   f.at(3), f.at(4), f.at(5),
   f.at(6), f.at(7), f.at(8)),

  b : (l.at(0), l.at(1), l.at(2),
   b.at(3), b.at(4), b.at(5),
   b.at(6), b.at(7), b.at(8)),

  r : (b.at(0), b.at(1), b.at(2),  
   r.at(3), r.at(4), r.at(5),
   r.at(6), r.at(7), r.at(8)),

  l : (f.at(0), f.at(1), f.at(2),  
   l.at(3), l.at(4), l.at(5),
   l.at(6), l.at(7), l.at(8))
)

#let U2 = (cube) => U(U(cube))
#let U3 = (cube) => U(U(U(cube)))

#let R = (cube) => z(U(z3(cube)))
#let R2 = (cube) => R(R(cube))
#let R3 = (cube) => R(R(R(cube)))

#let F = (cube) => x3(U(x(cube)))
#let F2 = (cube) => F(F(cube))
#let F3 = (cube) => F(F(F(cube)))

#let L = (cube) => z3(U(z(cube)))
#let L2 = (cube) => L(L(cube))
#let L3 = (cube) => L(L(L(cube)))

#let B = (cube) => x(U(x3(cube)))
#let B2 = (cube) => B(B(cube))
#let B3 = (cube) => B(B(B(cube)))

#let D = (cube) => z2(U(z2(cube)))
#let D2 = (cube) => D(D(cube))
#let D3 = (cube) => D(D(D(cube)))


#let r = (cube) => L(x(cube))
#let r2 = (cube) => r(r(cube))
#let r3 = (cube) => r(r(r(cube)))

#let l = (cube) => R(x3(cube))
#let l2 = (cube) => l(l(cube))
#let l3 = (cube) => l(l(l(cube)))

#let f = (cube) => B(z(cube))
#let f2 = (cube) => f(f(cube))
#let f3 = (cube) => f(f(f(cube)))

#let b = (cube) => U(z(cube))
#let b2 = (cube) => b(b(cube))
#let b3 = (cube) => b(b(b(cube)))

#let u = (cube) => D(y(cube))
#let u2 = (cube) => u(u(cube))
#let u3 = (cube) => u(u(u(cube)))

#let d = (cube) => U(y3(cube))
#let d2 = (cube) => d(d(cube))
#let d3 = (cube) => d(d(d(cube)))


#let M = (cube) => R3(L(x(cube)))
#let M2 = (cube) => M(M(cube))
#let M3 = (cube) => M(M(M(cube)))

#let E = (cube) => y(U3(D(cube)))
#let E2 = (cube) => E(E(cube))
#let E3 = (cube) => E(E(E(cube)))

#let S = (cube) => z(F3(B(cube)))
#let S2 = (cube) => S(S(cube))
#let S3 = (cube) => S(S(S(cube)))


#let apply-move = (cube, move) => {
       if move == "x" {x(cube)}
  else if move == "x'" {x3(cube)}
  else if move == "x2" {x2(cube)}

  else if move == "y" {y(cube)}
  else if move == "y'" {y3(cube)}
  else if move == "y2" {y2(cube)}

  else if move == "z" {z(cube)}
  else if move == "z'" {z3(cube)}
  else if move == "z2" {z2(cube)}
  
  else if move == "R"  {R(cube)}
  else if move == "R'" {R3(cube)}
  else if move == "R2" {R2(cube)}
  else if move == "R3" {R3(cube)}

  else if move == "L"  {L(cube)}
  else if move == "L'" {L3(cube)}
  else if move == "L2" {L2(cube)}

  else if move == "U"  {U(cube)}
  else if move == "U'" {U3(cube)}
  else if move == "U2" {U2(cube)}

  else if move == "D"  {D(cube)}
  else if move == "D'" {D3(cube)}
  else if move == "D2" {D2(cube)}

  else if move == "F"  {F(cube)}
  else if move == "F'" {F3(cube)}
  else if move == "F2" {F2(cube)}

  else if move == "B"  {B(cube)}
  else if move == "B'" {B3(cube)}
  else if move == "B2" {B2(cube)}

  else if move == "d"  {d(cube)}
  else if move == "d'" {d3(cube)}
  else if move == "d2" {d2(cube)}

  else if move == "r"  {r(cube)}
  else if move == "r'" {r3(cube)}
  else if move == "r2" {r2(cube)}

  else if move == "l"  {l(cube)}
  else if move == "l'" {l3(cube)}
  else if move == "l2" {l2(cube)}

  else if move == "f"  {f(cube)}
  else if move == "f'" {f3(cube)}
  else if move == "f2" {f2(cube)}

  else if move == "u"  {u(cube)}
  else if move == "u'" {u3(cube)}
  else if move == "u2" {u2(cube)}

  else if move == "b"  {b(cube)}
  else if move == "b'" {b3(cube)}
  else if move == "b2" {b2(cube)}

  else if move == "M"  {M(cube)}
  else if move == "M'" {M3(cube)}
  else if move == "M2" {M2(cube)}

  else if move == "E"  {E(cube)}
  else if move == "E'" {E3(cube)}
  else if move == "E2" {E2(cube)}

  else if move == "S"  {S(cube)}
  else if move == "S'" {S3(cube)}
  else if move == "S2" {S2(cube)}

  else { cube } // If unknown move, return unchanged
}

