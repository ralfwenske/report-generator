Red [
    Title: "Report Generator Test"
    Needs: 'View
]

do %report-generator.red
what-functions: load %functions.txt
; structure: [["name" "type" {description}] ...]

what-kinds: function [] [
    kinds: []
    foreach item what-functions [
        unless find kinds item/2 [
            append kinds item/2
        ]
    ]
    kinds
] ; what-kinds

what-filter: function [filter [string!]] [
    result: copy []
    foreach item what-functions [
        if item/2 = filter [
            append result trim item/1
        ]
    ]
    result
] ; what-filter

what-columns: function [] [
    result: copy []
    foreach kind what-kinds [
        title: copy rejoin ["Red - " kind]
        append result reduce [
            []
            ["^L" 10]
            reduce [title ['h2] "  shown in as many columns as fit (automatically)" ['i]]
            []
        ]
        kind-column: copy ['COLUMN * 0]
        f: copy what-filter kind
        repeat ix (length? f) [
            append/only kind-column reduce [f/(ix)]
        ]
        append/only result kind-column
    ]
    result
] ; what-columns


std-header: func [title [string!]] [
    reduce [
        'HEADER
        reduce [['b] "ACME Corp" ['h1 red] (title) ['h2] "%DATE%"]
        reduce ["Page %PAGE% of %PAGES%" "" "%TIME%"]
        [""]
    ]
] ; std-header

std-footer: function [extra [string!]] [
    result: [
        'FOOTER
        []
        [['b] "Confidential" "%DATE%" "Page %PAGE% of %PAGES%"]
    ]
    if extra <> "" [
        append/only result reduce [extra ['i]]
    ]
    result
] ; std-footer

widgetC: ["Widget C" "245" ['b] 8890.00]
threethousand: 3000
total: 1890.0
zero: 0

pdf-report: function [] [

    rpt: copy std-header "Long Report Demo"

    append rpt [
        'CONTENT
        ["Sales Summary for " ['b] "Q1 2015" ['u]]
        ["Q1 sales data for all product lines. " ['u] zero ['b]]
        ["a bold monofont here" ['m 'b]]
        ["                   *" ['m 'u]]
        [""]
        ["Table with 'box 'alt" ['u 'h2]]
        ['table 'box 'alt
            ["Product" ['< 180] "Qty" ['^ 60 5.4 ] "Total" ['> 80 'money] "Status" ['^ 80]]
            ["Widget A" 120 threethousand ['b] "OK" [0.128.0 white]]
            ["Widget B" [80.150.200] "45" total "Check" [255.165.0 white]]
            widgetC
            ["TOTALS" ['b] "" "$13'780.00" ""]
        ]
        [""]
        ["Table with 'box" ['u 'h2]]
        ['table 'box
            ["Product" ['< 150] "Qty" ['^ 60 5.4 ] "Total" ['> 80 'money]]
            ["Widget A" 120 threethousand ['b] ]
            ["Widget B" "45" total]
        ]
        [""]
        ["^L" 6]
        ["Table " ['u 'h2]]
        ['table
            ["Product" ['< 120] "Qty" ['^ 60 5.4 ] "Total" ['> 80 'money]]
            ["Widget A" 120 threethousand ['b] ]
            ["Widget B" "45" total]
        ]
        [""]
    ]
    append/only rpt ["words-of system shown in columns " ['h2]]
    f-cols: copy ['COLUMN * 10]
    foreach w sort words-of system [
        append/only f-cols reduce [mold w]
    ]
    append/only rpt f-cols
    append rpt [""]
    append rpt ["(1) first paren"]
    append rpt ["2) second paren"]
    append rpt ["We start a new page (if needed)"]
    append rpt [{(each 'RED' word columns tests min 10 lines for page breaks)}]

    append rpt what-columns

    append rpt std-footer ""
    rpt
] ; pdf-report

emit-report: function [rpt
    file-name [file!]
][
    fontsize 14
    pdf: rejoin [%reports/ file-name]
    either preview/data [
        generate-report/browser rpt pdf
        wait 1
        delete pdf
    ][
        generate-report rpt pdf
    ]
] ; emit-report

view/options layout [
    title "PDF Generator Test"
    below
    text 180x20 "PDF Generator Test" bold white center
    preview: check "Preview" true
    landscape: check "Landscape" false

    button "PDF Report" [
        either landscape/data [
            paper-format/landscape 'a4
            emit-report pdf-report %report-landscape.pdf
        ][
            paper-format 'a4
            emit-report pdf-report %report-portrait.pdf
        ]
        unview
    ]
    button "Dump Source" [
        foreach item pdf-report [
            probe item
        ]
    ]
][size: 200x200]