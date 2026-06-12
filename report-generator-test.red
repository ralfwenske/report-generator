Red [
    Title: "Report Generator - Test"
]

do %report-generator.red

view/options layout [
    below
    text 350x20 "Report Generator Test" bold white center

    button "Text Report" blue [
        header: [
            "ACME Corporation"
            "Monthly Sales Report"
            ""
        ]

        content: copy []
        i: 0
        while [i < 60][
            i: i + 1
            append content rejoin ["Record #" i ": Product widget #" i " - Qty: " (i * 3)]
        ]

        footer: ["Page %PAGE% of %PAGES% | Confidential"]

        generate-report/no-print header content footer %reports/text-report.pdf
    ]

    button "Table Report" blue [
        header: ["Product Inventory"]

        content: copy []
        append/only content reduce [
            'table
            ["Product" 180 "L" "Qty" 60 "R" "Price" 80 "R" "Total" 80 "R"]
            ["Widget A" "10" "$25.00" "$250.00"]
            ["Widget B" "5" "$42.00" "$210.00"]
            ["Gadget X" "23" "$12.50" "$287.50"]
        ]

        footer: ["Page %PAGE% of %PAGES%"]

        generate-report/no-print header content footer %reports/table-report.pdf
    ]

    button "Unified Report (text + tables)" blue [
        header: [
            "ACME Corporation"
            "Quarterly Report"
            ""
        ]
        i: 0
        content: copy []

        append content "*Sales Summary*"
        append content ""
        append content "Below is the Q1 sales data for all product lines."
        append content "Revenue targets were met across all categories."
        append content ""

        append/only content reduce [
            'table
            ["Product" 180 "L" "Qty" 60 "R" "Price" 80 "R" "Total" 80 "R"]
            ["Widget A" "120" "$25.00" "$3000.00"]
            ["Widget B" "45" "$42.00" "$1890.00"]
            ["Gadget X" "200" "$12.50" "$2500.00"]
            ["Gizmo Z" "33" "$99.00" "$3267.00"]
            ["*TOTALS*" "" "" "$10657.00"]
        ]

        repeat x 10 [
            i: i + 1
            append content rejoin ["Record #" i ": Product widget #" i " - Qty: " (i * 3)]
        ]

        append/only content reduce [
            'table
            ["Product" 180 "L" "Qty" 60 "R" "Price" 80 "R" "Total" 80 "R"]
            ["Widget A" "120" "$25.00" "$3000.00"]
            ["Widget B" "45" "$42.00" "$1890.00"]
        ]

        repeat x 7 [
            i: i + 1
            append content rejoin ["Record #" i ": Product widget #" i " - Qty: " (i * 3)]
        ]
        append content "^L"
        append content "*Expenses*"
        append content ""
        append content "Operating expenses for the quarter."
        append content ""

        append/only content reduce [
            'table
            ["Category" 200 "L" "Amount" 100 "R"]
            ["Rent" "$4500.00"]
            ["Utilities" "$1200.00"]
            ["Supplies" "$800.00"]
            ["*TOTAL*" "$6500.00"]
        ]
   
        repeat x 40 [
            i: i + 1
            append content rejoin ["Record #" i ": Product widget #" i " - Qty: " (i * 3)]
        ]

        append content ""
        append content "*Net Profit: $4157.00*"
        append content ""
        append content "_End of quarterly report_"

        footer: [
            ""
            "ACME Corp - Confidential"
            "Page %PAGE% of %PAGES%"
        ]

        generate-report/no-print header content footer %reports/unified-report.pdf
    ]

    button "Report with page breaks" blue [
        header: ["Inventory Report"]

        content: copy []
        append content "Full inventory listing:"
        append content ""

        append/only content reduce [
            'table
            ["ID" 60 "R" "Name" 200 "L" "Amount" 100 "R"]
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

        append content ""
        append content "End of inventory."

        footer: ["Page %PAGE% of %PAGES%"]

        generate-report/no-print header content footer %reports/pagebreak-report.pdf
    ]

    button "Multi-column Header/Footer" blue [
        header: [
            ["ACME Corp" "Quarterly Report" "Confidential"]
            ["Dept: Sales" "" "Date: 2026-06-12"]
            ""
        ]

        content: copy []
        append content "This report demonstrates multi-column header and footer lines."
        append content "The header has left, center, and right text on each line."
        append content ""
        append content "*Sales by Region*"
        append content ""

        append/only content reduce [
            'table
            ["Region" 160 "L" "Q1" 80 "R" "Q2" 80 "R" "Total" 80 "R"]
            ["North" "$12000" "$14500" "$26500"]
            ["South" "$8500" "$9200" "$17700"]
            ["East" "$15000" "$16800" "$31800"]
            ["West" "$11000" "$12400" 23400]
            ["*TOTAL*" "$46500" "$52900" "$99400"]
        ]

        repeat x 30 [
            append content rejoin ["Detail line #" x ": Additional supporting data for the quarterly analysis."]
        ]

        footer: [
            ["ACME Corp" "" "Page %PAGE% of %PAGES%"]
        ]

        generate-report/no-print header content footer %reports/multicolumn-report.pdf
    ]

    button "Center-aligned Columns" blue [
        header: [
            ["Product Catalog" "Item Listing" "Rev 3"]
            ""
        ]

        content: copy []
        append content "Table below demonstrates center-aligned columns using ^"C^"."
        append content ""

        append/only content reduce [
            'table
            ["SKU" 80 "C" "Product Name" 200 "L" "Category" 120 "C" "Price" 80 "R"]
            ["W-001" "Widget Alpha" "Hardware" "$25.00"]
            ["W-002" "Widget Beta" "Hardware" "$42.00"]
            ["G-001" "Gadget Pro" "Electronics" "$99.00"]
            ["G-002" "Gadget Lite" "Electronics" "$59.00"]
            ["S-001" "Service Plan A" "Services" "$150.00"]
            ["S-002" "Service Plan B" "Services" "$250.00"]
            ["X-001" "Extension Kit" "Accessories" "$15.00"]
            ["X-002" "Mounting Bracket" "Accessories" "$8.50"]
        ]

        append content ""
        append content "SKU and Category columns are center-aligned."
        append content "Price column is right-aligned."
        append content "Product Name is left-aligned."

        footer: [
            ["" "Center-aligned demo" ""]
            ["Company Inc" "" "Page %PAGE% of %PAGES%"]
        ]

        generate-report/no-print header content footer %reports/center-align-report.pdf
    ]

    button "Text Styles" blue [
        header: [
            ["~b~ACME Corp" "~i~Style Demo" "~u~Internal"]
            ""
        ]

        content: copy []
        append content "~b~Bold Title"
        append content ""
        append content "~i~This line is italic."
        append content "~u~This line is underlined."
        append content "~bi~This line is bold italic."
        append content "~bu~This line is bold and underlined."
        append content "~iu~This line is italic and underlined."
        append content "~biu~This line is bold, italic and underlined."
        append content ""
        append content "~h1~Heading Level 1"
        append content "~h2~Heading Level 2"
        append content "~h3~Heading Level 3"
        append content ""
        append content "Regular text with legacy *bold* and _underline_ inline markup."
        append content ""
        append content "~b~Styled table cells below:"
        append content ""

        append/only content reduce [
            'table
            ["Item" 160 "L" "~b~Status" 100 "C" "~b~Amount" 100 "R"]
            ["~i~Widget A" "~bu~Active" "$250.00"]
            ["~b~Gadget B" "~u~Pending" "$420.00"]
            ["~bi~Service C" "~iu~Completed" "$125.00"]
            ["Regular Item" "Active" "$100.00"]
        ]

        append content ""
        append content "~h2~Summary"
        append content ""
        append content "Prefixes: b=bold i=italic u=underline h1/h2/h3=headings"
        append content "Combine letters: bi bu iu biu (any order)"

        footer: [
            ["~i~ACME Corp" "" "~b~Page %PAGE% of %PAGES%"]
        ]

        generate-report/no-print header content footer %reports/text-styles-report.pdf
    ]

    button "Exit" red [unview]
][size: 700x430]
