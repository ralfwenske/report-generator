Red [
    Title: "Report Generator - Test (v4 DSL)"
]

do %report-generator.red

rpt: copy []

emit-report: func [
    file-name [file!]
    /local pdf
][
    pdf: rejoin [%reports/ file-name]
    either preview/data [
        generate-report/browser rpt pdf
        wait 1
        delete pdf
    ][
        generate-report rpt pdf
    ]
]

view/options layout [
    below
    text 350x20 "Report Generator Test" bold white center
    preview: check "Preview" false

    button "Text Report" [
        rpt: copy [
            'HEADER
            [['b] "ACME Corp" "Monthly Sales Report"]
            [" " " " "%DATETIME%" ['b]]
            'CONTENT
        ]
        i: 0
        while [i < 60][
            i: i + 1
            append/only rpt reduce ["Record #" [] i ['b 5.0] ": Product widget #" i " - Qty: " i * 3] 
        ]
        append/only rpt [
            'FOOTER          
            [['b] "Confidential" "%DATE%" "Page %PAGE% of %PAGES%"]
        ]
        emit-report %text-report.pdf
    ]

    button "Table Report" [
        rpt: copy [
            'HEADER
            ["Product Inventory"]
            'CONTENT
        ]
        append/only rpt reduce [
            'table
            ["Product" ['< 180] "Qty" ['> 60] "Price" ['> 80] "Total" ['> 80]]
            ["Widget A" "10" "$25.00" "$250.00"]
            ["Widget B" "5" "$42.00" "$210.00"]
            ["Gadget X" "23" "$12.50" "$287.50"]
        ]
        append rpt [
            'FOOTER
            ["Page %PAGE% of %PAGES%" "" "%TIME%"]
        ]
        emit-report %table-report.pdf
    ]

    button "Unified Report" blue [
        rpt: copy []
        append rpt 'HEADER
        append/only rpt ["ACME Corporation"]
        append/only rpt ["Quarterly Report"]
        append rpt 'CONTENT
        append/only rpt ["Sales Summary" ['b]]
        append/only rpt [""]
        append/only rpt ["Below is the Q1 sales data for all product lines."]
        append/only rpt ["Revenue targets were met across all categories."]

        append/only rpt reduce [
            'table 'box 'alt
            ["Product" ['< 180] "Qty" ['> 60] "Price" ['> 80] "Total" ['> 80]]
            ["Widget A" "120" "$25.00" "$3000.00"]
            ["Widget B" "45" "$42.00" "$1890.00"]
            ["Gadget X" "200" "$12.50" "$2500.00"]
            ["Gizmo Z" "33" "$99.00" "$3267.00"]
            ["TOTALS" ['b] "" "" "$10657.00"]
        ]

        i: 0
        repeat x 10 [
            i: i + 1
            append/only rpt reduce [rejoin ["Record #" i ": Product widget #" i " - Qty: " (i * 3)]]
        ]

        append/only rpt reduce [
            'table
            ["Product" ['< 180] "Qty" ['> 60] "Price" ['> 80] "Total" ['> 80]]
            ["Widget A" "120" "$25.00" "$3000.00"]
            ["Widget B" "45" "$42.00" "$1890.00"]
        ]

        repeat x 7 [
            i: i + 1
            append/only rpt reduce [rejoin ["Record #" i ": Product widget #" i " - Qty: " (i * 3)]]
        ]

        append/only rpt ["^L"]
        append/only rpt ["Expenses" ['b]]
        append/only rpt [""]
        append/only rpt ["Operating expenses for the quarter."]

        append/only rpt reduce [
            'table
            ["Category" ['< 200] "Amount" ['> 100]]
            ["Rent" "$4500.00"]
            ["Utilities" "$1200.00"]
            ["Supplies" "$800.00"]
            ["TOTAL" ['b] "$6500.00"]
        ]

        repeat x 40 [
            i: i + 1
            append/only rpt reduce [rejoin ["Record #" i ": Product widget #" i " - Qty: " (i * 3)]]
        ]

        append/only rpt [""]
        append/only rpt ["Net Profit: $4157.00" ['b]]
        append/only rpt [""]
        append/only rpt ["End of quarterly report" ['u]]

        append rpt 'FOOTER
        append/only rpt ["" "ACME Corp - Confidential" ""]
        append/only rpt ["Page %PAGE% of %PAGES%" "" "%DATETIME%"]
        emit-report %unified-report.pdf
    ]

    button "Page breaks" blue [
        rpt: copy []
        append rpt 'HEADER
        append/only rpt ["Inventory Report"]
        append rpt 'CONTENT
        append/only rpt ["Full inventory listing:"]

        append/only rpt reduce [
            'table 'alt
            ["ID" ['> 60] "Name" ['< 200] "Amount" ['> 100]]
            ["1" "Item A" "$100.00"] ["2" "Item B" "$200.00"] ["3" "Item C" "$300.00"]
            ["4" "Item D" "$400.00"] ["5" "Item E" "$500.00"] ["6" "Item F" "$600.00"]
            ["7" "Item G" "$700.00"] ["8" "Item H" "$800.00"] ["9" "Item I" "$900.00"]
            ["10" "Item J" "$1000.00"] ["11" "Item K" "$1100.00"] ["12" "Item L" "$1200.00"]
            ["13" "Item M" "$1300.00"]
            ["^L" "" ""]
            ["14" "Item N" "$1400.00"] ["15" "Item O" "$1500.00"] ["16" "Item P" "$1600.00"]
            ["17" "Item Q" "$1700.00"] ["18" "Item R" "$1800.00"] ["19" "Item S" "$1900.00"]
            ["20" "Item T" "$2000.00"] ["21" "Item U" "$2100.00"] ["22" "Item V" "$2200.00"]
            ["23" "Item W" "$2300.00"] ["24" "Item X" "$2400.00"] ["25" "Item Y" "$2500.00"]
            ["26" "Item Z" "$2600.00"]
        ]

        append/only rpt ["End of inventory."]

        append rpt 'FOOTER
        append/only rpt [["Page %PAGE% of %PAGES%" "" "%DATETIME%"]]
        emit-report %pagebreak-report.pdf
    ]

    button "Multi-column Header/Footer" blue [
        rpt: copy []
        append rpt 'HEADER
        append/only rpt [['b] "ACME Corp" "Quarterly Report" "Confidential"]
        append/only rpt ["Dept: Sales" "" "%DATETIME%" ['b]]
        append rpt 'CONTENT
        append/only rpt ["This report demonstrates multi-column header and footer lines."]
        append/only rpt ["The header has left, center, and right text on each line."]
        append/only rpt [""]
        append/only rpt ["Sales by Region" ['b]]

        append/only rpt reduce [
            'table 'box 'alt
            ["Region" ['< 160] "Q1" ['> 80] "Q2" ['> 80] "Total" ['> 80]]
            ["North" "$12000" "$14500" "$26500"]
            ["South" "$8500" "$9200" "$17700"]
            ["East" "$15000" "$16800" "$31800"]
            ["West" "$11000" "$12400" 23400]
            ["TOTAL" ['b] "$46500" "$52900" "$99400"]
        ]

        repeat x 40 [
            append/only rpt reduce [rejoin ["Detail line #" x ": Additional supporting data for the quarterly analysis."]]
        ]

        append rpt 'FOOTER
        append/only rpt [['b] "ACME Corp" "%DATETIME%" "Page %PAGE% of %PAGES%"]
        emit-report %multicolumn-report.pdf
    ]

    button "Center-aligned Columns" blue [
        rpt: copy []
        append rpt 'HEADER
        append/only rpt [['b] "Product Catalog" "Item Listing" "Rev 3"]
        append rpt 'CONTENT
        append/only rpt ["Table below demonstrates center-aligned columns using style blocks."]

        append/only rpt reduce [
            'table 'alt
            ["SKU" ['^ 80] "Product Name" ['< 200] "Category" ['^ 120] "Price" ['> 80]]
            ["W-001" "Widget Alpha" "Hardware" "$25.00"]
            ["W-002" "Widget Beta" "Hardware" "$42.00"]
            ["G-001" "Gadget Pro" "Electronics" "$99.00"]
            ["G-002" "Gadget Lite" "Electronics" "$59.00"]
            ["S-001" "Service Plan A" "Services" "$150.00"]
            ["S-002" "Service Plan B" "Services" "$250.00"]
            ["X-001" "Extension Kit" "Accessories" "$15.00"]
            ["X-002" "Mounting Bracket" "Accessories" "$8.50"]
        ]

        append/only rpt ["SKU and Category columns are center-aligned."]
        append/only rpt ["Price column is right-aligned."]
        append/only rpt ["Product Name is left-aligned."]

        append rpt 'FOOTER
        append/only rpt ["" "Center-aligned demo" ""]
        append/only rpt [['b] "Company Inc" "%DATE%" "Page %PAGE% of %PAGES%"]
        emit-report %center-align-report.pdf
    ]

    button "Text Styles" blue [
        rpt: copy []
        append rpt 'HEADER
        append/only rpt [['b] "ACME Corp" ['i] "Style Demo" ['u] "Internal"]
        append rpt 'CONTENT
        append/only rpt ["Bold Title" ['b]]
        append/only rpt [""]
        append/only rpt ["This line is italic." ['i]]
        append/only rpt ["This line is underlined." ['u]]
        append/only rpt ["This line is bold italic." ['b 'i]]
        append/only rpt ["This line is bold and underlined." ['b 'u]]
        append/only rpt ["This line is italic and underlined." ['i 'u]]
        append/only rpt ["This line is bold, italic and underlined." ['b 'i 'u]]
        append/only rpt [""]
        append/only rpt ["Heading Level 1" ['h1]]
        append/only rpt ["Heading Level 2" ['h2]]
        append/only rpt ["Heading Level 3" ['h3]]
        append/only rpt [""]
        append/only rpt ["Styled table cells below:"]

        append/only rpt reduce [
            'table 'box 'alt
            ["Item" ['< 160] "Status" ['^ 100] "Amount" ['> 100]]
            ["Widget A" ['i] "Active" ['b 'u] "$250.00"]
            ["Gadget B" ['b] "Pending" ['u] "$420.00"]
            ["Service C" ['b 'i] "Completed" ['i 'u] "$125.00"]
            ["Regular Item" "Active" "$100.00"]
        ]

        append/only rpt [""]
        append/only rpt ["Summary" ['h2]]
        append/only rpt [""]
        append/only rpt ["Tags: data ['b] data ['i] data ['u] data ['h1] data ['h2] data ['h3]"]
        append/only rpt ["Line-level: ['m] ['h1] ['h2] ['h3] (as style block after data)"]

        append rpt 'FOOTER
        append/only rpt [['i] "ACME Corp" "%TIME%" ['b] "Page %PAGE% of %PAGES%"]
        emit-report %text-styles-report.pdf
    ]

    button "Mono Font" blue [
        rpt: copy []
        append rpt 'HEADER
        append/only rpt [['m] "ACME Corp" ['b] "Mono Demo" ['i] "Internal"]
        append rpt 'CONTENT
        append/only rpt ["Monospaced text is ideal for aligned columns." ['m]]
        append/only rpt ["Bold mono for emphasis." ['m 'b]]
        append/only rpt ["Italic mono for variety." ['m 'i]]
        append/only rpt ["Bold italic underline mono." ['m 'b 'i 'u]]
        append/only rpt [""]
        append/only rpt ["Column alignments in mono:" ['m]]

        append/only rpt reduce [
            'table 'box 'alt
            ["Name" ['< 150] "Value" ['> 80] "Code" ['^ 100]]
            ["Alpha" ['m] "123.45" "AB-001"]
            ["Beta" ['m] "67.89" "CD-002"]
            ["Gamma" ['m] "901.23" "EF-003"]
            ["TOTAL" ['b] "1092.57" ""]
        ]

        append/only rpt [""]
        append/only rpt ["Regular mono" ['m]]
        append/only rpt ["Bold mono" ['m 'b]]
        append/only rpt ["Italic mono" ['m 'i]]
        append/only rpt [""]
        append/only rpt ["Headings still use proportional font" ['h2]]

        append rpt 'FOOTER
        append/only rpt [['m] "Mono Demo" "%TIME%" ['b] "Page %PAGE% of %PAGES%"]
        emit-report %mono-report.pdf
    ]

    button "Number Formatting" blue [
        rpt: copy []
        append rpt 'HEADER
        append/only rpt ["Number & Money Formatting"]
        append rpt 'CONTENT
        append/only rpt ["Tables support automatic number formatting."]
        append/only rpt ["Use 'money for currency and 5.4 for decimal places."]

        append/only rpt reduce [
            'table 'box 'alt
            ["Item" ['< 150] "Qty" ['> 80] "Weight" ['> 100 5.4] "Price" ['> 100 'money] "Total" ['> 100 'money]]
            ["Widget" 100 3.14159 25.00 2500]
            ["Gadget" 50 0.001 42.50 2125.0]
            ["Parts" 200 1234.5678 0.75 150.0]
            ["TOTALS" ['b] 350 "" "" 4775.00]
        ]

        append/only rpt ["Numbers in table cells are formatted automatically."]
        append/only rpt ["Negative values get a minus prefix."]

        append rpt 'FOOTER
        append/only rpt [['b] "Page %PAGE% of %PAGES%"]
        emit-report %format-report.pdf
    ]

    button "Mixed Sizes" blue [
        rpt: copy []
        append rpt 'HEADER
        append/only rpt [['b] "Mixed Font Size Demo" [h1]]
        append/only rpt [" " " " "%DATETIME%" ['b]]
        append rpt 'CONTENT
        append/only rpt ["Per-segment heading styles mixed with regular text:"]
        append/only rpt [""]
        append/only rpt ["Big title " ['h1] "followed by normal text."]
        append/only rpt ["Regular " [] "bold " ['b] "italic " ['i] "and " ['h3] "small heading" [] " together."]
        append/only rpt ["Mono " ['m] "mixed with " [] "h2 heading" ['h2] " and " [] "bold underline" ['b 'u] "."]
        append/only rpt [""]
        append/only rpt ["The line height adapts to the tallest segment on each line."]
        append/only rpt [""]
        append/only rpt ["Table with heading-sized cells:"]

        append/only rpt reduce [
            'table 'box 'alt
            ["Category" ['< 150] "Label" ['< 180] "Value" ['> 100]]
            ["Revenue" ['h3] "Total income" 50000]
            ["Costs" ['b] "Operating expenses" 35000]
            ["Net" ['h2] "Profit" ['b 'u] 15000]
            ["Plain" "Regular row" 0]
        ]

        append rpt 'FOOTER
        append/only rpt [['b] "ACME Corp" "%TIME%" "Page %PAGE% of %PAGES%"]
        emit-report %mixed-sizes-report.pdf
    ]

    button "Exit" red [unview]
][size: 400x500]
