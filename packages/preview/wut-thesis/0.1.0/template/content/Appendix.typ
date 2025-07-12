#import "../utils.typ": todo, silentheading, flex-caption
#import "@preview/cheq:0.1.0": checklist

#show: checklist

#heading[Supplementary Material]<supplementary>

#todo[Replace this with your appendix (not the organ)!]


#silentheading(2)[Introduction]
Thank you for participating in this survey. Your responses will help us understand how feline manipulation tactics affect human behavior. Please answer the following questions based on your experiences with your cat(s).

+ Frequency of Observed Behaviors

  - How often does your cat meow to get your attention?

    - [ ] Rarely
    - [ ] Occasionally
    - [ ] Frequently
    - [ ] Very frequently

  - How often does your cat purr to get your attention?

    - [ ] Rarely
    - [ ] Occasionally
    - [ ] Frequently
    - [ ] Very frequently

  - How often does your cat bring objects (e.g., toys) to you?

    - [ ] Rarely
    - [ ] Occasionally
    - [ ] Frequently
    - [ ] Very frequently

+ Effectiveness of Behaviors

  - How effective do you find meowing in getting your cat's needs met?

    - [ ] Not effective
    - [ ] Slightly effective
    - [ ] Moderately effective
    - [ ] Very effective

  - How effective do you find purring in calming or eliciting a positive response from you?

    - [ ] Not effective
    - [ ] Slightly effective
    - [ ] Moderately effective
    - [ ] Very effective

  - How effective is bringing objects (e.g., toys) in initiating play sessions or interaction?

    - [ ] Not effective
    - [ ] Slightly effective
    - [ ] Moderately effective
    - [ ] Very effective

+ Impact on Routines and Emotions

  - How has your cat's behavior affected your daily routine?

    - [ ] No impact
    - [ ] Minor impact
    - [ ] Moderate impact
    - [ ] Significant impact

  - How do you generally feel when your cat uses manipulation tactics?

    - [ ] Frustrated
    - [ ] Amused
    - [ ] Indifferent
    - [ ] Affectionate

+ Additional Comments
  - Please provide any additional comments or experiences related to your cat's manipulation tactics.

#heading[Interview Guide]

#silentheading(2)[Introduction]

Thank you for agreeing to participate in this interview. The following questions are designed to gather detailed insights into your experiences with your cat's behavior. Feel free to elaborate on your answers as much as you like.

+ Instances of Manipulation
  - Can you describe a specific instance where your cat used manipulation tactics to achieve something?
  - How did you respond to this behavior?

+ Emotional Responses
  - How did you feel during and after the manipulation?
  - Did the behavior change your emotional state or relationship with your cat?

+ Behavioral Changes
  - Have you made any changes to your routine or behavior in response to your cat's manipulation?
  - How have these changes affected your interactions with your cat?

+ General Impressions
  - What do you think about the manipulation tactics used by your cat?
  - Are there any particular behaviors you find especially effective or challenging?

+ This is a cat:
  #figure(image("../images/cat1.png", width: 60%), caption: [Example of a cat])<appendix_image>

+ This is a table:
  #let ofi = [Office]
  #let rem = [_Remote_]
  #let lea = [*On leave*]

  #show table.cell.where(y: 0): set text(
    fill: white,
    weight: "bold",
  )

  #figure(
    table(
      columns: 6 * (1fr,),
      align: (x, y) => if x == 0 or y == 0 { left + horizon } else { center + horizon },
      stroke: (x, y) => (
        // Separate black cells with white strokes.
        left: if y == 0 and x > 0 { white } else { black },
        rest: black,
      ),
      fill: (_, y) => if y == 0 { black },

      table.header(
        [Team member],
        [Monday],
        [Tuesday],
        [Wednesday],
        [Thursday],
        [Friday],
      ),
      [Evelyn Archer],
      table.cell(colspan: 2, ofi),
      table.cell(colspan: 2, rem),
      ofi,
      [Lila Montgomery],
      table.cell(colspan: 5, lea),
      [Nolan Pearce],
      rem,
      table.cell(colspan: 2, ofi),
      rem,
      ofi,
    ),
    caption: [Example of a table],
  )
