#import "@preview/abbr:0.3.1"

= Work Completed and Outlook

This chapter summarises the technical work completed in the first half of
the PhD and the plan for the second half. The linear filtering approach
of @kalman1960new served as the reference method.

== Surrogate model architecture

The surrogate is a Fourier neural operator trained on 5000 simulation
runs. A representative loss curve is shown in @fig-loss.

#figure(
  image("../assets/placeholder-figure.pdf", width: 60%),
  caption: [Training and validation loss across 200 epochs.],
) <fig-loss>

The training objective is the standard mean-squared error in
@eq-loss, computed on a held-out validation set.

$ cal(L) = 1 / N sum_(i=1)^N (hat(y)_i - y_i)^2 $ <eq-loss>

== Inversion loop

The Bayesian inversion loop wraps the surrogate inside an adaptive
@MCMC sampler. The inner loop iterates as follows.

```python
for step in range(num_steps):
    proposal = sampler.propose(current)
    y_hat = surrogate(proposal)
    log_alpha = log_likelihood(y_hat, y_obs) - log_likelihood_prev
    current = sampler.accept_or_reject(proposal, log_alpha)
```

Wall-clock time for 10000 samples dropped from about 14 hours with the full
solver to under 4 minutes with the surrogate, at the cost of an
acceptance-rate reduction of 12%.

== Plan for the second half

The remainder of the PhD addresses RQ2 and RQ3 and produces the journal
article that anchors the dissertation.

/ Months 1 to 3: Benchmark @MCMC against ensemble Kalman approaches on
  the synthetic dataset.
/ Months 4 to 6: Transfer the methodology to two real-world catchments.
/ Months 7 to 9: Write the journal article on the surrogate-accelerated
  inversion pipeline.
/ Months 10 to 12: Write the dissertation.
