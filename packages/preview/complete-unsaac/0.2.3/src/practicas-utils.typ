#import "./utils/fecha.typ": get_mes

#let skip_days = (6, 7)
#let hd(day, month) = datetime(year: datetime.today().year(), month: month, day: day)
#let holidays = (
  hd(01, 01), // Año Nuevo
  hd(02, 04), // Jueves Santo
  hd(03, 04), // Viernes Santo
  hd(01, 05), // Día del Trabajo
  hd(07, 06), // Batalla de Arica / Día de la Bandera
  hd(29, 06), // San Pedro y San Pablo
  hd(23, 07), // Día de la Fuerza Aérea
  hd(28, 07), // Fiestas Patrias
  hd(29, 07), // Fiestas Patrias
  hd(06, 08), // Batalla de Junín
  hd(30, 08), // Santa Rosa de Lima
  hd(08, 10), // Combate de Angamos
  hd(01, 11), // Día de Todos los Santos
  hd(08, 12), // Inmaculada Concepción
  hd(09, 12), // Batalla de Ayacucho
  hd(25, 12), // Navidad
)

#let inc_day(date) = {
  date + duration(days: 1)
}

#let dec_day(date) = {
  date - duration(days: 1)
}

#let next_working_day(date) = {
  let new_date = inc_day(date)
  while holidays.contains(new_date) or skip_days.contains(new_date.weekday()) {
    new_date = inc_day(new_date)
  }
  new_date
}

#let prev_working_day(date) = {
  let new_date = dec_day(date)
  while holidays.contains(new_date) or skip_days.contains(new_date.weekday()) {
    new_date = dec_day(new_date)
  }
  new_date
}

#let is_working_day(date) = {
  not (holidays.contains(date) or skip_days.contains(date.weekday()))
}

#let end_of_working_day(n, period_start, hours_per_day) = {
  if n <= hours_per_day {
    return period_start
  }
  let days_needed = calc.ceil(n / hours_per_day)
  let date = period_start
  let days_counted = 0
  while days_counted < days_needed {
    date = next_working_day(date)
    days_counted += 1
  }
  prev_working_day(date)
}

#let activity_start_date(period_start, hours_per_day, cumulative_hours) = {
  if cumulative_hours == 0 {
    period_start
  } else {
    next_working_day(end_of_working_day(
      cumulative_hours,
      period_start,
      hours_per_day,
    ))
  }
}

#let activity_end_date(period_start, hours_per_day, cumulative_hours) = {
  end_of_working_day(cumulative_hours, period_start, hours_per_day)
}

#let calc_total_hours(activities) = {
  if activities == none { return 0 }
  activities.fold(0, (acc, act) => acc + act.at("duracion", default: 0))
}

#let get_period_end(period_start, hours_per_day, activities) = {
  if activities == none { return none }
  let total = calc_total_hours(activities)
  if total == 0 { return none }
  end_of_working_day(total, period_start, hours_per_day)
}

#let get_period_end_str(period_start, hours_per_day, activities) = {
  if activities == none { return "" }
  let total = calc_total_hours(activities)
  if total == 0 { return "" }
  let final_date = end_of_working_day(total, period_start, hours_per_day)
  (
    period_start.display("[day] de " + str(get_mes(period_start)) + " de [year]")
      + " - "
      + final_date.display("[day] de " + str(get_mes(final_date)) + " de [year]")
  )
}

/// Gantt stuff
#let distribute_duration(total, count, hours_per_day) = {
  assert(count > 0)
  assert(hours_per_day > 0)

  let full_days = calc.floor(total / hours_per_day)
  let remainder_hours = calc.rem(total, hours_per_day)

  let base_days = calc.floor(full_days / count)
  let extra_days = calc.rem(full_days, count)

  range(count).map(i => {
    let days = base_days + if i >= count - extra_days { 1 } else { 0 }
    let hours = days * hours_per_day
    if i == count - 1 {
      hours + remainder_hours
    } else {
      hours
    }
  })
}

#let normalize_activity(act, hours_per_day) = {
  let children = act.at("gantt", default: none)

  if children == none or children.len() == 0 {
    return act
  }

  let parent_duration = act.at("duracion", default: none)

  // CASE 1
  if parent_duration != none {
    assert(
      parent_duration > 0,
      message: "Parent duracion must be > 0",
    )

    let distributed = distribute_duration(
      parent_duration,
      children.len(),
      hours_per_day,
    )

    return (
      ..act,
      duracion: parent_duration,
      gantt: children
        .enumerate()
        .map(((i, st)) => (
          ..st,
          duracion: distributed.at(i),
        )),
    )
  }

  // CASE 2
  let normalized_children = children.map(st => {
    let dur = st.at("duracion", default: none)

    assert(
      dur != none,
      message: "Subtask `" + repr(st.at("nombre", default: "?")) + "` is missing duracion",
    )

    assert(
      dur > 0,
      message: "Subtask `" + repr(st.at("nombre", default: "?")) + "` must have duracion > 0",
    )

    st
  })

  let total_duration = normalized_children.fold(
    0,
    (acc, st) => acc + st.at("duracion"),
  )

  (
    ..act,
    duracion: total_duration,
    gantt: normalized_children,
  )
}
