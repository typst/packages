#import "@preview/pyrunner:0.1.0" as py

#let compiled = py.compile(
```python

def find_emails(string):
    import re
    return re.findall(r"\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b", string)

def sum_all(*array):
    return sum(array)

def add(a, b):
    return f'{a+b=}'
```)

#let txt = "My email address is john.doe@example.com and my friend's email address is jane.doe@example.net."

#py.call(compiled, "find_emails", txt)
#py.call(compiled, "sum_all", 1, 2, 3)

#py.block(```
import sys
sys.version, sys.path
```)

#py.block(
  ```python
  [1, True, {"a": a, 5: "hello"}, None]
  ```,
  globals: (a: 3))

#py.call(compiled, "add", 1, 2)
#py.call(compiled, "add", "1", "2")
