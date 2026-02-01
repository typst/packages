// manual.typ — Documentation and examples for diagramgrid
#import "lib.typ": *

#set document(title: "diagramgrid Manual", author: "diagramgrid")
#set page(margin: 1.5cm)
#set text(size: 10pt)
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  text(size: 18pt, weight: "bold", it)
  v(0.5em)
}
#show heading.where(level: 2): it => {
  v(0.8em)
  text(size: 14pt, weight: "semibold", it)
  v(0.3em)
}

= diagramgrid Manual

A lightweight Typst package for creating clean block diagrams with CSS flexbox-like layouts.

== Example 1: Simple Vertical Layers

The most basic use case — a vertical stack of layers:

#figure(
  dg-layers(
    dg-rect([Presentation Layer], fill: rgb("#f8f9fa"), width: 200pt),
    dg-rect([Business Logic Layer], fill: rgb("#f8f9fa"), width: 200pt),
    dg-rect([Data Access Layer], fill: rgb("#f8f9fa"), width: 200pt),
    dg-rect([Database], fill: rgb("#f8f9fa"), width: 200pt),
  ),
  caption: [A simple four-tier architecture using vertical layers.],
)

```typst
#dg-layers(
  dg-rect([Presentation Layer], fill: rgb("#f8f9fa"), width: 200pt),
  dg-rect([Business Logic Layer], fill: rgb("#f8f9fa"), width: 200pt),
  dg-rect([Data Access Layer], fill: rgb("#f8f9fa"), width: 200pt),
  dg-rect([Database], fill: rgb("#f8f9fa"), width: 200pt),
)
```

== Example 2: Horizontal Components with Circles

Using `dg-flex` for horizontal layout and `dg-circle` for nodes:

#figure(
  dg-flex(
    direction: "row",
    justify: "center",
    gap: 1.2em,
    dg-circle([A], fill: rgb("#e3f2fd")),
    dg-circle([B], fill: rgb("#e8f5e9")),
    dg-circle([C], fill: rgb("#fff3e0")),
    dg-circle([D], fill: rgb("#fce4ec")),
  ),
  caption: [Horizontal row of circular nodes.],
)

```typst
#dg-flex(
  direction: "row",
  justify: "center",
  gap: 1.2em,
  dg-circle([A], fill: rgb("#e3f2fd")),
  dg-circle([B], fill: rgb("#e8f5e9")),
  dg-circle([C], fill: rgb("#fff3e0")),
  dg-circle([D], fill: rgb("#fce4ec")),
)
```

== Example 3: Nested Layout — Services Inside Layers

Combining `dg-layers` with nested `dg-flex`:

#figure(
  dg-layers(
    dg-rect([*Client Applications*], fill: rgb("#e2e8f0"), width: 280pt),
    dg-flex(
      direction: "row",
      justify: "center",
      dg-rect([API Gateway], fill: rgb("#dbeafe")),
      dg-rect([Auth Service], fill: rgb("#dcfce7")),
      dg-rect([Cache], fill: rgb("#fef3c7")),
    ),
    dg-flex(
      direction: "row",
      justify: "center",
      dg-rect([User Service], fill: rgb("#e0e7ff")),
      dg-rect([Order Service], fill: rgb("#e0e7ff")),
      dg-rect([Inventory], fill: rgb("#e0e7ff")),
    ),
    dg-rect([*Database Cluster*], fill: rgb("#e2e8f0"), width: 280pt),
  ),
  caption: [Nested layout with services grouped inside layers.],
)

```typst
#dg-layers(
  dg-rect([*Client Applications*], fill: rgb("#e2e8f0"), width: 280pt),
  dg-flex(
    direction: "row",
    justify: "center",
    dg-rect([API Gateway], fill: rgb("#dbeafe")),
    dg-rect([Auth Service], fill: rgb("#dcfce7")),
    dg-rect([Cache], fill: rgb("#fef3c7")),
  ),
  // ... more layers
)
```

== Example 4: Mixed Shapes

Combining rectangles, circles, and ellipses:

#figure(
  dg-flex(
    direction: "row",
    justify: "space-around",
    align-items: "center",
    gap: 1em,
    dg-rect([Storage], fill: rgb("#f3e8ff"), width: 80pt),
    dg-circle([Hub], fill: rgb("#fef9c3")),
    dg-ellipse([Processing Unit], fill: rgb("#dbeafe"), width: 100pt),
    dg-rect([Output], fill: rgb("#dcfce7"), width: 80pt),
  ),
  caption: [Mixed shapes: rectangles, circles, and ellipses.],
)

