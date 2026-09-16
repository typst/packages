#import "/lib.typ": energy-level, orbital-column, correlate, mo-model, mo-diagram

#set page(width: auto, height: auto, margin: 0.45cm)

#let oxygen = orbital-column("oxygen", (
  energy-level("o-2s", -32.0, label: $2s$, occupation: 2),
  energy-level("o-2p", -15.0, label: $2p$, degeneracy: 3, occupation: 4),
), label: [O atomic orbitals])

#let molecular = orbital-column("co", (
  energy-level("sigma-2s", -29.0, label: $sigma_(2s)$, occupation: 2, role: "bonding"),
  energy-level("sigma-2s-star", -21.0, label: $sigma_(2s)^*$, occupation: 2, role: "antibonding"),
  energy-level("pi-2p", -14.2, label: $pi_(2p)$, degeneracy: 2, occupation: 4, role: "bonding"),
  energy-level("sigma-2p", -12.0, label: $sigma_(2p)$, occupation: 2, role: "bonding"),
  energy-level("pi-2p-star", -5.0, label: $pi_(2p)^*$, degeneracy: 2, role: "antibonding"),
  energy-level("sigma-2p-star", -2.5, label: $sigma_(2p)^*$, role: "antibonding"),
), label: [CO molecular orbitals], kind: "molecular")

#let carbon = orbital-column("carbon", (
  energy-level("c-2s", -19.0, label: $2s$, occupation: 2),
  energy-level("c-2p", -11.0, label: $2p$, degeneracy: 3, occupation: 2),
), label: [C atomic orbitals])

#let model = mo-model(
  (oxygen, molecular, carbon),
  energy-label: [Schematic energy],
  correlations: (
    correlate("o-2s", "sigma-2s"),
    correlate("o-2s", "sigma-2s-star"),
    correlate("c-2s", "sigma-2s"),
    correlate("c-2s", "sigma-2s-star"),
    correlate("o-2p", "pi-2p"),
    correlate("o-2p", "sigma-2p"),
    correlate("o-2p", "pi-2p-star"),
    correlate("o-2p", "sigma-2p-star"),
    correlate("c-2p", "pi-2p"),
    correlate("c-2p", "sigma-2p"),
    correlate("c-2p", "pi-2p-star"),
    correlate("c-2p", "sigma-2p-star"),
  ),
)

#mo-diagram(model, width: 13cm)
