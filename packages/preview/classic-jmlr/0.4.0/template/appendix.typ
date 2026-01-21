// There are no numbers in sample paper.
#set math.equation(numbering: none)

// The first nameless section in the appendix.
= <app:theorem>

// Note: in this sample, the section number is hard-coded in. Following proper
// LaTeX conventions, it should properly be coded as a reference:

// In this appendix we prove the following theorem from
// Section~\ref{sec:textree-generalization}:

In this appendix we prove the following theorem from Section~6.2:

*Theorem* #emph[Let $u,v,w$ be discrete variables such that $v, w$ do not
co-occur with $u$ (i.e., $u !=0 arrow.r.double v = w = 0$ in a given dataset
$cal(D)$). Let $N_(v 0), N_(w 0)$ be the number of data points for which $v=0,
w=0$ respectively, and let $I_(u v), I_(u w)$ be the respective empirical
mutual information values based on the sample $cal(D)$. Then

$ N_(v 0) > N_(w 0) arrow.r.double I_(u v) <= I_(u w) $

with equality only if $u$ is identically 0.] $square.filled$

// The second section in the appendix.
=

#block[
*Proof.* We use the notation:

$ P_(v)(i) = N_v^i / N, space.en i != 0; space.en
  P_(v 0) equiv P_v(0) = 1 - sum_(i != 0) P_v(i). $

These values represent the (empirical) probabilities of $v$ taking value $i !=
0$ and 0 respectively. Entropies will be denoted by $H$. We aim to show that
$(diff I_(u v)) / (diff P_(v 0)) < 0$....
]

_Remainder omitted in this sample. See #link("http://www.jmlr.org/papers/") for
full paper._