```typst
#dg-flex(
  direction: "row",
  justify: "space-around",
  align-items: "center",
  gap: 1em,
  dg-rect([Storage], fill: rgb("#f3e8ff"), width: 80pt),
  dg-circle([Hub], fill: rgb("#fef9c3")),
  dg-ellipse([Processing Unit], fill: rgb("#dbeafe"), width: 100pt),
  dg-rect([Output], fill: rgb("#dcfce7"), width: 80pt),
)
```

== Example 5: Themed Diagrams

Using the blueprint theme:

#figure(
  themed-layers(theme-blueprint,
    [Frontend Application],
    [API Layer],
    [Service Mesh],
    [Infrastructure],
  ),
  caption: [Blueprint theme with technical styling.],
)

Using the warm theme:

#figure(
  themed-layers(theme-warm,
    [User Interface],
    [Business Rules],
    [Data Store],
  ),
  caption: [Warm theme with softer colors.],
)

```typst
#themed-layers(theme-blueprint,
  [Frontend Application],
  [API Layer],
  [Service Mesh],
  [Infrastructure],
)

#themed-layers(theme-warm,
  [User Interface],
  [Business Rules],
  [Data Store],
)
```

== Example 6: Full Architecture (4 Levels Deep)

A realistic microservices architecture diagram:

#figure(
  dg-layers(
    // Level 1: Clients
    dg-flex(
      direction: "row",
      justify: "center",
      dg-rect([Web App], fill: rgb("#dbeafe")),
      dg-rect([Mobile App], fill: rgb("#dbeafe")),
      dg-rect([CLI], fill: rgb("#dbeafe")),
    ),
    // Level 2: Gateway & Bus
    dg-flex(
      direction: "row",
      justify: "center",
      dg-rect(
        dg-layers(
          dg-rect([API Gateway], fill: rgb("#fef3c7")),
          dg-flex(
            dg-rect([Rate Limit], fill: white, inset: 4pt),
            dg-rect([Auth], fill: white, inset: 4pt),
          ),
        ),
        fill: rgb("#fef3c7").lighten(50%),
        inset: 6pt,
      ),
      dg-rect(
        dg-layers(
          dg-rect([Event Bus], fill: rgb("#dcfce7")),
          dg-flex(
            dg-rect([Kafka], fill: white, inset: 4pt),
            dg-rect([Redis], fill: white, inset: 4pt),
          ),
        ),
        fill: rgb("#dcfce7").lighten(50%),
        inset: 6pt,
      ),
    ),
    // Level 3: Microservices
    dg-flex(
      direction: "row",
      justify: "center",
      dg-rect([Users], fill: rgb("#e0e7ff")),
      dg-rect([Orders], fill: rgb("#e0e7ff")),
      dg-rect([Products], fill: rgb("#e0e7ff")),
      dg-rect([Payments], fill: rgb("#e0e7ff")),
    ),
    // Level 4: Data stores
    dg-flex(
      direction: "row",
      justify: "center",
      dg-rect([PostgreSQL], fill: rgb("#f3e8ff")),
      dg-rect([MongoDB], fill: rgb("#f3e8ff")),
    ),
  ),
  caption: [Microservices architecture with clients, gateway, services, and data stores.],
)

== Example 7: Figure with Caption

Using diagramgrid inside a figure:

#figure(
  dg-layers(
    dg-rect([Input Processing], fill: rgb("#d1fae5"), width: 220pt),
    dg-flex(
      direction: "row",
      justify: "center",
      dg-rect([Transform], fill: white),
      dg-rect([Validate], fill: white),
      dg-rect([Enrich], fill: white),
    ),
    dg-rect([Output Generation], fill: rgb("#d1fae5"), width: 220pt),
  ),
  caption: [Data pipeline architecture showing the three-stage processing flow.],
)

```typst
#figure(
  dg-layers(
    dg-rect([Input Processing], fill: rgb("#d1fae5"), width: 220pt),
    dg-flex(
      justify: "center",
      dg-rect([Transform], fill: white),
      dg-rect([Validate], fill: white),
      dg-rect([Enrich], fill: white),
    ),
    dg-rect([Output Generation], fill: rgb("#d1fae5"), width: 220pt),
  ),
  caption: [Data pipeline architecture.],
)
```

== Function Reference

=== Shapes

