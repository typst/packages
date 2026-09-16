#import "../index.typ": template, tufted
#show: template

= Iterators vs Generators in Python

Python's iteration protocols are fundamental to writing efficient, Pythonic code.#footnote[The iterator protocol was introduced in Python 2.2 (2001) as part of PEP 234.] While iterators and generators are closely related, understanding their differences helps you choose the right tool for the job.

== What Are Iterators?

An iterator is any object that implements the iterator protocol: the `__iter__()` and `__next__()` methods.#footnote[An _iterable_ returns an iterator when you call `__iter__()` on it, while an _iterator_ returns itself from `__iter__()` and produces values via `__next__()`.] When you loop over a list or tuple, Python creates an iterator behind the scenes. You can also build custom iterators by defining these methods in a class.

```python
class Counter:
    def __init__(self, max):
        self.max = max
        self.current = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self.current >= self.max:
            raise StopIteration
        self.current += 1
        return self.current
```

== Enter Generators

Generators are a simpler way to create iterators using functions and the `yield` keyword.#footnote[Python also supports generator expressions like `(x*2 for x in range(10))`, which are similar to list comprehensions but create generators instead of lists.] Instead of maintaining state in class attributes, generators automatically preserve state between calls. This makes them more concise and often easier to read.

```python
def counter(max):
    current = 0
    while current < max:
        current += 1
        yield current
```

The generator function produces the same results as our iterator class, but with far less boilerplate.#footnote[Generators preserve their state in local variables and execution position, making them essentially resumable functions.] When you call a generator function, it returns a generator object that implements the iterator protocol automatically.

== Memory Efficiency

Both iterators and generators are lazy—they produce values on demand rather than storing them all in memory. This makes them ideal for working with large datasets or infinite sequences.#footnote[The `itertools` module provides powerful functions like `count()` and `cycle()` that create infinite iterators.] A generator that produces a billion numbers consumes minimal memory, while a list of a billion numbers would exhaust most systems.

#figure(image("imgs/python.webp"), caption: [Four people holding a long python])

== When to Use Each

Use generators for most cases—they're simpler and more readable. Reach for custom iterator classes when you need complex state management, multiple iterator methods, or when building reusable components that require more sophisticated behavior.

Understanding these tools unlocks more elegant solutions to common programming challenges.
