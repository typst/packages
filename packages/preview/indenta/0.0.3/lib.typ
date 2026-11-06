// https://github.com/flaribbit/indenta
#let fix-indent(unsafe: false)={
  return it=>{
  let _is_block(e,fn)=fn==heading or (fn==math.equation and e.block) or (fn==raw and e.has("block") and e.block) or fn==figure or fn==block or fn==list.item or fn==enum.item or fn==table or fn==grid or fn==align
  // TODO: smallcaps returns styled(...)
  let _is_inline(e,fn)=fn==text or fn==box or (fn==math.equation and not e.block) or (fn==raw and not (e.has("block") and e.block)) or fn==highlight or fn==overline or fn==smartquote or fn==strike or fn==sub or fn==super or fn==underline
  let st=2
  for e in it.children{
    let fn=e.func()
    if fn==heading{
      st=2
    }else if _is_block(e,fn){
      st=1
    }else if st==1{
      if e==parbreak(){st=2}
      else if e!=[ ]{st=0}
    }else if st==2 and not (_is_block(e,fn) or e==[ ] or e==parbreak()){
      if unsafe or _is_inline(e,fn){context h(par.first-line-indent)}
      st=0
    }
    e
  }
}}
