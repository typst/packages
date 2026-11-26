#import "utils.typ" as ut

/// A list of lang tag settings for common languages.
#let pre-lang-tag-config = (
  (
    ("typ", "typst", "typc", "typm"),
    (icon: image("../styling/icons/typst.png")),
  ),
  (("js", "javascript"), (icon: image("../styling/icons/javascript.svg"))),
  (
    ("html", "htm", "shtml", "xhtml"),
    (icon: image("../styling/icons/html.svg")),
  ),
  (("css",), (icon: image("../styling/icons/css.svg"))),
  (("sql",), (icon: image("../styling/icons/sql.svg"))),
  // Website: https://python.org/
  (
    ("py", "py3", "pyw", "pyi", "pyx", "pxd", "pxi", "rpy", "cpy", "python"),
    (icon: image("../styling/icons/python.svg")),
  ),
  // Website: https://www.gnu.org/software/bash/
  (("sh", "bash", "zsh", "ash"), (icon: image("../styling/icons/bash.svg"))),
  // Website: https://www.typescriptlang.org/
  (("typescript", "ts"), (icon: image("../styling/icons/typescript.svg"))),
  // Website: https://dotnet.microsoft.com/en-us/languages/csharp
  (("cs",), (icon: image("../styling/icons/csharp.svg"))),
  // Website: https://isocpp.org/
  (("cpp",), (icon: image("../styling/icons/cpp.svg"))),
  (("c",), (icon: image("../styling/icons/c.svg"))),
  (("php",), (icon: image("../styling/icons/php.svg"))),
  (("go",), (icon: image("../styling/icons/go.svg"))),
  // Website: https://rustfoundation.org/
  (("rs", "rust"), (icon: image("../styling/icons/rust.svg"))),
  // Website: https://ocaml.org/
  (("ocaml", "ml"), (icon: image("../styling/icons/ocaml.svg"))),
  // Website: https://rocq-prover.org/
  (("rocq",), (icon: image("../styling/icons/rocq.svg"))),
)

#let lang-tag-config = ut.keys-value-to-dict(pre-lang-tag-config)
