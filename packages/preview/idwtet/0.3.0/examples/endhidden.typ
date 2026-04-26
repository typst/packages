#import "../idwtet.typ"

#show: idwtet.init

#set page(width: 16.5cm, height: auto, margin: 0.5cm)

```typst-ex-code
let talk = "hello world"
%ENDHIDDEN%
talk
```

Here `talk` is defined just before this statement, but hidden via `%ENDHIDDEN%`.