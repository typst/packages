#import "global.typ": *

= Background

#lorem(45)

#todo(
  [
  In the background section you might give explanations which are necessary to
  read the remainder of the thesis. For example define and/or explain the terms
  used. Optionally, you might provide a glossary (index of terms used with/without
  explanations).

  *Hints for equations in Typst*:

  Mathematical formulars are (embedded in `$`) in Typst. For example:

  The notation used for #textbf([calculating]) of #textit([code performance]) might
  typically look like shown in @eq:performance, i.e. the first one for *slow* in
  @slow and the other one for *very slow* in @veryslow.

  #figure(
    kind: math.equation, align(left, [
      #set math.equation(numbering: "(I)", supplement: [Eq.])
      $ O(n) = n^2 $ <slow>
      $ O(n) = 2^n $ <veryslow>
    ]), caption: flex-caption([Equations calculste the performance.], [Performance.]),
  ) <eq:performance>

  #figure(
    kind: math.equation, align(
      left, [
        In the text we refer multiple times to $phi.alt$. We define it to be calcultated
        as shown here:
        #set math.equation(numbering: "(I)", supplement: [Eq.])
        $ d := 7 - sqrt(3) $ <diff>
        $ phi.alt := d / 3 $ <ratio>
      ],
    ), caption: flex-caption(
      [A custom definition of $phi.alt$ allows to shorten upcoming equations.], [Phi defined in two steps.],
    ),
  ) <eq:phidef>

  The @eq:phidef explains (for the single steps see @diff and @ratio) how the
  overall $phi.alt$ is calculated to be used in the upcoming formulars of this
  thesis.

  ],
)
