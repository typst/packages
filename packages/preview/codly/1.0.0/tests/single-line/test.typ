#import "../../codly.typ": *

#set page("a6")

#show: codly-init

= Default
```typst
Hello, world!
```

= Disabled
#codly-disable()
```typst
Hello, world!
```

= Re-enabled
#codly-enable()
```typst
Hello, world!
```

= No line numbers
#codly(number-format: none)
```typst
Hello, world!
```

= No language icon
#codly(lang-format: none)
```typst
Hello, world!
```

= With annotation
#codly(annotations: ((start: 0, content: "Hello, world!"), ))
```typst
Hello, world!
```

= With annotation & lang icon
#codly(lang-format: auto)
#codly(annotations: ((start: 0, content: "Hello, world!"), ))
```typst
Hello, world!
```

= With highlight
#codly(highlights: ((line: 0, tag: "Hello, world!"), ))
#codly(inset: 0.5pt)
```typst
Hello, world!
```

= Locally disabled
#local(enabled: false)[
  ```typst
  Hello, world!
  ```
]

= With large inset
#codly(inset: 10pt)
```typst
Hello, world!
```

= With small inset
#codly(inset: 0.5pt)
```typst
Hello, world!
```

= Wrap-around line
#codly-reset()
#codly(languages: (py: (name: "Python", icon: "Sss ", color: rgb("#4584b6")), ))
```py
# Example code that calculates the sum of the first 10 natural numbers squares
```