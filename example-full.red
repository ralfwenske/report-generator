Red []

do %report-generator.red

widgetC: ["Widget C" "245" 8890.00]
threethousand: 3000
total: 1890.0

i: 0
rpt: copy []

;--- Header ---
append rpt 'HEADER
append/only rpt [['b] "ACME Corp" [h1] "Full Example Report" [] "Confidential"]
append/only rpt [" " " " "%DATETIME%" ['b]]

;--- Content ---
append rpt 'CONTENT

;--- Section 1: Text with styles ---
append/only rpt [
    ["Report Generator Demo" ['h1]]
    [""]
    ["This report demonstrates all features of the report-generator module." ['b]]
    [""]
    ["Italic text" ['i]]
    ["Underlined text" ['u]]
    ["Bold text" ['b]]
    ["Bold italic" ['b 'i]]
    ["Bold underline" ['b 'u]]
    ["Italic underline" ['i 'u]]
    ["Bold italic underline" ['b 'i 'u]]
    [""]
    ["Monospace" ['h2]]
    ["Monospaced text is ideal for aligned columns." ['m]]
    ["Bold mono" ['m 'b]]
    ["Italic mono" ['m 'i]]
    [""]
    ["Headings" ['h2]]
    ["Heading Level 1" ['h1]]
    ["Heading Level 2" ['h2]]
    ["Heading Level 3" ['h3]]
]

;--- Section 2: Boxed table with alternating rows ---
append/only rpt [
    [""]
    ["Boxed Table with Alternating Rows" ['h2]]
    ["A table with 'box and 'alt modifiers, number formatting, and styled cells."]
]
append/only rpt reduce [
    'table 'box 'alt
    ["Product" ['< 180] "Qty" ['^ 60 5.4] "Price" ['> 80 'money] "Total" ['> 80 'money]]
    ["Widget A" 120 25.00 3000.00]
    ["Widget B" 45 42.00 1890.00]
    ["Gadget X" 200 12.50 2500.00]
    ["Gizmo Z" 33 99.00 3267.00]
    ["TOTALS" ['b] 398 "" 10657.00]
]

;--- Section 3: Plain table ---
append/only rpt [
    [""]
    ["Plain Table" ['h2]]
    ["A table without 'box or 'alt — just column separators."]
]
append/only rpt reduce [
    'table
    ["Category" ['< 200] "Amount" ['> 100]]
    ["Rent" 4500.00]
    ["Utilities" 1200.00]
    ["Supplies" 800.00]
    ["TOTAL" ['b] 6500.00]
]

;--- Section 4: Center-aligned columns ---
append/only rpt [
    [""]
    ["Center-aligned Columns" ['h2]]
    ["Demonstrates ^ (center) alignment in column definitions."]
]
append/only rpt reduce [
    'table 'alt
    ["SKU" ['^ 80] "Product Name" ['< 200] "Category" ['^ 120] "Price" ['> 80]]
    ["W-001" "Widget Alpha" "Hardware" 25.00]
    ["W-002" "Widget Beta" "Hardware" 42.00]
    ["G-001" "Gadget Pro" "Electronics" 99.00]
    ["G-002" "Gadget Lite" "Electronics" 59.00]
    ["S-001" "Service Plan A" "Services" 150.00]
    ["S-002" "Service Plan B" "Services" 250.00]
]

;--- Section 5: Styled table cells ---
append/only rpt [
    [""]
    ["Styled Table Cells" ['h2]]
    ["Style tags work inside table cells."]
]
append/only rpt reduce [
    'table 'box 'alt
    ["Item" ['< 160] "Status" ['^ 100] "Amount" ['> 100]]
    ["Widget A" ['i] "Active" ['b 'u] 250.00]
    ["Gadget B" ['b] "Pending" ['u] 420.00]
    ["Service C" ['b 'i] "Completed" ['i 'u] 125.00]
    ["Regular Item" "Active" 100.00]
]

;--- Section 6: Mono table ---
append/only rpt [
    [""]
    ["Monospace Table" ['h2]]
    ["Using 'm for aligned mono columns." ['m]]
]
append/only rpt reduce [
    'table 'box 'alt
    ["Name" ['< 150] "Value" ['> 80] "Code" ['^ 100]]
    ["Alpha" ['m] 123.45 "AB-001"]
    ["Beta" ['m] 67.89 "CD-002"]
    ["Gamma" ['m] 901.23 "EF-003"]
    ["TOTAL" ['b] 1092.57 ""]
]

;--- Section 7: Dynamic content ---
append/only rpt [
    [""]
    ["Dynamic Content" ['h2]]
    ["Generating lines with a loop:"]
]

;repeat x 10 [
;    i: i + 1
;    append/only rpt reduce [rejoin ["Record #" i ": "] ['m '> 4.0] rejoin ["Product widget #" i " - Qty: " (i * 3) [4.2 '> ]]]
;]
repeat x 10 [
    i: i + 1
    append/only rpt reduce ["Record #" i ['m 5.0] ": Product widget #" i ['b 6.3] " - Qty: " (i * 3) [4.2]]
]

;--- Section 8: Page break in table ---
append/only rpt [
    [""]
    ["Table with Page Break" ['h2]]
    ["A long table that breaks across pages using a ^L row."]
]
append/only rpt reduce [
    'table 'alt
    ["ID" ['> 60] "Name" ['< 200] "Amount" ['> 100]]
    ["1" "Item A" 100.00] ["2" "Item B" 200.00] ["3" "Item C" 300.00]
    ["4" "Item D" 400.00] ["5" "Item E" 500.00] ["6" "Item F" 600.00]
    ["7" "Item G" 700.00] ["8" "Item H" 800.00] ["9" "Item I" 900.00]
    ["10" "Item J" 1000.00] ["11" "Item K" 1100.00] ["12" "Item L" 1200.00]
    ["^L" "" ""]
    ["13" "Item M" 1300.00] ["14" "Item N" 1400.00] ["15" "Item O" 1500.00]
    ["16" "Item P" 1600.00] ["17" "Item Q" 1700.00] ["18" "Item R" 1800.00]
]

append/only rpt [
    [""]
    ["End of report." ['b]]
]

;--- Section 9: Mixed font sizes on one line ---
append/only rpt [
    [""]
    ["Mixed Font Sizes" ['h2]]
    ["Heading styles can be applied per-segment, mixed with regular text on the same line."]
    ["Big " ['h1] "and small" [] " and " ['h3] "tiny" [] " on one line."]
    [""]
    ["The line height adapts to the tallest segment."]
    ["Regular " [] "mono " ['m] "and " [] "bold italic" ['b 'i] " together."]
]

;--- Section 10: Table with heading in a cell ---
append/only rpt [
    [""]
    ["Headings in Table Cells" ['h2]]
    ["Table rows expand to fit heading-sized text."]
]
append/only rpt reduce [
    'table 'box 'alt
    ["Category" ['< 160] "Description" ['< 200] "Amount" ['> 100 'blank]]
    ["Revenue" ['h3] "Total quarterly income" 50000.00]
    ["Expenses" ['b] "Operating costs" 35000.00]
    ["Profit" ['h2] "Net result" ['b 'u] 15000.00]
    ["Regular" "No special styling" 0.00]
]

;--- Footer ---
append rpt 'FOOTER
append/only rpt [['i] "ACME Corp" ['b 'h2] "%TIME%" "Page %PAGE% of %PAGES%"]

;--- Generate ---
generate-report rpt %reports/example-full.pdf
