Red [
    Title: "Report Generator Module v4"
    Purpose: "Generate multi-page A4 PostScript reports with flat content DSL"
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
    row-padding: 4
    bold-font: "/Times-Bold"
    italic-font: "/Times-Italic"
    bold-italic-font: "/Times-BoldItalic"
    regular-font: "/Times-Roman"
    mono-font: "/Courier"
    mono-bold-font: "/Courier-Bold"
    mono-italic-font: "/Courier-Oblique"
    mono-bold-italic-font: "/Courier-BoldOblique"

    ps-escape: func [s [string!]][
        replace/all s "\\" "\\\\"
        replace/all s "("  "\\("
        replace/all s ")"  "\\)"
        s
    ]

    emit-font: func [out [string!] font-name [string!]][
        append out rejoin [font-name " findfont " font-size " scalefont setfont"]
        append out lf
    ]

    emit-text: func [
        out [string!] x [integer!] y [integer!] text [string!]
        /center col-w-c [integer!] /right col-w-r [integer!]
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

    emit-text-join: func [out [string!] y [integer!] text [string!]][
        append out rejoin [
            "_jx _jy moveto"
            " (" ps-escape text ") show"
            " currentpoint /_jy exch def /_jx exch def" lf
        ]
    ]

    emit-text-start: func [out [string!] x [integer!] y [integer!]][
        append out rejoin ["/_jx " x " def /_jy " y " def" lf]
    ]

    emit-underline: func [
        out [string!] x [integer!] y [integer!] text [string!]
        col-w [integer!] align [string!]
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

    emit-rect: func [out [string!] x [integer!] y [integer!] w [integer!] h [integer!]][
        append out rejoin ["gsave 0.5 setlinewidth newpath " x " " y " moveto " w " 0 rlineto 0 " h " rlineto " (0 - w) " 0 rlineto closepath stroke grestore"]
        append out lf
    ]

    emit-vline: func [out [string!] x [integer!] y [integer!] h [integer!]][
        append out rejoin ["gsave 0.5 setlinewidth newpath " x " " y " moveto 0 " h " rlineto stroke grestore"]
        append out lf
    ]

    emit-filled-rect: func [out [string!] x [integer!] y [integer!] w [integer!] h [integer!] gray [float!]][
        append out "gsave"
        append out lf
        append out rejoin [gray " setgray newpath " x " " y " moveto " w " 0 rlineto 0 " h " rlineto " (0 - w) " 0 rlineto closepath fill"]
        append out lf
        append out "grestore"
        append out lf
    ]

    ;--- Style helpers ---

    style-has: func [styles [block!] target [word!]][
        not none? find styles target
    ]

    style-heading: func [styles [block!] /local s][
        foreach s styles [
            if find [h1 h2 h3] s [return case [s = 'h1 [1] s = 'h2 [2] true [3]]]
        ]
        0
    ]

    heading-size: func [hd [integer!]][
        case [hd = 1 [24] hd = 2 [18] hd = 3 [14] true [font-size]]
    ]

    max-style-size: func [
        "Largest font size from style blocks in a line/row"
        line-block [block!]
        /local v s best hd sz
    ][
        best: font-size
        foreach v line-block [
            if block? v [
                foreach s v [
                    hd: case [s = 'h1 [1] s = 'h2 [2] s = 'h3 [3] true [0]]
                    if hd > 0 [
                        sz: heading-size hd
                        if sz > best [best: sz]
                    ]
                ]
            ]
        ]
        best
    ]

    heading-gap: func [
        "Extra spacing above a line with heading-sized segments"
        line-block [block!]
        /local sz
    ][
        sz: max-style-size line-block
        either sz > font-size [sz - font-size + 2][0]
    ]

    row-height: func [
        "Height for a table row, adapting to largest segment font"
        row [block!]
        /local sz
    ][
        sz: max-style-size row
        either sz > font-size [sz + row-padding + 1][line-height + row-padding]
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
                true [bold-font]
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

    select-style-font: func [out [string!] styles [block!] /local hd sz][
        hd: style-heading styles
        sz: heading-size hd
        append out rejoin [font-for-styles styles " findfont " sz " scalefont setfont"]
        append out lf
    ]

    emit-styled-text: func [
        out [string!] x [integer!] y [integer!] text [string!]
        col-w [integer!] align [string!] styles [block!]
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
                append out rejoin ["/_ulx _jx def" lf]
                emit-text-join out y text
                if style-has styles 'u [
                    append out rejoin [
                        "gsave newpath"
                        " _ulx " (y - 2) " moveto"
                        " (" ps-escape text ") stringwidth pop 0 rlineto stroke grestore" lf
                    ]
                ]
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

    ;--- Number formatting ---

    format-number-value: func [val [number!] fmt [none! word! float!]][
        case [
            none? fmt [to string! val]
            fmt = 'money [
                either val < 0 [
                    rejoin ["-$" format-decimal (0 - val) 2]
                ][
                    rejoin ["$" format-decimal val 2]
                ]
            ]
            float? fmt [format-decimal val to integer! ((fmt - to integer! fmt) * 10)]
            true [to string! val]
        ]
    ]

    format-decimal: func [
        val [number!] decimals [integer!]
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
            if all [i > 1 ((n - i + 1) // 3) = 0][append result "'"]
            append result ch
            i: i + 1
        ]
        either decimals > 0 [
            rejoin [either neg? ["-"][""] result "." dec-part]
        ][
            rejoin [either neg? ["-"][""] result]
        ]
    ]

    ;--- Parsing ---

    parse-columns: func [
        "Parse column header row: data followed by style block"
        cols [block!]
        /local col-titles col-widths col-aligns col-formats col-bolds num-cols
            cur-text cur-align cur-bold cur-format cur-width v s
    ][
        col-titles: copy []
        col-widths: copy []
        col-aligns: copy []
        col-formats: copy []
        col-bolds: copy []
        num-cols: 0
        cur-text: none

        foreach v cols [
            either block? v [
                if cur-text [
                    append col-titles cur-text
                    cur-align: "L"
                    cur-bold: false
                    cur-format: none
                    cur-width: 80
                    foreach s v [
                        case [
                            s = '<     [cur-align: "L"]
                            s = '^     [cur-align: "C"]
                            s = '>     [cur-align: "R"]
                            s = 'b     [cur-bold: true]
                            s = 'money [cur-format: 'money]
                            integer? s [cur-width: s]
                            float? s   [cur-format: s]
                        ]
                    ]
                    append col-widths cur-width
                    append col-aligns cur-align
                    append col-formats cur-format
                    append col-bolds cur-bold
                    num-cols: num-cols + 1
                    cur-text: none
                ]
            ][
                case [
                    string? v  [cur-text: v]
                    word? v    [cur-text: form v]
                    integer? v [cur-text: form v]
                    float? v   [cur-text: form v]
                ]
            ]
        ]
        reduce [col-titles col-widths col-aligns col-formats col-bolds num-cols]
    ]

    eval-val: func [v /local val][
        case [
            word? v     [val: attempt [get v] either val [val][v]]
            get-word? v [val: attempt [get v] either val [val][v]]
            true        [v]
        ]
    ]

    parse-row-segments: func [
        "Parse a row: data elements followed by style blocks. Returns [styles text ...] pairs"
        row [block!]
        /local result cur-text cur-styles v s
    ][
        result: copy []
        cur-text: none
        cur-styles: copy []

        foreach v row [
            either block? v [
                cur-styles: copy []
                foreach s v [
                    case [
                        word? s     [append cur-styles s]
                        lit-word? s [append cur-styles to word! s]
                    ]
                ]
                if cur-text [
                    append/only result cur-styles
                    append result cur-text
                    cur-text: none
                    cur-styles: copy []
                ]
            ][
                if cur-text [
                    append/only result copy []
                    append result cur-text
                ]
                cur-text: case [
                    string? v  [v]
                    number? v  [v]
                    word? v    [eval-val v]
                    true       [form v]
                ]
            ]
        ]
        if cur-text [
            append/only result copy cur-styles
            append result cur-text
        ]
        result
    ]

    parse-line: func [
        "Parse a content line block. Returns [line-styles segments] where line-styles is the leading style block (or []) and segments is the parsed data+style pairs."
        line-block [block!]
        /local line-styles rest
    ][
        either all [
            not empty? line-block
            block? line-block/1
        ][
            line-styles: line-block/1
            rest: copy next line-block
        ][
            line-styles: copy []
            rest: line-block
        ]
        reduce [line-styles parse-row-segments rest]
    ]

    ;--- Table helpers ---

    table-modifiers: func [
        "Scan table block for modifiers. Returns [boxed? alt? col-index]"
        item [block!]
        /local idx v boxed? alt? col-idx found
    ][
        idx: 2
        boxed?: false
        alt?: false
        col-idx: idx
        found: false
        while [all [idx <= length? item not found]][
            v: eval-val pick item idx
            case [
                v = 'box  [boxed?: true  idx: idx + 1]
                v = 'alt  [alt?: true    idx: idx + 1]
                string? v [col-idx: idx  found: true]
                true      [col-idx: idx  found: true]
            ]
        ]
        reduce [boxed? alt? col-idx]
    ]

    replace-tokens: func [
        text [string!] page-num [integer!] total-pages [integer!]
        date-str [string!] time-str [string!] datetime-str [string!]
    ][
        text: copy text
        text: replace/all text "%PAGE%" to string! page-num
        text: replace/all text "%PAGES%" to string! total-pages
        text: replace/all text "%DATE%" date-str
        text: replace/all text "%TIME%" time-str
        text: replace/all text "%DATETIME%" datetime-str
        text
    ]

    ;--- Emit helpers ---

    col-w: does [page-width - margin-left - margin-right]

    emit-content-line: func [
        out [string!] line-block [block!] page-y [integer!]
        /local parsed line-styles segments nsegs i styles text
    ][
        parsed: parse-line line-block
        line-styles: parsed/1
        segments: parsed/2
        nsegs: (length? segments) / 2
        if nsegs > 0 [
            either nsegs = 1 [
                styles: segments/1
                if all [empty? styles not empty? line-styles][styles: line-styles]
                emit-styled-text out margin-left page-y segments/2 col-w "L" styles
            ][
                emit-text-start out margin-left page-y
                i: 1
                while [i <= length? segments][
                    styles: pick segments i
                    if all [empty? styles not empty? line-styles][styles: line-styles]
                    text: pick segments (i + 1)
                    emit-styled-text/join out margin-left page-y text col-w "L" styles
                    i: i + 2
                ]
            ]
        ]
    ]

    emit-header-line: func [
        "Emit a header/footer line with positional alignment (1st=L, 2nd=C, 3rd=R)"
        out [string!] y [integer!] line-block [block!]
        page-num [integer!] total-pages [integer!]
        date-str [string!] time-str [string!] datetime-str [string!]
        /default-style def-styles [block!]
        /local parsed line-styles segments nsegs idx styles text align
    ][
        parsed: parse-line line-block
        line-styles: parsed/1
        segments: parsed/2
        nsegs: (length? segments) / 2
        if nsegs > 0 [
            repeat idx nsegs [
                styles: pick segments ((idx - 1) * 2 + 1)
                text: pick segments (idx * 2)
                align: case [idx = 1 ["L"] idx = 2 ["C"] idx = 3 ["R"] true ["L"]]
                text: replace-tokens text page-num total-pages date-str time-str datetime-str
                either all [empty? styles not empty? line-styles][
                    emit-styled-text out margin-left y text col-w align line-styles
                ][
                    either all [empty? styles default-style][
                        emit-styled-text out margin-left y text col-w align def-styles
                    ][
                        emit-styled-text out margin-left y text col-w align styles
                    ]
                ]
            ]
        ]
    ]

    ;--- Header / Footer emit ---

    emit-header: func [
        out [string!] hdr [block! none!] page-y [integer!]
        date-str [string!] time-str [string!] datetime-str [string!]
        /local line
    ][
        if none? hdr [return page-y]
        foreach line hdr [
            either block? line [
                emit-header-line/default-style out page-y line 0 0 date-str time-str datetime-str ['b]
            ][
                emit-styled-text out margin-left page-y (replace-tokens line 0 0 date-str time-str datetime-str) col-w "L" ['b]
            ]
            page-y: page-y - line-height
        ]
        emit-font out regular-font
        page-y
    ]

    emit-footer: func [
        out [string!] ftr [block! none!] page-num [integer!] total-pages [integer!]
        date-str [string!] time-str [string!] datetime-str [string!]
        /local ftr-y line
    ][
        if none? ftr [exit]
        ftr-y: margin-bottom + ((length? ftr) * line-height)
        foreach line ftr [
            either block? line [
                emit-header-line out ftr-y line page-num total-pages date-str time-str datetime-str
            ][
                emit-styled-text out margin-left ftr-y (replace-tokens line page-num total-pages date-str time-str datetime-str) col-w "L" []
            ]
            ftr-y: ftr-y - line-height
        ]
    ]

    ;--- Table emit ---

    header-row-h: does [line-height + row-padding]

    emit-table-row: func [
        "Emit a table row (header or data). box-top = y - rh."
        out [string!] y [integer!] rh [integer!]
        tl [integer!] tw [integer!] boxed? [logic!]
        is-header [logic!] row-num [integer!]
        col-info [block!] row [block!]
        /local box-top text-y
            ct cw ca cf cb nc ci col-x col-w col-text col-align col-format
            raw-val text styles col-styles final-styles s
    ][
        box-top: y - rh
        text-y: box-top + row-padding

        ct: col-info/1
        cw: col-info/2
        ca: col-info/3
        cf: col-info/4
        cb: col-info/5
        nc: col-info/6

        either is-header [
            emit-filled-rect out tl box-top tw rh 0.85
        ][
            if (row-num // 2) = 0 [
                emit-filled-rect out tl box-top tw rh 0.95
            ]
        ]

        col-styles: parse-row-segments row

        col-x: tl
        ci: 1
        while [ci <= nc][
            col-w: pick cw ci
            col-align: pick ca ci
            col-format: pick cf ci

            either is-header [
                col-text: pick ct ci
                emit-styled-text out (col-x + 3) text-y col-text (col-w - 6) col-align ['b]
            ][
                styles: either ci <= ((length? col-styles) / 2) [
                    pick col-styles ((ci - 1) * 2 + 1)
                ][copy []]
                raw-val: either ci <= ((length? col-styles) / 2) [
                    pick col-styles (ci * 2)
                ][none]

                final-styles: copy []
                if pick cb ci [append final-styles 'b]
                foreach s styles [unless find final-styles s [append final-styles s]]

                text: case [
                    none? raw-val   [""]
                    string? raw-val [raw-val]
                    number? raw-val [either col-format [format-number-value raw-val col-format][form raw-val]]
                    true            [form raw-val]
                ]
                emit-styled-text out (col-x + 3) text-y text (col-w - 6) col-align final-styles
            ]
            col-x: col-x + col-w
            ci: ci + 1
        ]

        if boxed? [emit-rect out tl box-top tw rh]

        col-x: tl
        ci: 2
        while [ci <= nc][
            col-w: pick cw (ci - 1)
            col-x: col-x + col-w
            emit-vline out col-x box-top rh
            ci: ci + 1
        ]
    ]

    ;--- Section parser ---

    parse-sections: func [
        "Parse flat content into [header content footer]. Sections are delimited by 'HEADER 'CONTENT 'FOOTER lit-words."
        block [block!]
        /local header content footer current item
    ][
        header: none
        content: copy []
        footer: none
        current: 'content

        foreach item block [
            case [
                item = 'HEADER  [current: 'header  header: copy []]
                item = 'CONTENT [current: 'content]
                item = 'FOOTER  [current: 'footer  footer: copy []]
                true [
                    case [
                        current = 'header  [append/only header item]
                        current = 'content [append/only content item]
                        current = 'footer  [append/only footer item]
                    ]
                ]
            ]
        ]
        reduce [header content footer]
    ]

    ;--- Main entry point ---

    set 'generate-report func [
        "Generate a multi-page A4 report"
        content [block!]        "Content block with 'HEADER 'CONTENT 'FOOTER sections"
        output [file!]          "Output PDF file path"
        /browser                "Generate PDF and open in default PDF viewer"
        /local usable-top usable-bottom page-bottom
            pages page-num page-content page-y
            item out-ps total-pages ps-file pdf-file p page-ps
            col-info num-cols table-left table-width row-h
            row-num table-total-h ci table-columns table-rows
            date-str time-str datetime-str new-page
            table-col-idx rows-start row-item boxed? alt?
            mods result sections hdr ctn ftr
    ][
        sections: parse-sections content
        hdr: sections/1
        ctn: sections/2
        ftr: sections/3

        usable-top: page-height - margin-top
        usable-bottom: margin-bottom
        page-bottom: usable-bottom + either ftr [(length? ftr) * line-height][0]

        date-str: form now/date
        time-str: copy/part form now/time ((length? form now/time) - 3)
        datetime-str: rejoin [date-str " " time-str]

        pages: copy []
        page-num: 1
        page-content: copy ""

        emit-font page-content regular-font

        page-y: usable-top
        page-y: emit-header page-content hdr page-y date-str time-str datetime-str
        page-y: page-y - line-height

        new-page: does [
            append pages page-content
            page-num: page-num + 1
            page-content: copy ""
            emit-font page-content regular-font
            page-y: usable-top
            page-y: emit-header page-content hdr page-y date-str time-str datetime-str
            page-y: page-y - line-height
        ]

        foreach item ctn [
            either block? item [
                either all [not empty? item item/1 = 'table][
                    mods: table-modifiers item
                    boxed?: mods/1
                    alt?: mods/2
                    table-col-idx: mods/3
                    table-columns: pick item table-col-idx
                    rows-start: table-col-idx + 1

                    table-rows: copy []
                    ci: rows-start
                    while [ci <= length? item][
                        append/only table-rows eval-val pick item ci
                        ci: ci + 1
                    ]

                    col-info: parse-columns table-columns
                    num-cols: col-info/6

                    table-left: margin-left
                    table-width: 0
                    foreach w col-info/2 [table-width: table-width + w]

                    row-h: header-row-h

                    table-total-h: row-h
                    forall table-rows [
                        row-item: first table-rows
                        either all [
                            block? row-item
                            not empty? row-item
                            string? first row-item
                            (first row-item) = "^L"
                        ][
                            table-total-h: table-total-h + row-h
                        ][
                            table-total-h: table-total-h + row-height row-item
                        ]
                    ]

                    page-y: page-y - row-h
                    if (page-y - table-total-h - line-height) < page-bottom [new-page]

                    emit-table-row page-content page-y row-h table-left table-width boxed? true 0 col-info []
                    page-y: page-y - row-h

                    row-num: 0
                    forall table-rows [
                        row-item: first table-rows
                        row-h: row-height row-item
                        either all [
                            block? row-item
                            not empty? row-item
                            string? first row-item
                            (first row-item) = "^L"
                        ][
                            new-page
                            row-h: header-row-h
                            emit-table-row page-content page-y row-h table-left table-width boxed? true 0 col-info []
                            page-y: page-y - row-h
                        ][
                            if (page-y - row-h) < page-bottom [
                                new-page
                                row-h: header-row-h
                                emit-table-row page-content page-y row-h table-left table-width boxed? true 0 col-info []
                                page-y: page-y - row-h
                                row-h: row-height row-item
                            ]

                            row-num: row-num + 1
                            emit-table-row page-content page-y row-h table-left table-width boxed? false row-num col-info row-item
                            page-y: page-y - row-h
                        ]
                    ]
                    page-y: page-y - line-height
                ][
                    page-y: page-y - heading-gap item
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
            emit-footer out-ps ftr p total-pages date-str time-str datetime-str
            append out-ps "showpage"
            append out-ps lf
        ]

        append out-ps "%%EOF"
        append out-ps lf

        ps-file: to file! rejoin [copy/part to string! output ((length? to string! output) - 4) ".ps"]
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

        if browser [browse pdf-file]
        delete ps-file
    ] ; generate-report
];context
