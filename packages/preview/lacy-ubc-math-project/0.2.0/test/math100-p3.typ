#import "@preview/lacy-ubc-math-project:0.2.0": *
#import markscheme as m: markit
#import drawing: *

#import "config.typ": *
#import theme: ubc-light

#show: setup.with(
  number: 3,
  group: group-name,
  jane-doe,
  alex-conquitlam[(NP)],
  config: ubc-light
)

#let rule = {
  v(0.2em)
  line(length: 100%, stroke: 0.4pt)
}

#let submarine = "noun-submarine-7265824.png"

_In this project, you will see how power function dominance can be used to gain insights into a biological model. You'll practice critical thinking skills, and doing algebra with parameters (unknown constants)._

Your group submission must be typed, and marks will be awarded for communication (see Canvas assignment).

*Learning objectives:*
- Be able to solve relates rates questions using the chain rule.
- Interpret derivatives in the context of a model.
- Apply mathematical concepts to models of physical processes.
- Practice the skill of using parameters rather than specific numbers in mathematical expressions.
- Be able to clearly and effectively communicate mathematical content in prose.

#rule

= Contributors

On the first page of your submission, list the student numbers and full names (with the last name in *bold*) of all team members.

After submitting this assignment, you will provide feedback on your teammates' contributions using iPeer. If there is zero contact with a group member, please mark NP (for 'non-participating') beside their name in this list, and award a 0 on iPeer.

#rule

= Reflection question

At this point in the course, having written the first test and completed a pair of assignments, it is appropriate to take stock of your habits. The following simple survey generates an individual score.

- _For the past five weeks, I have done deliberate problem-solving practice for one hour a day, six days a week._

  If this is true, give yourself 10 points. Otherwise, give yourself 0 points.

- _For the past five weeks, I have attended all small classes (except in cases of illness or emergency)._

  If this is true, give yourself 4 points. If you have missed one small class, give yourself 1 point. Otherwise, give yourself 0 points.

- _For the past five weeks, I have attended all lectures (except in cases of illness or emergency)._

  If this is true, give yourself 4 points. If you have missed one lecture, give yourself 1 point. Otherwise, give yourself 0 points.

- _For the past five weeks, I have started all assignments at least 5 days before the due date._

  If this is true, give yourself 3 points. If it is true in all but one case, give yourself 1 point. Otherwise, give yourself 0 points.

What is the average score of your team members? (Be honest with yourselves; no points will be awarded based on what this average score is.) In one or two paragraphs, describe at least two concrete steps you can take to help each other raise that score.

#qns(
  config: (
    solution: (
      container: defaults.solution.container.with(markscheme: true),
    ),
  ),
  solution[
    #markit(m.c(2))[Individual scores:
      - ???
      - ???
      - ???
      - ???
      Average: ?
    ]

    #markit(lorem(122), m.c(3))

    #markit(lorem(98), m.c(4))
  ],
)


= Assignment questions

