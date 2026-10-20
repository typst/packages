#import "@preview/abbr:0.3.1"

= Introduction and Research Questions

This halftime report summarises the first half of the doctoral project on
@UQ for groundwater models governed by @PDE. The work spans the
development of surrogate models, the use of @MCMC methods for posterior
sampling, and the evaluation of these techniques on realistic catchment
geometries.

== Motivation

Groundwater flow models are central to long-term water management. Their
predictions carry substantial uncertainty driven by spatially variable
hydraulic conductivity, sparse observations, and imperfect process
representations. Quantifying this uncertainty in a computationally
tractable way is the broader question this PhD addresses.

== Research questions

The doctoral project is structured around three research questions.

+ Can a neural surrogate replace the costly forward solver in a Bayesian
  inversion loop without losing posterior accuracy?
+ How does sample efficiency of @MCMC compare against ensemble Kalman
  approaches on the same benchmark?
+ Do uncertainty bounds obtained from the surrogate generalise to
  unseen catchment geometries?

The first half of the PhD focused on RQ1 and laid the foundations for RQ2.
RQ3 remains for the second half.
