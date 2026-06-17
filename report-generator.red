Red [
    Title: "Report Generator Module v2"
    Purpose: "Generate multi-page A4 PostScript reports with lit-word style DSL"
    Exports: [generate-report]
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
    mono-font: "/Courier"
    mono-bold-font: "/Courier-Bold"
    mono-italic-font: "/Courier-Oblique"
    mono-bold-italic-font: "/Courier-BoldOblique"

    ps-escape: func [
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
            append out rejoin [" stringwidth pop" lf col-w-c " exch sub 2 div " x " add " y " moveto (" ps-escape text ")"]
        ]
        if right [
            append out rejoin [" stringwidth pop" lf col-w-r " exch sub " x " add " y " moveto (" ps-escape text ")"]
        ]
        append out rejoin [" show" lf "grestore" lf]
    ]

    emit-text-join: func [
        "Emit left-aligned text at _jx/_jy, update _jx/_jy to end position"
        out [string!]
        y [integer!]
        text [string!]
    ][
        append out rejoin [
            "_jx _jy moveto"
            " (" ps-escape text ") show"
            " currentpoint /_jy exch def /_jx exch def" lf
        ]
    ]

    emit-text-start: func [
        "Initialize _jx/_jy for a joined line"
        out [string!]
        x [integer!]
        y [integer!]
    ][
        append out rejoin ["/_jx " x " def /_jy " y " def" lf]
    ]

    emit-underline: func [
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

    style-has: func [styles [block!] target [word! refinement!]][
        not none? find styles target
    ]

    style-heading: func [styles [block!] /local s][
        foreach s styles [
            if find [h1 h2 h3] s [return case [s = 'h1 [1] s = 'h2 [2] true [3]]]
        ]
        0
    ]

    heading-size: func [hd [integer!]][
        case [
            hd = 1 [24]
            hd = 2 [18]
            hd = 3 [14]
            true [font-size]
        ]
    ]

    font-for-styles: func [styles [block!] /local b? i? m? hd][
        b?: style-has styles 'b
        i?: style-has styles 'i
        m?: style-has styles 'm
        hd: style-heading styles

        either hd > 0 [
            case [
                m? [either b? [mono-bold-font][mono-font]]
                b? [bold-font]
                i? [italic-font]
                true [regular-font]
            ]
        ][
            case [
                all [m? b? i?] [mono-bold-italic-font]
                all [m? i?]     [mono-italic-font]
                all [m? b?]     [mono-bold-font]
                m?              [mono-font]
                all [b? i?]     [bold-italic-font]
                b?              [bold-font]
                i?              [italic-font]
                true            [regular-font]
            ]
        ]
    ]

    select-style-font: func [
        out [string!]
        styles [block!]
        /local hd sz
    ][
        hd: style-heading styles
        sz: heading-size hd
        either hd > 0 [
            append out rejoin [font-for-styles styles " findfont " sz " scalefont setfont"]
        ][
            append out rejoin [font-for-styles styles " findfont " sz " scalefont setfont"]
        ]
        append out lf
    ]

    emit-styled-text: func [
        out [string!]
        x [integer!]
        y [integer!]
        text [string!]
        col-w [integer!]
        align [string!]
        styles [block!]
        /join "Use PS chaining for left-aligned segments"
        /local any-style?
    ][
        if (length? text) = 0 [exit]
        any-style?: any [
            style-has styles 'b
            style-has styles 'i
            style-has styles 'u
            style-has styles 'm
            (style-heading styles) > 0
        ]
        either join [
            either any-style? [
                select-style-font out styles
                emit-text-join out y text
            ][
                emit-font out regular-font
                emit-text-join out y text
            ]
        ][
            either any-style? [
                select-style-font out styles
                case [
                    align = "C" [emit-text/center out x y text col-w]
                    align = "R" [emit-text/right out x y text col-w]
                    true [emit-text out x y text]
                ]
                if style-has styles 'u [emit-underline out x y text col-w align]
                emit-font out regular-font
            ][
                emit-font out regular-font
                case [
                    align = "C" [emit-text/center out x y text col-w]
                    align = "R" [emit-text/right out x y text col-w]
                    true [emit-text out x y text]
                ]
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

    emit-vline: func [
        "Draw a thin vertical line"
        out [string!]
        x [integer!]
        y [integer!]
        h [integer!]
    ][
        append out rejoin ["gsave 0.5 setlinewidth newpath " x " " y " moveto 0 " h " rlineto stroke grestore"]
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

    format-number-value: func [
        val [number!]
        fmt [none! word! float!]
    ][
        case [
            none? fmt [to string! val]
            fmt = 'money [
                either val < 0 [
                    rejoin ["-$" format-decimal (0 - val) 2]
                ][
                    rejoin ["$" format-decimal val 2]
                ]
            ]
            float? fmt [
                format-decimal val to integer! ((fmt - to integer! fmt) * 10)
            ]
            true [to string! val]
        ]
    ]

    format-decimal: func [
        val [number!]
        decimals [integer!]
        /local s ipart dpos dpad dec-part i n result ch neg?
    ][
        s: form val
        neg?: false
        if all [(length? s) > 0 s/1 = #"-"][
            neg?: true
            s: copy next s
        ]

        dpos: find s #"."
        either dpos [
            ipart: copy/part s dpos
            dec-part: copy next dpos
        ][
            ipart: copy s
            dec-part: copy ""
        ]

        if decimals > 0 [
            dpad: copy ""
            loop (decimals - length? dec-part) [append dpad "0"]
            dec-part: rejoin [dec-part dpad]
            if (length? dec-part) > decimals [dec-part: copy/part dec-part decimals]
        ]

        result: copy ""
        n: length? ipart
        i: 1
        foreach ch ipart [
            if all [i > 1 ((n - i + 1) // 3) = 0][
                append result "'"
            ]
            append result ch
            i: i + 1
        ]

        either decimals > 0 [
            rejoin [either neg? ["-"][""] result "." dec-part]
        ][
            rejoin [either neg? ["-"][""] result]
        ]
    ]

    parse-columns-v2: func [
        cols [block!]
        /local col-titles col-widths col-aligns col-formats col-bolds num-cols
            cur-align cur-bold cur-format v cur-width
    ][
        col-titles: copy []
        col-widths: copy []
        col-aligns: copy []
        col-formats: copy []
        col-bolds: copy []
        num-cols: 0

        cur-align: "L"
        cur-bold: false
        cur-format: none
        cur-width: none

        foreach v cols [
            case [
                v = '<  [cur-align: "L"]
                v = '^  [cur-align: "C"]
                v = '>  [cur-align: "R"]
                v = 'b  [cur-bold: true]
                v = 'money [cur-format: 'money]
                integer? v [cur-width: v]
                float? v [cur-format: v]
                string? v [
                    append col-titles v
                    append col-widths any [cur-width 80]
                    append col-aligns cur-align
                    append col-formats cur-format
                    append col-bolds cur-bold
                    num-cols: num-cols + 1
                    cur-align: "L"
                    cur-bold: false
                    cur-format: none
                    cur-width: none
                ]
            ]
        ]

        reduce [col-titles col-widths col-aligns col-formats col-bolds num-cols]
    ]

    end-tag-target: func [v][
        case [
            v = /b  ['b]
            v = /i  ['i]
            v = /u  ['u]
            v = /m  ['m]
            v = /h1 ['h1]
            v = /h2 ['h2]
            v = /h3 ['h3]
            true [none]
        ]
    ]

    remove-style: func [styles [block!] target [word! none!] /local pos][
        if none? target [exit]
        pos: find styles target
        if pos [remove pos]
    ]

    process-line-values: func [
        values [block!]
        /local result styles v target
    ][
        result: copy []
        styles: copy []

        foreach v values [
            case [
                refinement? v [
                    target: end-tag-target v
                    remove-style styles target
                ]
                v = 'b  [append styles 'b]
                v = 'i  [append styles 'i]
                v = 'u  [append styles 'u]
                v = 'm  [append styles 'm]
                v = 'h1 [append styles 'h1]
                v = 'h2 [append styles 'h2]
                v = 'h3 [append styles 'h3]
                string? v [
                    append/only result copy styles
                    append result v
                ]
            ]
        ]
        result
    ]

    emit-processed-line: func [
        out [string!]
        x [integer!]
        y [integer!]
        processed [block!]
        col-w [integer!]
        align [string!]
        /local i styles text
    ][
        either align = "L" [
            emit-text-start out x y
            i: 1
            while [i <= length? processed][
                styles: pick processed i
                text: pick processed (i + 1)
                emit-styled-text/join out x y text col-w "L" styles
                i: i + 2
            ]
        ][
            i: 1
            while [i <= length? processed][
                styles: pick processed i
                text: pick processed (i + 1)
                emit-styled-text out x y text col-w align styles
                i: i + 2
            ]
        ]
    ]

    replace-tokens: func [
        text [string!]
        page-num [integer!]
        total-pages [integer!]
        date-str [string!]
        time-str [string!]
        datetime-str [string!]
    ][
        text: copy text
        text: replace/all text "%PAGE%" to string! page-num
        text: replace/all text "%PAGES%" to string! total-pages
        text: replace/all text "%DATE%" date-str
        text: replace/all text "%TIME%" time-str
        text: replace/all text "%DATETIME%" datetime-str
        text
    ]

    emit-header-v2: func [
        out [string!]
        hdr [block! none!]
        page-y [integer!]
        date-str [string!]
        time-str [string!]
        datetime-str [string!]
        /local col-w line processed segments nsegs align styles text idx i
    ][
        if none? hdr [return page-y]

        col-w: page-width - margin-left - margin-right

        foreach line hdr [
            either block? line [
                processed: process-line-values line
                nsegs: (length? processed) / 2
                if nsegs > 0 [
                    segments: copy []
                    i: 1
                    while [i <= length? processed][
                        append/only segments reduce [pick processed i pick processed (i + 1)]
                        i: i + 2
                    ]
                    repeat idx length? segments [
                        styles: segments/:idx/1
                        text: segments/:idx/2
                        align: case [
                            idx = 1 ["L"]
                            idx = 2 ["C"]
                            idx = 3 ["R"]
                            true ["L"]
                        ]
                        text: replace-tokens text 0 0 date-str time-str datetime-str
                        either any [
                            style-has styles 'b
                            style-has styles 'i
                            style-has styles 'u
                            style-has styles 'm
                            (style-heading styles) > 0
                        ][
                            emit-styled-text out margin-left page-y text col-w align styles
                        ][
                            emit-styled-text out margin-left page-y text col-w align ['b]
                        ]
                    ]
                ]
            ][
                emit-styled-text out margin-left page-y (replace-tokens line 0 0 date-str time-str datetime-str) col-w "L" ['b]
            ]
            page-y: page-y - line-height
        ]
        emit-font out regular-font
        page-y
    ]

    emit-footer-v2: func [
        out [string!]
        ftr [block! none!]
        page-num [integer!]
        total-pages [integer!]
        date-str [string!]
        time-str [string!]
        datetime-str [string!]
        /local ftr-y col-w line processed segments nsegs align styles text idx i
    ][
        if none? ftr [exit]

        col-w: page-width - margin-left - margin-right
        ftr-y: margin-bottom + ((length? ftr) * line-height)

        foreach line ftr [
            either block? line [
                processed: process-line-values line
                nsegs: (length? processed) / 2
                if nsegs > 0 [
                    segments: copy []
                    i: 1
                    while [i <= length? processed][
                        append/only segments reduce [pick processed i pick processed (i + 1)]
                        i: i + 2
                    ]
                    repeat idx length? segments [
                        styles: segments/:idx/1
                        text: segments/:idx/2
                        align: case [
                            idx = 1 ["L"]
                            idx = 2 ["C"]
                            idx = 3 ["R"]
                            true ["L"]
                        ]
                        text: replace-tokens text page-num total-pages date-str time-str datetime-str
                        emit-styled-text out margin-left ftr-y text col-w align styles
                    ]
                ]
            ][
                text: replace-tokens line page-num total-pages date-str time-str datetime-str
                emit-styled-text out margin-left ftr-y text col-w "L" []
            ]
            ftr-y: ftr-y - line-height
        ]
    ]

    emit-content-line: func [
        out [string!]
        line-block [block!]
        page-y [integer!]
        /local line-styles rest v processed col-w i seg-styles s
    ][
        line-styles: copy []
        rest: copy []

        foreach v line-block [
            case [
                all [empty? rest v = 'm]  [append line-styles 'm]
                all [empty? rest v = 'h1] [append line-styles 'h1]
                all [empty? rest v = 'h2] [append line-styles 'h2]
                all [empty? rest v = 'h3] [append line-styles 'h3]
                true [append rest v]
            ]
        ]

        processed: process-line-values rest
        col-w: page-width - margin-left - margin-right

        unless empty? line-styles [
            i: 1
            while [i <= length? processed][
                seg-styles: pick processed i
                foreach s line-styles [
                    unless find seg-styles s [append seg-styles s]
                ]
                i: i + 2
            ]
        ]

        emit-processed-line out margin-left page-y processed col-w "L"
    ]

    emit-table-header-v2: func [
        out [string!]
        y [integer!]
        tl [integer!]
        tw [integer!]
        rh [integer!]
        col-info [block!]
        boxed? [logic!]
        /local ct cw ca cf cb nc ci col-x col-w col-text col-align
    ][
        ct: col-info/1
        cw: col-info/2
        ca: col-info/3
        cf: col-info/4
        cb: col-info/5
        nc: col-info/6

        emit-filled-rect out tl (y - 2) tw rh 0.85

        col-x: tl
        ci: 1
        while [ci <= nc][
            col-text: pick ct ci
            col-w: pick cw ci
            col-align: pick ca ci

            emit-styled-text out (col-x + 3) (y + 2) col-text (col-w - 6) col-align ['b]
            col-x: col-x + col-w
            ci: ci + 1
        ]

        if boxed? [emit-rect out tl (y - 2) tw rh]

        col-x: tl
        ci: 2
        while [ci <= nc][
            col-w: pick cw (ci - 1)
            col-x: col-x + col-w
            emit-vline out col-x (y - 2) rh
            ci: ci + 1
        ]
    ]

    emit-table-row-v2: func [
        out [string!]
        row [block!]
        y [integer!]
        rn [integer!]
        tl [integer!]
        tw [integer!]
        rh [integer!]
        col-info [block!]
        boxed? [logic!]
        alt? [logic!]
        /local cw ca cf cb nc ci col-x col-w col-align col-format
            raw-val text styles row-i v final-styles s target
    ][
        cw: col-info/2
        ca: col-info/3
        cf: col-info/4
        cb: col-info/5
        nc: col-info/6

        if all [alt? (rn // 2) = 0] [
            emit-filled-rect out tl (y - 2) tw rh 0.95
        ]

        row-i: 1
        ci: 1
        col-x: tl
        while [ci <= nc][
            col-w: pick cw ci
            col-align: pick ca ci
            col-format: pick cf ci

            styles: copy []
            raw-val: none

            while [row-i <= length? row][
                v: pick row row-i
                case [
                    refinement? v [
                        target: end-tag-target v
                        if target [
                            unless find styles target [append styles target]
                        ]
                        row-i: row-i + 1
                    ]
                    v = 'b  [append styles 'b  row-i: row-i + 1]
                    v = 'i  [append styles 'i  row-i: row-i + 1]
                    v = 'u  [append styles 'u  row-i: row-i + 1]
                    v = 'm  [append styles 'm  row-i: row-i + 1]
                    true [
                        raw-val: eval-val v
                        row-i: row-i + 1
                        break
                    ]
                ]
            ]

            final-styles: copy []
            if pick cb ci [append final-styles 'b]
            foreach s styles [
                either refinement? s [
                    target: end-tag-target s
                    remove-style final-styles target
                ][
                    unless find final-styles s [append final-styles s]
                ]
            ]

            text: case [
                none? raw-val [""]
                string? raw-val [raw-val]
                number? raw-val [
                    either col-format [
                        format-number-value raw-val col-format
                    ][
                        form raw-val
                    ]
                ]
                true [form raw-val]
            ]

            emit-styled-text out (col-x + 3) (y + 2) text (col-w - 6) col-align final-styles
            col-x: col-x + col-w
            ci: ci + 1
        ]

        if boxed? [emit-rect out tl (y - 2) tw rh]

        col-x: tl
        ci: 2
        while [ci <= nc][
            col-w: pick cw (ci - 1)
            col-x: col-x + col-w
            emit-vline out col-x (y - 2) rh
            ci: ci + 1
        ]
    ]

    eval-val: func [v][
        case [
            word? v [get v]
            get-word? v [get v]
            true [v]
        ]
    ]

    is-table-block: func [item [block!]][
        all [
            not empty? item
            (eval-val item/1) = 'table
        ]
    ]

    table-is-boxed: func [item [block!] /local idx v][
        idx: 2
        while [idx <= length? item][
            v: eval-val pick item idx
            if string? v [return false]
            if v = 'box [return true]
            if v = 'alt [idx: idx + 1 continue]
            idx: idx + 1
        ]
        false
    ]

    table-has-alt: func [item [block!] /local idx v][
        idx: 2
        while [idx <= length? item][
            v: eval-val pick item idx
            if string? v [return false]
            if v = 'alt [return true]
            if v = 'box [idx: idx + 1 continue]
            idx: idx + 1
        ]
        false
    ]

    table-col-index: func [item [block!] /local idx v][
        idx: 2
        while [idx <= length? item][
            v: eval-val pick item idx
            if string? v [return idx]
            if any [v = 'box v = 'alt] [idx: idx + 1 continue]
            return idx
        ]
        idx
    ]

    table-rows-start: func [item [block!] /local idx][
        idx: table-col-index item
        idx + 1
    ]

    set 'generate-report func [
        "Generate a multi-page A4 report with lit-word style DSL"
        header [block! none!]   "Optional header lines (shown at top of each page)"
        content [block!]        "Content: blocks for lines, 'table blocks for tables"
        footer [block! none!]   "Optional footer lines"
        output [file!]          "Output PDF file path"
        /browser                "Generate PDF and open in default PDF viewer"
        /local usable-top usable-bottom page-bottom
            pages page-num page-content page-y
            item out-ps total-pages ps-file pdf-file p page-ps
            col-info num-cols table-left table-width row-h
            row-num table-total-h ci table-columns table-rows
            date-str time-str datetime-str new-page
            table-col-idx rows-start row-item boxed? alt?
    ][
        usable-top: page-height - margin-top
        usable-bottom: margin-bottom
        page-bottom: usable-bottom + either ftr: footer [(length? ftr) * line-height][0]

        date-str: form now/date
        time-str: copy/part form now/time 5
        datetime-str: rejoin [date-str " " time-str]

        pages: copy []
        page-num: 1
        page-content: copy ""

        emit-font page-content regular-font

        page-y: usable-top
        page-y: emit-header-v2 page-content header page-y date-str time-str datetime-str
        page-y: page-y - line-height

        new-page: does [
            append pages page-content
            page-num: page-num + 1
            page-content: copy ""
            emit-font page-content regular-font
            page-y: usable-top
            page-y: emit-header-v2 page-content header page-y date-str time-str datetime-str
            page-y: page-y - line-height
        ]

        foreach item content [
            either block? item [
                either is-table-block item [
                    boxed?: table-is-boxed item
                    alt?: table-has-alt item
                    table-col-idx: table-col-index item
                    table-columns: pick item table-col-idx

                    rows-start: table-rows-start item
                    table-rows: copy []
                    ci: rows-start
                    while [ci <= length? item][
                        append/only table-rows eval-val pick item ci
                        ci: ci + 1
                    ]

                    col-info: parse-columns-v2 table-columns
                    num-cols: col-info/6

                    table-left: margin-left
                    table-width: 0
                    foreach w col-info/2 [table-width: table-width + w]

                    row-h: line-height + 4

                    table-total-h: row-h + ((length? table-rows) * row-h)
                    page-y: page-y - row-h
                    if (page-y - table-total-h - line-height) < page-bottom [new-page]

                    emit-table-header-v2 page-content page-y table-left table-width row-h col-info boxed?
                    page-y: page-y - row-h

                    row-num: 0
                    forall table-rows [
                        row-item: first table-rows
                        either all [
                            block? row-item
                            not empty? row-item
                            string? first row-item
                            (first row-item) = "^L"
                        ][
                            new-page
                            emit-table-header-v2 page-content page-y table-left table-width row-h col-info boxed?
                            page-y: page-y - row-h
                        ][
                            if (page-y - row-h) < page-bottom [
                                new-page
                                emit-table-header-v2 page-content page-y table-left table-width row-h col-info boxed?
                                page-y: page-y - row-h
                            ]

                            row-num: row-num + 1
                            emit-table-row-v2 page-content row-item page-y row-num table-left table-width row-h col-info boxed? alt?
                            page-y: page-y - row-h
                        ]
                    ]
                ][
                    if (page-y - line-height) < page-bottom [new-page]
                    emit-content-line page-content item page-y
                    page-y: page-y - line-height
                ]
            ][
                if string? item [
                    if item = "^L" [new-page continue]
                    if (page-y - line-height) < page-bottom [new-page]
                    emit-content-line page-content reduce [item] page-y
                    page-y: page-y - line-height
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
            page-ps: copy pick pages p
            replace/all page-ps "%PAGE%" to string! p
            replace/all page-ps "%PAGES%" to string! total-pages
            replace/all page-ps "%DATE%" date-str
            replace/all page-ps "%TIME%" time-str
            replace/all page-ps "%DATETIME%" datetime-str
            append out-ps rejoin ["%%Page: " p " " p]
            append out-ps lf
            append out-ps "0 setgray 1 setlinewidth"
            append out-ps lf
            append out-ps page-ps
            emit-footer-v2 out-ps footer p total-pages date-str time-str datetime-str
            append out-ps "showpage"
            append out-ps lf
        ]

        append out-ps "%%EOF"
        append out-ps lf

        ps-file: replace/all copy output ".pdf" ".ps"
        pdf-file: output

        write ps-file out-ps
        result: call/wait rejoin ["ps2pdf " ps-file " " pdf-file]
        if result <> 0 [
            print rejoin [
                "Error: ps2pdf failed (exit code " result ")." lf
                "Ghostscript is required to convert PostScript to PDF." lf
                "Install it with:" lf
                "  Linux:   sudo apt install ghostscript" lf
                "  macOS:   brew install ghostscript" lf
                "  Windows: https://ghostscript.com/releases/gsdnld.html"
            ]
            exit
        ]

        if browser [
            browse pdf-file
        ]
        delete ps-file
    ] ; generate-report
];context
