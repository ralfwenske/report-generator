Red [
    File: %basic-demo.red
    Title: "Basic Demo"
]
unless value? 'report-generator [
    do load %report-generator.red
]

report-dir: to-file rejoin [get-current-dir %reports/] 

title: "Basic Demo"
widget-C:  [[red] "Widget B" [green] "-45" [red] total [red] "Check" [255.165.0 white]]
get-items: func [res [block!]] [
    repeat i 30 [
        append/only res reduce ["Item " i]
    ]
    res
]

rpt: copy []
append rpt reduce [        
    'HEADER
    reduce [['b] "ACME Corp" ['h1 red] (title) ['h2] "%DATE%"]
    ["Page %PAGE% of %PAGES%" "" "%TIME%"]
    []
    'CONTENT
    ["Basic Report" ['b]]
    ["Generated on " ['i] "%DATE%"]
    []
    [['m] "Sample content goes here." [purple white] "and yellow here" [yellow black]]
    ["Table with 'box 'alt" ['u 'h2]]
    ['table 'box 'alt
        ["Product" ['< 180] "Qty" ['^ 60 5.4 ] "Total" ['> 80 'money] "Status" ['^ 80]]
        ["Widget A" 120 threethousand ['b] "OK" [80.128.80 white]]
        ["Widget B" [80.150.200] "45" total "Check" [55.105.90 white]]
        widget-C
        ["TOTALS" ['b] "" "$13'780.00" ""]
    ]
    [['IMAGE 300 rejoin [report-dir %crypto.jpg]]]
    ["and here a columns demo" ['u 'h2]]
    get-items ['COLUMN]
    'FOOTER
    []
    [['b] " Confidential " ['h3 blue white] "%DATE%" "Page %PAGE% of %PAGES%"]
]
generate-report/browser rpt rejoin [report-dir %basic-demo.pdf]
wait 1
delete rejoin [report-dir %basic-demo.pdf]