#import "@preview/typtorial:0.1.0": tutorial

#show: tutorial.with(
  title: [My first tutorial],
  abstract: [
    A short summary of what the reader will learn:

    - how to write a function that says hello,
    - and how to greet several names with it.
  ],
)

= Say hello

Every step starts with a heading. The explanation follows as normal text, and the code
of the step appears in the panel on the right.

```python hello.py
def greet(name):
    print(f"Hello, {name}!")

greet("you")
```

= Greet everyone

Show the whole file again in the next step. What changed since the previous step is
highlighted automatically: new lines in green, removed ones in red.

```python hello.py
def greet(name):
    print(f"Hello, {name}!")

for name in ["world", "Typst"]:
    greet(name)
```
