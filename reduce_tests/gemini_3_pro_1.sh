#!/bin/sh

export LC_ALL=C
INPUT_FILE="${1:-/dev/stdin}"

awk '
# Проверка: является ли элемент "чистым" литералом (число или строка в кавычках)
function is_strict_literal(s) {
    gsub(/^[ \t\n\r]+|[ \t\n\r]+$/, "", s)
    if (s == "") return 1
    # Добавляем проверку: если элемент сам является уже сокращенным или коротким массивом
    if (s ~ /^(\[|\(|\{).*(\]|\)|\})$/) return 1 
    
    if (s ~ /^"[^"]*"$/ || s ~ /^\047[^\047]*\047$/) return 1
    if (s ~ /^[-+]?([0-9]+(\.[0-9]*)?|\.[0-9]+)([eE][-+]?[0-9]+)?[fFlLuU]*$/) return 1
    if (s ~ /^0x[0-9a-fA-F_]+$/) return 1
    if (s ~ /^0b[01_]+$/) return 1
    if (s ~ /^(true|false|null|None|Nil|TRUE|FALSE)$/) return 1
    return 0
}

function process_block(block, open_br, close_br,    parts, n, i, all_literals, res) {
    # Удаляем комментарии внутри блока для чистоты проверки (простой стрип //)
    gsub(/\/\/[^\n]*/, "", block)
    
    # Считаем элементы
    n = split(block, parts, ",")
    
    if (n < THRESHOLD) return open_br block close_br
    
    # Проверка: все ли элементы являются литералами?
    # Если там переменные или выражения (i+1), мы не должны редуцировать.
    all_literals = 1
    for (i = 1; i <= n; i++) {
        if (!is_strict_literal(parts[i])) {
            all_literals = 0
            break
        }
    }
    
    # Если это не массив данных (а вызов функции или список переменных) - возвращаем как было
    if (!all_literals) return open_br block close_br

    # Формируем сокращение
    res = open_br
    for (i = 1; i <= 3; i++) {
        gsub(/^[ \t\n\r]+|[ \t\n\r]+$/, "", parts[i])
        res = res parts[i] ", "
    }
    res = res ".... REDUCED ...."
    for (i = n - 2; i <= n; i++) {
        gsub(/^[ \t\n\r]+|[ \t\n\r]+$/, "", parts[i])
        res = res ", " parts[i]
    }
    return res close_br
}

BEGIN {
    THRESHOLD = 7  # Начинаем сокращать, если больше 6 элементов
    RS = "^$"      # Читаем весь файл целиком
}

{
    text = $0
    len = length(text)
    out = ""
    
    for (i = 1; i <= len; i++) {
        char = substr(text, i, 1)
        
        # Обработка начала блока
        if (char == "[" || char == "(" || char == "{") {
            start_pos = i
            br_level = 1
            open_c = char
            close_c = (char == "[" ? "]" : (char == "(" ? ")" : "}"))
            
            # Поиск закрывающей скобки
            for (j = i + 1; j <= len; j++) {
                c_inner = substr(text, j, 1)
                
                # Пропускаем строки, чтобы не считать скобки внутри них
                if (c_inner == "\"" || c_inner == "\047") {
                    q = c_inner
                    for (j++; j <= len; j++) {
                        if (substr(text, j, 1) == q && substr(text, j-1, 1) != "\\") break
                    }
                }
                
                if (substr(text, j, 1) == open_c) br_level++
                else if (substr(text, j, 1) == close_c) br_level--
                
                if (br_level == 0) {
                    content = substr(text, i + 1, j - i - 1)
                    # Рекурсивно обрабатываем внутренности (для вложенных массивов)
                    out = out process_block(content, open_c, close_c)
                    i = j
                    break
                }
            }
            if (br_level > 0) out = out char
        } else {
            out = out char
        }
    }
    printf "%s", out
}
' "$INPUT_FILE"