*`dg-rect(content, ..options)`* — Rectangle block
- `width`, `height`: Dimensions (default: auto)
- `fill`: Background color
- `stroke`: Border (default: `0.8pt + luma(120)`)
- `radius`: Corner radius (default: `5pt`)
- `inset`: Padding (default: `(x: 8pt, y: 6pt)`)
- `content-align`: Content alignment (default: `center + horizon`)
- `header`: Header text/content displayed at top
- `header-fill`: Background color for header section
- `header-inset`: Padding for header (default: `(x: 8pt, y: 4pt)`)

*`dg-circle(content, ..options)`* — Circle block (same options, no radius)

*`dg-ellipse(content, ..options)`* — Ellipse block

=== Layouts

*`dg-flex(direction, justify, align-items, gap, ..children)`*
- `direction`: `"row"` or `"column"` (default: `"row"`)
- `justify`: `"start"`, `"center"`, `"end"`, `"space-between"`, `"space-around"`
- `align-items`: `"stretch"`, `"start"`, `"center"`, `"end"`
- `gap`: Spacing between items (default: `0.8em`)

*`dg-layers(gap, align-items, ..children)`*
- Vertical stack (shorthand for column flex)
- `gap`: Space between items (default: `0.5em`)
- `align-items`: Cross-axis alignment (default: `"center"`)

*`dg-group(width, height, padding, fill, stroke, ..children)`*
- Simple wrapper for grouping and adding space

=== Themes

Built-in themes: `theme-light`, `theme-dark`, `theme-blueprint`, `theme-warm`, `theme-minimal`

```typst
#themed-layers(theme-blueprint, [Layer 1], [Layer 2])
#themed-rect(theme-warm, [Block])
```

= SysML Internal Block Diagram Style

A SysML-style IBD showing internal structure of a Vehicle Control System. This demonstrates the characteristic nested parts with typed instances, stereotypes, and port-like interfaces.

