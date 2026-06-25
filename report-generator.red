Red [
    Title: "Report Generator Module v4"
    Purpose: "Generate multi-page A4 PostScript reports with flat content DSL"
    Exports: [generate-report paper-format]
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
    cell-pad: 3
    underline-offset: 2
    stroke-width: 0.5
    header-gray: 0.85
    alt-row-gray: 0.95
    default-col-width: 80
    bold-font: "/Times-Bold"
    italic-font: "/Times-Italic"
    bold-italic-font: "/Times-BoldItalic"
    regular-font: "/Times-Roman"
    mono-font: "/Courier"
    mono-bold-font: "/Courier-Bold"
    mono-italic-font: "/Courier-Oblique"
    mono-bold-italic-font: "/Courier-BoldOblique"

    paper-sizes: [
        a4     [595  842]
        letter [612  792]
        legal  [612 1008]
        a3     [842 1190]
        a5     [420  595]
    ]

    landscape?: false

    set 'paper-format func [
        "Set paper size by name. Returns none if unknown."
        name [word!] "One of: a4 letter legal a3 a5"
        /landscape "Swap width and height for horizontal orientation"
        /local sz
    ][
        sz: select paper-sizes name
        either sz [
            landscape?: landscape
            either landscape [
                page-width: sz/2
                page-height: sz/1
            ][
                page-width: sz/1
                page-height: sz/2
            ]
        ][
            print rejoin ["Unknown paper format: " name ". Valid: " mold words-of paper-sizes]
            none
        ]
    ]

    emit: func ["Append PS line with newline" out [string!] data [block!]][
        append out rejoin data
        append out lf
    ]

    ps-escape: func ["Escape parentheses and backslashes for PostScript" s [string!] /local result ch bs][
        result: copy ""
        bs: to char! 92
        foreach ch s [
            case [
                ch = bs    [append result bs append result bs]
                ch = #"("  [append result bs append result #"("]
                ch = #")"  [append result bs append result #")"]
                true       [append result ch]
            ]
        ]
        result
    ]

    emit-font: func ["Emit PostScript font selection" out [string!] font-name [string!]][
        emit out [font-name " findfont " font-size " scalefont setfont"]
    ]

    emit-text: func [
        "Emit positioned text with optional center/right alignment"
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

    emit-text-join: func ["Continue text from currentpoint (PS chaining)" out [string!] y [integer!] text [string!]][
        append out rejoin [
            "_jx _jy moveto"
            " (" ps-escape text ") show"
            " currentpoint /_jy exch def /_jx exch def" lf
        ]
    ]

    emit-text-start: func ["Initialize PS chaining variables at position" out [string!] x [integer!] y [integer!]][
        append out rejoin ["/_jx " x " def /_jy " y " def" lf]
    ]

    emit-underline: func [
        "Emit underline stroke for text at position"
        out [string!] x [integer!] y [integer!] text [string!]
        col-w [integer!] align [string!]
    ][
        emit out ["gsave"]
        emit out ["newpath"]
        case [
            align = "C" [
                append out rejoin [
                    "(" ps-escape text ") stringwidth pop dup "
                    col-w " exch sub 2 div " x " add "
                    (y - underline-offset) " moveto 0 rlineto stroke"
                ]
            ]
            align = "R" [
                append out rejoin [
                    "(" ps-escape text ") stringwidth pop dup "
                    col-w " exch sub " x " add " cell-pad " sub "
                    (y - underline-offset) " moveto 0 rlineto stroke"
                ]
            ]
            true [
                append out rejoin [
                    x " " (y - underline-offset) " moveto "
                    "(" ps-escape text ") stringwidth pop 0 rlineto stroke"
                ]
            ]
        ]
        append out lf
        emit out ["grestore"]
    ]

    emit-rect: func ["Emit rectangle stroke" out [string!] x [integer!] y [integer!] w [integer!] h [integer!]][
        emit out ["gsave " stroke-width " setlinewidth newpath " x " " y " moveto " w " 0 rlineto 0 " h " rlineto " (0 - w) " 0 rlineto closepath stroke grestore"]
    ]

    emit-vline: func ["Emit vertical line stroke" out [string!] x [integer!] y [integer!] h [integer!]][
        emit out ["gsave " stroke-width " setlinewidth newpath " x " " y " moveto 0 " h " rlineto stroke grestore"]
    ]

    emit-filled-rect: func ["Emit filled rectangle with gray level" out [string!] x [integer!] y [integer!] w [integer!] h [integer!] gray [float!]][
        emit out ["gsave"]
        emit out [gray " setgray newpath " x " " y " moveto " w " 0 rlineto 0 " h " rlineto " (0 - w) " 0 rlineto closepath fill"]
        emit out ["grestore"]
    ]

    ;--- Style helpers ---

    style-has: func ["Check if style block contains target word" styles [block!] target [word!]][
        not none? find styles target
    ]

    style-heading: func ["Return heading level (1-3) from styles, or 0" styles [block!] /local s][
        foreach s styles [
            if find [h1 h2 h3] s [return case [s = 'h1 [1] s = 'h2 [2] true [3]]]
        ]
        0
    ]

    heading-size: func ["Font size for heading level (1=24, 2=18, 3=14)" hd [integer!]][
        case [hd = 1 [24] hd = 2 [18] hd = 3 [14] true [font-size]]
    ]

    max-style-size: function [
        "Largest font size from style blocks in a line/row"
        line-block [block!]
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

    font-for-styles: func ["Select font name for style combination" styles [block!] /local b? i? m? hd][
        b?: style-has styles 'b
        i?: style-has styles 'i
        m?: style-has styles 'm
        hd: style-heading styles

        either hd > 0 [
            case [
                all [m? b?] [mono-bold-font]
                m?          [mono-font]
                b?          [bold-font]
                i?          [italic-font]
                true        [bold-font]
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

    select-style-font: func ["Emit font selection for given styles" out [string!] styles [block!] /local hd sz][
        hd: style-heading styles
        sz: heading-size hd
        emit out [font-for-styles styles " findfont " sz " scalefont setfont"]
    ]

    emit-styled-text: func [
        "Emit text with style-aware font selection and alignment"
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
            either any-style? [select-style-font out styles][emit-font out regular-font]
            if any-style? [emit out ["/_ulx _jx def"]]
            emit-text-join out y text
            if all [any-style? style-has styles 'u] [
                emit out [
                    "gsave newpath"
                    " _ulx " (y - underline-offset) " moveto"
                    " (" ps-escape text ") stringwidth pop 0 rlineto stroke grestore"
                ]
            ]
        ][
            either any-style? [select-style-font out styles][emit-font out regular-font]
            case [
                align = "C" [emit-text/center out x y text col-w]
                align = "R" [emit-text/right out x y text col-w]
                true [emit-text out x y text]
            ]
            if any-style? [
                if style-has styles 'u [emit-underline out x y text col-w align]
                emit-font out regular-font
            ]
        ]
    ]

    ;--- Number formatting ---

    format-number-value: function ["Format number with optional money/decimal format" val [number!] fmt [none! word! float!]][
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
                s: form fmt
                dpos: find s #"."
                either dpos [
                    int-width: to integer! copy/part s dpos
                    decimals: to integer! copy next dpos
                ][
                    int-width: to integer! s
                    decimals: 0
                ]
                result: format-decimal val decimals
                int-part: either find result #"." [
                    copy/part result find result #"."
                ][
                    copy result
                ]
                if (length? int-part) < int-width [
                    result: rejoin [copy/part "                    " (int-width - length? int-part) result]
                ]
                result
            ]
            true [to string! val]
        ]
    ]

    format-decimal: function [
        "Format number with fixed decimals and thousand separators"
        val [number!] decimals [integer!]
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

    format-date-value: function [
        "Format date value as date, time, or datetime string"
        val [date!] fmt [word!]
    ][
        case [
            fmt = 'date [form val/date]
            fmt = 'time [
                t: form any [val/time 0:00]
                copy/part t ((length? t) - 3)
            ]
            true [
                d: form val/date
                t: form any [val/time 0:00]
                rejoin [d " " copy/part t ((length? t) - 3)]
            ]
        ]
    ]

    ;--- Parsing ---

    parse-columns: function [
        "Parse column header row: data followed by style block"
        cols [block!]
    ][
        col-titles: copy []
        col-widths: copy []
        col-aligns: copy []
        col-formats: copy []
        col-bolds: copy []
        col-blanks: copy []
        num-cols: 0
        cur-text: none

        foreach v cols [
            either block? v [
                if cur-text [
                    append col-titles cur-text
                    cur-align: "L"
                    cur-bold: false
                    cur-format: none
                    cur-width: default-col-width
                    cur-blank: false
                    foreach s v [
                        case [
                            s = '<      [cur-align: "L"]
                            s = '^      [cur-align: "C"]
                            s = '>      [cur-align: "R"]
                            s = 'b      [cur-bold: true]
                            s = 'blank  [cur-blank: true]
                            s = 'money  [cur-format: 'money]
                            integer? s  [cur-width: s]
                            float? s    [cur-format: s]
                        ]
                    ]
                    append col-widths cur-width
                    append col-aligns cur-align
                    append col-formats cur-format
                    append col-bolds cur-bold
                    append col-blanks cur-blank
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
        reduce [col-titles col-widths col-aligns col-formats col-bolds col-blanks num-cols]
    ]

    eval-val: func ["Resolve word to its value, or return as-is" v /local val][
        case [
            word? v     [val: attempt [get v] either val [val][v]]
            get-word? v [val: attempt [get v] either val [val][v]]
            true        [v]
        ]
    ]

    parse-row-segments: function [
        "Parse a row: data elements followed by style blocks. Returns [styles text ...] pairs. Floats in style blocks format preceding numbers. Numbers are kept as-is for column formatting."
        row [block!]
    ][
        result: copy []
        cur-text: none
        cur-styles: copy []
        fmt: none

        foreach v row [
            either block? v [
                cur-styles: copy []
                fmt: none
                foreach s v [
                    case [
                        word? s     [append cur-styles s]
                        lit-word? s [append cur-styles to word! s]
                        float? s    [fmt: s]
                        integer? s  [fmt: to float! s]
                    ]
                ]
                if cur-text [
                    if all [fmt number? cur-text][
                        cur-text: format-number-value cur-text fmt
                    ]
                    if date? cur-text [
                        case [
                            find cur-styles 'date     [cur-text: format-date-value cur-text 'date]
                            find cur-styles 'time     [cur-text: format-date-value cur-text 'time]
                            find cur-styles 'datetime [cur-text: format-date-value cur-text 'datetime]
                        ]
                    ]
                    append/only result cur-styles
                    append result cur-text
                    cur-text: none
                    cur-styles: copy []
                    fmt: none
                ]
            ][
                if cur-text [
                    append/only result copy []
                    append result cur-text
                ]
                cur-text: case [
                    string? v  [v]
                    number? v  [v]
                    word? v    [
                        val: attempt [get v]
                        case [
                            none? val    [form v]
                            string? val  [val]
                            number? val  [val]
                            date? val    [val]
                            true         [form val]
                        ]
                    ]
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

    table-modifiers: function [
        "Scan table block for modifiers. Returns [boxed? alt? col-index]"
        item [block!]
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
        "Replace %PAGE%, %PAGES%, %DATE%, %TIME%, %DATETIME% tokens"
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

    ceil-div: func ["Integer division rounding up" a [integer!] b [integer!]][
        to integer! (a + b - 1) / b
    ]

    merge-styles: func [
        "Merge line-wide styles into segment styles. Segment styles take precedence."
        base [block!] "Line-wide styles (e.g. ['m])"
        override [block!] "Segment styles (e.g. ['b])"
        /local result s
    ][
        either empty? override [copy base][
            result: copy base
            foreach s override [unless find result s [append result s]]
            result
        ]
    ]

    emit-content-line: function [
        "Emit a content line with parsed styles and segments"
        out [string!] line-block [block!] page-y [integer!]
    ][
        parsed: parse-line line-block
        line-styles: parsed/1
        segments: parsed/2
        nsegs: (length? segments) / 2
        if nsegs > 0 [
            either nsegs = 1 [
                styles: merge-styles line-styles segments/1
                text: segments/2
                if any [number? text date? text] [text: form text]
                emit-styled-text out margin-left page-y text col-w "L" styles
            ][
                emit-text-start out margin-left page-y
                i: 1
                while [i <= length? segments][
                    styles: merge-styles line-styles pick segments i
                    text: pick segments (i + 1)
                    if any [number? text date? text] [text: form text]
                    emit-styled-text/join out margin-left page-y text col-w "L" styles
                    i: i + 2
                ]
            ]
        ]
    ]

    emit-header-line: function [
        "Emit a header/footer line with positional alignment (1st=L, 2nd=C, 3rd=R)"
        out [string!] y [integer!] line-block [block!]
        page-num [integer!] total-pages [integer!]
        date-str [string!] time-str [string!] datetime-str [string!]
        /default-style def-styles [block!]
        /skip-tokens "Don't replace tokens; deferred for later"
    ][
        parsed: parse-line line-block
        line-styles: parsed/1
        segments: parsed/2
        nsegs: (length? segments) / 2
        if nsegs > 0 [
            repeat idx nsegs [
                styles: merge-styles line-styles pick segments ((idx - 1) * 2 + 1)
                text: pick segments (idx * 2)
                if number? text [text: form text]
                align: case [idx = 1 ["L"] idx = 2 ["C"] idx = 3 ["R"] true ["L"]]
                unless skip-tokens [
                    text: replace-tokens text page-num total-pages date-str time-str datetime-str
                ]
                either all [empty? styles default-style][
                    emit-styled-text out margin-left y text col-w align def-styles
                ][
                    emit-styled-text out margin-left y text col-w align styles
                ]
            ]
        ]
    ]

    ;--- Header / Footer emit ---

    emit-header: func [
        "Emit header block at top of page, return updated page-y"
        out [string!] hdr [block! none!] page-y [integer!]
        date-str [string!] time-str [string!] datetime-str [string!]
        /local line
    ][
        if none? hdr [return page-y]
        foreach line hdr [
            either block? line [
                emit-header-line/skip-tokens/default-style out page-y line 0 0 date-str time-str datetime-str ['b]
            ][
                emit-styled-text out margin-left page-y line col-w "L" ['b]
            ]
            page-y: page-y - line-height
        ]
        emit-font out regular-font
        page-y
    ]

    emit-footer: func [
        "Emit footer block at bottom of page"
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

    emit-table-row: function [
        "Emit a table row (header or data). box-top = y - rh."
        out [string!] y [integer!] rh [integer!]
        tl [integer!] tw [integer!] boxed? [logic!] alt? [logic!]
        is-header [logic!] row-num [integer!]
        col-info [block!] row [block!]
    ][
        box-top: y - rh
        text-y: box-top + row-padding

        col-titles:  col-info/1
        col-widths:  col-info/2
        col-aligns:  col-info/3
        col-formats: col-info/4
        col-bolds:   col-info/5
        col-blanks:  col-info/6
        num-cols:    col-info/7

        either is-header [
            emit-filled-rect out tl box-top tw rh header-gray
        ][
            if all [alt? (row-num // 2) = 0] [
                emit-filled-rect out tl box-top tw rh alt-row-gray
            ]
        ]

        col-styles: parse-row-segments row

        col-x: tl
        col-i: 1
        while [col-i <= num-cols][
            col-w: pick col-widths col-i
            col-align: pick col-aligns col-i
            col-format: pick col-formats col-i

            either is-header [
                col-text: pick col-titles col-i
                emit-styled-text out (col-x + cell-pad) text-y col-text (col-w - (cell-pad * 2)) col-align ['b]
            ][
                styles: either col-i <= ((length? col-styles) / 2) [
                    pick col-styles ((col-i - 1) * 2 + 1)
                ][copy []]
                raw-val: either col-i <= ((length? col-styles) / 2) [
                    pick col-styles (col-i * 2)
                ][none]

                final-styles: copy []
                if pick col-bolds col-i [append final-styles 'b]
                foreach s styles [unless any [find final-styles s  s = 'blank] [append final-styles s]]

                text: case [
                    none? raw-val   [""]
                    all [pick col-blanks col-i number? raw-val raw-val = 0] [""]
                    all [find styles 'blank number? raw-val raw-val = 0] [""]
                    string? raw-val [raw-val]
                    number? raw-val [either col-format [format-number-value raw-val col-format][form raw-val]]
                    date? raw-val   [
                        case [
                            find styles 'date     [format-date-value raw-val 'date]
                            find styles 'time     [format-date-value raw-val 'time]
                            find styles 'datetime [format-date-value raw-val 'datetime]
                            true                  [form raw-val]
                        ]
                    ]
                    true            [form raw-val]
                ]
                emit-styled-text out (col-x + cell-pad) text-y text (col-w - (cell-pad * 2)) col-align final-styles
            ]
            col-x: col-x + col-w
            col-i: col-i + 1
        ]

        if boxed? [emit-rect out tl box-top tw rh]

        col-x: tl
        col-i: 2
        while [col-i <= num-cols][
            col-w: pick col-widths (col-i - 1)
            col-x: col-x + col-w
            emit-vline out col-x box-top rh
            col-i: col-i + 1
        ]
    ]

    ;--- Section parser ---

    parse-sections: function [
        "Parse flat content into [header content footer]. Sections are delimited by 'HEADER 'CONTENT 'FOOTER lit-words."
        block [block!]
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
                    if not none? item [
                        if word? item [item: eval-val item]
                        case [
                            current = 'header  [append/only header item]
                            current = 'content [append/only content item]
                            current = 'footer  [append/only footer item]
                        ]
                    ]
                ]
            ]
        ]
        reduce [header content footer]
    ]

    ;--- Main entry point ---

    is-page-break-row?: func [
        "Check if a table row is a page break marker (^L)"
        row
    ][
        all [
            block? row
            not empty? row
            string? first row
            (first row) = "^L"
        ]
    ]

    assemble-ps: function [
        "Build PostScript document from page buffers"
        pages [block!] total-pages [integer!]
        ftr [block! none!]
        date-str [string!] time-str [string!] datetime-str [string!]
    ][
        out-ps: rejoin ["%!PS-Adobe-3.0" lf]
        emit out-ps ["%%Pages: " total-pages]
        emit out-ps ["%%DocumentMedia: Default " page-width " " page-height " 0 () ()"]
        emit out-ps ["%%BoundingBox: 0 0 " page-width " " page-height]
        emit out-ps ["%%EndComments"]
        emit out-ps ["<< /PageSize [" page-width " " page-height "] >> setpagedevice"]

        p: 0
        while [p < total-pages][
            p: p + 1
            page-ps: copy pick pages p
            replace/all page-ps "%PAGE%" to string! p
            replace/all page-ps "%PAGES%" to string! total-pages
            replace/all page-ps "%DATE%" date-str
            replace/all page-ps "%TIME%" time-str
            replace/all page-ps "%DATETIME%" datetime-str
            emit out-ps ["%%Page: " p " " p]
            emit out-ps ["0 setgray 1 setlinewidth"]
            append out-ps page-ps
            emit-footer out-ps ftr p total-pages date-str time-str datetime-str
            emit out-ps ["showpage"]
        ]

        emit out-ps ["%%EOF"]
        out-ps
    ]

    convert-to-pdf: func [
        "Convert PostScript file to PDF using ps2pdf. Returns true on success."
        ps-file [file!] pdf-file [file!]
        /local result
    ][
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
        ]
        result = 0
    ]

    set 'generate-report function [
        "Generate a multi-page report (default A4, use paper-format to change)"
        content [block!]        "Content block with 'HEADER 'CONTENT 'FOOTER sections"
        output [file!]          "Output PDF file path"
        /browser                "Generate PDF and open in default PDF viewer"
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

                    table-left: margin-left
                    table-width: 0
                    foreach w col-info/2 [table-width: table-width + w]

                    row-h: header-row-h

                    table-total-h: row-h
                    forall table-rows [
                        row-item: first table-rows
                        either is-page-break-row? row-item [
                            table-total-h: table-total-h + row-h
                        ][
                            table-total-h: table-total-h + row-height row-item
                        ]
                    ]

                    page-y: page-y - row-h
                    if (page-y - table-total-h - line-height) < page-bottom [new-page]

                    emit-table-row page-content page-y row-h table-left table-width boxed? alt? true 0 col-info []
                    page-y: page-y - row-h

                    row-num: 0
                    forall table-rows [
                        row-item: first table-rows
                        row-h: row-height row-item
                        either is-page-break-row? row-item [
                            new-page
                            row-h: header-row-h
                            emit-table-row page-content page-y row-h table-left table-width boxed? alt? true 0 col-info []
                            page-y: page-y - row-h
                        ][
                            if (page-y - row-h) < page-bottom [
                                new-page
                                row-h: header-row-h
                                emit-table-row page-content page-y row-h table-left table-width boxed? alt? true 0 col-info []
                                page-y: page-y - row-h
                                row-h: row-height row-item
                            ]

                            row-num: row-num + 1
                            emit-table-row page-content page-y row-h table-left table-width boxed? alt? false row-num col-info row-item
                            page-y: page-y - row-h
                        ]
                    ]
                    page-y: page-y - line-height
                ][
                    either all [
                        not empty? item
                        item/1 = 'column
                        (length? item) >= 3
                    ][
                        ;--- Column layout: ['column col-width gap-width line1 line2 ...] ---
                        col-col-w: item/2
                        col-gap: item/3
                        col-rows: copy []
                        ci: 4
                        while [ci <= length? item][
                            append/only col-rows pick item ci
                            ci: ci + 1
                        ]
                        col-total: length? col-rows
                        col-num: to integer! (page-width - margin-left - margin-right) / (col-col-w + col-gap)
                        if col-num < 1 [col-num: 1]
                        col-idx: 1
                        col-remaining: col-total
                        while [col-remaining > 0][
                            ; how many rows each column needs to show all remaining
                            col-rows-per-col: ceil-div col-remaining col-num
                            col-avail: to integer! (page-y - page-bottom) / line-height
                            if col-avail < 1 [new-page col-avail: to integer! (page-y - page-bottom) / line-height]
                            either col-rows-per-col <= col-avail [
                                ; all remaining fits — distribute evenly
                                col-cols-fit: col-num
                            ][
                                ; won't fit — use as many rows as page allows
                                col-rows-per-col: col-avail
                                col-cols-fit: col-num
                            ]
                            ; render in column-major order
                            col-rendered: 0
                            repeat col-ci col-cols-fit [
                                col-x: (col-ci - 1) * (col-col-w + col-gap)
                                emit page-content ["gsave " col-x " 0 translate"]
                                repeat col-ri col-rows-per-col [
                                    col-r: col-idx + ((col-ci - 1) * col-rows-per-col) + col-ri - 1
                                    if col-r <= col-total [
                                        col-emit-y: page-y - ((col-ri - 1) * line-height)
                                        emit-content-line page-content col-rows/:col-r col-emit-y
                                        col-rendered: col-rendered + 1
                                    ]
                                ]
                                emit page-content ["grestore"]
                            ]
                            col-idx: col-idx + col-rendered
                            col-remaining: col-remaining - col-rendered
                            page-y: page-y - (col-rows-per-col * line-height)
                            if col-remaining > 0 [new-page]
                        ]
                    ][
                        either all [
                            not empty? item
                            string? first item
                            (first item) = "^L"
                            (length? item) > 1
                            number? item/2
                        ][
                            if (page-y - (item/2 * line-height)) < page-bottom [new-page]
                        ][
                            page-y: page-y - heading-gap item
                            if (page-y - line-height) < page-bottom [new-page]
                            emit-content-line page-content item page-y
                            page-y: page-y - line-height
                        ]
                    ]
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

        out-ps: assemble-ps pages total-pages ftr date-str time-str datetime-str

        ps-file: to file! rejoin [copy/part to string! output ((length? to string! output) - 4) ".ps"]
        pdf-file: output

        write ps-file out-ps
        unless convert-to-pdf ps-file pdf-file [exit]

        if browser [
            browse pdf-file
            delete ps-file
        ]
    ] ; generate-report
];context
