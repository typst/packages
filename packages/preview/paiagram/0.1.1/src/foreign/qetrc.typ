/// Turns three integers representing hours, minutes, and seconds into a total timestamp in seconds.
///
/// - h (hour): The hour value
/// - m (minute): The minute value
/// - s (second): The second value
/// -> int
#let to-timestamp(h, m, s) = {
  return int(h * 3600 + m * 60 + s)
}

#let match-name-color(name) = {
  let name = upper(name)
  let (c1, c2, c3) = if name.starts-with("G") {
    (purple, white, [高])
  } else if name.starts-with("D") {
    (orange, white, [动])
  } else if name.starts-with("C") {
    (blue, white, [城])
  } else if name.starts-with("K") {
    (red, white, [快])
  } else if name.starts-with("T") {
    (purple, white, [特])
  } else if name.starts-with("Z") {
    (blue, white, [直])
  } else if name.starts-with("L") {
    (gray, white, [临])
  } else {
    (green, white, [普])
  }
  box(stroke: 1pt, fill: c1, radius: .1em, pad(.1em, text(size: .6em, weight: 800, fill: c2)[#c3]))
}

#let read(
  qetrc,
  train-label: train => {
    pad(bottom: .14em, text(top-edge: "cap-height", bottom-edge: "baseline")[
      #place(center + horizon, text(stroke: .1em + white)[#train.name])
      #train.name
    ])
  },
  train-stroke: train => { red },
) = {
  let stations = (:)
  let trains = (:)
  let intervals = ()
  let available_stations = qetrc.line.stations.sorted(key: it => it.licheng)
  for i in range(available_stations.len() - 1) {
    let beg = available_stations.at(i)
    let end = available_stations.at(i + 1)
    let label = measure(beg.zhanming)
    stations.insert(beg.zhanming, (label_size: (label.width / 1pt, label.height / 1pt)))
    intervals.push(((beg.zhanming, end.zhanming), (length: int(end.licheng - beg.licheng) * 1000)))
  }
  // handle the last station
  let last_station = available_stations.at(available_stations.len() - 1)
  let last-label = measure(last_station.zhanming)
  stations.insert(last_station.zhanming, (label_size: (last-label.width / 1pt, last-label.height / 1pt)))
  for train in qetrc.at("trains") {
    let name = train.at("checi").at(0)
    let schedule = ()
    let previous_departure = none
    for entry in train.timetable {
      let arrival = to-timestamp(..entry.ddsj.split(":").map(int))
      let departure = to-timestamp(..entry.cfsj.split(":").map(int))
      if previous_departure != none and previous_departure > arrival {
        // add an offset to both times to ensure they are in order
        arrival += 86400
        departure += 86400
      }
      let station = entry.zhanming
      schedule.push((
        station: station,
        arrival: arrival,
        departure: departure,
      ))
      previous_departure = departure
    }
    let placed_label = train-label((name: name, schedule: schedule, raw: train))
    let draw-stroke = train-stroke((name: name, schedule: schedule, raw: train))
    let label = measure(placed_label)
    trains.insert(name, (
      label_size: (label.width / 1pt, label.height / 1pt),
      schedule: schedule,
      placed_label: placed_label,
      stroke: draw-stroke,
    ))
  }
  (stations: stations, trains: trains, intervals: intervals)
}
