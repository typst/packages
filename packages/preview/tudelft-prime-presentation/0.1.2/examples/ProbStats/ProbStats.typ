#import "@preview/tudelft-prime-presentation:0.1.2": * 
#import "@preview/pinit:0.2.2": *

#show math.equation: set text(font : "Lete Sans Math") 

#let green_highlight_color = rgb(108, 194, 74, 50)
#let green_arrow_color = rgb(108, 194, 74)

#set math.mat(delim: "[")
#set math.vec(delim: "[")
#set enum(spacing: 1em, indent: 1em)
#set list(spacing: 1.2em, indent: 1em)

#set math.mat(column-gap: 1em)


#show: prime-slides.with(
    //config-common(show-notes-on-second-screen: bottom),
    title: "Probability and Statistics: Lecture 11",
    subtitle: "Hypothesis Testing",
    background : "background/background.png", // Courtesy of Nelson Chan
    logo : "ProbStats/Logos/logo_dice.png",
)

== Programme
#programme_slide(book_sections: (25,26.1,26.2,27.1,27.2))[
 - Hypothesis testing
 - Test statistic and $p$-value
 - Asymptotic test for a proportion
 - $t$-test for the mean
]

#new-section-slide(slide-type: "probstats", subtype: "models")[Hypothesis Testing]

== Hypothesis Testing
#slide(slide-type: "models", subtype: "polling")[
    At a party you want to test whether tapping a can of soda makes the drink less likely to 'foam over'. Let $p_#text("tap")$ and $p_#text("no tap")$ be the respective probabilities of foaming over for tapping and not tapping a can. What is your null hypothesis and what is your alternative hypothesis?

    #poll_answers(correct_answer: 1, cols: 1)[
        1. $H_0 : p_#text("tap") = p_#text("no tap")$, $H_1 : p_#text("tap") < p_#text("no tap")$
        2. $H_0 : p_text("tap") < p_text("no tap")$, $H_1 : p_text("tap") = p_text("no tap")$
        3. $H_0 : p_text("tap") > p_text("no tap")$, $H_1 : p_text("tap") = p_text("no tap")$
        4. $H_0 : p_text("tap") = p_text("no tap")$, $H_1 : p_text("tap") > p_text("no tap")$
    ]

    #speaker-note[
        - $H_0$ is the default setting: the action of tapping a can has no influence on its probability to foam over.
        - $H_1$ is what you are seeking evidence for: the probability to foam over has reduced after the tapping.

        The idea is that tapping releases gas bubbles from the side and the bottom and brings them to the top, so that opening the can does not lead to gas that rushes through the fluid.
    ]
]

== Introduction: what is a statistical test?
#slide( slide-type: "models", subtype: "discussion")[
You have two hypotheses $H_0$ and $H_1$ and you would like to test \
whether the unknown data generating process satisfies $H_0$ or $H_1$, \
The goal is to find enough evidence to be sure to reject $H_0$. \
\
Can you think of an example of $H_0$ and $H_1$?

#speaker-note[
Lots of possibilities: Is group A (e.g. Dutch) taller than group B, does group A study for more years than group B, does group A have an average IQ of 100, is my six-sided die fair, etc. You can let students think about this in groups, or just ask if anyone has any ideas.
]
]


== The three steps of hypothesis testing
#slide(slide-type: "models")[

    1. Formulate $H_0$ and $H_1$
    2. Do the experiment
    3. Calculate whether results justify rejecting $H_0$

    #grid(
        columns: 2,
        inset: .3em,
        rows: 3*(25pt),
        align: center + horizon,
        row-gutter: .5em,
        column-gutter: .5em,
        grid.cell(
            colspan : 2, 
            fill: MOOCblue,
            align: center,
            text("Results:", fill : tudelft-colors.neutral-lightest)
        ),
        grid.cell( fill : MOOCblue,
            block[
                #set text(fill: tudelft-colors.neutral-lightest )
                Do not reject $H_0$]
        ),
        grid.cell( fill : MOOCblue,
            block[
                #set text(fill: tudelft-colors.neutral-lightest )
                Reject $H_0$
            ]
        ),
        grid.cell( fill : MOOCGray,
            block[Insufficient evidence to support $H_1$]
        ),
        grid.cell( fill : MOOCGray,
            block[$H_1$ true "beyond reasonable doubt"]
        )
    )

    #speaker-note[
        Slide from prelecture. Please explain that we are going to compute whether or not $H_0$ has to be rejected. Part 1. has been explained in prelecture and Part 2. is outside the scope of this course.
    ]
]

