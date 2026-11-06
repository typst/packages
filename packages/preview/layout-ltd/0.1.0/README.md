# Layout Ltd

A simple package to limit the number of iterations the compiler will run to resolve context. Works by performing empty compilations for the first $5-n$ iterations, then running normally for the last $n$, where $n$ is the specified number of iterations.

"Approved" by one of the creators of typst:

> This is cursed
>
> &mdash; <cite>@laurmaedje</cite>

## Usage

Just import the package and use it with a show rule at the top of your file:

```typst
#import "@preview/layout-ltd:0.1.0": layout-limiter
#show: layout-limiter
```

You can then specify the limit with a command line argument: 
```bash
typst compile --input=max-layout-iterations=1 main.typ
```

Or you can specify the limit directly in your show rule:
```typst
#import "@preview/layout-ltd:0.1.0": layout-limiter
#show: layout-limiter.with(max-iterations: 2)
```