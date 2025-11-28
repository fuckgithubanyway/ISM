#!/usr/bin/env sh

# DDS TREE GENERATOR
#
# Назначение:
#   Обеспечивает атомарную операцию обхода файловой системы для всех инструментов DDS.
#   Генерирует "сырой" поток путей с мета-разметкой для последующей обработки (парсинга).
#
# Архитектурные принципы:
#   1. Dumb Generator: Не содержит бизнес-логики DDS (не знает про .ddsignore или типы файлов).
#      Его задача — только предоставить корректную карту ФС.
#   2. Explicit Types: Тип файла кодируется суффиксом в самом пути, что позволяет парсерам
#      (например, dds-list) работать без повторных обращений к диску (stat):
#        - "path/"         -> Директория
#        - "path -> target" -> Символическая ссылка
#        - "path"          -> Файл
#   3. Safety First: Реализует жесткую защиту от рекурсивных циклов (через inode tracking).
#      Рекурсия прерывается ДО входа в зацикленную директорию.
#
# Режимы вывода:
#   --plain: Линейный список для машинного парсинга (используется в dds-list).
#   (default): Визуальное дерево для человека (используется в dds-snapshot/report).


usage() {
  cat << EOF
DDS Structure Scanner — Генератор структурного представления файловой системы.

Инструмент выполняет безопасный рекурсивный обход указанной директории,
обеспечивая детекцию циклических символических ссылок и унифицированное
форматирование вывода для дальнейшей обработки.

Использование: $(basename "$0") [--help] [--all] [--plain] [путь]

Опции:
  --help     Показать справку.
  --all      Включать в вывод скрытые файлы и директории (начинающиеся с точки).
  --plain    Включить режим плоского машиночитаемого списка:
             - Директории завершаются символом '/' (например: 'src/').
             - Ссылки содержат указатель на цель (например: 'lib -> /usr/lib').
             - Древовидная графика (├──) отключается.

Аргументы:
  [путь]     Корневая директория для сканирования (по умолчанию: текущая).
EOF
}

fail() {
  printf "ОШИБКА: %s\n\n" "$1" >&2
  usage
  exit 1
}

# Функция для получения цели ссылки (переносимая)
get_link_target() {
  _path="$1"
  if command -v readlink >/dev/null 2>&1; then
     readlink -- "$_path"
  else
     command ls -ld -- "$_path" | sed 's/.* -> //'
  fi
}

