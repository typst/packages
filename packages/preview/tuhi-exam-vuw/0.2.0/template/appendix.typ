
#pagebreak()

= APPENDIX


=== Vector calculus identities
<vector-calculus-identities>

$nabla lr((f g)) eq f nabla g plus g nabla f$

$nabla lr((bold(A) dot.op bold(B))) eq bold(A) times lr((nabla times bold(B))) plus bold(B) times lr((nabla times bold(A))) plus lr((bold(A) dot.op nabla)) bold(B) plus lr((bold(B) dot.op nabla)) bold(A)$

$nabla dot.op lr((f bold(A))) eq f lr((nabla dot.op bold(A))) plus bold(A) dot.op lr((nabla f))$

$nabla dot.op lr((bold(A) times bold(B))) eq bold(B) dot.op lr((nabla times bold(A))) minus bold(A) dot.op lr((nabla times bold(B)))$

$nabla times lr((f bold(A))) eq f lr((nabla times bold(A))) minus bold(A) times lr((nabla f))$

$nabla times lr((bold(A) times bold(B))) eq lr((bold(B) dot.op nabla)) bold(A) minus lr((bold(A) dot.op nabla)) bold(B) plus lr((nabla dot.op bold(B))) bold(A) minus lr((nabla dot.op bold(A))) bold(B)$

=== Cylindrical coordinates:
<cylindrical-coordinates>

$x & eq s cos phi\
y & eq s sin phi\
z & eq z $

$ nabla f eq  & frac(diff f, diff s) bold(hat(s)) plus 1 / s frac(diff f, diff phi) bold(hat(phi)) plus frac(diff f, diff z) bold(hat(z))\
nabla dot.op bold(A) eq  & 1 / s frac(diff, diff s) lr((s A_s)) plus 1 / s frac(diff A_phi, diff phi) plus frac(diff A_z, diff z)\
nabla times bold(A) eq  & lr((1 / s frac(diff A_z, diff phi) minus frac(diff A_phi, diff z))) bold(hat(s)) plus lr((frac(diff A_s, diff z) minus frac(diff A_z, diff s))) bold(hat(phi)) plus 1 / s lr((frac(diff, diff s) lr((s A_phi)) minus frac(diff A_s, diff phi))) bold(hat(z))\
nabla^2 f eq  & 1 / s frac(diff, diff s) lr((s frac(diff f, diff s))) plus 1 / s^2 frac(diff^2 f, diff phi^2) plus frac(diff^2 f, diff z^2) $

=== Spherical coordinates:
<spherical-coordinates>

$x & eq r thin sin theta thin cos phi\
y & eq r thin sin theta thin sin phi\
z & eq r thin cos theta $

$ nabla f eq  & frac(diff f, diff r) bold(hat(r)) plus 1 / r frac(diff f, diff theta) bold(hat(theta)) plus frac(1, r sin theta) frac(diff f, diff phi) bold(hat(phi))\
nabla dot.op bold(A) eq  & 1 / r^2 frac(diff, diff r) lr((r^2 A_r)) plus frac(1, r sin theta) frac(diff, diff theta) lr((sin theta A_theta)) plus frac(1, r sin theta) frac(diff A_phi, diff phi)\
nabla times bold(A) eq  & frac(1, r sin theta) lr((frac(diff, diff theta) lr((A_phi sin theta)) minus frac(diff A_theta, diff phi))) bold(hat(r))\
 &  plus 1 / r lr((frac(1, sin theta) frac(diff A_r, diff phi) minus frac(diff, diff r) lr((r A_phi)))) bold(hat(theta))\
 &  plus 1 / r lr((frac(diff, diff r) lr((r A_theta)) minus frac(diff A_r, diff theta))) bold(hat(phi))\
nabla^2 f eq  & 1 / r^2 frac(diff, diff r) lr((r^2 frac(diff f, diff r))) plus frac(1, r^2 sin theta) frac(diff, diff theta) lr((sin theta frac(diff f, diff theta))) plus frac(1, r^2 sin^2 theta) frac(diff^2 f, diff phi^2) $

