#import "info.typ": *

#let get-song-font(info) = {
  return info.at(info-keys-private.字体).宋体
}

#let get-hei-font(info) = {
  return info.at(info-keys-private.字体).黑体
}

#let get-mono-font(info) = {
  return info.at(info-keys-private.字体).等宽
}
