// solveng – unit-aware calculations that read like your notes.
//
//   #show: solve-block                  // math and code in the document are calculated:
//   $I = 30 "mA"$, $Q_0 = 3450 "mAh"$    //   values …
//   $t = Q_0 / I$                         //   … computed and solved equations
//   ```solveng
//   P = [5 V] I -> mW                    // solveng code blocks show every step
//   ```
//   #solve("Q0/2 = I t", unit: "h")      // or as calls: def, solve, defined, graph, lambdify

#import "src/api.typ": def, solve, solve-block
#import "src/core.typ": solve-config, reset
#import "src/defined.typ": defined
#import "src/graph.typ": graph
#import "src/lambdify.typ": lambdify
