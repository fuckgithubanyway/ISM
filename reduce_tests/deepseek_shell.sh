#!/bin/sh

# Функция для обработки одного массива
reduce_array() {
    local content="$1"
    local delimiter="$2"
    local open="$3"
    local close="$4"
    
    # Удаляем внешние скобки и разбиваем на элементы
    local inner="${content#$open}"
    inner="${inner%$close}"
    
    # Разбиваем на массив элементов (учитывая запятые и переносы строк)
    OLDIFS="$IFS"
    IFS=","
    set -- $inner
    IFS="$OLDIFS"
    
    local count=$#
    local result=""
    
    if [ "$count" -le 6 ]; then
        # Если элементов 6 или меньше, оставляем как есть
        result="$open$inner$close"
    else
        # Берем первые 3 элемента
        local i=1
        local first_part=""
        for elem in "$@"; do
            if [ "$i" -le 3 ]; then
                first_part="${first_part}${first_part:+,}$(echo "$elem" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
                i=$((i + 1))
            else
                break
            fi
        done
        
        # Берем последние 3 элемента
        local j=$((count - 2))
        local last_part=""
        while [ "$j" -le "$count" ]; do
            local elem=$(eval echo "\$$j")
            last_part="${last_part}${last_part:+,}$(echo "$elem" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
            j=$((j + 1))
        done
        
        result="$open$first_part, .... REDUCED .... $last_part$close"
    fi
    
    echo "$result"
}

# Основная функция обработки
process_code() {
    local code="$1"
    local result="$code"
    local temp=""
    
    # Обрабатываем квадратные скобки
    while echo "$result" | grep -q '\[[^][]*\]'; do
        # Находим самый внутренний массив без вложенных массивов
        local match=$(echo "$result" | grep -o '\[[^][]*\]' | head -1)
        if [ -n "$match" ]; then
            local replacement=$(reduce_array "$match" "," "[" "]")
            # Заменяем только первое вхождение
            result=$(echo "$result" | sed "s|$(echo "$match" | sed 's/\[/\\[/g;s/\]/\\]/g')|$replacement|")
        else
            break
        fi
    done
    
    # Обрабатываем круглые скобки
    while echo "$result" | grep -q '([^)(]*)'; do
        # Находим самый внутренний массив без вложенных массивов
        local match=$(echo "$result" | grep -o '([^)(]*)' | head -1)
        if [ -n "$match" ]; then
            local replacement=$(reduce_array "$match" "," "(" ")")
            # Заменяем только первое вхождение
            result=$(echo "$result" | sed "s|$(echo "$match" | sed 's/(/\\(/g;s/)/\\)/g')|$replacement|")
        else
            break
        fi
    done
    
    echo "$result"
}

# Главная программа
main() {
    # Читаем весь вход
    input=$(cat)
    
    if [ -z "$input" ]; then
        echo "Ошибка: пустой вход" >&2
        exit 1
    fi
    
    # Обрабатываем код
    process_code "$input"
}

main "$@"