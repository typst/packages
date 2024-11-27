open System

let cowsay (message: string) =
    let messageLength = message.Length
    let border = String.replicate (messageLength + 2) "-"
    let cow = @"
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
    "
    printfn $" {border}"
    printfn $"< {message} >"
    printfn $" {border}"
    printfn $"{cow}"

[<EntryPoint>]
let main argv =
    printf "Enter a message: "
    let input = Console.ReadLine()
    cowsay input
    0
