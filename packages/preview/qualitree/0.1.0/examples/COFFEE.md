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
- `revisions.typ`: compact manual-wand walkthrough, with five needs and five functions.
- `revision-components.typ`: continue the compact manual-wand change into five component groups.
- `milk-options.typ`: a shared compact coffee-only baseline and two alternatives (manual jug/wand or automatic refrigerated milk).
- `milk-automatic.typ`: two-page compact report for the automatic alternative.
- `milk-detailed.typ`: the complete integrated-milk revision of the original twelve-function coffee study.
- `milk-data.typ`: both revised stages and their baseline comparisons.
- `minimal.typ`: a two-by-two introduction to the positional API.

Revision comparison is different from competitive comparison. No café or competing appliance scores are supplied: they have not been measured. A future comparison should identify the particular café beverage and candidate concepts, use consistent conditions and scales, retain missing observations as `none`, and separate observed values from assumptions.


## Compact walkthrough: two milk options

The documentation starts with a five-by-five matrix so the reader can follow one change. `milk-options.typ` is a separate teaching model with a shared coffee-only baseline: four needs, three functions, and three component groups. It deliberately aggregates the detailed coffee study; its numerical priorities must not be mixed with that study.

**Option A — manual wand and removable jug.** Add the need “enjoy warm, textured milk” and the functions “heat milk” and “texture milk.” Existing cleaning and hazard-containment responsibilities expand. Add steam generation and a wand/jug group; revise the controller and housing/protection. Milk refrigeration stays outside the appliance. The user supplies, positions, and cleans the jug.

**Option B — automatic preparation with refrigerated storage.** Start from the same coffee-only baseline. Add the same milk-drink need plus “keep milk ready between sessions,” with refrigerated storage and automatic milk metering as additional functions. Proposed hardware includes a refrigerated reservoir, milk pump/valves/tubing, and an automatic mixer in addition to steam generation and revised controls/protection.

| Question | Manual wand + jug | Automatic + refrigeration |
| --- | --- | --- |
| Who meters and positions milk? | The user handles the jug. | The machine meters milk into a mixer. |
| Where is milk stored? | Outside the appliance, between sessions. | In an integrated refrigerated reservoir. |
| What must be cleaned? | Jug and accessible wand, alongside coffee paths. | Reservoir, milk circuit, and mixer, alongside coffee paths. |
| What happens to existing constraints? | Reassess steam handling, cleanup effort, and jug space. | Reassess cleaning access, cold storage, shared power, and the installation envelope. |

The diagrams show relevance and design responsibility, not which option is superior. Establish requirements, observe user handling, and assess both concepts before assigning satisfaction scores or selecting a technology. No numerical milk-storage or hygiene target has been asserted. Both alternatives carry their own recalculated function priorities into their component matrices.

## Deploying a new capability: detailed milk study

The revision asks what adding milk drinks implies for the whole existing product. The baseline is the capsule-coffee concept above. The provisional extension has integrated refrigerated milk storage feeding an automatic steam/frothing path. This is a concept assumption, not a description of an actual Nespresso product. A removable jug with a manual steam wand would produce a different deployment, particularly for refrigeration, handling, and user protection.

Two new needs are **enjoy warm milk drinks with suitable texture** and **keep milk ready between drink sessions**. “Store refrigerated milk,” “heat milk,” and “generate steam and texture milk” are functions serving those needs. Five added functions cover cold storage, milk metering/transport, controlled heating, steam/texturing, and cleaning milk-contact paths. The second stage allocates them to four proposed component groups: refrigerated reservoir/sensor, milk pump/valves/tubing, steam generator/protection, and mixer/outlet. The cooling principle, steam-generation technology, and sensing implementation remain open technology choices.

### Read the needs comparison row by row

| Existing or new need | Consequence of the milk extension | What the team must resolve |
| --- | --- | --- |
| Café-worthy taste | Milk preparation and residues can affect the drink and coffee experience. | Agree milk recipes, sensory acceptance, and cleaning effectiveness. |
| Acceptable drink temperature | The final result now depends on milk heating and mixing as well as coffee temperature. | Define measurement conditions for the combined drink. |
| Two to three consecutive drinks | Milk capacity, steam recovery, shared heat demand, and rinsing become contributors. | Evaluate a mixed coffee/milk drink sequence with refill and cleanup. |
| Easy setup and cleaning | This existing need expands to milk-contact surfaces and the cold reservoir. | Establish a feasible cleaning procedure and validate it. |
| Six-month grounds preservation | The original sealed-dose preservation function remains unchanged. | Retain the existing coffee validation; do not confuse it with milk storage. |
| Small footprint | The reservoir, cooling system, tubing, and service clearances consume space. | Revisit the full installation and maintenance envelope. |
| Safe household use | Steam, added power demand, milk handling, and cleaning add interfaces to assess. | Revisit protection and acceptance gates with appropriate specialists. |
| **New: warm milk drinks with suitable texture** | Requires metering, controlled heating, and texturing. | Agree drink volume, texture, temperature, and reproducibility criteria. |
| **New: milk ready between sessions** | Requires controlled storage and a workable cleaning/storage routine. | Define and validate storage and hygiene conditions; targets remain TBD. |

### Follow each function into components

The first twelve rows preserve the original function identities. The last five are the new milk functions. Read the changes across each row before reading the totals:

- **Convert electrical energy into heat:** the proposed steam module adds demand; controller and power-protection relationships strengthen from 3 to 9 to represent coordinated operation.
- **Channel water and serve drinks:** the water circuit gains a steam supply interface; the cup interface must accommodate the milk outlet.
- **Collect waste:** retain the existing coffee-drip relationship and add milk-rinse collection. The tray/capacity definition changes; no arbitrary removal is introduced.
- **Guide operation:** the existing controller now coordinates coffee, milk, storage, and cleaning sequences.
- **Contain hazards:** the housing and protection functions extend to the cold module, milk circuit, steam generator, and hot outlet.
- **Store milk:** allocate controlled storage to the refrigerated reservoir and sensing, with controller and housing interfaces.
- **Meter milk:** allocate transport/dosing to the milk circuit and controller, with reservoir and outlet interfaces.
- **Heat and texture milk:** allocate energy transfer and texture formation to the steam module and mixer, while retaining shared water, power, and control interfaces.
- **Clean milk-contact paths:** allocate access/flushability across reservoir, tubing, mixer, controller, and waste collector. A new dedicated cleaning device is not assumed.

All strengths are illustrative engineering judgments. A strong need/function relationship means the function matters to that need; it does **not** mean adding it improves satisfaction. Refrigeration can strongly affect footprint while making the size constraint harder to satisfy. The proposed roof tensions flag simultaneous heat demand and cold/hot integration for investigation.

Each revised deployment is calculated independently from the actual revised stage, then compared against its baseline. Do not deploy the diff display itself. Relative priorities can move because new needs/functions change the normalization denominator: a yellow inherited weight alone does not establish a physical hardware modification. Existing IDs, relations, and labels let the reviewer distinguish these cases. This additive concept has no deleted component; removal rendering is covered by the library tests rather than an invented product deletion.
