#import "@preview/lacy-ubc-math-project:0.2.0": *
// Import the user config, including author information.
#import "config.typ": *
// Import markscheme as "m" so it is easier to type, then markit so it is easier to call (no need of "m.markit").
#import markscheme as m: markit
#set page(foreground: m.foreground-marking)

#show: setup.with(
  group: group-name,
  // Non-default config from config.typ
  config: (
    theme.ubc-light,
    config,
  ),
  // In config.typ, we set up these author information.
  alex-conquitlam,
  // Say, Jane was not participating, so we add a prefix and a suffix to indicate that.
  jane-doe[MISSING: ][NP],
  // /* Or, suffix only: */ jane-doe[NP],
  // Learn more about adding prefix and suffix in the manual.
)

// Below is your project content.

= The Problem

#qns(
  question(
    point: 5,
    [
      Hey, there's a cool math problem, let's solve it!
      // Encapsulate important visuals in figures,
      // so that they can be referenced later.
      #figure(
        // Include images from the assets folder.
        image(
          "assets/madeline-math.jpg",
          width: 80%,
          height: 25%,
          fit: "stretch",
        ),
        // Description.
        // Don't forget to give credit while using others' work.
        caption: [
          Madeline's math problem (image credit: #link("https://example.com")[Badeline]).
        ],
      )
    ],

    solution(label: "fair")[
      #markit(m.r(2)[this is a marking])[
        You can do it. By this reasoning I get 2 points, and I am labeled ```typ <sn:fair>```!
      ]
    ],
  ),
  question(
    [
      I do not have a point myself, but my sub-question have point, and I get the sum of theirs!
    ],
    question(
      point: 1,
      [The point is...],
      solution(
        [
          ...that you try solving @qs:1 (```typ @qs:1```), learn something along the way.
        ],
        question(
          point: 99,
          [
            I am worth 99 points, but my parent question had explicitly stated that it is worth 1 point.
          ],
          solution[
            The marking of @sn:fair[that] (```typ @sn:fair[that]```) sure sounds fair.
          ],
        ),
      ),
    ),
    question(
      [
        Take a look at the #link("https://github.com/lace-wing/lacy-ubc-math-project/blob/master/manual.pdf")[manual] there if you are lost or want advanced stuff!
      ],
      solution[
        $
          #markit(m.c(6), $42^T$) #<eq:me>
        $
      ],
    ),
  ),
)

