#let usd(input) = {
  set align(right);

  let dollars-int = int(input);
  let cents-int = int((input - dollars-int) * 100);

  let dollars-str = str(dollars-int);
  let cents-str = str(cents-int);

  if cents-str.len() < 2 {
    cents-str = "0" + cents-str;
  }

  let dollars-chunks = ();
  let dollars-to-chunk = dollars-str.rev();
  
  while dollars-to-chunk.len() > 3 {
    dollars-chunks.push(
      dollars-to-chunk.slice(0, 3).rev()
    );

    dollars-to-chunk = dollars-to-chunk.slice(3);
  } 

  dollars-chunks.push(dollars-to-chunk.rev());

  [\$#{dollars-chunks.rev().join(",")}.#cents-str]
}