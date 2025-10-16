#import "@preview/tdtr:0.1.0" : *

#set page(flipped: true)

#tidy-tree-graph([
  - $integral_0^infinity e^(-x) dif x = 1$
    - `int main() { return 0; }`
      - Hello
        - This
        - Continue
        - Hello World
      - This
    - _literally_
      - Like
    - *day*
      - tomorrow $1$
])

#tidy-tree-graph(
  draw-edge: tidy-tree-draws.horizontal-vertical-draw-edge,
  [
  - Hello
    - World
      - How
        - Whats
          - Day
        - the
        - Time
          - Hello
            - World
              - How
                - Whats
                  - Day
                - the
                - Time
                  - Hello
      - This
      - Day
        - Hello
      - People
    - are
      - Hello
          - World
        - Day
          - Hello
          - World
          - Fine
          - I'm
          - Very
            - Happy
            - That
            - They
            - have
            - what
        - you
        - Byte
        - integer
        - Today
      - you
    - !
      - Fine
      - Day
      - You
        - World
        - This
    - Day One
      - doing
        - abcd
        - efgh
      - today
        - Tomorrow
        - Tomorrow
        - Tomorrow
    - Hello
      - Day
      - One
    - Fine
      - Hello
      - Fine
      - Day
    - Hello
])

#tidy-tree-graph(json("test.json"))
#tidy-tree-graph(yaml("test.yaml"))