== Reasoning: checking defective proportion
#slide(slide-type: "models")[
  A manufacturer of integrated circuits claims that 1% of its integrated circuits are defective. Based on previous experiences with this manufacturer you think the defective proportion is higher.\
  Therefore, you want to test the manufacturer’s claim.

  Let $theta$ be the unknown ‘true’ defective proportion. \
  What would you choose as $H_0$ and $H_1$?

  #gray_block()[
    The appropriate hypotheses are: \
    #h(1cm)$H_0 : theta = 0.01$\
    #h(1cm)$H_1 : theta > 0.01$
  ]

  #speaker-note[
    $theta$ was chosen as probability symbol to avoid confusion with the $p$-value which we will also cover in this example setting.
  ]
]

#new-section-slide(slide-type: "probstats", subtype : ("probability", "models"))[Type I and Type II errors]

== Type I and Type II errors
#slide(slide-type : "models")[

  #place(dx:12.89cm, dy:0cm,[
    Our decision based on the test
  ])
  #place(dx: 14.89cm,dy: 0.3cm,rotate(45deg,common_icons.arrow_down))
  #place(dx: 22.89cm,dy: 0.3cm,rotate(-45deg,common_icons.arrow_down))
  #place(dx: -4cm, dy: 10cm, rotate(-90deg, [True state of nature]))
  #place(dx: 1.4cm,dy: 11cm,rotate(-45deg,common_icons.arrow_down))
  #place(dx: 1.4cm,dy: 7cm,rotate(-140deg,common_icons.arrow_down))
  \
  \ 
  #grid(
    rows: 4 * (25pt),
    columns : (.3fr,.5fr, 1fr, 1fr),
    inset: .3em,
    align: center + horizon,
    row-gutter: .3em,
    column-gutter: .2em,
    [],[],
    grid.cell( fill : MOOCblue,
            block[
                #set text(fill: tudelft-colors.neutral-lightest )
                Do not reject $H_0$]
    ),
    grid.cell( fill : MOOCblue,
            block[
                #set text(fill: tudelft-colors.neutral-lightest )
                Reject $H_0$]
    ),
    [],
    grid.cell( fill : MOOCblue,
            block[
                #set text(fill: tudelft-colors.neutral-lightest )
                $H_0$ is true]
    ),
    grid.cell( fill : MOOCGray,
            block[Correct]
    ),
    grid.cell( fill : MOOCGray,
            block[Type I error]
    ),
    [],
    grid.cell( fill : MOOCblue,
            block[
                #set text(fill: tudelft-colors.neutral-lightest )
                $H_1$ is true]
    ),
    grid.cell( fill : MOOCGray,
            block[Type II error]
    ),
    grid.cell( fill : MOOCGray,
            block[Correct]
    ),
  )
  #speaker-note[
    Mention that whether $H_0$ is true or $H_1$ is true is not decided by the test nor random!
  ]
]

== Introduction: Type I and Type II errors
#slide(slide-type: "models", subtype: "polling")[
  You went to a party and drank some beers. On your way home, the police stop you for an alcohol check. According to the breath analyzer you are sober and the police let you go. What kind of error are the police making?

  #poll_answers(
    cols: 1,
    correct_answer: 2
  )[
    1. Type I
    2. Type II
    3. The police didn't make an error
    4. I can not tell from the information I have so far
  ]
  #speaker-note[
    B: null hypothesis is the default, i.e. you are innocent. The police seek evidence for the contrary. Hence $H_1$ is actually true, but the police do not reject $H_0$: a type II error.
  ]
  
]

