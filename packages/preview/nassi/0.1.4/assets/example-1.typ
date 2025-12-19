#set page(width: 13cm, height:auto, margin: 5mm)

#import "../src/nassi.typ"
#show: nassi.shneiderman()

```nassi
function ggt(a, b)
  while a > 0 and b > 0
    if a > b
      a <- a - b
    else
      b <- b - a
    end if
  end while
  if b == 0
    return a
  else
    return b
  end if
end function
```
