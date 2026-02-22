# ENSA El Jadida – Typst Engineering Report Template

## 📘 Overview

This project provides a structured and reusable **Typst report template** designed for engineering students at ENSA El Jadida.

It includes a professionally designed cover page and a custom code block method to ensure clean, consistent, and modern report formatting.

The goal of this template is to simplify academic report preparation while maintaining a polished and structured presentation style.

---

## ✨ Features

### 1️⃣ Custom Cover Page Function

The template includes a fully parameterized `cover-page` function that allows students to configure all essential report information from one place.

### Supported Parameters

- `title` → Main report title  
- `contributors` → List of authors  
- `jury` → Supervisors / reviewers  
- `subject-image` → Optional centered image  
- `date` → Automatically used to compute the academic year  
- `module` → Course or module name  
- `field` → Field of study  
- `degree` → Degree title  
- `code` → Student code  
- `dep` → Head of department  

The academic year is automatically calculated based on the current date, ensuring dynamic and accurate formatting.

---

### 2️⃣ Custom Code Block Method

A reusable function:

#achraf_code_block(code, language)


This method:

- Displays the programming language label
- Applies consistent typography
- Uses rounded borders and subtle background styling
- Ensures clean alignment
- Integrates Typst’s `raw()` for syntax highlighting

Example usage:
#achraf_code_block("print('Hello World')", "PYTHON")


This ensures uniform and professional code formatting throughout the report.

---

## 🎯 Purpose

This template was created to:

- Standardize report presentation
- Reduce formatting time
- Improve visual quality
- Provide a reusable foundation for engineering students
- Encourage structured and clean documentation practices

It is intended to help students focus more on technical content rather than formatting concerns.

---

## ⚠️ Disclaimer

This project is **not officially affiliated with, endorsed by, or associated with ENSA El Jadida** or any institutional administrative body.

It is an independent initiative developed voluntarily by a student as a personal academic contribution.

The objective is to support fellow students by providing a structured and professional Typst template adapted to our school’s report requirements.

This work reflects individual effort and initiative in contributing positively to the student academic community.

---

## 📌 Usage

1. Import the template file:

#import "lib.typ": cover-page, achraf_code_block


2. Configure your cover page using the `cover-page` function.

3. Use `#achraf_code_block()` wherever code snippets are required.

---

