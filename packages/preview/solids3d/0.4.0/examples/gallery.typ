// Galerie : portage des figures de https://asy.marris.fr/asymptote/Solides/
// (fichiers fig_*.asy de G. Marris). Compiler avec :
//     typst compile --root .. gallery.typ
#import "../lib.typ": *

#set page(width: 21cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 10pt)
#show heading: set text(size: 12pt)

#let fig(title, body) = block(breakable: false, width: 100%, inset: 3pt, {
  align(center, body)
  v(1pt)
  align(center, text(size: 8pt, style: "italic", title))
})

= Solides — portage Typst du module `solids` d'Asymptote

Chaque figure reprend le code Asymptote de la galerie « Solides » (nom du fichier en légende).
Tout est calculé en Typst : projection 3D → 2D, squelettes des solides de révolution
(parties cachées en pointillés), silhouettes, surfaces éclairées et triées par profondeur.

#let nslice4 = 4 * nslice

#grid(columns: 3, gutter: 6pt,
  // ---------------------------------------------------------------- sphères
  fig[fig_aa01 : `draw(unitsphere, green)`][
    #picture(size: 5cm, projection: orthographic(5, 4, 3), draw(unitsphere, green))
  ],
  fig[fig_ab01 : `light(paleyellow, (5,-5,10), (0,0,-10))`][
    #{
      // Asymptote draws the skeleton before the surface and lets OpenGL sort
      // them; here the lines are not depth-tested against surfaces, so the
      // back circles are drawn before the (90% opaque) surface and the front
      // circles after it.
      let P = orthographic(0, 10, 5)
      let b = sphere(1, n: 8 * nslice)
      let s = transverse(b, m: 10, P: P)
      picture(width: 5cm, projection: P, light: light(paleyellow, (5, -5, 10), (0, 0, -10)),
        draw(s.back, pen(linetype("8 0"), blue, 0.8pt)),
        draw(surface(sphere(1, n: 4 * nslice), n: 24), withopacity(palegreen, 0.9)),
        draw(s.front, blue + 0.8pt),
      )
    }
  ],
  fig[fig_ab02 : `currentlight = White`, transverse à 0.5][
    #{
      let b = sphere(O, 1)
      let P = orthographic(0, 8, 2)
      let s = transverse(b, reltime(b.g, 0.5), P)
      picture(width: 5cm, projection: P, light: White, margin: 5pt,
        draw(surface(b), withopacity(yellow, 0.3)),
        draw(s.back, pen(linetype("8 8", offset: 8), black, 1pt)), draw(s.front, black + 1pt),
      )
    }
  ],
  fig[fig_ab03 : plan sécant `unitsquare3`, sphère orange][
    #{
      let P = orthographic(3, 9, 2)
      let sph = sphere(O, 1)
      let (a, b) = (0.7, 2.4)
      let s = transverse(sph, reltime(sph.g, a), P)
      picture(width: 5cm, projection: P, light: White,
        draw(surface(apply(compose(shift(-b / 2, -b / 2, calc.sin(calc.pi * (a - 0.5) * 1rad)), scale3(b)), unitsquare3)), withopacity(white, 0.7)),
        draw(surface(sph), orange),
        draw(s.back, linetype("8 8", offset: 8)), draw(s.front),
      )
    }
  ],
  fig[fig_ab04 : `nolight`, `nslice = 48`, longitudinal][
    #{
      let P = orthographic(3, 2, 2)
      let b = sphere(O, 1, n: nslice4)
      let s1 = transverse(b, reltime(b.g, 0.6), P)
      let s2 = transverse(b, reltime(b.g, 0.5), P)
      let l = longitudinal(b, P)
      picture(width: 5cm, projection: P, light: nolight,
        draw(surface(b, n: nslice4), withopacity(paleblue, 0.5)),
        draw(s1.back + s2.back, linetype("8 8", offset: 8)), draw(s1.front + s2.front),
        draw(l.front), draw(l.back, linetype("8 8", offset: 8)),
      )
    }
  ],
  fig[fig_ab05 : `orthographic(10,5,2)`, coupes à 0.2 et 0.5][
    #{
      let P = orthographic(10, 5, 2)
      let b = sphere(O, 1, n: nslice4)
      let s1 = transverse(b, reltime(b.g, 0.2), P)
      let s2 = transverse(b, reltime(b.g, 0.5), P)
      picture(size: 5cm, projection: P,
        draw(surface(b, n: nslice4), withopacity(palegreen, 0.5)),
        draw(s1.back + s2.back, linetype("8 4", offset: 8)), draw(s1.front + s2.front, red),
      )
    }
  ],
  fig[fig_ab06 : projection par défaut `perspective(5,4,2)`][
    #{
      let P = currentprojection
      let boule = sphere(O, 1, n: nslice4)
      let cmds = ()
      for i in range(5) {
        let s = transverse(boule, reltime(boule.g, 0.5 + 0.1 * i), P)
        cmds += draw(s.back, linetype("10 10", offset: 10)) + draw(s.front)
      }
      picture(width: 5cm, projection: P,
        draw(surface(boule, n: nslice4), withopacity(color-add(lightgrey, white), 0.5)),
        cmds,
      )
    }
  ],
  fig[fig_ab08 : `White`, coupes à `acos(i)/pi`][
    #{
      let P = currentprojection
      let boule = sphere(O, 1, n: nslice4)
      let cmds = ()
      for k in range(5) {
        let i = -0.2 * k
        let s = transverse(boule, reltime(boule.g, calc.acos(i).rad() / calc.pi), P)
        cmds += draw(s.back, linetype("10 10", offset: 10)) + draw(s.front)
      }
      picture(width: 5cm, projection: P, light: White,
        draw(surface(boule, n: nslice4), withopacity(color-add(lightgrey, yellow), 0.5)),
        cmds,
      )
    }
  ],
  fig[fig_ac01 : `draw(b, .5bp+blue)` + coupes 1bp][
    #{
      let P = orthographic(3, 2, 2)
      let b = sphere(O, 1)
      let s1 = transverse(b, reltime(b.g, 0.6), P)
      let s2 = transverse(b, reltime(b.g, 0.5), P)
      picture(width: 5cm, projection: P, margin: 5pt,
        draw(b, blue + 0.5pt),
        draw(s1.back + s2.back, pen(1pt, linetype("8 8", offset: 8))), draw(s1.front + s2.front, black + 1pt),
      )
    }
  ],
  fig[fig_ad02 : `silhouette()`, `dotfactor = 3.5`][
    #{
      let P = orthographic(10, 5, 2)
      let b = sphere(O, 3)
      let s = transverse(b, reltime(b.g, 0.5), P)
      picture(width: 5cm, projection: P, dotfactor: 3.5,
        draw(s.back, pen(red, linetype("8 8", offset: 8))), draw(s.front, blue),
        draw(silhouette(b), black), dot(O),
      )
    }
  ],
  fig[fig_ad03 : `draw(b, 1, longitudinalpen: nullpen)`][
    #{
      let P = orthographic(10, 5, 2)
      let b = sphere(O, 3)
      picture(width: 5cm, projection: P, dotfactor: 3.5,
        draw(b, 1, longitudinalpen: nullpen),
        draw(surface(b), withopacity(color-scale(0.9, white), 0.1)),
        draw(silhouette(b), black), dot(O),
      )
    }
  ],
  fig[fig_ad04 : repère `Label("$x$", align=N)`, silhouette bleue][
    #{
      let P = orthographic(10, 5, 2)
      let a = 3
      let b = sphere(O, a)
      let s = transverse(b, reltime(b.g, 0.5), P)
      picture(width: 5cm, projection: P, dotfactor: 3.5,
        draw(surface(b), withopacity(color-scale(0.9, white), 0.15)),
        draw(s.back, pen(green, linetype("8 8", offset: 8))), draw(s.front, blue),
        dot(O), dot((vmul(a, X), vmul(a, Y), vmul(a, Z), O)),
        draw(Label($x$, align: N), line3(O, vmul(a, X)), red),
        draw(Label($y$, align: N), line3(O, vmul(a, Y)), red),
        draw(Label($z$, align: E), line3(O, vmul(a, Z)), red),
        draw(silhouette(b), blue),
      )
    }
  ],
  // ---------------------------------------------------------------- cônes
  fig[fig_ba01 : `cone(pO, r, h, axis: Z, n: 1)`][
    #{
      let (r, h) = (4, 7)
      let (pO, pS, pA) = (O, (0, 0, h), (r, 0, 0))
      picture(width: 5cm, projection: orthographic(50, 50, 25),
        draw(cone(pO, r, h, Z, 1), blue + 1pt),
        draw(line3(pS, pA)),
        draw((line3(pS, pO), line3(pO, pA)), dashed),
        label($S$, pS, N), dot(Label($O$, align: SE), pO), dot(Label($A$, align: SW), pA),
      )
    }
  ],
  fig[fig_ba03 : surface + squelette, `n: 2`][
    #{
      let (r, h) = (4, 7)
      let (pO, pS, pA) = (O, (0, 0, h), (r, 0, 0))
      let CoRev = cone(pO, r, h, Z, 2)
      picture(width: 5cm, projection: orthographic(50, 20, 25),
        draw(surface(CoRev), withopacity(lightblue, 0.5)),
        draw(CoRev, blue + 1pt),
        draw(line3(pS, pA)),
        draw((line3(pS, pO), line3(pO, pA)), dashed),
        label($S$, pS, N), dot(Label($O$, align: SE), pO), dot(Label($A$, align: SW), pA),
        dot(Label($O'$, align: SE), vmul(0.5, pS)),
      )
    }
  ],
  fig[fig_bb01 : cotes avec `Arrow3`, `draw("$r$", g, N, red)`][
    #{
      let (r, h, s, sr) = (4.0, 10.0, 8.0, 5.0)
      let x = r * s / h
      let xr = r * sr / h
      let (s1, s2) = (sr - 0.1, sr + 0.2)
      let (x1, x2) = (r * s1 / h, r * s2 / h)
      let a = revolution(line3(O, (x, 0, s)), Z)
      let b = revolution(line3((x, 0, s), (r, 0, h)), Z)
      let w = revolution(line3((x1, 0, s1), (x2, 0, s2), (0, 0, s2)), Z)
      picture(width: 5cm, projection: orthographic(0, -30, 5),
        draw(surface(a, 4), withopacity(lightblue, 0.5)),
        draw(surface(b), withopacity(white, 0.5)),
        draw(line3((-r - 1, 0, 0), (r + 1, 0, 0))),
        draw(line3(O, (0, 0, h + 1)), dashed),
        draw(surface(w), withopacity(blue, 0.5)),
        draw(circle3((0, 0, s2), x2)), draw(circle3((0, 0, s1), x1)),
        draw($x$, line3((xr, 0, 0), (xr, 0, sr)), red, Arrow3),
        draw($r$, line3((0, 0, sr), (xr, 0, sr)), N, red),
        draw([4], line3((0, 0, h), (r, 0, h)), N, red),
        draw([10], line3((r, 0, 0), (r, 0, h)), red, Arrow3),
        draw([8], line3((-x, 0, 0), (-x, 0, s)), W, red, Arrow3),
      )
    }
  ],
  fig[fig_bc01 : `unitcone`, `limits(O, X+Y+Z)`, `xaxis3(Label(..,1), Arrow3)`][
    #picture(size: 5cm, projection: orthographic(5, 5, 2),
      limits(O, (1, 1, 1)),
      xaxis3(Label($(1,0,0)$, 1), Arrow3), yaxis3(Label($(0,1,0)$, 1), Arrow3), zaxis3(Label($(0,0,1)$, 1), Arrow3),
      draw(unitcone, withopacity(palegreen, 0.5)),
      draw(cone(O, 1, 1, Z, 1), blue + 1pt),
    )
  ],
  fig[fig_bs01 : section d'un cône par un plan (`graph3`, `plane`)][
    #{
      let (a, r, h) = (2.0, 4.0, 7.0)
      let l = calc.pow(r / h, 2)
      let m = calc.sqrt(l * h * h - a * a)
      let (pA1, pA2, pB1, pB2) = ((0, 0, -h), (0, 0, h), (r, 0, -h), (-r, 0, h))
      let pO = O
      let pI = (a, 0, -calc.sqrt(a * a / l))
      let F1 = y => (a, y, calc.sqrt((a * a + y * y) / l))
      let F2 = y => (a, y, -calc.sqrt((a * a + y * y) / l))
      let b1 = graph3(F1, -r, r, join: "..")
      let b2 = graph3(F2, -r, r, join: "..")
      let pl1 = plane((0, 2 * m, 0), (0, 0, 2 * h), (a, -m, -h))
      picture(width: 5.5cm, projection: orthographic(40, 10, 10), inset: 3mm, fill: white,
        limits((-r, -r, -h), (2 * r, r, 1.2 * h)),
        draw(cone(pA1, r, h, Z, 1), blue + 1pt, longitudinalpen: nullpen),
        draw(cone(pA2, r, h, vneg(Z), 1), blue + 1pt, longitudinalpen: nullpen),
        draw(surface(cone(pA1, r, h, Z, 1)), color-add(lightgray, white)),
        draw(surface(cone(pA2, r, h, vneg(Z), 1)), lightgray),
        draw(surface(pl1), withopacity(green, 0.6)),
        draw((line3(pI, pB1), line3(pA2, pB2))),
        draw((line3(pB1, pA1, pA2), line3(pI, pO, pB2)), dashed),
        draw((b1, b2), red + 1pt),
        dot((line3(pB1, pA1, pA2), line3(pI, pO, pB2))),
        dot(line3((a, m, -h), (a, m, h), (a, -m, h), (a, -m, -h))),
        dot(Label($a$, align: vadd(vneg(Y), X)), (a, 0, 0)),
        label($O$, pO, pair-scale(2, E)),
        xaxis3($x$, Arrow3), yaxis3($y$, Arrow3), zaxis3($z$, Arrow3),
      )
    }
  ],
  // ---------------------------------------------------------------- cylindres
  fig[fig_ca01 : `unitcylinder`, `orthographic(4,5,8)`][
    #picture(size: 5cm, projection: orthographic(4, 5, 8),
      limits(O, (1, 1, 1)),
      xaxis3(Label($(1,0,0)$, 1), Arrow3), yaxis3(Label($(0,1,0)$, 1), Arrow3), zaxis3(Label($(0,0,1)$, 1), Arrow3),
      draw(unitcylinder, withopacity(blue, 0.6)),
      draw(cylinder(O, 1, 1), orange + 1pt),
    )
  ],
  fig[fig_ca02 : `orthographic(camera:, up:, target:)`, `zscale3(3)`][
    #picture(size: 5cm, light: White,
      projection: orthographic(camera: (0.901370856430926, 6.6670309932277, 4.12892953058253),
        up: (-0.00669345996391094, -0.00562113947193458, 0.0167831924904972),
        target: (0.250973517912766, 0.260452385430086, 1.72379105889263)),
      limits(O, (2, 2, 4)),
      xaxis3(Arrow3), yaxis3(Arrow3), zaxis3(Arrow3),
      draw(apply(zscale3(3), unitcylinder), withopacity(paleyellow, 0.95)),
    )
  ],
  fig[fig_cb01 : cylindres concentriques, `zoom: .95`][
    #{
      let (r1, r2, h1, h2) = (4, 3, 5, 3)
      let g1 = revolution(line3(O, (r1, 0, 0), (r1, 0, h1), (r2, 0, h1)), Z)
      let g2 = revolution(line3((r2, 0, h1), (r2, 0, h1 + h2), (0, 0, h1 + h2)), Z)
      picture(size: 5cm, projection: orthographic((5, 2, 2), up: Z, zoom: 0.95),
        draw(surface(g1), lightblue), draw(surface(g2), lightred),
        limits(O, (r1 + 2, r1 + 2, h1 + h2 + 2)),
        xaxis3($x$, arrow3()), yaxis3($y$, arrow3()), zaxis3($z$, arrow3()),
      )
    }
  ],
  fig[fig_cb02 : couronne `surface(p, planar: true)` + `extrude`, `zsort: "global"`][
    #{
      let p = (reverse(unitcircle3), apply(scale3(0.5), unitcircle3))
      picture(size: 5cm, projection: perspective(camera: (4, 4, 7), up: Z), zsort: "global",
        limits(O, (1.5, 1.5, 2)),
        draw(surface(p, planar: true), red),
        draw(surface(apply(shift(Z), p), planar: true), red),
        draw(extrude(reverse(unitcircle3), Z), lightgray),
        draw(extrude(apply(scale3(0.5), unitcircle3), Z), lightgray),
        xaxis3($x$, arrow3()), yaxis3($y$, arrow3()), zaxis3($z$, arrow3()),
      )
    }
  ],
  // ---------------------------------------------------------------- cubes, pavés, pyramides
  fig[fig_pa01 : `unitbox`, `dot(unitbox, blue)`][
    #picture(size: 5cm, projection: orthographic(5, 3, 2),
      limits(O, (1, 1, 1)),
      xaxis3(Label($(1,0,0)$, 1), Arrow3), yaxis3(Label($(0,1,0)$, 1), Arrow3), zaxis3(Label($(0,0,1)$, 1), Arrow3),
      draw(unitbox), dot(unitbox, blue), label($O$, O, NW),
    )
  ],
  fig[fig_pa04 : `obj(..)` avec une couleur par face, `nolight`][
    #{
      let cube2 = "v 0 0 0\nv 1 0 0\nv 1 1 0\nv 0 1 0\nv 0 0 1\nv 1 0 1\nv 1 1 1\nv 0 1 1\nf 5 6 7 8\nf 1 4 3 2\nf 1 2 6 5\nf 2 3 7 6\nf 3 4 8 7\nf 4 1 5 8\n"
      picture(size: 5cm, projection: orthographic(3, 2, 4),
        draw(obj(cube2), (paleblue, palered, paleyellow, pink, palegreen, orange), nolight),
      )
    }
  ],
  fig[fig_pc01 : `draw(unitcube, blue+opacity(.6), orange)`][
    #picture(size: 5cm, projection: orthographic(5, 4, 4),
      draw(unitcube, withopacity(blue, 0.6), orange), label($O$, O, NW),
    )
  ],
  fig[fig_pd02 : `box3(O, (5,4,3))`, axes `lightgreen`][
    #picture(size: 5cm, projection: orthographic(5, 3, 4),
      draw(box3(O, (5, 4, 3)), blue),
      limits(O, (1, 1, 1)),
      xaxis3(Label(text(size: 1.5em, $x$), 1), lightgreen, Arrow3),
      yaxis3(Label(text(size: 1.5em, $y$), 1), lightgreen, Arrow3),
      zaxis3(Label(text(size: 1.5em, $z$), 1), lightgreen, Arrow3),
    )
  ],
  fig[fig_pd03 : `box3` vert, `shift(Z)*unitsquare3`, vecteurs de base][
    #picture(size: 5cm, projection: orthographic(5, 3, 4),
      draw(box3(O, (6, 3, 2)), green),
      draw(apply(shift(Z), unitsquare3), blue + 2pt),
      limits(O, (1, 1, 1)),
      xaxis3(Label(text(size: 1.5em, $arrow(dotless.i)$), 1), red + 1pt, Arrow3),
      yaxis3(Label(text(size: 1.5em, $arrow(dotless.j)$), 1), red + 1pt, Arrow3),
      zaxis3(Label(text(size: 1.5em, $arrow(k)$), 1), red + 1pt, Arrow3),
    )
  ],
  fig[fig_py02 : pyramide en fil de fer, arêtes cachées][
    #{
      let (pA, pB, pC, pD, pS) = ((2, 2, 0), (-2, 2, 0), (-2, -2, 0), (2, -2, 0), (0, 0, 5))
      picture(size: 5cm, projection: orthographic(5, 4, 3),
        draw(line3(pS, pD, pA, pS, pB, pA)),
        draw((line3(pD, pC, pS), line3(pC, pB)), dashed),
        label($A$, pA, S), label($B$, pB, E), label($C$, pC, NW), label($D$, pD, W), label($S$, pS, N),
      )
    }
  ],
  fig[fig_py03 : `surface(faces)`, `light(10,0,10)`][
    #{
      let (pA, pB, pC, pD, pS) = ((2, 2, 0), (-2, 2, 0), (-2, -2, 0), (2, -2, 0), (0, 0, 5))
      let faces = (line3(pA, pB, pC, pD, cyclic: true), line3(pS, pB, pC, cyclic: true), line3(pS, pC, pD, cyclic: true), line3(pS, pD, pA, cyclic: true), line3(pS, pA, pB, cyclic: true))
      picture(size: 5cm, projection: orthographic(5, 4, 3), light: light(10, 0, 10),
        draw(surface(faces), withopacity(green, 0.8)),
        label($A$, pA, S), label($B$, pB, E), label($D$, pD, W), label($S$, pS, N),
      )
    }
  ],
  fig[fig_py04 : `light(0,10,10)`, arêtes `1.5bp+orange`][
    #{
      let (pA, pB, pC, pD, pS) = ((2, 2, 0), (-2, 2, 0), (-2, -2, 0), (2, -2, 0), (0, 0, 5))
      let faces = (line3(pA, pB, pC, pD, cyclic: true), line3(pS, pB, pC, cyclic: true), line3(pS, pC, pD, cyclic: true), line3(pS, pD, pA, cyclic: true), line3(pS, pA, pB, cyclic: true))
      picture(size: 5cm, projection: orthographic(5, 4, 3), light: light(0, 10, 10),
        draw(surface(faces), withopacity(blue, 0.9)),
        draw(faces, orange + 1.5pt),
        label($A$, pA, S), label($B$, pB, E), label($D$, pD, W), label($S$, pS, N),
      )
    }
  ],
  // ---------------------------------------------------------------- tore, solides unitaires
  fig[fig_ta01 : tore `revolution(shift(R*X)*Circle3(O,a,Y,32), Z)`, `light: (0,5,5)`][
    #{
      let (R, a) = (3, 1)
      let d = R + 2 * a
      let tore = revolution(apply(shift(R, 0, 0), Circle3(O, a, normal: Y, n: 32)), Z)
      let g = spline3(vmul(d, vunit((1, 0.3, 0))), vmul(0.5, vsub(X, Y)), vmul(d, vunit((-1, -1, 0))), (-d, 0, a), vmul(0.5, vsub(Y, X)), vmul(d, vunit((0.5, 1, 0))))
      picture(width: 5.5cm, projection: orthographic(8.5, 9.5, 8), light: (0, 5, 5),
        draw(surface(tore), orange),
        draw(g, blue + 2pt), dot(g, green + 1pt),
        limits((-d, -d, -2 * a), (d, d, 2 * a)),
        xaxis3($x$, Arrow3), yaxis3($y$, Arrow3), zaxis3($z$, Arrow3),
      )
    }
  ],
  fig[fig_ua01 : `unitsphere`, `unithemisphere`, `unitcone`, `unitsolidcone`][
    #picture(size: 5.5cm,
      projection: perspective(camera: (4.73967542895427, 4.76147519718155, -2.88109885734294),
        up: (-0.00275043462732612, 0.0152291034920296, 0.0169895927889711),
        target: (1.06760561304443, 0.948066353128621, -0.0573107557817889)),
      draw(unitsphere, green),
      draw(apply(shift(2, 0, 0), unithemisphere), palegreen),
      draw(apply(shift(0, 2, 0), unitcone), palegreen),
      draw(apply(shift(0, 0, -2), unitsolidcone), palegreen),
      limits((-2, -2, -2.5), (3.4, 3.3, 1.5)),
      xaxis3($x$, Arrow3), yaxis3($y$, Arrow3), zaxis3($z$, Arrow3),
    )
  ],
  fig[fig_ua02 : `unitcube`, `unitcylinder`, `unitdisk`, `unitplane`][
    #picture(size: 5.5cm,
      projection: perspective(camera: (4.53371578035063, 6.12745948340995, 5.70601516082761),
        up: (0.000619140254556352, -0.0150578483347696, 0.0142075032912145),
        target: (1.04450822437829, 0.602473887294338, 0.00241466111189625)),
      draw(unitcube, green),
      draw(apply(shift(2, 0, 0), unitcylinder), palegreen),
      draw(apply(shift(0, 2, 0), unitdisk), paleblue),
      draw(apply(shift(0, 0, -2), unitplane), palered),
      limits((-2, -2, -2.5), (3.4, 3.3, 1.5)),
      xaxis3($x$, Arrow3), yaxis3($y$, Arrow3), zaxis3($z$, Arrow3),
    )
  ],
  fig[fig_ua03 : `unitfrustum(0.5,1)`, `(2,3)`, `(4,6)`][
    #picture(size: 5.5cm,
      projection: perspective(camera: (10.0727817501153, 3.74298428635732, 8.52398607861811),
        up: (-0.0297367955490125, -0.00628656900952393, 0.0232777528581501),
        target: (2.23313907154483, 2.16099419927418, -1.91821818048332)),
      draw(unitfrustum(0.5, 1), blue),
      draw(unitfrustum(2, 3), white),
      draw(unitfrustum(4, 6), red),
      limits((-2, -2, -2.5), (3.4, 3.3, 1.5)),
      xaxis3($x$, Arrow3), yaxis3($y$, Arrow3), zaxis3($z$, Arrow3),
    )
  ],
)