#figure(
  // System boundary block with stereotype header
  dg-rect(
    dg-layers(
      gap: 0.3em,
      // Stereotype and block name header
      dg-rect(
        [#text(size: 8pt)[«block»] \ #text(weight: "bold")[VehicleControlSystem]],
        fill: rgb("#f1f5f9"),
        width: 380pt,
        stroke: none,
        inset: (x: 8pt, y: 4pt),
      ),
      // Internal parts
      dg-flex(
        justify: "center",
        gap: 1em,
        // Sensor Subsystem part
        dg-rect(
          dg-layers(
            gap: 0.2em,
            dg-rect(
              [#text(size: 7pt)[sensors : SensorSubsystem]],
              fill: rgb("#dbeafe"),
              stroke: none,
              inset: 3pt,
            ),
            dg-flex(
              gap: 0.5em,
              dg-rect([lidar : LiDAR], fill: white, inset: 4pt),
              dg-rect([camera : Camera], fill: white, inset: 4pt),
            ),
            dg-flex(
              gap: 0.5em,
              dg-rect([radar : Radar], fill: white, inset: 4pt),
              dg-rect([imu : IMU], fill: white, inset: 4pt),
            ),
          ),
          fill: rgb("#dbeafe").lighten(60%),
          inset: 6pt,
        ),
        // Processing Unit part
        dg-rect(
          dg-layers(
            gap: 0.2em,
            dg-rect(
              [#text(size: 7pt)[processor : ProcessingUnit]],
              fill: rgb("#dcfce7"),
              stroke: none,
              inset: 3pt,
            ),
            dg-rect([fusion : SensorFusion], fill: white, inset: 4pt),
            dg-rect([planner : PathPlanner], fill: white, inset: 4pt),
            dg-rect([controller : MotionCtrl], fill: white, inset: 4pt),
          ),
          fill: rgb("#dcfce7").lighten(60%),
          inset: 6pt,
        ),
        // Actuator Subsystem part
        dg-rect(
          dg-layers(
            gap: 0.2em,
            dg-rect(
              [#text(size: 7pt)[actuators : ActuatorSubsystem]],
              fill: rgb("#f3e8ff"),
              stroke: none,
              inset: 3pt,
            ),
            dg-rect([steering : SteerCtrl], fill: white, inset: 4pt),
            dg-rect([throttle : ThrottleCtrl], fill: white, inset: 4pt),
            dg-rect([brake : BrakeCtrl], fill: white, inset: 4pt),
          ),
          fill: rgb("#f3e8ff").lighten(60%),
          inset: 6pt,
        ),
      ),
    ),
    fill: rgb("#f8fafc"),
    stroke: 1.2pt + rgb("#334155"),
    inset: 8pt,
  ),
  caption: [SysML Internal Block Diagram for a Vehicle Control System.],
)

The diagram uses:
- *Stereotype headers* (`«block»`) identifying the block type
- *Typed parts* (`name : Type` notation) showing instances
- *Nested composition* showing internal structure of subsystems

```typst
dg-rect(
  dg-layers(
    // Stereotype header
    dg-rect([#text(size: 8pt)[«block»] \ #text(weight: "bold")[SystemName]], ...),
    // Internal parts row
    dg-flex(
      // Each part with typed name
      dg-rect(
        dg-layers(
          dg-rect([partName : PartType], ...),
          // Nested components...
        ),
        fill: color.lighten(60%),
      ),
    ),
  ),
  stroke: 1.2pt + rgb("#334155"),  // System boundary
)
```

= AOSP Architecture Diagram

The standard Android Open Source Project architecture stack, showing the layered system design from Linux kernel to applications.

#let aosp-green = rgb("#a4c639")
#let aosp-blue = rgb("#3b82f6")
#let aosp-red = rgb("#ef4444")
#let aosp-yellow = rgb("#fbbf24")
#let aosp-gray = rgb("#6b7280")

#figure(
  dg-layers(
    gap: 0.4em,
    // System Apps layer
    dg-rect(
      dg-layers(
        gap: 0.2em,
        dg-rect([*System Apps*], fill: aosp-green.lighten(20%), stroke: none, width: 420pt),
        dg-flex(
          justify: "center",
          gap: 0.4em,
          dg-rect([Dialer], fill: aosp-green.lighten(60%), inset: 5pt),
          dg-rect([Email], fill: aosp-green.lighten(60%), inset: 5pt),
          dg-rect([Calendar], fill: aosp-green.lighten(60%), inset: 5pt),
          dg-rect([Camera], fill: aosp-green.lighten(60%), inset: 5pt),
          dg-rect([Browser], fill: aosp-green.lighten(60%), inset: 5pt),
          dg-rect([...], fill: aosp-green.lighten(60%), inset: 5pt),
        ),
      ),
      fill: aosp-green.lighten(80%),
      inset: 6pt,
      width: 440pt,
    ),
    // Java API Framework
    dg-rect(
      dg-layers(
        gap: 0.2em,
        dg-rect([*Java API Framework*], fill: aosp-blue.lighten(20%), stroke: none, width: 420pt),
        dg-flex(
          justify: "center",
          gap: 0.4em,
          dg-rect([Content Providers], fill: aosp-blue.lighten(70%), inset: 5pt),
          dg-rect([View System], fill: aosp-blue.lighten(70%), inset: 5pt),
          dg-rect([Managers], fill: aosp-blue.lighten(70%), inset: 5pt),
        ),
        dg-flex(
          justify: "center",
          gap: 0.4em,
          dg-rect([Activity], fill: aosp-blue.lighten(80%), inset: 4pt),
          dg-rect([Window], fill: aosp-blue.lighten(80%), inset: 4pt),
          dg-rect([Package], fill: aosp-blue.lighten(80%), inset: 4pt),
          dg-rect([Telephony], fill: aosp-blue.lighten(80%), inset: 4pt),
          dg-rect([Resource], fill: aosp-blue.lighten(80%), inset: 4pt),
          dg-rect([Location], fill: aosp-blue.lighten(80%), inset: 4pt),
          dg-rect([Notification], fill: aosp-blue.lighten(80%), inset: 4pt),
        ),
      ),
      fill: aosp-blue.lighten(85%),
      inset: 6pt,
      width: 440pt,
    ),
    // Native Libraries + Android Runtime (side by side)
    dg-flex(
      justify: "center",
      gap: 0.4em,
      // Native C/C++ Libraries
      dg-rect(
        dg-layers(
          gap: 0.2em,
          dg-rect([*Native C/C++ Libraries*], fill: aosp-blue.lighten(30%), stroke: none),
          dg-flex(
            gap: 0.3em,
            dg-rect([Webkit], fill: aosp-blue.lighten(75%), inset: 4pt),
            dg-rect([Libc], fill: aosp-blue.lighten(75%), inset: 4pt),
          ),
          dg-flex(
            gap: 0.3em,
            dg-rect([Media], fill: aosp-blue.lighten(75%), inset: 4pt),
            dg-rect([OpenGL ES], fill: aosp-blue.lighten(75%), inset: 4pt),
          ),
          dg-flex(
            gap: 0.3em,
            dg-rect([SQLite], fill: aosp-blue.lighten(75%), inset: 4pt),
            dg-rect([SSL], fill: aosp-blue.lighten(75%), inset: 4pt),
          ),
        ),
        fill: aosp-blue.lighten(88%),
        inset: 6pt,
      ),
      // Android Runtime
      dg-rect(
        dg-layers(
          gap: 0.2em,
          dg-rect([*Android Runtime*], fill: aosp-yellow.lighten(20%), stroke: none),
          dg-rect([Android Runtime (ART)], fill: aosp-yellow.lighten(60%), inset: 5pt),
          dg-rect([Core Libraries], fill: aosp-yellow.lighten(60%), inset: 5pt),
        ),
        fill: aosp-yellow.lighten(80%),
        inset: 6pt,
      ),
    ),
    // Hardware Abstraction Layer
    dg-rect(
      dg-layers(
        gap: 0.2em,
        dg-rect([*Hardware Abstraction Layer (HAL)*], fill: aosp-green.lighten(30%), stroke: none, width: 420pt),
        dg-flex(
          justify: "center",
          gap: 0.4em,
          dg-rect([Audio], fill: aosp-green.lighten(70%), inset: 4pt),
          dg-rect([Bluetooth], fill: aosp-green.lighten(70%), inset: 4pt),
          dg-rect([Camera], fill: aosp-green.lighten(70%), inset: 4pt),
          dg-rect([Sensors], fill: aosp-green.lighten(70%), inset: 4pt),
          dg-rect([Graphics], fill: aosp-green.lighten(70%), inset: 4pt),
          dg-rect([...], fill: aosp-green.lighten(70%), inset: 4pt),
        ),
      ),
      fill: aosp-green.lighten(85%),
      inset: 6pt,
      width: 440pt,
    ),
    // Linux Kernel
    dg-rect(
      dg-layers(
        gap: 0.2em,
        dg-rect([*Linux Kernel*], fill: aosp-red.lighten(20%), stroke: none, width: 420pt),
        dg-flex(
          justify: "center",
          gap: 0.3em,
          dg-rect([Audio], fill: aosp-red.lighten(70%), inset: 4pt),
          dg-rect([Binder], fill: aosp-red.lighten(70%), inset: 4pt),
          dg-rect([Display], fill: aosp-red.lighten(70%), inset: 4pt),
          dg-rect([Camera], fill: aosp-red.lighten(70%), inset: 4pt),
          dg-rect([USB], fill: aosp-red.lighten(70%), inset: 4pt),
          dg-rect([WiFi], fill: aosp-red.lighten(70%), inset: 4pt),
          dg-rect([Power], fill: aosp-red.lighten(70%), inset: 4pt),
        ),
      ),
      fill: aosp-red.lighten(85%),
      inset: 6pt,
      width: 440pt,
    ),
  ),
  caption: [Android Open Source Project (AOSP) architecture stack.],
)

The classic 5-layer Android stack:
- *System Apps* — Pre-installed applications (green)
- *Java API Framework* — Android SDK APIs and managers (blue)
- *Native Libraries + Runtime* — C/C++ libs and ART side-by-side (blue/yellow)
- *HAL* — Hardware abstraction interfaces (green)
- *Linux Kernel* — Drivers and core OS (red)

= Decorators

Decorators add visual annotations to shapes like stereotypes, status indicators, and more.

== Stereotype Labels

Add UML-style stereotype labels using the convenience `stereotype` parameter:

#figure(
  dg-flex(
    gap: 1.5em,
    dg-rect([UserService], stereotype: "service", fill: rgb("#dbeafe")),
    dg-rect([IRepository], stereotype: "interface", fill: rgb("#dcfce7")),
    dg-rect([BaseEntity], stereotype: "abstract", fill: rgb("#fef3c7")),
  ),
  caption: [Stereotype labels for service, interface, and abstract types.],
)

```typst
#dg-rect([UserService], stereotype: "service", fill: rgb("#dbeafe"))
#dg-rect([IRepository], stereotype: "interface", fill: rgb("#dcfce7"))
#dg-rect([BaseEntity], stereotype: "abstract", fill: rgb("#fef3c7"))
```

== Status Indicators

Add status dots to show component health or state:

#figure(
  dg-flex(
    gap: 1.5em,
    dg-rect([Database], status: green, fill: rgb("#f0fdf4")),
    dg-rect([Cache], status: yellow, fill: rgb("#fefce8")),
    dg-rect([External API], status: red, fill: rgb("#fef2f2")),
  ),
  caption: [Status indicators showing healthy, warning, and error states.],
)

