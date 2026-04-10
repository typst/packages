#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(t) = {
  utils.assert_type(t, tiling);
  
  let vars = eval("arguments(" + repr(t).replace("..", "").match(regex("tiling\((.*?)\)$")).captures.at(0) + ")");

  import "dictionary.typ" as dict_;
  return dict_.serializer((
      size: vars.pos().at(0),
      ..vars.named()
  ));
};

#let deserializer(d) = {
  utils.assert_type(d, dictionary);

  import "dictionary.typ" as dict_;
  let args = dict_.deserializer(d);
  
  return tiling(
    text("Unsupported", color.red),
    size: args.remove("size"),
    ..args
  );
};

#let test(cycle) = {
  let null = cycle(
    tiling(size: (30pt, 30pt))[
      #place(line(start: (0%, 0%), end: (100%, 100%)))
      #place(line(start: (0%, 100%), end: (100%, 0%)))
    ]
  );
}