#import "ankiconf.typ": *
#show: doc => conf(doc)

#let custom_card(
  id: "",
  Q: "",
  A: "",
  ..args
) = {
  card(
    id: id,
    Q: Q,
    A: A,
    container: true,
    show_labels: true
  )
}

#custom_card(
  id: "20241226124001",
  target_deck: "Molecular Structures",
  Q: "How are molecular connections represented in this structure?",
  A: [
    #skeletize({
      molecule(name: "A", "A")
      single()
      molecule("B")
      branch({
        single(angle: 1)
        molecule(
          "W",
          links: (
            "A": double(stroke: red),
          ),
        )
        single()
        molecule(name: "X", "X")
      })
      branch({
        single(angle: -1)
        molecule("Y")
        single()
        molecule(
          name: "Z",
          "Z",
          links: (
            "X": single(stroke: black + 3pt),
          ),
        )
      })
      single()
      molecule(
        "C",
        links: (
          "X": cram-filled-left(fill: blue),
          "Z": single(),
        ),
      )
    })
  ],
)

#custom_card(
  id: "20241226124002",
  target_deck: "Security",
  Q: "How to scan open ports on a local network?",
  A: [
    ```python
    import socket
    def scan_ports(ip, start_port, end_port):
    open_ports = []
    for port in range(start_port, end_port + 1):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.settimeout(0.5)
    if s.connect_ex((ip, port)) == 0:
    open_ports.append(port)
    return open_ports

    ip = "192.168.1.1"  # Change to the desired IP
    start_port, end_port = 1, 1024
    print(f"Open ports on {ip}: {scan_ports(ip, start_port, end_port)}")
    ```
  ],
)

#custom_card(
  id: "20241226123512",
  Q: "How is a conclusion derived from labeled premises in this rule structure?",
  A: [
    #let tree = rule(
      label: [Label],
      name: [Rule name],
      [Conclusion],
      [Premise 1],
      [Premise 2],
      [Premise 3]
    )
    #proof-tree(tree)
  ],
)