```typst
#dg-rect([Database], status: green, fill: rgb("#f0fdf4"))
#dg-rect([Cache], status: yellow, fill: rgb("#fefce8"))
#dg-rect([External API], status: red, fill: rgb("#fef2f2"))
```

== Combining Decorators

Use both stereotype and status together:

#figure(
  dg-flex(
    gap: 1.5em,
    dg-rect([OrderService], stereotype: "service", status: green, fill: rgb("#e0e7ff")),
    dg-rect([PaymentGateway], stereotype: "external", status: orange, fill: rgb("#fff7ed")),
  ),
  caption: [Combined stereotype labels and status indicators.],
)

```typst
#dg-rect([OrderService], stereotype: "service", status: green)
#dg-rect([PaymentGateway], stereotype: "external", status: orange)
```

== Explicit Decorator List

For full control, use the `decorators` parameter with constructor functions:

#figure(
  dg-rect(
    [Component],
    fill: rgb("#f1f5f9"),
    decorators: (
      dg-stereotype("controller", fill: rgb("#dbeafe")),
      dg-status(blue, position: "top-right", size: 8pt),
    )
  ),
  caption: [Explicit decorator list with custom positioning.],
)

```typst
#dg-rect(
  [Component],
  decorators: (
    dg-stereotype("controller", fill: rgb("#dbeafe")),
    dg-status(blue, position: "top-right", size: 8pt),
  )
)
```

