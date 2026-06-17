Red []

do %report-generator.red

widgetC: ["Widget C" "245" 8890.00]
threethousand: 3000
total: 1890.0

i: 0
content: copy []

;--- Section 1: Text with styles ---
append content [
    ['h1 "Report Generator Demo" /h1]
    [""]
    ['b "This report demonstrates all features of the report-generator module." /b]
    [""]
    ['i "Italic text" /i]
    ['u "Underlined text" /u]
    ['b "Bold text" /b]
    ['b 'i "Bold italic" /i /b]
    ['b 'u "Bold underline" /u /b]
    ['i 'u "Italic underline" /u /i]
    ['b 'i 'u "Bold italic underline" /u /i /b]
    [""]
    ['h2 "Monospace" /h2]
    ['m "Monospaced text is ideal for aligned columns."]
    ['m 'b "Bold mono" /b]
    ['m 'i "Italic mono" /i]
    [""]
    ['h2 "Headings" /h2]
    ['h1 "Heading Level 1" /h1]
    ['h2 "Heading Level 2" /h2]
    ['h3 "Heading Level 3" /h3]
]

;--- Section 2: Boxed table with alternating rows ---
append content [
    [""]
    ['h2 "Boxed Table with Alternating Rows" /h2]
    ["A table with 'box and 'alt modifiers, number formatting, and styled cells."]
]

append/only content reduce [
    'table 'box 'alt
    ['< 180 "Product" '^ 60 5.4 "Qty" '> 80 'money "Price" '> 80 'money "Total"]
    ["Widget A" 120 25.00 3000.00]
    ["Widget B" 45 42.00 1890.00]
    ["Gadget X" 200 12.50 2500.00]
    ["Gizmo Z" 33 99.00 3267.00]
    ['b "TOTALS" /b 398 "" 10657.00]
]

;--- Section 3: Plain table (no box, no alternation) ---
append content [
    [""]
    ['h2 "Plain Table" /h2]
    ["A table without 'box or 'alt — just column separators."]
]

append/only content reduce [
    'table
    ['< 200 "Category" '> 100 "Amount"]
    ["Rent" 4500.00]
    ["Utilities" 1200.00]
    ["Supplies" 800.00]
    ['b "TOTAL" /b 6500.00]
]

;--- Section 4: Center-aligned columns ---
append content [
    [""]
    ['h2 "Center-aligned Columns" /h2]
    ["Demonstrates ^ (center) alignment in column definitions."]
]

append/only content reduce [
    'table 'alt
    ['^ 80 "SKU" '< 200 "Product Name" '^ 120 "Category" '> 80 "Price"]
    ["W-001" "Widget Alpha" "Hardware" 25.00]
    ["W-002" "Widget Beta" "Hardware" 42.00]
    ["G-001" "Gadget Pro" "Electronics" 99.00]
    ["G-002" "Gadget Lite" "Electronics" 59.00]
    ["S-001" "Service Plan A" "Services" 150.00]
    ["S-002" "Service Plan B" "Services" 250.00]
]

;--- Section 5: Styled table cells ---
append content [
    [""]
    ['h2 "Styled Table Cells" /h2]
    ["Style tags work inside table cells."]
]

append/only content reduce [
    'table 'box 'alt
    ['< 160 "Item" '^ 100 "Status" '> 100 "Amount"]
    ['i "Widget A" /i 'b 'u "Active" /u /b 250.00]
    ['b "Gadget B" /b 'u "Pending" /u 420.00]
    ['b 'i "Service C" /i /b 'i 'u "Completed" /u /i 125.00]
    ["Regular Item" "Active" 100.00]
]

;--- Section 6: Mono table ---
append content [
    [""]
    ['h2 "Monospace Table" /h2]
    ['m "Using 'm for aligned mono columns."]
]

append/only content reduce [
    'table 'box 'alt
    ['< 150 "Name" '> 80 "Value" '^ 100 "Code"]
    ['m "Alpha" /m 123.45 "AB-001"]
    ['m "Beta" /m 67.89 "CD-002"]
    ['m "Gamma" /m 901.23 "EF-003"]
    ['b "TOTAL" /b 1092.57 ""]
]

;--- Section 7: Dynamic content ---
append content [
    [""]
    ['h2 "Dynamic Content" /h2]
    ["Generating lines with a loop:"]
]

repeat x 10 [
    i: i + 1
    append/only content reduce [
        'b rejoin ["Record #" i ": "] /b rejoin ["Product widget #" i " - Qty: " (i * 3)]
    ]
]

;--- Section 8: Page break in table ---
append content [
    [""]
    ['h2 "Table with Page Break" /h2]
    ["A long table that breaks across pages using a ^L row."]
]

append/only content reduce [
    'table 'alt
    ['> 60 "ID" '< 200 "Name" '> 100 "Amount"]
    ["1" "Item A" 100.00] ["2" "Item B" 200.00] ["3" "Item C" 300.00]
    ["4" "Item D" 400.00] ["5" "Item E" 500.00] ["6" "Item F" 600.00]
    ["7" "Item G" 700.00] ["8" "Item H" 800.00] ["9" "Item I" 900.00]
    ["10" "Item J" 1000.00] ["11" "Item K" 1100.00] ["12" "Item L" 1200.00]
    ["^L" "" ""]
    ["13" "Item M" 1300.00] ["14" "Item N" 1400.00] ["15" "Item O" 1500.00]
    ["16" "Item P" 1600.00] ["17" "Item Q" 1700.00] ["18" "Item R" 1800.00]
]

append content [
    [""]
    ['b "End of report." /b]
]

;--- Generate ---
generate-report
    [ ;HEADER
        ['h1 "ACME Corp" /h1 'b "Full Example Report" /b "Confidential"]
        [" " " " 'b "%DATETIME%"]
    ] ;header

    content

    [ ;FOOTER
        ['b "ACME Corp" /b "%TIME%" "Page %PAGE% of %PAGES%"]
    ] ;footer

    %reports/full-example.pdf
