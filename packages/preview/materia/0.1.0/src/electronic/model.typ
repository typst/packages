// Declarative molecular-orbital data. This module validates diagram inputs;
// it does not infer orbital energies, occupations, or chemical bonding.

#let _roles = ("bonding", "antibonding", "nonbonding")

/// Describe one energy level.
///
/// `occupation` is the total electron count across `degeneracy` orbitals and
/// must lie between zero and `2 * degeneracy`.
#let energy-level(
  id,
  energy,
  label: auto,
  degeneracy: 1,
  occupation: 0,
  role: "nonbonding",
  color: auto,
) = {
  assert(type(id) == str and id != "",
    message: "materia: an energy-level id must be a non-empty string")
  assert(type(energy) in (int, float),
    message: "materia: energy for level " + repr(id) + " must be numeric")
  assert(type(degeneracy) == int and degeneracy > 0,
    message: "materia: degeneracy for level " + repr(id) + " must be a positive integer")
  assert(type(occupation) == int and occupation >= 0 and occupation <= 2 * degeneracy,
    message: "materia: occupation for level " + repr(id) + " must be an integer from 0 to "
      + str(2 * degeneracy))
  assert(role in _roles,
    message: "materia: role for level " + repr(id)
      + " must be bonding, antibonding, or nonbonding")
  assert(color == auto or type(color) == type(black),
    message: "materia: color for level " + repr(id) + " must be auto or a color")
  (
    id: id,
    energy: energy,
    label: if label == auto { id } else { label },
    degeneracy: degeneracy,
    occupation: occupation,
    role: role,
    color: color,
  )
}

/// Group energy levels into one diagram column.
#let orbital-column(id, levels, label: auto, kind: "atomic", color: auto) = {
  assert(type(id) == str and id != "",
    message: "materia: an orbital-column id must be a non-empty string")
  assert(type(levels) == array and levels.len() > 0,
    message: "materia: orbital column " + repr(id) + " must contain at least one level")
  assert(kind in ("atomic", "molecular"),
    message: "materia: column kind must be atomic or molecular, got " + repr(kind))
  assert(color == auto or type(color) == type(black),
    message: "materia: color for column " + repr(id) + " must be auto or a color")
  (
    id: id,
    levels: levels,
    label: if label == auto { id } else { label },
    kind: kind,
    color: color,
  )
}

/// Connect two level IDs with a correlation line.
#let correlate(from, to, color: auto) = {
  assert(type(from) == str and type(to) == str,
    message: "materia: correlation endpoints must be level-id strings")
  assert(color == auto or type(color) == type(black),
    message: "materia: correlation color must be auto or a color")
  (from: from, to: to, color: color)
}

/// Validate and assemble a molecular-orbital diagram model.
#let mo-model(columns, correlations: (), energy-label: [Energy]) = {
  assert(type(columns) == array and columns.len() >= 2,
    message: "materia: an MO model needs at least two orbital columns")
  assert(type(correlations) == array,
    message: "materia: correlations must be an array")

  let column-ids = ()
  let level-ids = ()
  for column in columns {
    assert(type(column) == dictionary and "id" in column and "levels" in column,
      message: "materia: every MO column must be made with orbital-column")
    assert(column.id not in column-ids,
      message: "materia: duplicate orbital-column id " + repr(column.id))
    column-ids.push(column.id)
    for level in column.levels {
      assert(type(level) == dictionary and "id" in level and "energy" in level,
        message: "materia: every MO level must be made with energy-level")
      assert(level.id not in level-ids,
        message: "materia: duplicate energy-level id " + repr(level.id))
      level-ids.push(level.id)
    }
  }

  for correlation in correlations {
    assert(type(correlation) == dictionary
      and "from" in correlation and "to" in correlation,
      message: "materia: every correlation must be made with correlate")
    assert(correlation.at("from") in level-ids,
      message: "materia: unknown correlation source " + repr(correlation.at("from")))
    assert(correlation.at("to") in level-ids,
      message: "materia: unknown correlation target " + repr(correlation.at("to")))
    assert(correlation.at("from") != correlation.at("to"),
      message: "materia: a level cannot correlate with itself")
  }

  (
    kind: "mo-model",
    columns: columns,
    correlations: correlations,
    energy-label: energy-label,
  )
}

/// Compute `(bonding electrons - antibonding electrons) / 2`.
#let bond-order(model) = {
  assert(type(model) == dictionary and model.at("kind", default: none) == "mo-model",
    message: "materia: bond-order expects an mo-model")
  let bonding = 0
  let antibonding = 0
  for column in model.columns {
    for level in column.levels {
      if level.role == "bonding" { bonding += level.occupation }
      if level.role == "antibonding" { antibonding += level.occupation }
    }
  }
  (bonding - antibonding) / 2
}
