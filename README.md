# report-generator.red

A Red module that generates multi-page A4 PDF reports with mixed text and table content, ready for printing via CUPS/lpr.

## How it works

The module generates PostScript, converts it to PDF via `ps2pdf` (Ghostscript), and optionally sends it to the default printer via `lpr`. All rendering happens in PostScript — no external PDF libraries needed.

**Dependencies:** Red, Ghostscript (`ps2pdf`), CUPS (`lpr`)

## Usage

```red
do %report-generator.red
```

### Exported function

```red
generate-report header content footer %report.pdf
generate-report/no-print header content footer %report.pdf   ; skip printing, just generate PDF
```

| Argument | Type | Description |
|----------|------|-------------|
| `header` | `block!` or `none!` | Lines printed at the top of every page (bold). Each line can be a string or a block of 1–3 strings for multi-column layout. |
| `content` | `block!` | Mixed text lines and table definitions |
| `footer` | `block!` or `none!` | Lines printed at the bottom of every page. Same format as header. |
| `output` | `file!` | Output PDF file path. A `.ps` file is also created alongside it. |

### Content block

The `content` block is a flat list of items:

- **String** — a text line. Supports `~X~` style prefixes (see below) and legacy `*bold*` / `_underline_` inline markup.
- **`^L` string** — forces a page break at that point.
- **Table block** — a nested block starting with the word `'table`, followed by column definitions and row data.

Tables must be added with `append/only`:

```red
content: copy []
append content "Some text"
append content "*Bold heading*"
append content ""
append/only content reduce [
    'table
    ["Name" 200 "L" "Amount" 100 "R"]   ; columns: [Title Width Align ...]
    ["Widget" "$25.00"]                   ; rows: [col1 col2 ...]
    ["Gadget" "$42.00"]
]
append content "Text after table"
```

### Column definitions

Each column is defined by 2 or 3 elements:

```
["Title" Width "Align" ...]
```

- **Width** — integer, in PostScript points (72 pts = 1 inch)
- **Align** — `"L"` (left, default), `"C"` (center), or `"R"` (right). If omitted, all columns default to left.

With alignment (3 elements per column):
```red
["Product" 180 "L" "Qty" 60 "C" "Total" 80 "R"]
```

Without alignment (2 elements per column, all left-aligned):
```red
["Product" 180 "Qty" 60 "Total" 80]
```

### Text styles

Prefix any string with `~X~` to apply styling. Works everywhere: content lines, table cells, headers, and footers.

| Prefix | Style |
|--------|-------|
| `~b~` | **Bold** |
| `~i~` | *Italic* |
| `~u~` | Underline |
| `~bi~` or `~ib~` | Bold + italic |
| `~bu~` or `~ub~` | Bold + underline |
| `~iu~` or `~ui~` | Italic + underline |
| `~biu~` (any order) | Bold + italic + underline |
| `~h1~` | Heading 1 (24pt bold) |
| `~h2~` | Heading 2 (18pt bold) |
| `~h3~` | Heading 3 (14pt bold) |

Examples:

```red
append content "~b~Bold title"
append content "~i~Italic paragraph"
append content "~bu~Bold and underlined"
append content "~h2~Section heading"
```

In table cells:

```red
["~i~Widget A" "~bu~Active" "$250.00"]
```

In header/footer lines:

```red
header: [
    ["~b~ACME Corp" "~i~Quarterly Report" "~u~Confidential"]
]
footer: [
    ["~i~Company Inc" "" "~b~Page %PAGE% of %PAGES%"]
]
```

Styles can also be combined with multi-column block lines and with `%PAGE%`/`%PAGES%` tokens in footers.

**Legacy inline markup** (content lines only, for backward compatibility):
- `*text*` — renders as bold (asterisks are stripped)
- `_text_` — renders with underline (underscores are stripped)

### Page breaks

Insert `"^L"` as a string in content to force a page break:

```red
append content "Last line before break"
append content "^L"
append content "First line on new page"
```

Inside table data, use a row where the first column is `"^L"`:

```red
["^L" "" ""]
```

This triggers a page break and automatically repeats the table header on the next page. Useful for tables that are too large for a single page.

### Footer tokens

- `%PAGE%` — replaced with the current page number
- `%PAGES%` — replaced with the total number of pages

```red
footer: ["Page %PAGE% of %PAGES%" "Confidential"]
```