#qns(
  question(
    [
      An elastic tube is being stretched so that its diameter grows while its length stays the same. Initially, its inner radius is 1cm and the thickness of the material making up the tube is 1 cm.
      #{
        set align(center)
        cetz.canvas({
          import cetz.draw: *
          scale(80%)

          let cyc1 = (x: 2, y: -2)
          let cyc2 = (x: 12, y: -2)
          let fill = (fill-top: std.gray.lighten(80%), fill-side: std.gray.lighten(80%))

          cylinder(cyc1, (4, 1), 2cm, ..fill)
          circle(cyc1, radius: (2, .5), fill: white)
          line(cyc1, (4, -2), mark: (symbol: "|"), name: "r")
          content("r.mid", anchor: "south", padding: .07, text(size: 0.8em, fill: blue)[1 cm])
          line((4, -2), (6, -2), mark: (symbol: "|"), name: "R")
          content("R.mid", anchor: "south", padding: .07, text(size: 0.8em, fill: red)[1 cm])
          content((cyc1.x, cyc1.y - 3.5), [initial])

          cylinder(cyc2, (5, 1), 2cm, ..fill)
          circle(cyc2, radius: (4, .5), fill: white)
          content((cyc2.x, cyc2.y - 3.5), [stretched])
        })
      }

      The tube maintains a cylindrical shape as it stretches. The material making up the tube deforms in such a way that the thickness of the tube (i.e. the difference between the outer radius and the inner radius) is always inversely proportional to the inner diameter. That is, if the tube has thickness $x(t)$ and inner diameter $d(t)$ (both of which change with time, $t$), then
      $ x(t) = c / d(t) $
      for some constant $c$.

      At a certain time $t_0$, the inner diameter is growing at a rate of 2 centimetres per second, and the inner diameter is 3 cm.
    ],
    question(
      point: 2,
      [
        How fast is the thickness of the tube changing at time $t_0$?
      ],

      solution[
        Known that $d(t_0) = qty("3", "cm"), d'(t_0) = qty("2", "cm/s")$, we can differentiate $x(t_0)$ in respect to $t$:
        $
          x'(t_0) &= - c / d(t_0)^2 dot d'(t_0), \
          &= -c / 3^2 dot 2 \
          &= - (2c) / 9 space unit("cm/s").
        $
        Therefore, thickness of the tube, is changing at $- (2c) / 9 space unit("cm/s")$ at time $t_0$.
      ],
    ),

    question(
      point: 3,
      label: <rate>,
      [
        Calculate the rate of change of the volume of the material making up the tube at time $t_0$ if the length of the tube is $ell$ centimetres. (Note: this is typeset in Typst as `ell`.)
      ],

      solution[
        Let volume be $V$,
        $
          V(t_0) &= pi ell [ ( d(t_0) / 2 + x(t_0) )^2 - ( d(t_0) / 2 )^2 ].
        $
        Differentiate $V$ in respect of $t$:
        $
          &#hide[\= ] V'(t_0) \ &= pi ell [ 2 ( d(t_0) / 2 + x(t_0) ) ( 1 / 2d'(t_0) - c / d(t_0)^2 d'(t_0) ) - 2( d(t_0) / 2 ) 1 / 2 d'(t) ] \
          &= 2pi ell [ ( d(t) / 2 + x(t) ) ( 1 / 2d'(t) - c / d(t)^2 d'(t) ) - d(t) / 2 dot 1 / 2 d'(t) ].
        $
        $t = t_0$, so $d(t) = 3, d'(t) = 2, x(t) = c / 3$, substitute them into the equation:
        $
          V'(t) &= 2pi ell [ ( 3 / 2 + c / 3 ) times ( 1 - (2c) / 9 ) - (3 / 2 times 2 / 2) ] \
          &= 2pi ell ( ( ( 9 + 2c) / 6 )times((9-2c) / 9)-3 / 2) \
          &= 2pi ell ((81-4c^2) / 54 -3 / 2 ) \
          &= (pi ell (-8c^2)) / 54 unit("cm^3/s")
        $
        Therefore volume of the tube grows at $-(4pi ell c^2) / 27 unit("cm^3/s")$ at time $t_0$.
      ],
    ),

    question(
      [
        Finally, assume that the tube has the mass $2$ grams, which is constant. The density of the material making up the tube is found by dividing its mass by its volume.
      ],

      question(
        point: 1,
        [
          Based on the sign of your answer from @rate, will the density be increasing or decreasing at time $t_0$? Give an explanation that doesn't involve actually calculating the derivative of the density.
        ],

        solution[
          The formula for density $rho$ is equal to mass $m$ divided by volume $V$. The sign of the rate of volume change was negative, meaning _the volume is decreasing at $t_0$_. The mass will be constant and not changing at all times, which means it has no effect on the sign of rate of change of density. Thus, the density will be increasing, as it is inversely related to the volume, which is decreasing.
        ],
      ),
      question(
        point: 2,
        [
          Calculate the rate of change of the density of the material making up the tube at the time $t_0$.
        ],

        solution[
          Density, $rho$, can be given by:
          $
            rho &= m / V \
            &= 2 / V,
          $
          where $V$ is volume and $m$ is mass.

          #align(
            center,
            {
              table(
                columns: (25%,) * 2,
                inset: .65em,
                stroke: ubc-light.solution.stroke-minor,
                align: center + horizon,
                $d(t_0)$, $x(t_0)$,
                $3$, $ c / 3 $,
              )
            },
          )

          We can find the value of Volume at $t_0$:
          $
            V &= pi ell [ ( d(t_0) / 2 + x(t_0) )^2 - ( d(t_0) / 2 )^2 ] \
            &= pi ell [ (3 / 2+c / 3)^2-(3 / 2)^2 ] \
            &= pi ell [9 / 4+(6c) / 6+c^2 / 9-9 / 4]\
            &= pi ell (c^2 / 9 + c) unit("cm^3").
          $
          Differentiate both sides in respect to $t$, using chain rule:
          $
            dv(rho, t) &= - 2 / V^2 dot dv(V, t) \
            &= - 2 / (pi ell (c^2 / 9 + c))^2 times - (4pi ell c^2) / 27 \
            &= (8 pi ell c^2) / (27 (pi ell (c^2 / 9 + c)^2)).\
            &= 8 / (pi ell (c^2 / 3+6c+27)) unit("g/cm^3/s").
          $
        ],
      ),
    ),
  ),


  question(
    [
      Fluid in the centre of a pipe flows faster than fluid near the edges. Suppose the velocity $v$ of fluid is given by
      $ v = 1 / 16 (R^2 - r^2) $
      where $R$ is the radius of the pipe and $r$ is the distance of a layer of fluid from the centre of the pipe. We'll measure $R$ and $r$ in cm, and we'll measure $v$ in cm per second.
    ],

    question(
      [
        Imagine a remote-controlled toy submarine enters a hatch at the side of the pipe at time $t=0$. (So, its distance from the centre of the pipe at that time would be $R$.) As it flows along with the fluid, it propels itself straight through the centre of the pipe, to the other side.
      ],

      [#{
          set align(center)
          cetz.canvas({
            import cetz.draw: *

            let cc = (0, 0)
            let circle = circle.with(cc, stroke: 0.6pt)

            circle(radius: 2.5, name: "c")
            circle(radius: 2.45)
            content((-3.1, 0), image(submarine, width: 1cm), name: "s")
            line("s.east", "c.east", stroke: (dash: "dashed"))
          })
        }

        The submarine moves through the cross-section of the pipe (i.e. the path shown above) at a constant rate of $qty("5", "cm/s")$. That is, if $r$ is the submarine's distance from the centre of the pipe, $abs(dv(r, t)) = qty("5", "cm/s")$ over the entire domain of $dv(r, t)$.
      ],

      question(
        point: 1,
        [
          Give an explicit expression for $r$ in term of time, for the duration of the submarine's journey, if $R=40$ cm.
        ],

        solution[
          $ r = abs(40 - 5t) unit("cm") space.med (0 lt.eq t lt.eq qty("16", "s")) $
        ],
      ),

      question(
        point: 2,
        [
          Which image below best displays the path the submarine might take, and why?

          #let start = (x: 0, y: 2)
          #let sub-path(samples, size: (4, 4), domain: (-1, 1), paint: red) = {
            cetz.canvas({
              import cetz.draw: *
              import cetz-plot: *

              plot.plot(
                size: size,
                axis-style: none,
                name: "path",
                {
                  plot.add-anchor("left", (-1, 0))
                  plot.add(domain: domain, samples, style: (stroke: (paint: paint, dash: "dashed")))
                },
              )

              set-origin("path.left")
              group({
                rotate(90deg)
                cylinder((0, 0), (2, 1), 4cm)
              })
              content((start.x - .5, start.y + .5), angle: -45deg, image(submarine, width: 1cm))
            })
          }

          #enum(numbering: "A.")[
            #sub-path(x => (-2 * calc.pow(x, 3)), paint: blue)
          ][
            #sub-path(size: (4.37, 3.75), x => -x)
          ][
            #sub-path(x => -calc.root(x, 3))
          ]
        ],
        solution[
          A. The submarine is heading to the other side of the pipe, but also drifting with the water flow in horizontal direction. The faster the stream is, the more horizontal the path of the submarine would be. Based on $v = 1 / 16 (R^2 - r^2)$, the velocity of the fluid is greatest when $r$ is smallest, in the centre of the cross sectional area, so graph A most accurately represents the path.
        ],
      ),

      question(
        point: 2,
        [
          Suppose $R=40$. How fast is the velocity of the fluid experienced by the submarine changing when it begins its journey, at $r=40$? What about when it's in the middle of its journey, at $r=0$?

          _Note:_ be careful with your work here, since $r(t)$ is not differentiable everywhere.
        ],

        solution[
          $
            cases(
              dv(r, t) = -5 quad&(t < 8),
              dv(r, t) = "DNE" quad&(t = 8),
              dv(r, t) = 5 quad&(t > 8),
            )
          $

          Substitute $R = qty("40", "cm")$ into velocity,
          $
            v &= 1 / 16 (40^2-r^2) \
            v &= 40^2 / 16 - r^2 / 16 \
          $
          Differentiate velocity with respect to time,
          $ dv(v, t) &= -r / 8 times dv(r, t) \ $
          1. At $r = qty("40", "cm")$, $t$ can be 0 or 16, one smaller than 8, the other greater than 8.
            $
              dv(v, t) &= -40 / 8 times plus.minus 5\
              &= plus.minus qty("25", "cm/s^2") \
            $

          2. At $r = qty("0", "cm")$, which $t = 8$, derivatives of each side of $t$ are:
            $
              cases(
                dv(v, t) = (5r) / 8 quad&(t < 8),
                dv(v, t) = -(5r) / 8 quad&(t > 8),
              )
            $
            Since $r$ is always positive when $t eq.not 8$, $(5r) / 8 > 0, -(5r) / 8 < 0$, meaning $v(8)$, as the only singularity/critical point, is the sole maxima. The rate of change of fluid velocity, $dv(v, t)$, should be $qty("0", "cm/s^2")$.

          Therefore, the rates of change of velocity experienced at $r = qty("40", "cm")$ is $plus.minus qty("25", "cm/s^2")$ and at $r = qty("0", "cm")$ is $qty("0", "cm/s^2")$.
        ],
      ),

      question(
        point: 1,
        [
          Would the submarine experience a more rapid fluid velocity when it was close to the edges of the pipe, or close to the centre? <given>
        ],

        solution[
          // As the fluid moves faster at the centre of the pipe and slower near the edges of the pipe, the submarine will experience a more rapid fluid velocity closer to the centre of the pipe than when it is close to the edges of the pipe.

          Based on @qs:2-a-iii /* #link(<qs:2:a:iii>)[part #numbering("i", 3)] */, $v(t)$ has only one maxima when $t = 8$, i.e. when the submarine is at the center of the pipe.
          Hence, the fluid velocity close to the center can only be more rapid than that close to the edges.
        ],
      ),

      question(
        point: 1,
        [
          Would the submarine experience a more rapid change in fluid velocity when it was close to the edges of the pipe, or close to the centre? <acc>
        ],
        solution[
          // By taking the derivative of $v=1/16 (R^2-r^2)$, we can find the change of rate in fluid density
          // $ dv(v, r) = -1/8r $
          // As the rate of fluid change depends on r, when fluid is at the centre of the pipe, $(r approx 0)$, there is a minimal rate of fluid velocity change. When fluid is at the edge of the pipe, there is a much ($r approx 40$), the rate of fluid change is much larger.

          $
            dv(v, t) &= -r / 8 times plus.minus 5, \
            abs(dv(v, t)) &= abs(- r / 8 times plus.minus 5) \
            &= (5r) / 8.
          $

          It's obvious that how fast the fluid velocity is changing #sym.prop $r$.

          Closer to the edges, bigger the $r$.
          Therefore, the submarine experienced a more rapid change in fluid velocity when it was close to the edges of the pipe.
        ],
      ),
    ),

    question(
      [
        Cold weather is causing a pipe to contract at a constant rate, say $dv(R, t) = - 1 / 10^6$ cm per second. Still, the velocity of fluid $r$ centimetres from the centre is given by $v = 1 / 16 (R^2-r^2)$.
      ],

      question(
        point: 1,
        [
          How fast is the velocity of the fluid $r$ cm from the centre changing when the radius of the pipe is $qty("40", "cm")$?
        ],

        solution[
          Start by finding the derivative of velocity, where $R$ is no longer constant:\
          $
            dv(v, t) &= 1 / 8R (dv(R, t)) -1 / 8r (dv(r, t)) \
          $Now substituting known values:$ abs(dv(v, t)) &= abs(1 / 8 40 (-1 / 10^6) - 1 / 8r (plus.minus 5))\
          &= -5 / 10^6 - 5 / 8r. $
          Therefore, the velocity of the fluid r cm from the centre at a radius of 40cm is changing at a rate of $-5 / 10^6 - 5 / 8r unit("cm/s^2")$.
        ],
      ),
      question(
        point: 1,
        [
          Is fluid closer to the centre experiencing a faster or slower change in velocity than fluid farther from the centre?
        ],
        solution[
          The previous part demonstrates that the change in velocity is proportional to -r. This means that as r increases, the change in velocity decreases, this means the fluid closer to the centre experiencing a larger change in velocity/acceleration.
        ],
      ),
    ),
  ),
)
