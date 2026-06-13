Red [
    Title: "Report Generator Module"
    Purpose: "Generate multi-page A4 PostScript reports with text and tables"
    Exports: [generate-report ]
]

context [
    page-width: 595
    page-height: 842
    margin-left: 50
    margin-right: 50
    margin-top: 50
    margin-bottom: 50
    font-size: 12
    line-height: 15
    bold-font: "/Times-Bold"
    italic-font: "/Times-Italic"
    bold-italic-font: "/Times-BoldItalic"
    regular-font: "/Times-Roman"

    ps-escape: func [
        "Escape parentheses and backslashes for PostScript strings"
        s [string!]
    ][
        replace/all s "\\" "\\\\"
        replace/all s "("  "\\("
        replace/all s ")"  "\\)"
        s
    ]

    emit-font: func [
        out [string!]
        font-name [string!]
    ][
        append out rejoin [font-name " findfont " font-size " scalefont setfont"]
        append out lf
    ]

    emit-text: func [
        out [string!]
        x [integer!]
        y [integer!]
        text [string!]
        /center col-w-c [integer!]
        /right col-w-r [integer!]
    ][
        append out rejoin ["gsave" lf x " " y " moveto (" ps-escape text ")"]
        if center [
            append out rejoin [" stringwidth pop" lf  col-w-c " exch sub 2 div " x " add " y " moveto (" ps-escape text ")"]
        ]
        if right [
            append out rejoin [" stringwidth pop" lf  col-w-r " exch sub " x " add " y " moveto (" ps-escape text ")" ]
        ]
        append out rejoin [" show" lf "grestore" lf]
    ]

    parse-style: func [
        "Parse ~X~ style prefix from text, returns [bold? italic? underline? heading text]"
        s [string!]
        /local n prefix ch bold italic underline heading text i has-style
    ][
        bold: false
        italic: false
        underline: false
        heading: 0
        has-style: false
        text: s

        if (length? s) < 3 [return reduce [bold italic underline heading text]]
        if s/1 <> #"~" [return reduce [bold italic underline heading text]]

        n: 2
        while [n <= 5][
            if n > length? s [break]
            if s/:n = #"~" [break]
            n: n + 1
        ]

        either all [n >= 3 n <= 5 n <= length? s s/:n = #"~"][
            prefix: copy/part at s 2 (n - 2)
            text: copy at s (n + 1)

            i: 1
            while [i <= length? prefix][
                ch: prefix/:i
                has-style: true
                case [
                    ch = #"b" [bold: true]
                    ch = #"i" [italic: true]
                    ch = #"u" [underline: true]
                    ch = #"h" [
                        if (i + 1) <= length? prefix [
                            ch: prefix/(i + 1)
                            if all [ch >= #"1" ch <= #"3"][
                                heading: to integer! to string! ch
                            ]
                            i: i + 1
                        ]
                    ]
                    true [has-style: false]
                ]
                i: i + 1
            ]
            unless has-style [text: s]
        ][
            text: s
        ]

        reduce [bold italic underline heading text]
    ]

    select-style-font: func [
        "Emit PostScript font selection based on style flags"
        out [string!]
        bold [logic!]
        italic [logic!]
        heading [integer!]
    ][
        either heading > 0 [
            append out rejoin [
                either bold [bold-font][either italic [italic-font][regular-font]]
                " findfont "
                case [
                    heading = 1 [24]
                    heading = 2 [18]
                    heading = 3 [14]
                    true [font-size]
                ]
                " scalefont setfont"
            ]
        ][
            append out rejoin [
                case [
                    all [bold italic] [bold-italic-font]
                    bold [bold-font]
                    italic [italic-font]
                    true [regular-font]
                ]
                " findfont " font-size " scalefont setfont"
            ]
        ]
        append out lf
    ]

    emit-underline: func [
        "Draw an underline beneath text at the current font, respecting alignment"
        out [string!]
        x [integer!]
        y [integer!]
        text [string!]
        col-w [integer!]
        align [string!]
    ][
        append out "gsave"
        append out lf
        append out "newpath"
        append out lf
        either align = "C" [
            append out rejoin [
                "(" ps-escape text ") stringwidth pop dup "
                col-w " exch sub 2 div " x " add "
                (y - 2) " moveto 0 rlineto stroke"
            ]
        ][either align = "R" [
            append out rejoin [
                "(" ps-escape text ") stringwidth pop dup "
                col-w " exch sub " x " add 3 sub "
                (y - 2) " moveto 0 rlineto stroke"
            ]
        ][
            append out rejoin [
                x " " (y - 2) " moveto "
                "(" ps-escape text ") stringwidth pop 0 rlineto stroke"
            ]
        ]]
        append out lf
        append out "grestore"
        append out lf
    ]

    emit-styled: func [
        "Parse ~X~ prefix, select font, emit aligned text, handle underline, reset font"
        out [string!]
        x [integer!]
        y [integer!]
        text [string!]
        col-w [integer!]
        align [string!]
        default-font [string!]
        /local style
    ][
        style: parse-style text
        either any [style/1 style/2 style/3 style/4 > 0][
            select-style-font out style/1 style/2 style/4
            case [
                align = "C" [emit-text/center out x y style/5 col-w]
                align = "R" [emit-text/right out x y style/5 col-w]
                true [emit-text out x y style/5]
            ]
            if style/3 [emit-underline out x y style/5 col-w align]
            emit-font out default-font
        ][
            emit-font out default-font
            case [
                align = "C" [emit-text/center out x y text col-w]
                align = "R" [emit-text/right out x y text col-w]
                true [emit-text out x y text]
            ]
        ]
    ]

    emit-rect: func [
        out [string!]
        x [integer!]
        y [integer!]
        w [integer!]
        h [integer!]
    ][
        append out rejoin ["newpath " x " " y " moveto " w " 0 rlineto 0 " h " rlineto " (0 - w) " 0 rlineto closepath stroke"]
        append out lf
    ]

    emit-filled-rect: func [
        out [string!]
        x [integer!]
        y [integer!]
        w [integer!]
        h [integer!]
        gray [float!]
    ][
        append out "gsave"
        append out lf
        append out rejoin [gray " setgray newpath " x " " y " moveto " w " 0 rlineto 0 " h " rlineto " (0 - w) " 0 rlineto closepath fill"]
        append out lf
        append out "grestore"
        append out lf
    ]

    emit-header: func [
        out [string!]
        hdr [block! none!]
        page-y [integer!]
        /local col-w s
    ][
        if none? hdr [return page-y]

        col-w: page-width - margin-left - margin-right
        foreach line hdr [
            either block? line [
                if (length? line) >= 1 [
                    if s: pick line 1 [emit-styled out margin-left page-y to string! s col-w "L" bold-font]
                ]
                if (length? line) >= 2 [
                    if s: pick line 2 [emit-styled out margin-left page-y to string! s col-w "C" bold-font]
                ]
                if (length? line) >= 3 [
                    if s: pick line 3 [emit-styled out margin-left page-y to string! s col-w "R" bold-font]
                ]
            ][
                emit-styled out margin-left page-y line col-w "L" bold-font
            ]
            page-y: page-y - line-height
        ]
        emit-font out regular-font
        page-y
    ]

    emit-footer: func [
        out [string!]
        ftr [block! none!]
        page-num [integer!]
        total-pages [integer!]
        /local ftr-y text col-w s
    ][
        if none? ftr [exit]

        col-w: page-width - margin-left - margin-right
        ftr-y: margin-bottom + ((length? ftr) * line-height)
        foreach line ftr [
            either block? line [
                repeat i 3 [
                    if (length? line) >= i [
                        if s: pick line i [
                            text: copy to string! s
                            text: replace/all text "%PAGE%" to string! page-num
                            text: replace/all text "%PAGES%" to string! total-pages
                            emit-styled out margin-left ftr-y text col-w "L" regular-font
                        ]
                    ]
                ]
            ][
                text: copy line
                text: replace/all text "%PAGE%" to string! page-num
                text: replace/all text "%PAGES%" to string! total-pages
                emit-styled out margin-left ftr-y text col-w "L" regular-font
            ]
            ftr-y: ftr-y - line-height
        ]
    ]

    emit-data-line: func [
        out [string!]
        line [string!]
        page-y [integer!]
        /local style text
    ][
        style: parse-style line
        either any [style/1 style/2 style/3 style/4 > 0][
            emit-styled out margin-left page-y line 0 "L" regular-font
        ][
            case [
                find line "*" [
                    text: replace/all copy line "*" ""
                    emit-font out bold-font
                    emit-text out margin-left page-y text
                    emit-font out regular-font
                ]
                find line "_" [
                    text: replace/all copy line "_" ""
                    emit-text out margin-left page-y text
                    emit-underline out margin-left page-y text 0 "L"
                ]
                true [
                    emit-text out margin-left page-y line
                ]
            ]
        ]
    ]

    emit-table-header: func [
        out [string!]
        y [integer!]
        tl [integer!]
        tw [integer!]
        rh [integer!]
        ct [block!]
        cw [block!]
        ca [block!]
        nc [integer!]
        /local ci col-x col-w col-text col-align
    ][
        emit-filled-rect out tl (y - 2) tw rh 0.85
        col-x: tl
        ci: 1
        while [ci <= nc][
            col-text: pick ct ci
            col-w: pick cw ci
            col-align: pick ca ci
            emit-styled out (col-x + 3) (y + 2) col-text (col-w - 6) col-align bold-font
            col-x: col-x + col-w
            ci: ci + 1
        ]
        emit-rect out tl (y - 2) tw rh

        col-x: tl
        ci: 2
        while [ci <= nc][
            col-w: pick cw (ci - 1)
            col-x: col-x + col-w
            emit-rect out col-x (y - 2) 1 rh
            ci: ci + 1
        ]
    ]

    emit-table-row: func [
        out [string!]
        row [block!]
        y [integer!]
        rn [integer!]
        tl [integer!]
        tw [integer!]
        rh [integer!]
        cw [block!]
        ca [block!]
        nc [integer!]
        /local ci col-x col-w col-text col-align
    ][
        if (rn // 2) = 0 [
            emit-filled-rect out tl (y - 2) tw rh 0.95
        ]

        col-x: tl
        ci: 1
        while [ci <= nc][
            col-text: either ci <= length? row [to string! pick row ci][""]
            col-w: pick cw ci
            col-align: pick ca ci
            emit-styled out (col-x + 3) (y + 2) col-text (col-w - 6) col-align regular-font
            col-x: col-x + col-w
            ci: ci + 1
        ]

        emit-rect out tl (y - 2) tw rh

        col-x: tl
        ci: 2
        while [ci <= nc][
            col-w: pick cw (ci - 1)
            col-x: col-x + col-w
            emit-rect out col-x (y - 2) 1 rh
            ci: ci + 1
        ]
    ]

    parse-table-columns: func [
        columns [block!]
        /local col-titles col-widths col-aligns num-cols ci third
    ][
        col-titles: copy []
        col-widths: copy []
        col-aligns: copy []

        either all [
            (length? columns) >= 3
            string? third: pick columns 3
            any [third = "L" third = "R" third = "C"]
        ][
            num-cols: (length? columns) / 3
            ci: 1
            while [ci <= length? columns][
                append col-titles pick columns ci
                append col-widths pick columns (ci + 1)
                append col-aligns pick columns (ci + 2)
                ci: ci + 3
            ]
        ][
            num-cols: (length? columns) / 2
            ci: 1
            while [ci <= length? columns][
                append col-titles pick columns ci
                append col-widths pick columns (ci + 1)
                append col-aligns "L"
                ci: ci + 2
            ]
        ]

        reduce [col-titles col-widths col-aligns num-cols]
    ]

    set 'generate-report func [
        "Generate a multi-page A4 report with mixed text and table content"
        header [block! none!]   "Optional header lines (shown at top of each page)"
        content [block!]        "Mixed content: strings for text, 'table blocks for tables"
        footer [block! none!]   "Optional footer lines (use %PAGE% and %PAGES% for page numbers)"
        output [file!]          "Output PDF file path"
        /no-print               "Generate PDF but do not send to printer"
        /local usable-top usable-bottom page-bottom
            pages page-num page-content page-y
            item out-ps total-pages ps-file pdf-file p
            table-columns table-rows col-info col-titles col-widths col-aligns
            num-cols table-left table-width row-h
            row-num table-total-h ci
    ][
        usable-top: page-height - margin-top
        usable-bottom: margin-bottom
        page-bottom: usable-bottom + either ftr: footer [(length? ftr) * line-height][0]

        pages: copy []
        page-num: 1
        page-content: copy ""

        emit-font page-content regular-font

        page-y: usable-top
        page-y: emit-header page-content header page-y
        page-y: page-y - line-height

        new-page: does [
            append pages page-content
            page-num: page-num + 1
            page-content: copy ""
            emit-font page-content regular-font
            page-y: usable-top
            page-y: emit-header page-content header page-y
            page-y: page-y - line-height
        ]

        foreach item content [
            either string? item [
                if item = "^L" [new-page continue]
                if (page-y - line-height) < page-bottom [new-page]
                emit-data-line page-content item page-y
                page-y: page-y - line-height
            ][
                if all [
                    block? item
                    not empty? item
                    item/1 = 'table
                ][
                    table-columns: item/2
                    table-rows: copy []
                    ci: 3
                    while [ci <= length? item][
                        append/only table-rows pick item ci
                        ci: ci + 1
                    ]

                    col-info: parse-table-columns table-columns
                    col-titles: col-info/1
                    col-widths: col-info/2
                    col-aligns: col-info/3
                    num-cols: col-info/4

                    table-left: margin-left
                    table-width: 0
                    foreach w col-widths [table-width: table-width + w]

                    row-h: line-height + 4

                    table-total-h: row-h + ((length? table-rows) * row-h)
                    page-y: page-y - row-h
                    if (page-y - table-total-h - line-height) < page-bottom [new-page]

                    emit-table-header page-content page-y table-left table-width row-h col-titles col-widths col-aligns num-cols
                    page-y: page-y - row-h

                    row-num: 0
                    forall table-rows [
                        either all [
                            block? first table-rows
                            not empty? first table-rows
                            string? first first table-rows
                            (first first table-rows) = "^L"
                        ][
                            append pages page-content
                            page-num: page-num + 1
                            page-content: copy ""
                            emit-font page-content regular-font
                            page-y: usable-top
                            page-y: emit-header page-content header page-y
                            page-y: page-y - line-height

                            emit-table-header page-content page-y table-left table-width row-h col-titles col-widths col-aligns num-cols
                            page-y: page-y - row-h
                        ][
                            if (page-y - row-h) < page-bottom [
                                append pages page-content
                                page-num: page-num + 1
                                page-content: copy ""
                                emit-font page-content regular-font
                                page-y: usable-top
                                page-y: emit-header page-content header page-y
                                page-y: page-y - line-height

                                emit-table-header page-content page-y table-left table-width row-h col-titles col-widths col-aligns num-cols
                                page-y: page-y - row-h
                            ]

                            row-num: row-num + 1
                            emit-table-row page-content first table-rows page-y row-num table-left table-width row-h col-widths col-aligns num-cols
                            page-y: page-y - row-h
                        ]
                    ]
                ]
            ]
        ]

        append pages page-content
        total-pages: length? pages

        out-ps: copy "%!PS-Adobe-3.0"
        append out-ps lf
        append out-ps rejoin ["%%Pages: " total-pages]
        append out-ps lf
        append out-ps "%%EndComments"
        append out-ps lf

        p: 0
        while [p < total-pages][
            p: p + 1
            append out-ps rejoin ["%%Page: " p " " p]
            append out-ps lf
            append out-ps "0 setgray 1 setlinewidth"
            append out-ps lf
            append out-ps pick pages p
            emit-footer out-ps footer p total-pages
            append out-ps "showpage"
            append out-ps lf
        ]

        append out-ps "%%EOF"
        append out-ps lf

        ps-file: replace/all copy output ".pdf" ".ps"
        pdf-file: output

        write ps-file out-ps

        call/wait rejoin ["ps2pdf " ps-file " " pdf-file]
        delete ps-file
        unless no-print [
            call/wait rejoin ["lpr " pdf-file]
        ]
    ]
];context