== Stroke Presets

Use stroke presets for planned, optional, or tentative elements:

#figure(
  dg-flex(
    gap: 1.5em,
    dg-rect([Current Feature], fill: rgb("#f0fdf4")),
    dg-rect([Planned Feature], stroke: stroke-dashed, fill: rgb("#f8fafc")),
    dg-rect([Optional Module], stroke: stroke-dotted, fill: rgb("#f8fafc")),
    dg-rect([Future Work], stroke: stroke-planned, fill: rgb("#fafafa")),
  ),
  caption: [Stroke presets: solid, dashed, dotted, and planned styles.],
)

```typst
#dg-rect([Current Feature], fill: rgb("#f0fdf4"))
#dg-rect([Planned Feature], stroke: stroke-dashed)
#dg-rect([Optional Module], stroke: stroke-dotted)
#dg-rect([Future Work], stroke: stroke-planned)
```

= Container Headers

Headers provide title bars for container elements, useful for labeling nested diagrams and grouped components.

== Basic Header

Add a header to any rectangle using the `header` parameter:

#figure(
  dg-rect(
    dg-flex(
      dg-rect([Service A], fill: white),
      dg-rect([Service B], fill: white),
    ),
    header: "API Gateway",
    fill: rgb("#dbeafe"),
  ),
  caption: [Simple header on a container element.],
)

```typst
#dg-rect(
  dg-flex(
    dg-rect([Service A], fill: white),
    dg-rect([Service B], fill: white),
  ),
  header: "API Gateway",
  fill: rgb("#dbeafe"),
)
```

== Header with Distinct Fill

Use `header-fill` to give the header a different background color:

#figure(
  dg-rect(
    dg-layers(
      dg-rect([Component 1], fill: white),
      dg-rect([Component 2], fill: white),
    ),
    header: text(fill: white, weight: "bold")[Container Name],
    header-fill: rgb("#1e293b"),
    fill: rgb("#f1f5f9"),
  ),
  caption: [Header with distinct dark background.],
)

```typst
#dg-rect(
  dg-layers(
    dg-rect([Component 1], fill: white),
    dg-rect([Component 2], fill: white),
  ),
  header: text(fill: white, weight: "bold")[Container Name],
  header-fill: rgb("#1e293b"),
  fill: rgb("#f1f5f9"),
)
```

== Nested Containers with Headers

Headers work well with deeply nested structures:

