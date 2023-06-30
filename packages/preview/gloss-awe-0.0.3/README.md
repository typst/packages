# typst-glossary

Automatically create a glossary in [typst](https://typst.app/).

This typst component creates a glossary page from a given pool of potential glossary
entries using only those entries, that are marked with the `gls` or `gls-add` functions in
the document. See sample-usage document for details.

⚠️ Typst is in beta and evolving, and this package evolves with it. As a result, no
backward compatibility is guaranteed yet. Also, the package itself is under development
and fine-tuning.

## Marking the Entries

To include a term into the glossary, it can be marked with the `gls` function. The
simplest form is like this:

```typ
This is how to mark something for the glossary in #gls[Typst].
```

The function will render as defined with the specified show rule (see below!).


## Controlling the Show

To control, how the markers are rendered in the document, a show rule has to be defined. It usually looks like the following:

```typ
// marker display : this rule makes the glossary marker in the document visible.
#show figure.where(kind: "jkrb_glossary"): it => {it.body}
```

## Pool of Entries

The "pool of entries" is a typst dictionary. It can be read from a file, like in this
sample, or may be the result of other operations.

One or more pool(s) are then given to the `make-glossary()` function. This will create a
glossary page of all referenced entries. If given more than one pool, the order pools are
searched in the order they are given to the method. The first match wins. This can be used
to have a global pool to be used in different documents, and another one for local usage
only.

The pool consists of a dictionary of definition entries. The key of an entry is the term.
Note, that it is case-sensitive. Each entry itself is also a dictionary, and its main key
is `description`. This is the content for the term. There may be other keys in an entry in
the future. For now, it supports:

- description
- link

An entry in the pool for the term "Engine" file may look like this:

```typ
    Engine: (
        description: [

            In the context of software, an engine...

        ],
        link: [

            (1) Software engine - Wikipedia.
            https://en.wikipedia.org/wiki/Software_engine
            (13.5.2023).

        ]
    ),
```

The glossary pool used in the sample document can be found in the file `GlossaryPool.typ`.

### Unknown Entries

If the document marks a term that is not contained in the pool, an entry will be generated
anyway, but it will be visually marked as missing. This is convenient for the workflow,
where one can mark the desired entries while writing the document, and provide missing
entries later.

There is a parameter for the `make-glossary()` function named `missing`, where a function
can be provided to format or even suppress the missing entries.

## Creating the glossary page

To create the glossary page, provide the pool of potential entries. In this example, we
read it from a file. Then we give it to the `make-glossary()` function:

```typ
#import "GlossaryPool.typ": glossary-pool

#columns(2)[
    #make-glossary(glossary-pool)
]
```

How the result looks like, can be seen on the home github page:

[Github home of the typst glossary.](https://github.com/RolfBremer/typst-glossary)

<span style="font-size:9pt">
<hr>

To use more than one pool, this can be used instead:

```typ
#import "GlossaryPool.typ": glossary-pool
#import "LocalGlossaryPool.typ": local-glossary-pool

#columns(2)[
    #make-glossary(local-glossary-pool, glossary-pool)
]
```

Using this, the local pool takes precedence over the global pool, because it is the first
parameter.

More usage samples are shown in the document `sample-usage.typ` on
[glossary´s GitHub]([Title](https://github.com/RolfBremer/typst-glossary)).

The resulting PDF is also available there as well.

</span>
