#import "../relai_poster_template.typ": poster

#show: doc => poster(
  doc,
  text("Deep Reinforcement Learning Agents learn Predatory Pricing", size: 60pt, weight: "bold"),
  flipped: false,
  n_columns: 2,
  authors: (
    ("name": "Ole Petersen", "affiliation": "TUM", "email": "ole.petersen@tum.de"),
    ("name": "Fabian Raoul Pieroth", "affiliation": "TUM", "email": "fabian.pieroth@tum.de"),
    ("name": "Martin Bichler", "affiliation": "TUM", "email": "bichler@in.tum.de")
  ),
  references: (
    ("url": "https://zuseschoolrelai.de", "label": "zuseschoolrelai.de"),
    //("url": "https://arxiv.org/abs/...", "label": "ArXiv"),
  ),
  font_size: 30pt,
)

= Motivation

- Complex economic models have been infesible to analyse until recently
- *Reinforcement Learning* (RL) can solve complex decision making problems

#sym.arrow.r.double What if RL controls economic agents?

= Dynamic Oligopoly Model
Agents are companies competing in an oligopoly over multiple rounds:
#image("resources/dynamic_oligopoly_algorithm.png", width: 90%)

The dropout mechanism removes unprofitable companies from the game

#sym.arrow.r.double *Discontinuous game dynamics*

#sym.arrow.r.double no analytical solutions with dropouts

= Equilibrium Learning
*Nash equilibria* (NE) are strategy fixed points where no player gains by deviating:

$
sup _(pi _(i ) in Sigma _(i ) )U _(i )\(pi _(i )\,pi ^(\*)_(- i )\) - U _(i )\(pi ^(\*)_(cal(N))\) <= epsilon quad forall i in cal(N)
$
Proximity to equilibrium is measured by
$
cal(L)_("bf")= sum _(i in cal(N)) sup _(pi _(i ) in Sigma _(i )^(K )) U _(i )\(pi _(i )\,pi _(- i )\) - U _(i )\(pi _(i )\,pi _(- i )\)
$
where $sup _(pi _(i ) in Sigma _(i )^(K )) U _(i )\(pi _(i )\,pi _(- i )\)$ is approximated by a brute force algorithm.

Each company is controlled by a RL agent aiming to maximize its profit:

#image("resources/equilibrium_learning.svg", width: 100%)

We use REINFORCE (or its variants) to update all agents' policies simultaneously:

$
theta _(i ) <- theta _(i ) + alpha nabla _(theta _(i )) U _(i )\(pi _(theta _(i ))\,\{ pi _(theta _(j ))\} _(j in cal(N)without \{ i \} )\)
$

#sym.arrow.r.double Hopefully converges to NE


// $
//    cal(L )_("bf,norm")         & =  frac(cal(L )_("bf"),sum _(i  in  cal(N )) max _(pi _(i ) in  Sigma _(i )^(K )) U _(i )\(pi _(i )\,pi _(- i )\))
// $

= Results
*Setup*
- $N=3$ companies, $T=4$ rounds
- Proximal Policy Optimization (PPO) for RL
- Company $0$ produces cheaper than $1$ and $2$

*Findings*
- Firm $0$ learns *predatory pricing*, first lowering prices to drive out competitors
- The result is a verified approximate NE

#image("resources/predatory_strategy.png", width: 90%)

*Broader implications*
- Our methodology finds approximate NE complex games without analytical solutions
- Brute-force verification is required due to lack of convergence guarantees in MARL
