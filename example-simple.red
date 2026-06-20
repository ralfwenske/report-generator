Red []

do %report-generator.red

widgetC: ["Widget C" "245" ['b] 8890.00]
threethousand: 3000
total: 1890.0

;---------------------------------------------------------
generate-report 
    [   'HEADER
        [['b] "ACME Corp" [h1] "Quarterly Report" [] "Confidential"]
        [" " " " "%DATETIME%" ['b]]

        'CONTENT
        ["Sales Summary for " ['b] "Q1 2015" ['u]]
        ["Q1 sales data for all product lines." ['u]]
        ["a bold monofont here" ['m 'b]]
        ["                   *" ['m]]
        [""]
        ["'table" ['b] " 'box 'alt" ['i]]

        ['table 'box 'alt
            ["Product" ['< 180] "Qty" ['^ 60 5.4 ] "Total" ['> 80 'money]]
            ["Widget A" 120 threethousand ['b] ]
            ["Widget B" "45" total]
            widgetC
            ["TOTALS" ['b] "" "$13'780.00"]
        ]
        []
        
        ['table 'alt
            ["Product" ['< 180] "Qty" ['^ 60 5.4 ] "Total" ['> 80 'money]]
            ["Widget A" 120 threethousand ['b] ]
            ["Widget B" "45" total]
            widgetC
            ["TOTALS" ['b] "" "$13'780.00"]
        ]
        ["'table 'alt" ['i]]
        ["End of report." ['u]]

        'FOOTER
        [['i] "ACME Corp" ['b 'h2] "%TIME%" "Page %PAGE% of %PAGES%"]
    ]

    %reports/example-simple.pdf
