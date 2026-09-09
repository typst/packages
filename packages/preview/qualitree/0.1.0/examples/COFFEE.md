# Coffee at home: a worked QFD example

The use case is replacing a coffee from the local café with a drink prepared at home. The numerical example is a fictional workshop, not a benchmark of an existing appliance. Every weight, relationship, and roof correlation is an illustrative judgment. The matrices help organize decisions and expose dependencies; they do not provide empirical evidence of product quality.

The provisional system boundary includes the machine, sealed preground dose, and protective packaging. That boundary makes preservation a function the team can influence. If the scope becomes machine-only, remove preservation from its functional deployment and treat supplied-dose freshness as an external interface requirement. This assumption remains open for confirmation.

## Needs and acceptance gates

| Need | What to establish before acceptance |
| --- | --- |
| Café-worthy taste | Agree a minimum acceptable result against a selected café reference, using a documented blind tasting protocol. No numerical cutoff has yet been agreed. |
| Acceptable drink temperature | Agree a minimum and acceptable range at a stated time after serving in a specified cup. Brewing-water temperature is a different measurement. |
| Two to three consecutive drinks | Test three drinks, including initial warm-up, recovery between drinks, reservoir capacity, dose replacement, and waste capacity. Specify rinse volume and beverage size. |
| Little setup and cleaning effort | Observe an untrained adult completing setup, brewing, refill, and cleanup; record time, actions, errors, and wet/dirty handling. |
| Preground coffee six months after roasting | Validate sealed doses of known roast date under defined storage conditions. Compare taste with a suitable fresh reference; record sealing delay, roast, grind, barrier construction, and storage. |
| Small footprint | Set a countertop envelope, including refill access, lid opening, ventilation, and clearance to remove the tray. |
| Low danger in ordinary household use | Establish acceptance gates for foreseeable heat, pressure, electrical, stability, and accessible-part hazards, including a child nearby; specialist assessment and applicable requirements remain to be identified. |

Taste, drink temperature, and safety are acceptance gates. Their presence in the weighted matrix helps allocate effort but does not turn a failed gate into an acceptable concept. There is no claim of safety certification, six-month shelf life, or café-equivalent taste.

## Functions, components, and technologies

The first deployment contains seven needs and twelve functions. The function groups are:

- Store water and convert electrical energy into controlled thermal delivery.
- Pressurize and channel water, open the dose flow path, and control contact with grounds.
- Preserve grounds before extraction, deliver coffee to the cup, and collect drips and spent doses.
- Guide the sequence and contain thermal, pressure, and electrical hazards.

These names describe transformations, storage, transport, and protection. Components implement them: reservoir, heater and sensor, pump and pressure-limiting path, flowmeter and circuit, dose chamber/opener/seals, sealed dose and packaging, outlet/cup support, waste collectors, controller/interface, and housing/protection.

A turbine is one candidate flowmeter principle. A vibration pump or thermoblock is a possible realization, not a requirement derived by this example. A stepper motor has no established need here. Each technology choice needs its own trade study once flow, pressure, temperature, noise, cost, lifetime, and control requirements are defined.

`qfd-deploy` uses the preceding column priorities as the next stage’s row weights. It preserves full-precision relative values; rounding is only for display. These two matrices share exactly the same function IDs, so changes to prose labels do not break identity.

## Provisional targets and sources

The example uses **92 ± 2 °C brewing water** and **about 25 seconds contact** as starting hypotheses. Earlier ranges of 85–95 °C and 10–20 seconds are also hypotheses to investigate, not standards. Timing needs a defined start/end event, and capsule geometry, coffee dose, grind, recipe, and beverage yield can change an appropriate operating window.

The Specialty Coffee Association article recounts a historical espresso definition with brewing water at 90.5–96.1 °C and extraction lasting 20–30 seconds, and discusses variation in surveyed practice. It provides context for an initial recipe, not proof that these values apply to this capsule concept. [SCA, “Defining the Ever-Changing Espresso”](https://sca.coffee/sca-news/25-magazine/issue-3/defining-ever-changing-espresso-25-magazine-issue-3-zyx36).

Nespresso describes sealed capsules and storage practices as ways to protect coffee freshness. This manufacturer information supports considering a protective barrier and controlled storage. It does not validate our proposed construction or establish acceptable taste six months after the roast date. [Nespresso, “How to store your coffee pods”](https://www.nespresso.com/nz/en/news/how-to-store-your-coffee-pods).

Both pages were consulted on 9 September 2026. Sources inform the discussion only; the need weights and relationships were not extracted from them.

## How to read the examples

- `espresso.typ`: needs → functions, with provisional targets and illustrative roof interactions.
- `components.typ`: functions → components, inheriting unrounded priorities.
- `report.typ`: a two-page A3 report with both deployments and the decision context.
- `revisions.typ`: a separate, deliberately small revision exercise. It reorders stable IDs, renames a need, changes relationships, adds protection, and removes a decorative-light requirement. Removed relations and roof signs remain reviewable; they contribute nothing to current priorities.
- `minimal.typ`: a two-by-two introduction to the positional API.

Revision comparison is different from competitive comparison. No café or competing appliance scores are supplied: they have not been measured. A future comparison should identify the particular café beverage and candidate concepts, use consistent conditions and scales, retain missing observations as `none`, and separate observed values from assumptions.
