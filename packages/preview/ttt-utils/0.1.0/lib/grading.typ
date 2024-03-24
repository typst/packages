// IHK Notenschlüssel
#let ihk_grades(max_points, steps: 1) = {
  assert((0.5,1).contains(steps), message: "only steps of [0.5] or [1] is supported.")
  let dist = range(max_points * 10, step: int(steps * 10)).map(el => {
        let points = el*0.1;
        let percent = calc.round(points/max_points, digits:2);
        let grade = if percent < 0.3 {6} else if percent < 0.5 {5} else if percent < 0.67 {4} else if percent < 0.81 {3} else if percent < 0.92 {2} else {1}
        return (points, grade)
      })
    dist.push((max_points, 1));
    return dist
}
      
#let get_min_points(dist,grade) = {
  dist.find(val => val.at(1) == grade).at(0)
};

#let get_max_points(dist,grade) = {
  dist.rev().find(val => val.at(1) == grade).at(0)
};

#let grades(..args) = {
  assert(args.named().len() == 0)
  let args = args.pos()
  assert(calc.odd(args.len()))

  range(0, args.len(), step: 2).map((i) => (
    body: args.at(i),
    lower-limit: if i > 0 { args.at(i - 1) },
    upper-limit: if i < args.len() - 1 { args.at(i + 1) },
  ))
}