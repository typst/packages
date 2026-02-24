#import "utils.typ": is-sequence, is-kind, is-heading, is-metadata, padright, get-all-children

#let category(name)= metadata((kind: "quick-cards.category", name: name))
#let question(body, card-template:none) = metadata((kind: "quick-cards.question", body: body, template: card-template))
#let answer(body)=metadata((kind: "quick-cards.answer", body: body))
#let hint(body)=metadata((kind: "quick-cards.hint", body: body))

#let quick-cards-layout(
  columns: 2,
  rows: 4,
  cards: (front: [], back: []),
  stroke: (thickness: 1pt, paint: gray, cap: "round", dash: "loosely-dashed"),
  inset-width: 2em,
)={
  set page(margin: - stroke.thickness)
  let columnIndices = range(0 ,columns)
  let rowIndices = range(0,rows)

  let cellsPerPage = columns * rows
  let contentCount = cards.len()
  let pageCount = calc.ceil(contentCount / cellsPerPage) * 2

  let page_card_chunks = cards.chunks(cellsPerPage)
  for current_page_number in range(0, pageCount) {
    let chunkIndex = int(current_page_number / 2)
    let current_page_card_chunk = page_card_chunks.at(chunkIndex, default: ())

    let grid_contents = if calc.rem(current_page_number, 2) == 0 {
      current_page_card_chunk.map(x=> x.front)
    }else{
      // flip direction so the card backs match the fronts when doing double sided printing 
      current_page_card_chunk
      .map(x=>x.back)
      .chunks(columns)
      .map(x=> padright(x, columns).rev())
      .flatten()
    }
    
    grid(
      columns: (1fr,) * columns,
      rows: (1fr,) * rows,
      inset: inset-width,
      stroke: stroke,
      ..grid_contents
    )
    if current_page_number != pageCount - 1{
      pagebreak()  
    }
  }
}

#let quick-cards-show(
  columns:2,
  rows:4,
  stroke-width: 1pt,
  stroke-color: gray,
  inset-width: 2em,
  card-template:(question, answer, hint, category) => (front:question, back:answer),
  parse-body: true,
  body)={
    
  let children = get-all-children(body)
  
  let questions = ()
  let categories = ()
  let answers = ()
  let hints = ()
  let current-category = ""
  let current-answer = ()
  let current-question = none
  let current-hint = none
  
  for child in children {
    if is-metadata(child){
      if is-kind(child, "quick-cards.question"){
        if current-question != none{
          answers.push(current-answer.sum())
          questions.push((current-question, none))
          categories.push(current-category)
          hints.push(current-hint)
          current-question = none
          current-answer = ()
        }else if questions.len()> answers.len() and current-answer.len() != 0{
          answers.push(current-answer.sum())
          current-answer = ()
        }
        hints = padright(hints, questions.len())
        questions.push((child.value.body, child.value.template))
        categories.push(current-category)
      } else if is-kind(child, "quick-cards.answer"){
        if current-question != none{
          answers.push(current-answer.sum())
          questions.push((current-question, none))
          categories.push(current-category)
          hints.push(current-hint)
          current-hint = none
          current-question = none
          current-answer = ()
        }else if questions.len()> answers.len() and current-answer.len() != 0{
          answers.push(current-answer.sum())
          current-answer = ()
      }
        answers.push(child.value.body)
      } else if is-kind(child, "quick-cards.category"){
        if current-question != none{
          answers.push(current-answer.sum())
          // questions = padright(questions, answers.len())
          questions.push((current-question, none))
          categories.push(current-category)
          hints.push(current-hint)
          current-hint = none
          current-question = none
          current-answer = ()
        }else if questions.len()> answers.len() and current-answer.len() != 0{
          answers.push(current-answer.sum())
          current-answer = ()
        }
        current-category = if type(child.value.name) == content{child.value.name.at("text", default: "")} else{child.value.name}
      } else if is-kind(child, "quick-cards.hint") and (questions.len() > hints.len() or current-question != none){
        hints.push(child.value.body)
      }
      
    }
    else if parse-body{
      if is-heading(child, depth: 1){
        if current-question != none{
          answers = padright(answers, questions.len())
          answers.push(current-answer.sum())
          questions.push((current-question, none))
          categories.push(current-category)
          hints.push(current-hint)
        }else if questions.len()> answers.len() and current-answer.len() != 0{
          answers.push(current-answer.sum())
        }
        current-question = none
        current-answer = ()
        current-hint = none
        current-category = child.body.text
      } else if is-heading(child, depth: 2){
        if current-question != none{
          answers = padright(answers, questions.len())
          answers.push(current-answer.sum())
          questions.push((current-question, none))
          categories.push(current-category)
          hints.push(current-hint)
        } else if questions.len()> answers.len() and current-answer.len() != 0{
          answers.push(current-answer.sum())
        }
        current-answer = ()
        current-hint = none
        current-question = child.body
      } else if is-heading(child, depth: 3){
        current-hint = child.body
      }
      //skips some random bullshit that automatically gets added
      else if child != none and child != [] and child != [ ] and child.func() != parbreak{
        current-answer.push(child)
      }
    }
  }
  if current-question != none{
    answers = padright(answers, questions.len())
    questions = padright(questions, answers.len())
    answers.push(current-answer.sum())
    questions.push((current-question, none))
    categories.push(current-category)
    hints.push(current-hint)
  }else if questions.len()> answers.len() and current-answer.len() != 0{
    answers.push(current-answer.sum())
  }

  let cards = ()
  for value in range(0, calc.max(questions.len(), answers.len(), categories.len())) {
    let category = if value >= categories.len(){categories.at(categories.len(), default:"")}else{ categories.at(value, default:"")}
    let q = questions.at(value, default:none)
    let question = if q != none{q.at(0, default:none)} 
    let answer = answers.at(value, default:none)
    let hint = hints.at(value, default: none)
    let template = if q != none{q.at(1, default:none)}
    if template == none{template = card-template}
    
    cards.push(template(question: question, answer: answer, hint:hint, category: category))
  }

  if parse-body == false{
    body
    pagebreak()
  }
  quick-cards-layout(columns: columns, rows: rows, cards: cards)
}