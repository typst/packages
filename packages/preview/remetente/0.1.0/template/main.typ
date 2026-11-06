#import "@preview/remetente:0.1.0": letter

#show: letter.with(
  // Sender address displayed at the top right of the first page
  sender-address: [
    Sender's Name \
    #emph[
      1 Example Street \
      Sampleton, Sampleshire \
      WX1 2YZ
    ]
  ],
  // Recipient address displayed below the sender address
  recipient-address: [
    Recipient's Name \
    #emph[
      2 Somewhere Avenue \
      Somewhereton \
      AB8 9CD
    ]
  ],
  // Letter's date
  date: [4 October 1905],
  // Letter's subject displayed in bold
  subject: [Very important subject matter],
  // Letter's closing signature(s)
  signature: [Sender's Name],
  // Content displayed in the coloured band at the top of the page
  band-content: text(fill: rgb("#2B58A2"), weight: "bold", size: 20pt)[Logo],
  // Only draw the header band on the first page
  first-page-header: true,
)

Dear Mr. Recipient,

// Write the body of your letter here
#lorem(99)

Sincerely,
