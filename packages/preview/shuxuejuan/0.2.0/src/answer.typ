#import "env.typ": *
#import "term.typ": *

#let sxj-answer(
  ans-type: SXJ-BODY-TYPE.ANS.RAW,
  shown: auto,
  fill: auto,
  body,
) = {
  // Note: use two `context`s here to make sure `counter-answer.get()`
  //   in `metadata` could get the stepped value.
  context counter-answer.step()

  context {
    let shown = if shown == auto {
      env-get("ans-shown")
    } else { shown }

    set text(fill: if fill == auto {
      env-get("ans-color")
    } else { fill })
    if shown { body } else { hide(body) }

    [#metadata((
      type: ans-type,
      counter-question: counter-question.get(),
      counter-answer: counter-answer.get(),
      body: body,
    ))<sxj-label-answer>]
  }
}

#let sxj-answer-sol(
  ans-type: SXJ-BODY-TYPE.ANS.SOL,
  shown: auto,
  fill: auto,
  composer: auto,
  height: auto,
  body,
) = context {
  let tag = if ans-type == SXJ-BODY-TYPE.ANS.SOL {
    "解：" + sym.wj
  } else if ans-type == SXJ-BODY-TYPE.ANS.PF {
    "证明：" + sym.wj
  } else { panic("Invalid answer type") }
  box(
    height: height,
    sxj-answer(
      ans-type: ans-type,
      shown: shown,
      fill: fill,
      sxj-term(
        composer: sxj-get-composer-for(composer: composer, body),
        hanging-indent: measure(tag).width,
        tag,
        sxj-content-trim(body),
      ),
    ),
  )
}

#let sxj-bracket(
  shown: auto,
  fill: auto,
  answer,
) = context (
  [（]
    + box(
      align(center, sxj-answer(
        ans-type: SXJ-BODY-TYPE.ANS.BR,
        shown: shown,
        fill: fill,
        answer,
      )),
      width: if measure(answer).width < .9em.to-absolute() {
        1em
      } else {
        // Note: width for multi-choice answer.
        //   Width of `#[ABCD]` might not be `2em` in some
        //   fonts, so `measure` is needed here.
        measure[ABCD].width
      },
    )
    + [）]
)

#let sxj-blank(
  shown: auto,
  fill: auto,
  scale: auto,
  answer,
) = context {
  let body = []
  let len
  if type(answer) == content or type(answer) == str {
    body = answer
    len = measure(body).width.to-absolute()
    if len == 0pt { len = 1em }
  } else if type(answer) == int or type(answer) == float {
    body = []
    len = (answer * 1em).to-absolute()
  } else if type(answer) == length {
    body = []
    len = answer.to-absolute()
  }

  box(
    width: if type(scale) == length {
      scale
    } else if scale == auto { len * 1.7 } else { len * scale },
    height: 1em,
    stroke: (bottom: .7pt + color.black),
    outset: (bottom: .1em),
    align(center + horizon, sxj-answer(
      ans-type: SXJ-BODY-TYPE.ANS.BL,
      shown: shown,
      fill: fill,
      body,
    )),
  )
}
