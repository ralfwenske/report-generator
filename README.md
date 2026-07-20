# report-generator.red

A Red module that generates multi-page A4 PDF reports with mixed text and tables.

![image](reports/PDF-Report.png)

## How it works

The module generates PostScript, converts it to PDF via `ps2pdf` (Ghostscript), and optionally opens the PDF in the default viewer via `browse`. All rendering happens in PostScript — no external PDF libraries needed.

**Dependencies:** Red, Ghostscript (`ps2pdf`)

### Installing Ghostscript

`ps2pdf` is part of [Ghostscript](https://ghostscript.com/) and is **not** pre-installed on macOS or Windows.

| OS | Install command |
|----|----------------|
| Linux | `sudo apt install ghostscript` |
| macOS | `brew install ghostscript` |
| Windows | Download from [ghostscript.com](https://ghostscript.com/releases/gsdnld.html) or `winget install GhostScript.GhostScript` |

## Usage

```red
do %report-generator.red
```

### Exported functions

```red
generate-report content %report.pdf
generate-report/browser content %report.pdf   ; generate and open in default PDF viewer
paper-format 'a4                              ; set paper size (default: a4)
paper-format/landscape 'a4                    ; set paper size in landscape orientation
fontsize 14                                   ; set font size in points (default: 12)
```

| Function | Argument | Type | Description |
|----------|----------|------|-------------|
| `generate-report` | `content` | `block!` | Flat block with `'HEADER`, `'CONTENT`, `'FOOTER` sections |
| | `output` | `file!` | Output PDF file path |
| `paper-format` | `name` | `word!` | Paper size: `a4`, `letter`, `legal`, `a3`, `a5` |
| `fontsize` | `size` | `integer!` | Font size in points (default: 12) |

## The one rule

Everything in report-generator follows a single pattern:

```red
[ [styles] value [styles] value value [styles]]
```

Styles are optional `[blocks]` that modify the preceding value. If a style is not applicable in a given context, it is silently ignored.

**How styles work:**

1. A **leading** style block (first element of a line) applies to the whole line as a default
2. A style block **following** a value applies to that value
3. Per-value styles **merge** with line-wide styles — per-value takes precedence
4. **All styles work everywhere** — content lines, table cells, column definitions, headers, footers

```red
["Hello" ['b]]                              ; "Hello" in bold
[['i] "Hello" ['b] " world"]                ; line-wide italic; "Hello" bold+italic, " world" italic
["Name:" ['b 20 '>] "Value" ['i]]           ; "Name:" bold, right-padded 20 chars; "Value" italic
[now ['date '>]]                            ; date value, right-aligned
[0 ['blank]]                                ; zero suppressed (empty)
```

## Content structure

The content block is a flat list delimited by section markers:

```red
generate-report [
    'HEADER
    header lines...
    'CONTENT
    content lines and tables...
    'FOOTER
    footer lines...
] %report.pdf
```

| Marker | Purpose |
|--------|---------|
| `'HEADER` | Lines shown at the top of every page |
| `'CONTENT` | Report body: text lines and tables |
| `'FOOTER` | Lines shown at the bottom of every page |

Sections are optional. If omitted, no header/footer is rendered.

## Styles reference

All styles are placed in optional `[blocks]`. They work the same everywhere — in content lines, table cells, column definitions, headers, and footers.

### Font styles

| Style | Effect |
|-------|--------|
| `b` | **Bold** |
| `i` | *Italic* |
| `u` | Underline |
| `m` | Monospace (Courier) |
| `h1` | Heading 1 (24pt, bold by default) |
| `h2` | Heading 2 (18pt, bold by default) |
| `h3` | Heading 3 (14pt, bold by default) |

Line and row heights adapt to the tallest segment.

### Alignment

| Style | Effect |
|-------|--------|
| `<` | Left-align |
| `^` | Center |
| `>` | Right-align |

In headers and footers, alignment is positional (1st segment = left, 2nd = center, 3rd = right), so alignment styles are ignored there.

### Number formatting

| Style | Effect | Example |
|-------|--------|---------|
| `10.4` (float) | Total width (integer part) + decimal places (decimal part) | `42` with `10.4` -> `"    42.0000"` |
| `'money` | Money with thousand separators | `1234.5` -> `"$1'234.50"` |
| `'s1000` | Thousand separators, no decimals | `1234567` -> `"1'234'567"` |
| `'blank` | Suppress zero values (show empty) | `0` -> `""` |

The float's integer part sets the total field width (padded with spaces). The decimal part sets the number of decimal places. Padding direction follows alignment.

### Date formatting

| Style | Effect | Example |
|-------|--------|---------|
| `'date` | Date only | `25-Jun-2026` |
| `'time` | Time only | `18:26` |
| `'datetime` | Date and time | `25-Jun-2026 18:26` |

### Width padding

An integer in a style block sets the width in characters. In content lines it pads the preceding string or formatted number. In table column definitions it sets the column width. Padding direction follows alignment (default: left):

```red
["Label:" ['b 20]]                    ; right-padded to 20 chars (left-aligned)
["Name:" ['b 20 '>]]                  ; left-padded to 20 chars (right-aligned)
["Title" ['b 40 '^]]                  ; center-padded to 40 chars
```

### Colors

| Style | Effect |
|-------|--------|
| `255.0.0` (tuple) | 1st tuple = font color |
| `0.0.200` (tuple) | 2nd tuple = background color |
| `red`, `blue`, etc. | Named colors (resolve to tuples) |

```red
["Alert" ['b red white]]              ; bold, red text, white background
["Status" [white 0.128.0]]            ; white text, green background
["Note" [blue yellow]]                ; blue text, yellow background
["Colored text only" [255.0.0]]       ; red text only
```

### Combining styles

All styles can be freely combined:

```red
["Alert" ['b 'i 'u red white]]       ; bold italic underlined, red text, white bg
[['m] "Code" ['b 10.2]]             ; line-wide mono, "Code" mono bold, 10 chars, 2 decimals
```

## Tables

Tables start with `'table` followed by optional modifiers, then a column definition block, then row blocks:

```red
['table 'box 'alt
    ["Product" ['< 30] "Qty" ['^ 10 10.4] "Total" ['> 13 'money] "Status" ['^ 13]]
    ["Widget A" 120 3000]
    ["Widget B" "45" 1890.0]
    ["TOTALS" ['b] "" 13780.00]
]
```

### Table modifiers

| Modifier | Meaning |
|----------|---------|
| `'box` | Draw outer border |
| `'alt` | Alternate row background (light gray on even rows) |

Both can be combined. Column separators are always drawn. Header rows always have a gray background.

### Column definitions

Each column title is followed by a style block setting defaults for that column. All styles work — alignment, width, format, bold, colors, etc.

```red
["Product" ['< 30] "Qty" ['^ 10 10.4] "Total" ['> 13 'money]]
```

### Styled table cells

All styles work in table cells and override column defaults. A leading style block applies to the entire row:

```red
[['b] "Widget A" 120 3000]                      ; entire row bold
[['b red white] "Widget A" 120 3000]            ; entire row: bold, red text, white bg
["Widget A" ['i] "Active" ['b 'u '>] 250.00]   ; cell-level overrides
```

### Page breaks in tables

Use a row where the first column is `"^L"` to break a table across pages. The table header is automatically repeated:

```red
["^L" "" ""]
```

## Columns layout

Multi-column layout for short lines, like newspaper columns. Rows are distributed evenly across columns, filling left-to-right.

```red
['column 33 3                           ; explicit: 33 chars wide, 3 chars gap
    [['m] "Record #" 1 ['b 10.2]]
    [['m] "Record #" 2 ['b 10.2]]
    ...
]

['column * 3                            ; auto-width, 3 chars gap
    [['m] "short"]
    [['m] "a much longer line"]
    ...
]

['column                                ; auto-width, default 0 gap
    [['m] "short"]
    ...
]
```

## Images

```red
['IMAGE 300 %photo.jpg]                 ; 300pt wide, height from aspect ratio
['IMAGE 400 %screenshot.png]
```

Supported: 8-bit non-interlaced JPEG and PNG (RGB, RGBA, grayscale, palette).

## Conditional page breaks

```red
["^L" 15]     ; break only if < 15 lines of space left
"^L"          ; unconditional break (string, not block)
```

## Header and footer tokens

| Token | Replaced with | Example |
|-------|---------------|---------|
| `%PAGE%` | Current page number | `3` |
| `%PAGES%` | Total number of pages | `12` |
| `%DATE%` | Current date | `2026-07-20` |
| `%TIME%` | Current time (hh:mm) | `19:04` |
| `%DATETIME%` | Date and time | `2026-07-20 19:04` |

## Page layout

- Default: A4 (595 x 842 pts). Use `paper-format` to change: `a4`, `letter`, `legal`, `a3`, `a5`. Add `/landscape` for horizontal orientation.
- 50pt margins on all sides
- Font: Times-Roman 12pt (configurable via `fontsize`), line height 15pt. Mono: Courier family (`'m`).
- Line and row heights adapt to the largest font size in the line/row

## Examples

See [`report-generator-test.red`](report-generator-test.red) for a GUI test harness. Run with `red-view report-generator-test.red`. Includes portrait/landscape demos with all features: text styles, headings, monospace, colored cells, boxed/alternating tables, number formatting, column layout, and images.

## File overview

| File | Purpose |
|------|---------|
| `report-generator.red` | The module. Load with `do %report-generator.red` |
| `report-generator-test.red` | GUI test harness |
| `basic-demo.red` | Minimal demo script |
| `what-columns.red` | Data file used by the test harness for dynamic column layout |
| `reports/` | Output directory for generated PDFs (gitignored) |

## Architecture

The module is wrapped in a `context` to isolate all internal state. `generate-report`, `paper-format`, and `fontsize` are exported.

**Rendering pipeline:**

1. `parse-sections` splits flat content into header/content/footer blocks
2. Content is processed page by page, tracking `page-y` position
3. Tables render with per-row height adaptation and seamless box connection
4. Columns render with PS `gsave/translate/grestore` for horizontal layout
5. Each page's PostScript is collected into a `pages` block
6. `assemble-ps` replaces tokens per page, emits footers, wraps in PS DSC comments
7. `convert-to-pdf` writes PS and calls `ps2pdf` to produce the final PDF
