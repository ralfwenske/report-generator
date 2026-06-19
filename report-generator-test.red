Red [
    Title: "Report Generator - Test (v3 DSL)"
]

do %report-generator.red

header:  []
content: []
footer:  none

emit-report: func [
    file-name [file!]
    /local pdf
][
    pdf: rejoin [%reports/ file-name]
    either preview/data [
        generate-report/browser header content footer pdf
        wait 1
        delete pdf
    ][
        generate-report header content footer pdf
    ]
]

view/options layout [
    below
    text 350x20 "Report Generator Test" bold white center
    preview: check "Preview" false

    button "Text Report" blue [
        header: [
            ["ACME Corp" "Monthly Sales Report"]
            [" " " " "%DATETIME%" ['b]]
        ]
        content: copy []
        footer: [["Confidential" ['b] "%DATE%" "Page %PAGE% of %PAGES%"]]

        i: 0
        while [i < 60][
            i: i + 1
            append/only content reduce [rejoin ["Record #" i ": "] ['b] rejoin ["Product widget #" i " - Qty: " (i * 3)]]
        ]

        emit-report %text-report.pdf
    ]

    button "Table Report" blue [
        header: ["Product Inventory"]
        content: copy []
        footer: [["Page %PAGE% of %PAGES%" "" "%TIME%"]]

        append/only content reduce [
            'table
            ["Product" ['< 180] "Qty" ['> 60] "Price" ['> 80] "Total" ['> 80]]
            ["Widget A" "10" "$25.00" "$250.00"]
            ["Widget B" "5" "$42.00" "$210.00"]
            ["Gadget X" "23" "$12.50" "$287.50"]
        ]

        emit-report %table-report.pdf
    ]

    button "Unified Report" blue [
        header: [
            "ACME Corporation"
            "Quarterly Report"
        ]
        content: copy []
        footer: [
            ["" "ACME Corp - Confidential" ""]
            ["Page %PAGE% of %PAGES%" "" "%DATETIME%"]
        ]

        append content [
            ["Sales Summary" ['b]]
            [""]
            ["Below is the Q1 sales data for all product lines."]
            ["Revenue targets were met across all categories."]
        ]

        append/only content reduce [
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
            append/only content reduce [rejoin ["Record #" i ": Product widget #" i " - Qty: " (i * 3)]]
        ]

        append/only content reduce [
            'table
            ["Product" ['< 180] "Qty" ['> 60] "Price" ['> 80] "Total" ['> 80]]
            ["Widget A" "120" "$25.00" "$3000.00"]
            ["Widget B" "45" "$42.00" "$1890.00"]
        ]

        repeat x 7 [
            i: i + 1
            append/only content reduce [rejoin ["Record #" i ": Product widget #" i " - Qty: " (i * 3)]]
        ]

        append content ["^L"]
        append content [
            ["Expenses" ['b]]
            [""]
            ["Operating expenses for the quarter."]
        ]

        append/only content reduce [
            'table
            ["Category" ['< 200] "Amount" ['> 100]]
            ["Rent" "$4500.00"]
            ["Utilities" "$1200.00"]
            ["Supplies" "$800.00"]
            ["TOTAL" ['b] "$6500.00"]
        ]

        repeat x 40 [
            i: i + 1
            append/only content reduce [rejoin ["Record #" i ": Product widget #" i " - Qty: " (i * 3)]]
        ]

        append content [
            [""]
            ["Net Profit: $4157.00" ['b]]
            [""]
            ["End of quarterly report" ['u]]
        ]

        emit-report %unified-report.pdf
    ]

    button "Page breaks" blue [
        header: ["Inventory Report"]
        content: copy []
        footer: [["Page %PAGE% of %PAGES%" "" "%DATETIME%"]]

        append content [
            ["Full inventory listing:"]
        ]

        append/only content reduce [
            'table 'alt
            ["ID" ['> 60] "Name" ['< 200] "Amount" ['> 100]]
            ["1" "Item A" "$100.00"]
            ["2" "Item B" "$200.00"]
            ["3" "Item C" "$300.00"]
            ["4" "Item D" "$400.00"]
            ["5" "Item E" "$500.00"]
            ["6" "Item F" "$600.00"]
            ["7" "Item G" "$700.00"]
            ["8" "Item H" "$800.00"]
            ["9" "Item I" "$900.00"]
            ["10" "Item J" "$1000.00"]
            ["11" "Item K" "$1100.00"]
            ["12" "Item L" "$1200.00"]
            ["13" "Item M" "$1300.00"]
            ["^L" "" ""]
            ["14" "Item N" "$1400.00"]
            ["15" "Item O" "$1500.00"]
            ["16" "Item P" "$1600.00"]
            ["17" "Item Q" "$1700.00"]
            ["18" "Item R" "$1800.00"]
            ["19" "Item S" "$1900.00"]
            ["20" "Item T" "$2000.00"]
            ["21" "Item U" "$2100.00"]
            ["22" "Item V" "$2200.00"]
            ["23" "Item W" "$2300.00"]
            ["24" "Item X" "$2400.00"]
            ["25" "Item Y" "$2500.00"]
            ["26" "Item Z" "$2600.00"]
        ]

        append content [
            ["End of inventory."]
        ]

        emit-report %pagebreak-report.pdf
    ]

    button "Multi-column Header/Footer" blue [
        header: [
            ["ACME Corp" "Quarterly Report" "Confidential"]
            ["Dept: Sales" "" "%DATETIME%"]
        ]
        content: copy []
        footer: [
            ["ACME Corp" "%DATETIME%" "Page %PAGE% of %PAGES%"]
        ]

        append content [
            ["This report demonstrates multi-column header and footer lines."]
            ["The header has left, center, and right text on each line."]
            [""]
            ["Sales by Region" ['b]]
        ]

        append/only content reduce [
            'table 'box 'alt
            ["Region" ['< 160] "Q1" ['> 80] "Q2" ['> 80] "Total" ['> 80]]
            ["North" "$12000" "$14500" "$26500"]
            ["South" "$8500" "$9200" "$17700"]
            ["East" "$15000" "$16800" "$31800"]
            ["West" "$11000" "$12400" 23400]
            ["TOTAL" ['b] "$46500" "$52900" "$99400"]
        ]

        repeat x 40 [
            append/only content reduce [rejoin ["Detail line #" x ": Additional supporting data for the quarterly analysis."]]
        ]

        emit-report %multicolumn-report.pdf
    ]

    button "Center-aligned Columns" blue [
        header: [
            ["Product Catalog" "Item Listing" "Rev 3"]
        ]
        content: copy []
        footer: [
            ["" "Center-aligned demo" ""]
            ["Company Inc" "%DATE%" "Page %PAGE% of %PAGES%"]
        ]

        append content [
            ["Table below demonstrates center-aligned columns using style blocks."]
        ]

        append/only content reduce [
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

        append content [
            ["SKU and Category columns are center-aligned."]
            ["Price column is right-aligned."]
            ["Product Name is left-aligned."]
        ]

        emit-report %center-align-report.pdf
    ]

    button "Text Styles" blue [
        header: [
            ["ACME Corp" ['b] "Style Demo" ['i] "Internal" ['u]]
        ]
        content: copy [
            ["Bold Title" ['b]]
            [""]
            ["This line is italic." ['i]]
            ["This line is underlined." ['u]]
            ["This line is bold italic." ['b 'i]]
            ["This line is bold and underlined." ['b 'u]]
            ["This line is italic and underlined." ['i 'u]]
            ["This line is bold, italic and underlined." ['b 'i 'u]]
            [""]
            ["Heading Level 1" ['h1]]
            ["Heading Level 2" ['h2]]
            ["Heading Level 3" ['h3]]
            [""]
            ["Styled table cells below:"]
        ]
        footer: [
            ["ACME Corp" ['i] "%TIME%" "Page %PAGE% of %PAGES%" ['b]]
        ]

        append/only content reduce [
            'table 'box 'alt
            ["Item" ['< 160] "Status" ['^ 100] "Amount" ['> 100]]
            ["Widget A" ['i] "Active" ['b 'u] "$250.00"]
            ["Gadget B" ['b] "Pending" ['u] "$420.00"]
            ["Service C" ['b 'i] "Completed" ['i 'u] "$125.00"]
            ["Regular Item" "Active" "$100.00"]
        ]

        append content [
            [""]
            ["Summary" ['h2]]
            [""]
            ["Tags: data ['b] data ['i] data ['u] data ['h1] data ['h2] data ['h3]"]
            ["Line-level: ['m] ['h1] ['h2] ['h3] (as style block after data)"]
        ]

        emit-report %text-styles-report.pdf
    ]

    button "Mono Font" blue [
        header: [
            ["ACME Corp" ['m] "Mono Demo" ['b] "Internal" ['i]]
        ]
        content: copy [
            ["Monospaced text is ideal for aligned columns." ['m]]
            ["Bold mono for emphasis." ['m 'b]]
            ["Italic mono for variety." ['m 'i]]
            ["Bold italic underline mono." ['m 'b 'i 'u]]
            [""]
            ["Column alignments in mono:" ['m]]
        ]
        footer: [
            ["Mono Demo" ['m] "%TIME%" "Page %PAGE% of %PAGES%" ['b]]
        ]

        append/only content reduce [
            'table 'box 'alt
            ["Name" ['< 150] "Value" ['> 80] "Code" ['^ 100]]
            ["Alpha" ['m] "123.45" "AB-001"]
            ["Beta" ['m] "67.89" "CD-002"]
            ["Gamma" ['m] "901.23" "EF-003"]
            ["TOTAL" ['b] "1092.57" ""]
        ]

        append content [
            [""]
            ["Regular mono" ['m]]
            ["Bold mono" ['m 'b]]
            ["Italic mono" ['m 'i]]
            [""]
            ["Headings still use proportional font" ['h2]]
        ]

        emit-report %mono-report.pdf
    ]

    button "Number Formatting" blue [
        header: [
            "Number & Money Formatting"
        ]
        content: copy []
        footer: [
            ["Page %PAGE% of %PAGES%" ['b]]
        ]

        append content [
            ["Tables support automatic number formatting."]
            ["Use 'money for currency and 5.4 for decimal places."]
        ]

        append/only content reduce [
            'table 'box 'alt
            ["Item" ['< 150] "Qty" ['> 80] "Weight" ['> 100 5.4] "Price" ['> 100 'money] "Total" ['> 100 'money]]
            ["Widget" 100 3.14159 25.00 2500]
            ["Gadget" 50 0.001 42.50 2125.0]
            ["Parts" 200 1234.5678 0.75 150.0]
            ["TOTALS" ['b] 350 "" "" 4775.00]
        ]

        append content [
            ["Numbers in table cells are formatted automatically."]
            ["Negative values get a minus prefix."]
        ]

        emit-report %format-report.pdf
    ]

    button "Mixed Sizes" blue [
        header: [
            ["Mixed Font Size Demo" ['h1]]
            [" " " " "%DATETIME%" ['b]]
        ]
        content: copy []
        footer: [
            ["ACME Corp" ['b] "%TIME%" "Page %PAGE% of %PAGES%"]
        ]

        append content [
            ["Per-segment heading styles mixed with regular text:"]
            [""]
            ["Big title " ['h1] "followed by normal text."]
            ["Regular " [] "bold " ['b] "italic " ['i] "and " ['h3] "small heading" [] " together."]
            ["Mono " ['m] "mixed with " [] "h2 heading" ['h2] " and " [] "bold underline" ['b 'u] "."]
            [""]
            ["The line height adapts to the tallest segment on each line."]
            [""]
            ["Table with heading-sized cells:"]
        ]

        append/only content reduce [
            'table 'box 'alt
            ["Category" ['< 150] "Label" ['< 180] "Value" ['> 100]]
            ["Revenue" ['h3] "Total income" 50000]
            ["Costs" ['b] "Operating expenses" 35000]
            ["Net" ['h2] "Profit" ['b 'u] 15000]
            ["Plain" "Regular row" 0]
        ]

        emit-report %mixed-sizes-report.pdf
    ]

    button "Exit" red [unview]
][size: 400x500]
