#let fix-indent(len: 2em, unsafe: false)={
  return it=>{
  let st=0
  let _is_block(e,fn)=(fn==math.equation and e.block) or fn==figure or fn==block or fn==list.item or fn==enum.item
  let _is_inline(e,fn)=fn==text or (fn==math.equation and not e.block) or fn==box
  for e in it.children{
    let fn=e.func()
    if st==0{
      if fn==heading or _is_block(e,fn){st=1}
    }else if st==1{
      if fn==parbreak{st=2}
      else{st=0}
    }else if st==2{
      if _is_block(e,fn){st=1}
      else {
        if unsafe or _is_inline(e,fn){h(len)}
        st=0
      }
    }
    e
  }
}}
