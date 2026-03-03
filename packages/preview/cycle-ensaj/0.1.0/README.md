# cycle-ensaj – Typst Engineering Report Template for ENSA El Jadida

## 📘 Overview

This project provides a structured and reusable **Typst report template** designed for engineering students at ENSA El Jadida (École Nationale des Sciences Appliquées d'El Jadida).

It includes a professionally designed cover page and a custom code block function to ensure clean, consistent, and modern report formatting.

The goal of this template is to simplify academic report preparation while maintaining a polished and structured presentation style.

> ⚠️ This project is **not officially affiliated with, endorsed by, or associated with ENSA El Jadida** or any institutional administrative body. It is an independent initiative developed voluntarily by a student as a personal academic contribution.

---

## ✨ Features

### 1️⃣ Custom Cover Page Function

The template includes a fully parameterized `cover-page` function that allows students to configure all essential report information from one place.

#### Supported Parameters

| Parameter | Description |
|---|---|
| `title` | Main report title |
| `contributors` | List of authors |
| `jury` | Supervisors / reviewers |
| `subject-image` | Optional centered image |
| `date` | Used to automatically compute the academic year |
| `module` | Course or module name |
| `field` | Field of study |
| `degree` | Degree title |
| `code` | Student code |
| `dep` | Head of department |

The academic year is automatically calculated based on the provided date, ensuring dynamic and accurate formatting.

---

### 2️⃣ Custom Code Block Function

A reusable function for clean, consistent code presentation:
```typ
#achraf-code-block(code, language)
```

This function:

- Displays the programming language label
- Applies consistent typography
- Uses rounded borders and subtle background styling
- Ensures clean alignment
- Integrates Typst's `raw()` for syntax highlighting

Example usage:
```typ
#achraf-code-block("print('Hello World')", "PYTHON")
```

---

## 📌 Usage

1. Import the template functions:
```typ
#import "@preview/cycle-ensaj:0.1.0": cover-page, achraf_code_block
```

2. Configure your cover page using the `cover-page` function with the parameters listed above.

3. Use `#achraf-code-block()` wherever code snippets are required.
---

## ⚖️ Assets & Licensing

### Template Source Code

The source code of this template is released under the **MIT License**. See the [`LICENSE`](LICENSE) file for details.

### University Logos

The ENSA El Jadida logos and visual identity assets used in this template are the **property of ENSA El Jadida**. They are included here solely to assist students in producing institutional academic reports. Any use outside of this academic context may require explicit permission from the university. This template and its author claim no ownership over these assets.

### Subject Image ("DevOps" illustration)

The "DevOps" illustration used as the sample `subject-image` on the cover page is sourced 
from [Flaticon](https://www.flaticon.com/free-icons/devops) and is subject to 
[Flaticon's Terms of Use](https://www.flaticon.com/legal).

**If you are a free Flaticon user**, attribution is required when using this image. You must 
credit Flaticon and the original author wherever the image appears, for example:

> DevOps icons created by [Freepik] (https://www.flaticon.com/authors/freepik)

**If you hold a Flaticon Premium subscription**, no attribution is required.

This image is included here solely as a demonstrative placeholder. Users are encouraged to 
replace it with their own image, or to ensure they comply with Flaticon's licensing terms 
if they choose to keep it.
---

## ⚠️ Disclaimer

This project is an independent initiative developed voluntarily by a student as a personal academic contribution. It is not officially affiliated with, endorsed by, or associated with ENSA El Jadida or any of its administrative bodies.

The objective is to support fellow students by providing a structured and professional Typst template adapted to the school's report requirements. This work reflects individual effort and initiative in contributing positively to the student academic community.

---

## 🤝 Contributing


Contributions, suggestions, and improvements are welcome. Feel free to open an issue or submit a pull request.