== Significance Level
#slide(slide-type : "probability")[
  #definition()[The #underline[significance level] $alpha$ is the largest acceptable probability of committing a type I error.
  ]
\
  We speak  of "performing the test at level $alpha$", as well as "rejecting $H_0$ in favor of $H_1$ at level $alpha$".
]

== Significance Level
#slide(slide-type: "probability")[

  #grid(
    rows: 4 * (16pt),
    columns : (.1fr,.5fr, 1fr, 1fr),
    inset: .2em,
    align: center + horizon,
    row-gutter: .2em,
    column-gutter: .2em,
    [],[],
    grid.cell( fill : MOOCblue,
            block[
                #set text(fill: tudelft-colors.neutral-lightest )
                Do not reject $H_0$]
    ),
    grid.cell( fill : MOOCblue,
            block[
                #set text(fill: tudelft-colors.neutral-lightest )
                Reject $H_0$]
    ),
    [],
    grid.cell( fill : MOOCblue,
            block[
                #set text(fill: tudelft-colors.neutral-lightest )
                $H_0$ is true]
    ),
    grid.cell( fill : MOOCGray,
            block[Correct]
    ),
    grid.cell( fill : MOOCGray,
            block[Type I error]
    ),
    [],
    grid.cell( fill : MOOCblue,
            block[
                #set text(fill: tudelft-colors.neutral-lightest )
                $H_1$ is true]
    ),
    grid.cell( fill : MOOCGray,
            block[Type II error]
    ),
    grid.cell( fill : MOOCGray,
            block[Correct]
    ),
  )
  Significance level of the test:\
  $alpha = P_H_0(text("reject"), H_0) = P_H_0("type I error")$\
  \
  We would like $alpha$ to be small, i.e., close to 0.\
  Example: $alpha = 0.05$.
]

#new-section-slide(slide-type: "probstats", subtype : ("estimation","probability","models"))[$t$-test for the mean]


== Reasoning: error and p-value
#slide(slide-type : "probability", subtype: "polling")[
  Consider the following two statements:
  
  1. A Type II error occurs if $H_0$  is falsely rejected.
  2. The $p$-value is the probability that $H_0$ is true.

  Which statement is/are true?

  #poll_answers(correct_answer : 1, cols : 1)[
    1. None
    2. Only 1
    3. Only 2
    4. Both
  ]
]

== Introduction: hypothesis testing for a proportion
#slide(slide-type: "models", subtype : "discussion", title-size: 33.5pt)[
  Last year, $15%$ of voters voted for the P&S party. This year, there will be another election. You wonder if this proportion has #pin("h1")changed#pin("h2"). You organize a poll, asking $n=1000$ people whether they intend to vote P&S (yes/no). We want to test $H_0: p=0.15$ against #pin("h3")$H_1: p eq.not 0.15$#pin("h4").\
  Suppose out of $1000$ people, $177$ say they intend to vote P&S.

  Call $X$ the number of people who answered yes.\
  *Question 1:* Assuming $H_0$, what is the distribution of $X$?

  #pause
  #pinit-highlight("h1", "h2",fill: green_highlight_color, stroke: 4pt + green_arrow_color,)
  #pinit-highlight("h3", "h4",fill: green_highlight_color ,stroke: 4pt + green_arrow_color)
  //#pinit-point-from(("h3","h4"),pin-dy: -25pt,offset-dx: 130pt,offset-dy: -60pt, fill: green_arrow_color, thickness: 5pt)[]
  #pinit-arrow("h2","h4", thickness: 5pt,fill : green_arrow_color)
  
]


#title-slide(title: "See you next lecture", subtitle: "")[]

