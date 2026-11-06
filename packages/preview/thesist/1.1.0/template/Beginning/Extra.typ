// Example optional page
#{
  set text(size: 12pt)

  v(25%)

  align(right,
    box(width: 75%,
      [
        _#lorem(20)_
        #linebreak()
        #linebreak()
        --- Lorem I. Dolor
      ]
    )
  )

  align(bottom+center,
    [
      This work was created using the Typst typesetting language.
    ]
  )

  v(10%)
}

// Example preface - USE ONLY IF REQUIRED
= Preface

The work presented in this thesis was performed at the [DEPARTMENT / CENTER] of [INSTITUTION] ([CITY], [COUNTRY]), from [MONTH, YEAR] to [MONTH, YEAR], under the supervision of [LOCAL SUPERVISORS], and within the frame of the [PROGRAM]. The thesis was co-supervised at Instituto Superior Técnico by [SUPERVISOR].
