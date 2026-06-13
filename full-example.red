Red []

do %report-generator.red

header: [
    ["ACME Corp" "Quarterly Report" "Confidential"]
    ""
]
footer: [
    ["ACME Corp" "" "Page %PAGE% of %PAGES%"]
]

content: copy []

append content "*Sales Summary*"
append content ""
append content "Q1 sales data for all product lines."
append content ""

append/only content reduce [
    'table
    ["Product" 180 "L" "Qty" 60 "C" "Total" 80 "R"]
    ["Widget A" "120" "$3000.00"]
    ["Widget B" "45" "$1890.00"]
    ["*TOTALS*" "" "$4890.00"]
]

append content ""
append content "End of report."

generate-report/no-print header content footer %reports/full-example.pdf
