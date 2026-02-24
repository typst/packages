#import "../Template-Import.typ": *
#show: format-doc-general.with()


// =================================================================
// Document
// =================================================================


// Title
#include "../00-Title/00-Title.typ"

// Import Glossary
#include "../50-Bibliography/52-Glossary.typ"

// Pre-Document
#include "../80-Structure/81-struct-pre.typ"

// Main-Document
#include "../80-Structure/82-struct-main.typ"

// Post-Document
#include "../80-Structure/83-struct-post.typ"

// Appendix
#include "../70-Appendix/70-Appendix.typ"
