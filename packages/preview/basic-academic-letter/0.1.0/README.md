# Basic Academic Letter Typst Template

A clean and professional letter template for [Typst](https://typst.app/), designed for academic use.

- Extremely concise, no additional dependencies
- Professional layout
- Customizable margins and spacing
- Customizable main color

<table>
<tr>
  <td>
    <a href="examples/THU/THU.typ">
      <img src="examples/THU/THU-thumbnail.png" width="250px">
    </a>
  </td>
  <td>
    <a href="examples/UESTC/UESTC.typ">
      <img src="examples/UESTC/UESTC-thumbnail.png" width="250px">
    </a>
  </td>
  <td>
    <a href="examples/HITSZ/HITSZ.typ">
      <img src="examples/HITSZ/HITSZ-thumbnail.png" width="250px">
    </a>
  </td>
</tr>
<tr>
  <td style="text-align: center;">THU</td>
  <td style="text-align: center;">UESTC</td>
  <td style="text-align: center;">HIT</td>
</tr>
</table>

**Click the image to view source code**

## Usage
Use the following CLI command to directly install and start this template. Typst will automatically create the relevant directories and default to the THU template.

```bash
typst init @preview/basic-academic-letter
```

Or you can also search and use this template in [Typst Universe](https://typst.app/universe/) in an online manner.

## Configuration

```typst
#show: basic-academic-letter.with(
  // Institutional information
  main-color: rgb("#641C78"),
  logo-img: image("assets/logo.jpg", width: 80%),
  signature-img: image("assets/signature.png", height: 30pt),
  school: [School of Computer Science],
  university: [Your University],
  site: [123 University Ave, City, State 12345],
  phone: [+1 234 567 8900],
  website: [https://university.edu],

  // Personal information
  per-name: "Dr. Jane Smith",
  per-homepage: "https://university.edu/faculty/jane-smith",
  per-title: "Professor",
  per-school: "School of Computer Science",
  per-university: "Your University",
  per-email: "jane.smith@university.edu",

  // Letter content
  salutation: [To the Admission Committee,],
  closing: [Sincerely,],

  // ... other parameters ...

  // Spacing customization
  header-bottom-margin: 0cm,      // Space after header
  date-bottom-margin: 0.8cm,      // Space after date
  salutation-bottom-margin: 0.6cm, // Space after salutation
  body-bottom-margin: 0.8cm,      // Space after body
  closing-bottom-margin: 0cm,     // Space after closing
  signature-bottom-margin: 0cm,   // Space after signature
)

// Your letter content goes here
I am pleased to recommend [Student Name] for admission to your graduate program...
```

## Parameters Reference

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `logo-img` | image | Institution logo |
| `signature-img` | image | Personal signature |
| `school` | content | School/department name |
| `university` | content | University name |
| `site` | content | Address |
| `phone` | content | Phone number |
| `website` | content | Website URL |
| `per-name` | str | Your name |
| `per-homepage` | str | Your homepage URL |
| `per-title` | str | Your title |
| `per-school` | str | Your school |
| `per-university` | str | Your university |
| `per-email` | str | Your email |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `main-color` | color | navy | Primary color for text highlights |
| `logo-frac` | fraction | 1.2fr | Logo column width |
| `info-frac` | fraction | 1fr | Info column width |
| `date` | content | today | Letter date |
| `salutation` | str | "To Whom It May Concern," | Letter opening |
| `closing` | str | "Sincerely," | Letter closing |
| `header-bottom-margin` | length | 0cm | Space after header |
| `date-bottom-margin` | length | 0.5cm | Space after date |
| `salutation-bottom-margin` | length | 0.5cm | Space after salutation |
| `body-bottom-margin` | length | 0.5cm | Space after body |
| `closing-bottom-margin` | length | 0cm | Space after closing |
| `signature-bottom-margin` | length | 0cm | Space after signature |

## Contributing
Contributions are welcome! Please feel free to submit issues and pull requests.