#figure(
  dg-rect(
    dg-flex(
      gap: 1em,
      dg-rect(
        dg-layers(
          dg-rect([Auth], fill: white, inset: 4pt),
          dg-rect([Users], fill: white, inset: 4pt),
        ),
        header: "Identity",
        header-fill: rgb("#dbeafe"),
        fill: rgb("#dbeafe").lighten(60%),
        inset: 6pt,
      ),
      dg-rect(
        dg-layers(
          dg-rect([Orders], fill: white, inset: 4pt),
          dg-rect([Inventory], fill: white, inset: 4pt),
        ),
        header: "Commerce",
        header-fill: rgb("#dcfce7"),
        fill: rgb("#dcfce7").lighten(60%),
        inset: 6pt,
      ),
    ),
    header: text(fill: white, weight: "bold")[Microservices Platform],
    header-fill: rgb("#334155"),
    fill: rgb("#f8fafc"),
    inset: 8pt,
  ),
  caption: [Nested containers with headers at multiple levels.],
)

```typst
#dg-rect(
  dg-flex(
    gap: 1em,
    dg-rect(
      dg-layers(...),
      header: "Identity",
      header-fill: rgb("#dbeafe"),
      fill: rgb("#dbeafe").lighten(60%),
    ),
    dg-rect(
      dg-layers(...),
      header: "Commerce",
      header-fill: rgb("#dcfce7"),
      fill: rgb("#dcfce7").lighten(60%),
    ),
  ),
  header: text(fill: white, weight: "bold")[Microservices Platform],
  header-fill: rgb("#334155"),
  fill: rgb("#f8fafc"),
)
```

== Headers with Decorators

Headers can be combined with stereotype and status decorators:

#figure(
  dg-flex(
    gap: 1.5em,
    dg-rect(
      dg-rect([Database], fill: white),
      header: "Data Layer",
      fill: rgb("#f3e8ff"),
      stereotype: "subsystem",
    ),
    dg-rect(
      dg-flex(
        dg-rect([API], fill: white, inset: 4pt),
        dg-rect([Auth], fill: white, inset: 4pt),
      ),
      header: "Gateway",
      fill: rgb("#dcfce7"),
      status: green,
    ),
  ),
  caption: [Headers combined with stereotype labels and status indicators.],
)

```typst
#dg-rect(
  dg-rect([Database], fill: white),
  header: "Data Layer",
  fill: rgb("#f3e8ff"),
  stereotype: "subsystem",
)
```

= Landscape Full-Page Diagram

For large diagrams, use a landscape page. Wrap your diagram in a `page()` call with `flipped: true`:

#page(flipped: true, margin: 1cm)[
  #figure(
    dg-rect(
      dg-layers(
        gap: 0.6em,
        // Top layer: External systems
        dg-flex(
          justify: "space-around",
          gap: 1em,
          dg-rect([Partner Portal], stereotype: "external", fill: rgb("#fef3c7"), width: 120pt),
          dg-rect([Mobile Apps], stereotype: "external", fill: rgb("#fef3c7"), width: 120pt),
          dg-rect([Web Frontend], stereotype: "external", fill: rgb("#fef3c7"), width: 120pt),
          dg-rect([Third-party APIs], stereotype: "external", fill: rgb("#fef3c7"), width: 120pt),
        ),
        // API Gateway layer
        dg-rect(
          dg-flex(
            justify: "center",
            gap: 2em,
            dg-rect([Auth], fill: white, inset: 6pt),
            dg-rect([Rate Limiting], fill: white, inset: 6pt),
            dg-rect([Routing], fill: white, inset: 6pt),
            dg-rect([Logging], fill: white, inset: 6pt),
          ),
          stereotype: "gateway",
          fill: rgb("#dbeafe"),
          width: 90%,
          inset: 10pt,
        ),
        // Services layer
        dg-flex(
          justify: "center",
          gap: 1em,
          dg-rect(
            dg-flex(gap: 0.5em,
              dg-rect([Users], status: green, fill: white, inset: 5pt),
              dg-rect([Auth], status: green, fill: white, inset: 5pt),
            ),
            header: text(weight: "bold")[User Domain],
            header-fill: rgb("#c7d2fe"),
            fill: rgb("#e0e7ff"),
            inset: 8pt,
          ),
          dg-rect(
            dg-flex(gap: 0.5em,
              dg-rect([Orders], status: green, fill: white, inset: 5pt),
              dg-rect([Cart], status: yellow, fill: white, inset: 5pt),
            ),
            header: text(weight: "bold")[Order Domain],
            header-fill: rgb("#c7d2fe"),
            fill: rgb("#e0e7ff"),
            inset: 8pt,
          ),
          dg-rect(
            dg-flex(gap: 0.5em,
              dg-rect([Catalog], status: green, fill: white, inset: 5pt),
              dg-rect([Inventory], status: green, fill: white, inset: 5pt),
            ),
            header: text(weight: "bold")[Product Domain],
            header-fill: rgb("#c7d2fe"),
            fill: rgb("#e0e7ff"),
            inset: 8pt,
          ),
          dg-rect(
            dg-flex(gap: 0.5em,
              dg-rect([Payments], status: green, fill: white, inset: 5pt),
              dg-rect([Billing], status: red, fill: white, inset: 5pt),
            ),
            header: text(weight: "bold")[Payment Domain],
            header-fill: rgb("#c7d2fe"),
            fill: rgb("#e0e7ff"),
            inset: 8pt,
          ),
        ),
        // Message bus
        dg-rect([*Event Bus* #h(2em) Kafka / RabbitMQ], stereotype: "infrastructure", fill: rgb("#dcfce7"), width: 90%),
        // Data layer
        dg-flex(
          justify: "center",
          gap: 1.5em,
          dg-rect([PostgreSQL], stereotype: "database", fill: rgb("#f3e8ff")),
          dg-rect([MongoDB], stereotype: "database", fill: rgb("#f3e8ff")),
          dg-rect([Redis Cache], stereotype: "cache", fill: rgb("#fce7f3")),
          dg-rect([Elasticsearch], stereotype: "search", fill: rgb("#cffafe")),
        ),
      ),
      header: text(fill: white, weight: "bold", size: 14pt)[Enterprise Integration Platform],
      header-fill: rgb("#1e293b"),
      header-inset: 12pt,
      fill: rgb("#f8fafc"),
      stroke: 1pt + rgb("#334155"),
      inset: 10pt,
    ),
    caption: [Enterprise Integration Platform — full landscape page layout with domain-driven microservices.],
  )
]

