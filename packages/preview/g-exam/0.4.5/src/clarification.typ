#import"./global.typ": *

///  Show a clarification.
///    - size(length): Size of clarification.
///    - body(string, content):  Body of clarification.
#let clarification(size:8pt, body) = { 
  text(size:size)[$(*)$ #body] 
}

#let g-clarification(size:8pt, body) = {
  clarification(size: size)[body]
}