process_dir() (
  path="$1"
  prefix="$2"
  visited_inodes="$3"

  if [ "$show_all" = "true" ]; then
    items=$(find -H "$path" -mindepth 1 -maxdepth 1 2>/dev/null | sort -f)
  else
    items=$(find -H "$path" -mindepth 1 -maxdepth 1 ! -name '.*' 2>/dev/null | sort -f)
  fi
  
  if [ -z "$items" ]; then
    return
  fi

  total_items=$(printf '%s\n' "$items" | wc -l)
  processed_items=0

  printf '%s\n' "$items" | while IFS= read -r full_item_path; do
    processed_items=$((processed_items + 1))
    item=$(basename -- "$full_item_path")
    
    # Определение типа
    is_dir=false
    if [ -d "$full_item_path" ]; then is_dir=true; fi
    
    if [ -L "$full_item_path" ]; then is_link=true; else is_link=false; fi

    # --- ЛОГИКА ОПРЕДЕЛЕНИЯ ЦИКЛОВ (Сохранена полностью) ---
    is_cycle=false
    current_inode=""
    
    if [ "$is_dir" = "true" ]; then
      current_inode=$(command ls -idL -- "$full_item_path" 2>/dev/null | awk '{print $1}')
      
      if [ -n "$current_inode" ]; then
        for visited_inode in $visited_inodes; do
          if [ "$visited_inode" = "$current_inode" ]; then
            is_cycle=true
            break
          fi
        done

        # Доп. защита по путям для ссылок
        if [ "$is_cycle" = "false" ] && [ "$is_link" = "true" ]; then
          target_dir=$(cd -P -- "$full_item_path" 2>/dev/null && pwd)
          current_dir=$(cd -P -- "$path" 2>/dev/null && pwd)
          if [ -n "$target_dir" ]; then
             case "$current_dir/" in
               "$target_dir/"*) is_cycle=true ;;
             esac
          fi
        fi
      fi
    fi

    # --- ФОРМИРОВАНИЕ СТРОКИ ОПИСАНИЯ ССЫЛКИ ---
    link_suffix=""
    if [ "$is_link" = "true" ]; then
      raw_target=$(get_link_target "$full_item_path")
      # Если цель - директория, добавляем слеш визуально
      if [ -d "$full_item_path" ]; then
        clean_target="${raw_target%/}/"
        link_suffix=" -> $clean_target"
      else
        link_suffix=" -> $raw_target"
      fi
    fi

    cycle_suffix=""
    if [ "$is_cycle" = "true" ]; then
      cycle_suffix=" [recursive]"
    fi

    # --- ВЫВОД ---

    if [ "$plain_mode" = "true" ]; then
      # -- Режим PLAIN --
      # Нормализуем путь (убираем ./ в начале)
      clean_path=$(printf '%s' "$full_item_path" | sed 's|^\./||')
      
      # Если директория, добавляем / к самому пути
      if [ "$is_dir" = "true" ]; then
        clean_path="${clean_path%/}/"
      fi

      printf '%s%s%s\n' "$clean_path" "$link_suffix" "$cycle_suffix"

    else
      # -- Режим TREE --
      if [ "$processed_items" -eq "$total_items" ]; then
        connector="└── "
        new_prefix="${prefix}    "
      else
        connector="├── "
        new_prefix="${prefix}│   "
      fi

      display_name="$item"
      if [ "$is_dir" = "true" ]; then display_name="$item/"; fi

      printf '%s%s%s%s%s\n' "$prefix" "$connector" "$display_name" "$link_suffix" "$cycle_suffix"
    fi

    # --- РЕКУРСИЯ ---
    
    if [ "$is_dir" = "true" ] && [ "$is_cycle" = "false" ]; then
      # Для plain режима префикс не нужен, но нужен для tree
      next_prefix=""
      if [ "$plain_mode" = "false" ]; then next_prefix="$new_prefix"; fi
      
      process_dir "$full_item_path" "$next_prefix" "$visited_inodes $current_inode"
    fi
    
  done
)

# --- Parse Arguments ---

show_all=false
plain_mode=false
target_dir=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --all) show_all=true; shift ;;
    --plain) plain_mode=true; shift ;;
    --help) usage; exit 0 ;;
    -*) fail "Неизвестная опция '$1'" ;;
    *) if [ -n "$target_dir" ]; then fail "Можно указать только одну директорию."; fi; target_dir="$1"; shift ;;
  esac
done

if [ -z "$target_dir" ]; then target_dir="."; fi

if ! [ -e "$target_dir" ]; then
  fail "Файл или директория '$target_dir' не найдена."
fi

# --- Вывод корня ---

# Нормализация имени корня
if [ "$target_dir" = "." ] || [ "$target_dir" = "./" ]; then
  display_root="."
else
  display_root="${target_dir%/}"
fi

# Если корень - директория, добавляем слеш в plain режиме, если это не точка
if [ -d "$target_dir" ] && [ "$plain_mode" = "true" ] && [ "$display_root" != "." ]; then
   display_root="${display_root}/"
fi

printf '%s\n' "$display_root"

# --- Запуск обхода ---

if [ -d "$target_dir" ]; then
  # Получаем inode корня для защиты от циклов
  root_inode=$(command ls -idL -- "$target_dir" | awk '{print $1}')
  # Убираем слеши на конце для корректной склейки путей внутри функции
  clean_target_dir=$(printf '%s' "$target_dir" | sed 's|/*$||')
  process_dir "$clean_target_dir" "" "$root_inode"
fi
