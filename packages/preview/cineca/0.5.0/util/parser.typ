#let time(..hms) = {
  let args = hms.pos()
  if args.len() > 3 {
    args = args.slice(0, 3)
  }
  let components = (0,) * 3
  if args.len() == 1 {
    let arg = args.at(0)
    if type(arg) == str {
      if arg.match(regex("^\\d+\\.\\d+$")) != none {
        let argv = arg.split(".").map(i => int(i))
        components = argv + (0,) * (3 - argv.len())
      } else if arg.match(regex("^\\d+:\\d+(:\\d+)?$")) != none {
        let argv = arg.split(":").map(i => int(i))
        components = argv + (0,) * (3 - argv.len())
      } else {
        panic("Cannot parse time")
      }
    } else if type(arg) == float or type(arg) == decimal {
      let t = calc.round(arg, digits: 2)
      components.at(0) = calc.trunc(t)
      components.at(1) = calc.trunc(calc.round(calc.fract(t) * 100, digits: 0))
    } else {
      components = args + (0,) * (3 - args.len())
    }
  } else {
    components = args + (0,) * (3 - args.len())
  }
  datetime(
    hour: components.at(0),
    minute: components.at(1),
    second: components.at(2)
  )
}

#let day(..ymd) = {
  let args = ymd.pos()
  if args.len() > 3 {
    args = args.slice(0, 3)
  }
  let components = (1,) * 3
  if args.len() == 1 {
    let arg = args.at(0)
    if type(arg) == str {
      if arg.match(regex("^\\d+\\-\\d+(\\-\\d+)?$")) != none {
        let argv = arg.split("-").map(i => int(i))
        components = argv + (1,) * (3 - argv.len())
      } else if arg.match(regex("^\\d+/\\d+(/\\d+)?$")) != none {
        let argv = arg.split("/").map(i => int(i)).rev()
        components = argv + (1,) * (3 - argv.len())
      } else {
        panic("Cannot parse time")
      }
    } else {
      components = args + (1,) * (3 - args.len())
    }
  } else {
    components = args + (1,) * (3 - args.len())
  }
  datetime(
    year: components.at(0),
    month: components.at(1),
    day: components.at(2)
  )
}

#let daytime(..args) = {
  let args = args.pos()
  let tv = none
  let dv = none
  if args.len() == 1 {
    let arg = args.at(0)
    if type(arg) == str {
      let (darg, targ) = arg.split(" ")
      dv = day(darg)
      tv = time(targ)
    } else {
      dv = day(..args)
    }
  } else {
    if type(args.first()) == str {
      dv = day(args.first())
      tv = time(..args.slice(1))
    } else if type(args.last()) == str or type(args.last()) == float or type(args.last()) == decimal {
      tv = time(args.last())
      dv = day(..args.slice(0, args.len() - 1))
    } else {
      if args.len() <= 3 {
        dv = day(..args)
      } else {
        dv = day(..args.slice(0, 3))
        tv = time(..args.slice(3))
      }
    }
  }
  if dv != none {
    if tv != none {
      datetime(year: dv.year(), month: dv.month(), day: dv.day(), hour: tv.hour(), minute: tv.minute(), second: tv.second())
    } else {
      datetime(year: dv.year(), month: dv.month(), day: dv.day(), hour: 0, minute: 0, second: 0)
    }
  } else {
    none
  }
}
