#let fix-indent(unsafe: false)={
  return it=>{
  let st=0
  let _is_block(e,fn)=fn==heading or (fn==math.equation and e.block) or (fn==raw and e.block) or fn==figure or fn==block or fn==list.item or fn==enum.item or fn==table or fn==grid or fn==align
  let _is_inline(e,fn)=fn==text or fn==box or (fn==math.equation and not e.block) or (fn==raw and not e.block)
  for e in it.children{
    let fn=e.func()
    if st==0{
      if _is_block(e,fn){st=1}
    }else if st==1{
      if fn==parbreak{st=2}
      else if _is_block(e,fn) or e==[ ]{}
      else{st=0}
    }else if st==2{
      if _is_block(e,fn){st=1}
      else {
        if unsafe or _is_inline(e,fn){context h(par.first-line-indent)}
        st=0
      }
    }
    e
  }
}}
