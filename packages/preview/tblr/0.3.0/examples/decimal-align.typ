#import "../tblr.typ": *

#set page(height: auto, width: auto, margin: 0em)


#context tblr(columns: 1,
  align: center, inset: 3pt, stroke: none,
  col-apply(auto, decimal-align),
  // content
  "Text",
  "10000",
  "0.12345",
  ".1",
  "1.00",
  "300.",
  "hello&",
  "&hello",
  "3x",
  "30. mi.",
  "100,000 sq. mi.",
  "192.168.1.1 ip",
  "v1.0.2"
)


