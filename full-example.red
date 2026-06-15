Red []

do %report-generator.red

widgetC: reduce ["Widget C" "245" (to-money 8890.00)]
threethousand: 3000

;---------------------------------------------------------
generate-report 
    [ ;HEADER
        ["ACME Corp" "~h1~Quarterly Report" "~iu~Confidential"]
        ["" "%DATETIME%"]
    ] ;header

    [ ;CONTENT
    ""
    "*Sales Summary*"
    ""
    "Q1 sales data for all product lines."
    ""
    [
        'table
        ["Product" 180 "L" "Qty" 60 "C" "Total" 80 "R"]
        ["Widget A" "120" (to-money threethousand)]
        ["Widget B" "45" "$1'890.00"]
        widgetC
        ["~b~TOTALS" "" "$13'780.00"]
    ]
    ""
    "End of report."
    ] ;content

    [ ;FOOTER
        ["ACME Corp" "%TIME%" "Page %PAGE% of %PAGES%"]
    ] ;footer

    %reports/full-example.pdf