### Multi-column headers and footers

Header and footer lines can be blocks of 1–3 strings instead of plain strings. Each string in the block is positioned across the page width:

| Position | Index | Alignment |
|----------|-------|-----------|
| Left     | 1     | Left-aligned at left margin |
| Center   | 2     | Centered across page width |
| Right    | 3     | Right-aligned at right margin |

You can use 1, 2, or 3 elements. Missing positions are simply skipped.

```red
header: [
    ["ACME Corp" "Quarterly Report" "Confidential"]
    ["Dept: Sales" "" "Date: 2026-06-12"]
    ""
]
```

The first line renders the company name on the left, title centered, and classification on the right. The second line has left and right text with an empty center. The third line is a plain string (full-width left-aligned, as before).

`%PAGE%` and `%PAGES%` tokens work inside block-based footer lines too:

```red
footer: [
    ["ACME Corp" "" "Page %PAGE% of %PAGES%"]
]
```

## Page layout

- A4 (595 x 842 pts)
- 50pt margins on all sides
- Font: Times-Roman 12pt, line height 15pt. Available styles: Times-Bold, Times-Italic, Times-BoldItalic.
- Table rows: 19pt (line-height + 4)
- Headers rendered in bold
- Table headers have a light gray background
- Alternating table rows have a very light gray background

## Full example

```red
Red []

do %report-generator.red

header: [
    ["ACME Corp" "Quarterly Report" "Confidential"]
    ""
]
footer: [
    ["ACME Corp" "" "Page %PAGE% of %PAGES%"]
]

content: copy []

append content "*Sales Summary*"
append content ""
append content "Q1 sales data for all product lines."
append content ""

append/only content reduce [
    'table
    ["Product" 180 "L" "Qty" 60 "C" "Total" 80 "R"]
    ["Widget A" "120" "$3000.00"]
    ["Widget B" "45" "$1890.00"]
    ["*TOTALS*" "" "$4890.00"]
]

append content ""
append content "End of report."

generate-report header content footer %quarterly-report.pdf
```

## File overview

| File | Purpose |
|------|---------|
| `report-generator.red` | The module. Load with `do %report-generator.red` |
| `report-generator-test.red` | GUI test harness with buttons for text, table, unified, page-break, multi-column, center-align, and style demos |
| `*.ps` | Generated PostScript (created alongside the PDF) |
| `*.pdf` | Generated PDF (filename specified by the `output` parameter) |

## Architecture

The module is wrapped in a `context` to isolate all internal state. Only `generate-report` is exported (via `set`).

**Internal helpers:**

| Function | Purpose |
|----------|---------|
| `ps-escape` | Escapes `\`, `(`, `)` in PostScript strings |
| `emit-font` | Emits a PostScript font selection command |
| `emit-text` | Emits a left-aligned text drawing command |
| `emit-text-center` | Emits a center-aligned text command (uses `stringwidth`) |
| `emit-text-right` | Emits a right-aligned text command (uses `stringwidth`) |
| `parse-style` | Parses `~X~` style prefix, returns `[bold? italic? underline? heading text]` |
| `select-style-font` | Emits PostScript font selection based on style flags |
| `emit-underline` | Draws an underline beneath text at the current font |
| `emit-styled` | Parses style prefix, selects font, emits aligned text, handles underline, resets font |
| `emit-rect` | Emits a stroked rectangle |
| `emit-filled-rect` | Emits a filled rectangle with gray fill (wrapped in `gsave`/`grestore`) |
| `emit-header` | Emits all header lines in bold (supports multi-column block lines) |
| `emit-footer` | Emits all footer lines with `%PAGE%`/`%PAGES%` replacement (supports multi-column block lines) |
| `emit-data-line` | Emits a text line with `~X~` style prefixes and legacy `*bold*`/`_underline_` markup |
| `emit-table-header` | Emits a table header row with gray background and column separators |
| `emit-table-row` | Emits a table data row with alternating row shading |
| `parse-table-columns` | Parses column definitions into titles, widths, and alignments |

**Rendering pipeline:**

1. Content is processed page by page, tracking `page-y` position
2. Each page's PostScript is collected into a `pages` block
3. Footers are added during final assembly (after total page count is known)
4. The final PS file is assembled with DSC comments, converted to PDF, and sent to the printer
