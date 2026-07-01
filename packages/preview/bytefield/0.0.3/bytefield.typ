// Bytefield - generate protocol headers and more
// Feel free to contribute with any features you think are missing.
// Still a WIP - alpha stage and a bit hacky at the moment

#import "@preview/tablex:0.0.6": tablex, cellx, gridx
#set text(font: "IBM Plex Mono")

#let bfcell(
  len, // lenght of the fields in bits 
  content, 
  fill: none, // color to fill the field
  height: auto, // height of the field
) = cellx(colspan: len, fill: fill, inset: 0pt)[#box(height: height, width: 100%, stroke: 1pt + black)[#content]]


#let bytefield(
  bits: 32, 
  rowheight: 2.5em, 
  bitheader: auto, 
  msb_first: false,
  ..fields
) = {
  // state variables
  let col_count = 0
  let cells = ()

  // Define default behavior - show 
  if (bitheader == auto) { bitheader = "smart"}

  // calculate cells
  let current_offset = 0;
  let computed_offsets = ();
  for (idx, field) in fields.pos().enumerate() {
    let (size, content, fill, ..) = field;
    let remaining_cols = bits - col_count;
    col_count = calc.rem(col_count + size, bits);
    // if no size was specified
    if size == none {
      size = remaining_cols
      content = content + sym.star
    }

    computed_offsets.push(if (bitheader == "smart-firstline") { current_offset } else { calc.rem(current_offset,bits) } );
    current_offset += size;
    
    if size > bits and remaining_cols == bits and calc.rem(size, bits) == 0 {
      content = content + " (" + str(size) + " Bit)"
      cells.push(bfcell(int(bits),fill:fill, height: rowheight * size/bits)[#content])
      size = 0
    }

    while size > 0 {
      let width = calc.min(size, remaining_cols);
      size -= remaining_cols
      remaining_cols = bits
      cells.push(bfcell(int(width),fill:fill, height: rowheight,)[#content])
    }
  
  }
  
  computed_offsets.push(bits - 1);

  let bitheader_font_size = 9pt;
  let bh_num_text(num) = {
    let alignment = if (bitheader == "all") {center} 
    else {
      if (msb_first) {
        if (num == 0) {end} else if (num == (bits - 1)) { start } else { center }
      } else { 
        if (num == (bits - 1)) {end} else if (num == 0) { start } else { center }
      }
    }

    align(alignment, text(bitheader_font_size)[#num]);
  }


  let _bitheader = if ( bitheader == "all" ) {
    // Show all numbers from 0 to total bits.
    range(bits).map(i => bh_num_text(i))
  } else if ( bitheader == "smart" or bitheader == "smart-firstline") {
    // Show nums aligned with given fields
    if msb_first == true {
      computed_offsets = computed_offsets.map(i => bits - i - 1);
    }
    range(bits).map(i => if i in computed_offsets { bh_num_text(i) } else {none})
  } else if ( type(bitheader) == array ) {
    // show given numbers from array
    range(bits).map(i => if i in bitheader { bh_num_text(i) } else {none})
  } else if ( type(bitheader) == int ) {
    // if an int is given show all multiples of this number
    let val = bitheader;
    range(bits).map(i =>
      if calc.rem(i,val) == 0 or i == (bits - 1) { bh_num_text(i) } 
      else { none })
  } else if ( bitheader == none ) {
    range(bits).map(_ => []);
  } else if (type(bitheader) == dictionary) {
    range(bits).map(i => [
      #set align(start + bottom)
      #let h_text = bitheader.at(str(i),default: "");
      #style(styles => {
        let size = measure(h_text, styles).width
        return box(height: size, inset:(left: 50%))[
          
          #if (h_text != "" and bitheader.at("marker", default: auto) != none){ place(bottom, line(end:(0pt, 5pt))) }
          #rotate(bitheader.at("angle", default: -60deg), origin: left, h_text)
        ]  
      })
    ])
  } else {
     panic("bitheader must be an integer,array, none, 'all' or 'smart'")
  }

  // revers bit order
  if msb_first == true {
    _bitheader = _bitheader.rev()
  }
  
  box(width: 100%)[
    #gridx(
      columns: range(bits).map(i => 1fr),
      align: center + horizon,
      inset: (x:0pt, y: 4pt),
      .._bitheader,
      ..cells,
    )
  ]
}

// Low level API
#let bitbox(length_in_bits, content, fill: none) = (
  type: "bitbox",
  size: length_in_bits,   // length of the field 
  fill: fill,
  content: content,
  var: false, 
  show_size: false,
)

// High level API
#let bit(..args) = bitbox(1, ..args)
#let bits(len, ..args) = bitbox(len, ..args)
#let byte(..args) = bitbox(8, ..args)
#let bytes(len, ..args) = bitbox(len * 8, ..args)
#let padding(..args) = bitbox(none, ..args)

// Rotating text for flags
#let flagtext(text) = align(center,rotate(270deg,text))

// Common network protocols
#let ipv4 = bytefield(
  bits(4)[Version], bits(4)[TTL], bytes(1)[TOS], bytes(2)[Total Length],
  bytes(2)[Identification], bits(3)[Flags], bits(13)[Fragment Offset],
  bytes(1)[TTL], bytes(1)[Protocol], bytes(2)[Header Checksum],
  bytes(4)[Source Address],
  bytes(4)[Destination Address],
  bytes(3)[Options], bytes(1)[Padding]
)

#let ipv6 = bytefield(
  bits(4)[Version], bytes(1)[Traffic Class], bits(20)[Flowlabel],
  bytes(2)[Payload Length], bytes(1)[Next Header], bytes(1)[Hop Limit],
  bytes(128/8)[Source Address],
  bytes(128/8)[Destination Address],
)

