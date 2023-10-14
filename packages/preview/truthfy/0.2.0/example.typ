#import "main.typ": * 

#columns(2)[
    #generate-table($u_7 => u_(22) => u$, $u_7 ? u_22 : u$)
    #generate-table($A xor B$, $A and B$)
    
    #colbreak()
    
    #generate-table($A and B$, $B or A$, $A => B$)
    #generate-table($p => q$, $not p => (q <=> p)$, $p or q$, $not p xor q$)
]