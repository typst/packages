#import "question.typ": *
#import "solution.typ": *
#import "clarification.typ": *

#let __sugar(content) = {
  show regex("=\?"): it => {
      let (sugar, ..rest) = it.text.split("?")

      if sugar == "=" {        
        question[]
      }
      else {
        [#it]
      }
    }

  show regex("=\?(.+)"): it => {
      let (sugar, ..rest) = it.text.split("?")

      if sugar == "=" {
        question[#rest.join("?").trim()]
      }
      else {
        [#it]
      }
    }

  show regex("=(\d+\.?\d*)\?"): it => {
      let (sugar, ..rest) = it.text.split("?")

      if sugar.starts-with("=") {
        let points = float(sugar.slice(1))
        question(points: points)[]
      }
      else {
        [#it]
      }
    }

  show regex("=(\d+\.?\d*)\?(.+)"): it => {
      let (sugar, ..rest) = it.text.split("?")
      if sugar.starts-with("=") {
        let points = float(sugar.slice(1))
        question(points: points)[#rest.join("?")]
      }
      else {
        [#it]
      }
    }

  show regex("==\?"): it => {
      let (sugar, ..rest) = it.text.split("?")

      if sugar == "==" {       
        subquestion[]
      }
      else {
        [#it]
      }
    }

  show regex("==\?(.+)"): it => {
      let (sugar, ..rest) = it.text.split("?")

      if sugar == "==" {
        subquestion[#rest.join("?").trim()]
      }
      else {
        [#it]
      }
    }

  show regex("==(\d+\.?\d*)\?"): it => {
      let (sugar, ..rest) = it.text.split("?")

      if sugar.starts-with("==") {
        let points = float(sugar.slice(2))
        subquestion(points: points)[]
      }
      else {
        [#it]
      }
    }

  show regex("==(\d+\.?\d*)\?(.+)"): it => {
      let (sugar, ..rest) = it.text.split("?")

      if sugar.starts-with("==") {
        let points = float(sugar.slice(2))
        subquestion(points: points)[#rest.join("?")]
      }
      else {
        [#it]
      }
    }
  
  show regex("=\!"): it => {
      let (sugar, ..rest) = it.text.split("!")

      if(sugar == "=") {        
        solution[]
      }
      else {
        [#it]
      }
    }

  show regex("=\!(.+)"): it => {
      let (sugar, ..rest) = it.text.split("!")

      if(sugar == "=") {
        solution[#rest.join("!").trim()]
      }
      else {
        [#it]
      }
    }

  show regex("=\%"): it => {
      let (sugar, ..rest) = it.text.split("%")

      if(sugar == "=") {        
        clarification[]
      }
      else {
        [#it]
      }
    }

  show regex("=\%(.+)"): it => {
      let (sugar, ..rest) = it.text.split("%")

      if(sugar == "=") {
        clarification[#rest.join("%").trim()]
      }
      else {
        [#it]
      }
    }

  content
}