#let icmp = bytefield(
  header: (0,8,16,31),
  byte[Type], byte[Code], bytes(2)[Checksum],
  bytes(2)[Identifier], bytes(2)[Sequence Number],
  padding[Optional Data ]
)

#let icmpv6 = bytefield(
  header: (0,8,16,31),
  byte[Type], byte[Code], bytes(2)[Checksum],
  padding[Internet Header + 64 bits of Original Data Datagram  ]
)

#let dns = bytefield(
  bytes(2)[Identification], bytes(2)[Flags],
  bytes(2)[Number of Questions], bytes(2)[Number of answer RRs],
  bytes(2)[Number of authority RRs], bytes(2)[Number of additional RRs],
  bytes(8)[Questions],
  bytes(8)[Answers (variable number of resource records) ],
  bytes(8)[Authority (variable number of resource records) ],
  bytes(8)[Additional information (variable number of resource records) ],
)

#let tcp = bytefield(
  bytes(2)[Source Port], bytes(2)[ Destinatino Port],
  bytes(4)[Sequence Number],
  bytes(4)[Acknowledgment Number],
  bits(4)[Data Offset],bits(6)[Reserved], bits(6)[Flags], bytes(2)[Window],
  bytes(2)[Checksum], bytes(2)[Urgent Pointer],
  bytes(3)[Options], byte[Padding],
  padding[...DATA...]
)



#let tcp_detailed = bytefield(
  bytes(2)[Source Port], bytes(2)[ Destinatino Port],
  bytes(4)[Sequence Number],
  bytes(4)[Acknowledgment Number],
  bits(4)[Data Offset],bits(6)[Reserved], bit[#flagtext("URG")], bit[#flagtext("ACK")], bit[#flagtext("PSH")], bit[#flagtext("RST")], bit[#flagtext("SYN")], bit[#flagtext("FIN")], bytes(2)[Window],
  bytes(2)[Checksum], bytes(2)[Urgent Pointer],
  bytes(3)[Options], byte[Padding],
  padding[...DATA...]
)

#let udp = bytefield(
  bitheader: (0,16,31),
  bytes(2)[Source Port], bytes(2)[ Destinatino Port],
  bytes(2)[Length], bytes(2)[Checksum],
  padding[...DATA...]
)

