#!/bin/sh

awk '
# Проверка: является ли строка безопасным литералом данных
function is_lit(s) {
    gsub(/^[ \t\n\r]+|[ \t\n\r]+$/, "", s)
    if (s == "") return 1
    # 1. Числа (вкл. hex, bin, sci-notation, суффиксы)
    if (s ~ /^[-+]?([0-9]+(\.[0-9]*)?|\.[0-9]+)([eE][-+]?[0-9]+)?[fFlLuU]*$/) return 1
    if (s ~ /^0[xXbB][0-9a-fA-F_]+$/) return 1
    # 2. Строки
    if (s ~ /^"[^"]*"$/ || s ~ /^\047[^\047]*\047$/) return 1
    # 3. Константы
    if (s ~ /^(true|false|null|None|Nil|undefined|TRUE|FALSE)$/i) return 1
    # 4. Вложенные структуры (разрешаем символы объектов, но не код)
    if (s ~ /^[[({].*[])}]$/ && s !~ /[=;]/ && s !~ /\<(if|for|while|return)\>/) return 1
    return 0
}

# "Умный" сплиттер: делит по запятым только на верхнем уровне вложенности
function smart_split(s, arr,    i, c, lvl, start, count) {
    lvl = 0; start = 1; count = 0;
    for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c ~ /[\[({]/) lvl++
        if (c ~ /[\])}]/) lvl--
        if (c == "," && lvl == 0) {
            arr[++count] = substr(s, start, i - start)
            start = i + 1
        }
    }
    arr[++count] = substr(s, start)
    return count
}

# Функция редукции
function reduce(content,    e, n, i, out) {
    n = smart_split(content, e)
    if (n < 7) return content

    # Проверяем края
    for (i=1; i<=3; i++) if (!is_lit(e[i])) return content
    for (i=n-2; i<=n; i++) if (!is_lit(e[i])) return content

    # Чистим элементы от лишних пробелов/переносов
    for (i=1; i<=n; i++) gsub(/^[ \t\n\r]+|[ \t\n\r]+$/, "", e[i])

    out = e[1] ", " e[2] ", " e[3] " , .... REDUCED (" (n-6) " items) .... , " e[n-2] ", " e[n-1] ", " e[n]
    return out
}

{ all = all $0 "\n" }

END {
    line = all
    # Ищем самые глубокие скобки и идем наружу
    while (match(line, /[\[({][^][(){}]*[\]})]/)) {
        pre = substr(line, 1, RSTART-1)
        full = substr(line, RSTART, RLENGTH)
        post = substr(line, RSTART+RLENGTH)

        op = substr(full, 1, 1)
        cl = substr(full, RLENGTH, 1)
        body = substr(full, 2, RLENGTH-2)

        if (body ~ /,/) body = reduce(body)
        
        printf "%s%s%s%s", pre, op, body, cl
        line = post
    }
    printf "%s", line
}
' "$@"
