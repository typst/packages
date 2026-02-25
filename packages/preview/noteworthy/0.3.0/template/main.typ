#import "@preview/noteworthy:0.3.0": *

#show: noteworthy.with(
  paper-size: "a4",
  font: "New Computer Modern",
  language: "EN",
  title: "Title of The Document",
  header-title: "Header Title", // Optional: The document title will be used instead of it if it is absent
  date: "15/08/1947", //Optional: Current system date will be used if this is absent
  author: "Your Name",
  contact-details: "https://example.com", // Optional: Maybe a link to your website, or phone number
  toc-title: "Table of Contents",
  watermark: "DRAFT", // Optional: Watermark for the document
)

// Write here
