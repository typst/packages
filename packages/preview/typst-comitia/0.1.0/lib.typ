#let p = plugin("./comitia.wasm")

// Generates ordinal indicators from numbers
#let xth(n) = {
  let x = if n == 1 {
    [st]
  } else if n == 2 {
    [nd]
  } else if n == 3 {
    [rd]
  } else {
    [th]
  }
  [*#n#super[#x]*]
}

// Adds a link to the current used method
#let method-link(method) = {
  if method == "Plurality" {
    link("https://en.wikipedia.org/wiki/Plurality_voting")[*Plurality*]
  } else if method == "STV" {
    link("https://en.wikipedia.org/wiki/Single_transferable_vote")[*STV*]
  } else {
    [*#method*]
  }
}

// Displays JSON data as a table
// Source: https://www.reddit.com/r/typst/comments/164v4pe/creating_tables_from_json_file/
// Credit goes to: a5sk6n
#let table-json(data) = {
  let keys = data.at(0).keys()
  table(
    columns: keys.len(),
    ..keys,
    ..data.map(
      row => keys.map(
        key => [#row.at(key, default: [n/a])]
      )
    ).flatten()
  )
}

// Adapted table-json(data) for displaying detailed voting results tables
#let details-table-json(data) = {
  let keys = data.at(0).keys()
  table(
    columns: keys.len(),
    [Run], [Candidate], [ID], [Votes], [Total Votes], [Percentage], [Winner], [Winner Candidate], [Eliminated], [Elem. Candidate],
    ..data.map(
      row => keys.map(
        key => {
          let value = row.at(key, default: [n/a])
          if key == "percentage" {
            value = calc.round(value*10)/10
          }
          [#value]
        }
      )
    ).flatten()
  )
}

// Returns the results for each iteration of voting
#let vote(ballots, method: "Plurality", tie-method : "All" ) = {
  let ballots = json.encode(ballots)
  let args = "{
      \"ballots\": "+ballots+",
      \"vote_method\": \""+method+"\",
      \"tie_method\": \""+tie-method+"\"
    }"

  json(p.vote(bytes(args)))
}

// Displays a detailled voting report for each step
#let vote-report(ballots, method: "Plurality", tie-method : "All", level-start : 4) = {
  let vote_results = vote(ballots, method : method, tie-method : tie-method)

  [
    #heading(level: level-start)[Report]

    #heading(level: level-start+1)[Method]

    We performed a *#method-link(method)* vote with *#tie-method* tie-breaking.

  ]

  let max_rounds = calc.max(..vote_results.map(r => r.run))
  let winners = vote_results.filter(r => r.is_winner)

  [
    #heading(level: level-start+1)[Results]

    The vote finished after *#max_rounds* rounds.

    The winner(s) is/are:
    #winners.map(w => [- *#w.candidate*]).join()

    #heading(level: level-start+2)[Details]
  ]

  for i in range(1, max_rounds + 1) {
    let round_results = vote_results.filter(r => r.run == i)
    let winner_candidates = round_results.filter(r => r.is_winner_candidate).map(r => r.candidate)
    let winners = round_results.filter(r => r.is_winner)
    let elimination_candidates = round_results.filter(r => r.is_elimination_candidate).map(r => r.candidate)
    let eliminated = round_results.filter(r => r.is_eliminated)

    let block_winner = [ We have not determined a winner yet. ]
    

    [

      #heading(level: level-start+3)[Round #i]

      We performed the #xth(i) round of the vote:

      #details-table-json(round_results)
    ]

    if winner_candidates.len() == 0 {  
      [ We have no winner candidates in this round. 
      
      ]
    }
    if winner_candidates.len() == 1 {  
      [ 
        We have found a winner: *#winner_candidates.first()*. 
        
      ]
    }
    if winner_candidates.len() > 1 {
      [ We have multiple winner candidates: #winner_candidates.map(c => [*#c*]).join([, ])

        We need to break the tie. The tie-breaking method is *#tie-method*. The final winner(s) is/are: #winners.map(w => [*#w.candidate*]).join([, ])
      
      ]
    }

    if elimination_candidates.len() == 0 {  
      [ 
        We have no elimination candidates in this round. 
      ]
    }
    if elimination_candidates.len() == 1 {  
      [ 
        We have found an elimination candidate: *#elimination_candidates.first()*. 
        
      ]
    }
    if elimination_candidates.len() > 1 {
      [ We have multiple elimination candidates: #elimination_candidates.map(c => [*#c*]).join(", ")

        We need to break the tie. The tie-breaking method is *#tie-method*. The final eliminated candidate(s) is/are: #eliminated.map(e => [*#e.candidate*]).join([, ]) 
      
      ]
    }
  }
}