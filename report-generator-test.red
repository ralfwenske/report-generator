Red [
    Title: "Report Generator - Test"
]

do %report-generator.red

view/options layout [
    below
    text 350x20 "Report Generator Test" bold white center
    preview: check "Preview" false

    button "Text Report" blue [
        header: [
            ["ACME Corp" "Monthly Sales Report"]
            [" " " " 'b "%DATETIME%"]
        ]

        content: copy []
        i: 0
        while [i < 60][
            i: i + 1
            append/only content reduce [['b rejoin ["Record #" i ": "] /b rejoin ["Product widget #" i " - Qty: " (i * 3)]]]
        ]

        footer: [['b "Confidential" /b "%DATE%" "Page %PAGE% of %PAGES%"]]

        either preview/data [
            generate-report/browser header content footer %reports/text-report.pdf
        ][
            generate-report header content footer %reports/text-report.pdf
        ]
    ]

    button "Table Report" blue [
        header: ["Product Inventory"]

        content: copy []
        append/only content reduce [
            'table
            ['< 180 "Product" '> 60 "Qty" '> 80 "Price" '> 80 "Total"]
            ["Widget A" "10" "$25.00" "$250.00"]
            ["Widget B" "5" "$42.00" "$210.00"]
            ["Gadget X" "23" "$12.50" "$287.50"]
        ]

        footer: [["Page %PAGE% of %PAGES%" "" "%TIME%"]]

        either preview/data [
            generate-report/browser header content footer %reports/table-report.pdf
        ][
            generate-report header content footer %reports/table-report.pdf
        ]
    ]

    button "Unified Report" blue [
        header: [
            "ACME Corporation"
            "Quarterly Report"
        ]

        i: 0
        content: copy []

        append content [
            ['b "Sales Summary" /b]
            [""]
            ["Below is the Q1 sales data for all product lines."]
            ["Revenue targets were met across all categories."]
        ]

        append/only content reduce [
            'table 'box 'alt
            ['< 180 "Product" '> 60 "Qty" '> 80 "Price" '> 80 "Total"]
            ["Widget A" "120" "$25.00" "$3000.00"]
            ["Widget B" "45" "$42.00" "$1890.00"]
            ["Gadget X" "200" "$12.50" "$2500.00"]
            ["Gizmo Z" "33" "$99.00" "$3267.00"]
            ['b "TOTALS" /b "" "" "$10657.00"]
        ]

        repeat x 10 [
            i: i + 1
            append/only content reduce [rejoin ["Record #" i ": Product widget #" i " - Qty: " (i * 3)]]
        ]

        append/only content reduce [
            'table
            ['< 180 "Product" '> 60 "Qty" '> 80 "Price" '> 80 "Total"]
            ["Widget A" "120" "$25.00" "$3000.00"]
            ["Widget B" "45" "$42.00" "$1890.00"]
        ]

        repeat x 7 [
            i: i + 1
            append/only content reduce [rejoin ["Record #" i ": Product widget #" i " - Qty: " (i * 3)]]
        ]

        append content ["^L"]
        append content [
            ['b "Expenses" /b]
            [""]
            ["Operating expenses for the quarter."]
        ]

        append/only content reduce [
            'table
            ['< 200 "Category" '> 100 "Amount"]
            ["Rent" "$4500.00"]
            ["Utilities" "$1200.00"]
            ["Supplies" "$800.00"]
            ['b "TOTAL" /b "$6500.00"]
        ]

        repeat x 40 [
            i: i + 1
            append/only content reduce [rejoin ["Record #" i ": Product widget #" i " - Qty: " (i * 3)]]
        ]

        append content [
            [""]
            ['b "Net Profit: $4157.00" /b]
            [""]
            ['u "End of quarterly report" /u]
        ]

        footer: [
            ["" "ACME Corp - Confidential" ""]
            ["Page %PAGE% of %PAGES%" "" "%DATETIME%"]
        ]

        either preview/data [
            generate-report/browser header content footer %reports/unified-report.pdf
        ][
            generate-report header content footer %reports/unified-report.pdf
        ]
    ]

    button "Page breaks" blue [
        header: ["Inventory Report"]

        content: copy []
        append content [
            ["Full inventory listing:"]
        ]

        append/only content reduce [
            'table 'alt
            ['> 60 "ID" '< 200 "Name" '> 100 "Amount"]
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

        footer: [["Page %PAGE% of %PAGES%" "" "%DATETIME%"]]

        either preview/data [
            generate-report/browser header content footer %reports/pagebreak-report.pdf
        ][
            generate-report header content footer %reports/pagebreak-report.pdf
        ]
    ]

    button "Multi-column Header/Footer" blue [
        header: [
            ["ACME Corp" "Quarterly Report" "Confidential"]
            ["Dept: Sales" "" "%DATETIME%"]
        ]

        content: copy []
        append content [
            ["This report demonstrates multi-column header and footer lines."]
            ["The header has left, center, and right text on each line."]
            [""]
            ['b "Sales by Region" /b]
        ]

        append/only content reduce [
            'table 'box 'alt
            ['< 160 "Region" '> 80 "Q1" '> 80 "Q2" '> 80 "Total"]
            ["North" "$12000" "$14500" "$26500"]
            ["South" "$8500" "$9200" "$17700"]
            ["East" "$15000" "$16800" "$31800"]
            ["West" "$11000" "$12400" 23400]
            ['b "TOTAL" /b "$46500" "$52900" "$99400"]
        ]

        repeat x 40 [
            append/only content reduce [rejoin ["Detail line #" x ": Additional supporting data for the quarterly analysis."]]
        ]

        footer: [
            ["ACME Corp" "%DATETIME%" "Page %PAGE% of %PAGES%"]
        ]

        either preview/data [
            generate-report/browser header content footer %reports/multicolumn-report.pdf
        ][
            generate-report header content footer %reports/multicolumn-report.pdf
        ]
    ]

    button "Center-aligned Columns" blue [
        header: [
            ["Product Catalog" "Item Listing" "Rev 3"]
        ]

        content: copy []
        append content [
            ["Table below demonstrates center-aligned columns using ^"."]
        ]

        append/only content reduce [
            'table 'alt
            ['^ 80 "SKU" '< 200 "Product Name" '^ 120 "Category" '> 80 "Price"]
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

        footer: [
            ["" "Center-aligned demo" ""]
            ["Company Inc" "%DATE%" "Page %PAGE% of %PAGES%"]
        ]

        either preview/data [
            generate-report/browser header content footer %reports/center-align-report.pdf
        ][
            generate-report header content footer %reports/center-align-report.pdf
        ]
    ]

    button "Text Styles" blue [
        header: [
            ['b "ACME Corp" /b 'i "Style Demo" /i 'u "Internal" /u]
        ]

        content: copy [
            ['b "Bold Title" /b]
            [""]
            ['i "This line is italic." /i]
            ['u "This line is underlined." /u]
            ['b 'i "This line is bold italic." /i /b]
            ['b 'u "This line is bold and underlined." /u /b]
            ['i 'u "This line is italic and underlined." /u /i]
            ['b 'i 'u "This line is bold, italic and underlined." /u /i /b]
            [""]
            ['h1 "Heading Level 1" /h1]
            ['h2 "Heading Level 2" /h2]
            ['h3 "Heading Level 3" /h3]
            [""]
            ["Styled table cells below:"]
        ]

        append/only content reduce [
            'table 'box 'alt
            ['< 160 "Item" '^ 100 "Status" '> 100 "Amount"]
            ['i "Widget A" /i 'b 'u "Active" /u /b "$250.00"]
            ['b "Gadget B" /b 'u "Pending" /u "$420.00"]
            ['b 'i "Service C" /i /b 'i 'u "Completed" /u /i "$125.00"]
            ["Regular Item" "Active" "$100.00"]
        ]

        append content [
            [""]
            ['h2 "Summary" /h2]
            [""]
            ["Tags: 'b '/b 'i '/i 'u '/u 'h1 '/h1 'h2 '/h2 'h3 '/h3"]
            ["Line-level: 'm 'h1 'h2 'h3 (at start of block)"]
        ]

        footer: [
            ['i "ACME Corp" /i "%TIME%" 'b "Page %PAGE% of %PAGES%" /b]
        ]

        either preview/data [
            generate-report/browser header content footer %reports/text-styles-report.pdf
        ][
            generate-report header content footer %reports/text-styles-report.pdf
        ]
    ]

    button "Mono Font" blue [
        header: [
            ['m "ACME Corp" 'b "Mono Demo" /b 'i "Internal" /i]
        ]

        content: copy [
            ['m "Monospaced text is ideal for aligned columns."]
            ['m 'b "Bold mono for emphasis." /b]
            ['m 'i "Italic mono for variety." /i]
            ['m 'b 'i 'u "Bold italic underline mono." /u /i /b]
            [""]
            ['m "Column alignments in mono:"]
        ]

        append/only content reduce [
            'table 'box 'alt
            ['< 150 "Name" '> 80 "Value" '^ 100 "Code"]
            ['m "Alpha" /m "123.45" "AB-001"]
            ['m "Beta" /m "67.89" "CD-002"]
            ['m "Gamma" /m "901.23" "EF-003"]
            ['b "TOTAL" /b "1092.57" ""]
        ]

        append content [
            [""]
            ['m "Regular mono"]
            ['m 'b "Bold mono" /b]
            ['m 'i "Italic mono" /i]
            [""]
            ['h2 "Headings still use proportional font" /h2]
        ]

        footer: [
            ['m "Mono Demo" "%TIME%" 'b "Page %PAGE% of %PAGES%" /b]
        ]

        either preview/data [
            generate-report/browser header content footer %reports/mono-report.pdf
        ][
            generate-report header content footer %reports/mono-report.pdf
        ]
    ]

    button "Number Formatting" blue [
        header: [
            "Number & Money Formatting"
        ]

        content: copy []

        append content [
            ["Tables support automatic number formatting."]
            ["Use 'money for currency and 5.4 for decimal places."]
        ]

        append/only content reduce [
            'table 'box 'alt
            ['< 150 "Item" '> 80 "Qty" '> 100 5.4 "Weight" '> 100 'money "Price" '> 100 'money "Total"]
            ["Widget" 100 3.14159 25.00 2500]
            ["Gadget" 50 0.001 42.50 2125.0]
            ["Parts" 200 1234.5678 0.75 150.0]
            ['b "TOTALS" /b 350 "" "" 4775.00]
        ]

        append content [
            ["Numbers in table cells are formatted automatically."]
            ["Negative values get a minus prefix."]
        ]

        footer: [
            ['b "Page %PAGE% of %PAGES%" /b]
        ]

        either preview/data [
            generate-report/browser header content footer %reports/format-report.pdf
        ][
            generate-report header content footer %reports/format-report.pdf
        ]
    ]

    button "Exit" red [unview]
][size: 700x470]
