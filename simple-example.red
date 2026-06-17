Red []

do %report-generator.red

widgetC: ["Widget C" "245" 8890.00]
threethousand: 3000
total: 1890.0

;---------------------------------------------------------
generate-report 
    [ ;HEADER
        ['h1 "ACME Corp" /h1 'b "Quarterly Report" /b "Confidential"]
        [" " " " 'b "%DATETIME%"]
    ] ;header

    [ ;CONTENT
        ['b "Sales Summary for " /b 'u "Q1 2015" /u]
        ["Q1 sales data for all product lines."]
        [
            'table 'box 'alt
            ['< 180 "Product" '^ 60 5.4 "Qty" '> 80 'money "Total"]
            ["Widget A" 120 'b threethousand]
            ["Widget B" "45" total]
            widgetC
            ['b "TOTALS" /b "" "$13'780.00"]
        ]
        ["End of report."]
    ] ;content

    [ ;FOOTER
        ['b "ACME Corp" /b "%TIME%" "Page %PAGE% of %PAGES%"]
    ] ;footer

    %reports/simple-example.pdf
