# Minienvs

Theorem environments in [Typst](https://typst.app/) with minimal fuss.

To use, import and add a show rule:

```typst
#import "@preview/minienvs:0.1.0": *
#show: minienvs
```

You can optionally pass a custom configuration in the show-rule via `minienvs.with(…)` (see [Customization](#customization)).

You can now just add a theorem along with its proof using the term list syntax. For example:

```typst
/ Theorem (Ville's inequality):
  Let $X_0, ...$ be a non-negative supermartingale. Then, for any real number $a > 0$,

  $ PP[sup_(n>=0) X_n >= a] <= EE[X_0]/a. $

Let us now prove it:

/ Proof:
  Consider the stopping time $N = inf {t >= 1 : X_t >= a}$.
  By the optional stopping theorem and the supermartingale convergence theorem, we have that

  $
    EE[X_0] >= EE[X_N]
    &= EE[X_N | N < oo] PP[N < oo] + EE[X_oo | N = oo] PP[N = oo] \
    &>= EE[X_N | N < oo] PP[N < oo]
    = EE[X_N/a | N < oo] a PP[N < oo]. \
  $

  And, therefore,

  $ PP[N < oo] <= EE[X_0] \/ a EE[X_N/a | N < oo] <= EE[X_0] \/ a. $
```

![](./assets/ville.png)

## Labels and references

Currently, in order to label a minienv one needs to use the `envlabel` function. For example:

```typst
/ Lemma (Donsker and Varadhan's variational formula) #envlabel(<change-of-measure>):
  For any measureable, bounded function $h : Theta -> RR$ we have:

  $ log EE_(theta ~ pi)[exp h(theta)] = sup_(rho in cal(P)(Theta)) [ EE_(theta~rho)[h(theta)] - KL(rho || pi) ]. $

As we will see, @change-of-measure is a fundamental building block of PAC-Bayes bounds.
```

![](./assets/donsker-varadhan.png)

## Customization

You can customize the appearance of minienvs by providing a configuration to the show-rule. For example, for the default configuration, you can do:

```typst
#show: minienvs.with(config: (
  // Whether to give numbers for environments.
  // If the environment is not mentioned in this dict, it has a number.
  no-numbering: (
    proof: true,
  ),
  // Additional options for the `block` containing the minienv (e.g., to put a box around the minienv).
  // If the environment is not mentioned in this dict, no additional options are passed.
  bbox: (:),
  // How to format the head of the minienv.
  // If the environment is not mentioned in this dict, then it is formatted in bold.
  head-style: (
    proof: it => [_#{it}_],
  ),
  // How to format the body of the minienv.
  // If the environment is not mentioned in this dict, then it is formatted in italic.
  transforms: (
    proof: it => [#it #h(1fr) $space qed$],
  )
))
```

## Coming soon / Work in progress

- Presets for multiple languages
- Separate counters
- More customization
<!-- - Labelling environments directly, without needing `envlabel` -->
