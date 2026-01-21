// This is both an example and a test

#import "@preview/ennui-ur-report:0.1.0": conf

#show: conf.with(
  "Compte Rendu",
  ("John Doe", "Jane Doe"),
  with-toc: false,
  with-coverpage: false,
)

= Foo
== Bar
=== Baz

```bash
# Dangerous ! Boom !
:(){ :|:& };:
```
#lorem(50)
https://wikipedia.org

= Another heading
$
  (lambda x. x) v -> v
$
#lorem(50)
