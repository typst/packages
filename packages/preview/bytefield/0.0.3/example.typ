#import "@local/bytefield:0.0.2": *

= Bytefield
== Colored Example
#bytefield(
  bytes(3, fill: red.lighten(30%))[Test],
  bytes(2)[Break],
  bits(24, fill: green.lighten(30%))[Fill],
  bytes(12)[Addr],
  padding(fill: purple.lighten(40%))[Padding],
)


== Show all bits in the bitheader

Show all bit headers with `bitheader: "all"` 

#bytefield(
    bits:32,
    msb_first: true,
    bitheader: "all",
    ..range(32).map(i => bit[#flagtext[B#i]]).rev(),
)

== Smart bit header

Show start bit of each bitbox with `bitheader: "smart"`.

#bytefield(
  bits: 32,
  // same as bitheader: (0,8,13,18,23,31),
  bitheader: "smart",
  bits(8)[opcode],
  bits(5)[rd],
  bits(5)[rs1],
  bits(5)[rs2],
  padding()[]
)

== Reversed bit order

Select `msb_first: true` for a reversed bit order. 

#bytefield(
    msb_first: true,
    bitheader: "smart",
    byte[MSB],bytes(2)[Two], bit[#flagtext("URG")], bits(7)[LSB],
)

== Custom bit header

Pass an `array` to specify each number.

#bytefield(
    bits:16,
    bitheader: (0,5,6,7,8, 12,15),
    bits(6)[First],
    bits(2)[Duo],
    bits(5)[Five],
    bits(3)[Last],
)

Pass an `integer` to show all multiples of this number.

#bytefield(
    bits:16,
    bitheader: 3,
    bits(6)[First],
    bits(2)[Duo],
    bits(5)[Five],
    bits(3)[Last],
)

== Text header instead of numbers  [*WIP*]

Pass an `dictionary` as bitheader. Example: 
```typst
#let myCustomTextBitheader = (
  "0": "LSB_starting_at_bit_0", 
  "13": "test", 
  "24": "next_field_at_bit_24", 
  "31":"MSB", 
  angle: -40deg,
  marker: auto // or none
)
```

#box(width: 100%)[

#bytefield(
  bitheader: ("0": "LSB_starting_at_bit_0", "13": "test", "25": "next_field_at_bit_25", "31":"MSB", angle: -45deg,),
  bits: 32,
  bit[F],
  byte[Start],
  bytes(2, fill: red.lighten(30%))[Test],
  bit[H],
  bits(5, fill: purple.lighten(40%))[CRC],
  bit[T],
)
]

= Some predefined network protocols

== IPv4
#ipv4

== IPv6
#ipv6

== ICMP
#icmp

== ICMPv6
#icmpv6

== DNS
#dns

== TCP
#tcp
#tcp_detailed

== UDP
#udp