```typst
#page(flipped: true, margin: 1cm)[
  #dg-rect(
    dg-layers(
      // External systems row
      dg-flex(...),
      // Domain services with headers
      dg-flex(
        dg-rect(
          dg-flex(...services...),
          header: text(weight: "bold")[User Domain],
          header-fill: rgb("#c7d2fe"),
          fill: rgb("#e0e7ff"),
        ),
        // More domains...
      ),
      // Data layer
      dg-flex(...),
    ),
    header: text(fill: white, weight: "bold")[Platform Name],
    header-fill: rgb("#1e293b"),
    fill: rgb("#f8fafc"),
  )
]
```

= Deep Recursion Example

Here's a multi-level architecture diagram showing nested components:

#figure(
  dg-layers(
    // Top label
    dg-rect([*Cloud Platform*], fill: rgb("#e2e8f0"), width: 320pt),
    // Middle section with nested boxes
    dg-flex(
      justify: "center",
      // Load Balancer group
      dg-rect(
        dg-layers(
          dg-rect([*Load Balancers*], fill: rgb("#dbeafe")),
          dg-flex(
            dg-rect([LB-1], fill: white, inset: 4pt),
            dg-rect([LB-2], fill: white, inset: 4pt),
          ),
        ),
        fill: rgb("#dbeafe").lighten(60%),
        inset: 6pt,
      ),
      // API Gateway group
      dg-rect(
        dg-layers(
          dg-rect([*API Gateway*], fill: rgb("#dcfce7")),
          dg-flex(
            dg-rect([Auth], fill: white, inset: 4pt),
            dg-rect([Rate], fill: white, inset: 4pt),
          ),
          dg-flex(
            dg-circle([REST], fill: rgb("#fef9c3")),
            dg-circle([gRPC], fill: rgb("#fef9c3")),
          ),
        ),
        fill: rgb("#dcfce7").lighten(60%),
        inset: 6pt,
      ),
    ),
    // Services row
    dg-flex(
      justify: "center",
      dg-rect([Users], fill: rgb("#fef3c7")),
      dg-rect([Orders], fill: rgb("#fef3c7")),
      dg-rect([Products], fill: rgb("#fef3c7")),
    ),
    // Database row
    dg-flex(
      justify: "center",
      dg-rect([PostgreSQL], fill: rgb("#f3e8ff")),
      dg-rect([Redis], fill: rgb("#f3e8ff")),
    ),
    // Bottom label
    dg-rect([*Kubernetes*], fill: rgb("#e2e8f0"), width: 320pt),
  ),
  caption: [Cloud platform architecture with deeply nested components.],
)
