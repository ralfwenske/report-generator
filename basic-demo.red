Red [
    File: %basic-demo.red
    Title: "Basic Demo"

]
unless value? 'report-generator [
    do load %report-generator.red
]

report-dir: to-file rejoin [get-current-dir %reports/] 
get-items: func [res [block!]] [
    repeat i 30 [
        append/only res reduce ["Item " i]
    ]
    res
]

landscape: system/script/args

title: "Basic Demo"
widget-C:  [[red] "Widget C" [green] "-45" [red] total [red] "Check" [255.165.0 white]]
fourthousand: 4000

rpt: copy []
append rpt reduce [        
    'HEADER
    reduce [['b] "ACME Corp" ['h1 red] (title) ['h2] "%DATE%"]
    ["Page %PAGE% of %PAGES%" "" "%TIME%"]
    []
    'CONTENT
    ["This code generates this pdf page:" ['h2 yellow]]
    ['IMAGE 400 %reports/PDF-Report-Code.png ]
    []
    ["Generated on " ['i] "%DATE%"]
    []
    [['m] " Sample content goes here. " [purple white] " And yellow here " [yellow black]]
    ["Table with 'box 'alt" ['u 'h2]]
    ['table 'box 'alt
        ["Product" ['< 180] "Qty" ['^ 60 5.4 ] "Total" ['> 80 'money] "Status" ['^ 80]]
        ["Widget A" 120 threethousand ['b] "OK" [80.128.80 white]]
        ["Widget A1" 120 fourthousand ['b] "OK" [80.128.80 white]]
        ["Widget B" [80.150.200] "45" total "Check" [55.105.90 white]]
        widget-C
        ["TOTALS" ['b] "" "$13'780.00" ""]
    ]
    ["and here a columns demo" ['u 'h2]]
    get-items ['COLUMN]
    'FOOTER
    []
    [['b] " Confidential " ['h3 blue white] "%DATE%" "Page %PAGE% of %PAGES%"]
]
if landscape = 'landscape [
    paper-format/landscape 'a4
]
generate-report/browser rpt rejoin [report-dir %basic-demo.pdf]
wait 1
delete rejoin [report-dir %basic-demo.pdf]