#!/bin/sh

awk '
function reduce_array(content, open, close,    parts, count, i, result) {
    # Удаляем внешние скобки
    sub("^" open, "", content)
    sub(close "$", "", content)
    
    # Разбиваем на элементы
    count = split(content, parts, ",")
    
    if (count <= 6) {
        return open content close
    }
    
    # Формируем результат
    result = open
    for (i = 1; i <= 3 && i <= count; i++) {
        # Убираем пробелы
        gsub(/^[ \t]+|[ \t]+$/, "", parts[i])
        if (i > 1) result = result ","
        result = result parts[i]
    }
    
    result = result ", .... REDUCED ...."
    
    for (i = count - 2; i <= count; i++) {
        if (i >= 1) {
            gsub(/^[ \t]+|[ \t]+$/, "", parts[i])
            result = result "," parts[i]
        }
    }
    
    return result close
}

{
    line = $0
    
    # Обрабатываем квадратные скобки
    while (match(line, /\[[^][]*\]/)) {
        pos = RSTART
        len = RLENGTH
        matched = substr(line, pos, len)
        replacement = reduce_array(matched, "[", "]")
        line = substr(line, 1, pos - 1) replacement substr(line, pos + len)
    }
    
    # Обрабатываем круглые скобки
    while (match(line, /\([^)(]*\)/)) {
        pos = RSTART
        len = RLENGTH
        matched = substr(line, pos, len)
        replacement = reduce_array(matched, "(", ")")
        line = substr(line, 1, pos - 1) replacement substr(line, pos + len)
    }
    
    print line
}
'
