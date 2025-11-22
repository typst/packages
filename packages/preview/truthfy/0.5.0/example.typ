#import "main.typ": * 
#set page(width: auto, height: 500pt)

#truth-table($u_7 => u_(22) => u$, $u_7 ? u_22 : u$)

#truth-table($A xor B$, $A and B$)    

#truth-table($A and B$, $B or A$, $A => B$)

#truth-table($p => q$, $not p => (q <=> p)$, $p or q$, $not p xor q$)

#truth-table(sc: (a) => {if (a) {"a"} else {"b"}}, $a and b$)

#truth-table-empty(sc: (a) => {if (a) {"x"} else {"$"}}, ($a and b$,), (false, [], true))

