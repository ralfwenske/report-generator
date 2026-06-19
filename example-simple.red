Red []

do %report-generator.red

widgetC: ["Widget C" "245" ['b] 8890.00]
threethousand: 3000
total: 1890.0

;---------------------------------------------------------
generate-report 
    [ ;HEADER
        ;['h1 "ACME Corp" /h1 'b "Quarterly Report" /b "Confidential"]
        ["ACME Corp" [h1] "Quarterly Report" ['b] "Confidential"]
        ;[" " " " 'b "%DATETIME%"]
        [" " " " "%DATETIME%" ['b]]
    ] ;header

    [ ;CONTENT
        ;['b "Sales Summary for " 'u "Q1 2015"]
        ["Sales Summary for " ['b] "Q1 2015" ['u]]
        ;['u "Q1 sales data for all product lines."]
        ["Q1 sales data for all product lines." ['u]]
        ;['m 'b "a bold monofont here"]
        ["a bold monofont here" ['m 'b]]
        ;['m    "                   *"]
        ["                   *" ['m]]
        []
        ;['b "'table" 'i " 'box 'alt"]
        ["'table" ['b] " 'box 'alt" ['i]]
        [
            'table 'box 'alt
            ;['< 180 "Product" '^ 60 5.4 "Qty" '> 80 'money "Total"]
            ["Product" ['< 180] "Qty" ['^ 60 5.4 ] "Total" ['> 80 'money]]
            ;["Widget A" 120 'b threethousand]
            ["Widget A" 120 threethousand ['b] ]
            ["Widget B" "45" total]
            widgetC
            ;['b "TOTALS" /b "" "$13'780.00"]
            ["TOTALS" ['b] "" "$13'780.00"]
        ]
        []
        ["'table 'alt" ['i]]

        ["End of report." ['u]]
    ] ;content

    [ ;FOOTER
        ;['b "ACME Corp" /b "%TIME%" "Page %PAGE% of %PAGES%"]
        ["ACME Corp" ['b] "%TIME%" "Page %PAGE% of %PAGES%"]
    ] ;footer

    %reports/example-simple.pdf
