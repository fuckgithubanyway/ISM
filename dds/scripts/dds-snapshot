#!/usr/bin/env sh

# DDS SNAPSHOT BUILDER
#
# Назначение:
#   Формирует единый текстовый документ (Снимок) из файлов проекта.
#
# Архитектурные принципы:
#   1. Agnostic Output: Пишет в stdout или файл, не зная о потребителе.
#   2. Protocol Strictness: Гарантирует наличие "Magic Header" (Manifest) в начале потока.
#   3. Input Safety: Четкое разделение строковых аргументов и путей к файлам.

usage() {
  cat << EOF
Формирует Полный Снимок проекта в соответствии с протоколом DDS.

Использование: $(basename "$0") [ОПЦИИ] [ПУТЬ...]

Опции ввода:
  --request "<текст>"    Добавить текст Запроса Действия (строковый литерал).
  --request-file <файл>  Добавить текст Запроса Действия из файла.

Опции вывода:
  --output <файл>        Сохранить вывод в файл вместо stdout.
  --all                  Включать скрытые файлы (кроме игнорируемых .ddsignore).

Опции справки:
  --help                 Показать это сообщение.
EOF
}

fail() {
  printf "ERROR: %s\n" "$1" >&2
  exit 1
}

# --- Configuration & Dependencies ---

script_dir=$(CDPATH="" cd -- "$(dirname -- "$0")" && pwd)
DDS_LINTER="$script_dir/dds-linter"
DDS_LIST="$script_dir/dds-list"
DDS_TREE="$script_dir/dds-tree"

for tool in "$DDS_LINTER" "$DDS_LIST" "$DDS_TREE"; do
  if ! [ -x "$tool" ]; then fail "Зависимость не найдена или не исполняема: $tool"; fi
done

output_file=""
request_content=""
show_all=""
path_args=""

# --- Argument Parsing ---

while [ "$#" -gt 0 ]; do
  case "$1" in
    --help) usage; exit 0 ;;
    
    --output)
      [ -z "$2" ] && fail "--output требует аргумент"
      output_file="$2"
      shift 2
      ;;
      
    --request)
      [ -z "$2" ] && fail "--request требует аргумент"
      request_content="$2"
      shift 2
      ;;
      
    --request-file)
      [ -z "$2" ] && fail "--request-file требует аргумент"
      req_file="$2"
      if [ ! -f "$req_file" ]; then fail "Файл запроса не найден: $req_file"; fi
      request_content=$(cat "$req_file")
      shift 2
      ;;
      
    --all) show_all="--all"; shift ;;
    
    -*) fail "Неизвестная опция '$1'" ;;
    
    *) 
      # Собираем пути для передачи в dds-list/tree
      path_args="$path_args \"$1\""
      shift 
      ;;
  esac
done

# Если пути не указаны, используем текущую директорию
if [ -z "$path_args" ]; then
  set -- "."
else
  eval set -- "$path_args"
fi

# --- Temporary Files ---

tmp_dir="${TMPDIR:-/tmp}"
tmp_linter="$tmp_dir/dds_snap_lint_$$"
tmp_list="$tmp_dir/dds_snap_list_$$"
tmp_tree="$tmp_dir/dds_snap_tree_$$"

cleanup() {
  rm -f "$tmp_linter" "$tmp_list" "$tmp_tree"
}
trap cleanup EXIT

# --- Step 1: Verification (Linter) ---

# Линтер проверяет структуру и правила DDS. 
# Вывод сохраняем для включения в Снимок.
if ! "$DDS_LINTER" "$@" > "$tmp_linter" 2>&1; then
  # Если ошибка критическая (exit code 1), линтер уже вывел ее в stderr? 
  # dds-linter пишет ошибки в stdout (для парсинга) или stderr?
  # В текущей реализации dds-linter пишет отчет в stdout, но fail() в stderr.
  # Мы перехватываем stdout отчета.
  
  # Если exit code != 0, это может быть WARNING (2) или ERROR (1).
  # Для Snapshot мы допускаем WARNING, но прерываем на ERROR.
  err_code=$?
  if [ "$err_code" -eq 1 ]; then
    cat "$tmp_linter" >&2
    fail "Проверка структуры проекта не пройдена (см. ошибки выше)."
  fi
fi

# --- Step 2: Context Collection ---

# Мы явно проверяем код возврата (!). Если dds-tree упал, мы должны упасть тоже.
if ! "$DDS_TREE" $show_all "$@" > "$tmp_tree"; then
  fail "Генерация дерева файлов не удалась."
fi

if ! "$DDS_LIST" $show_all "$@" > "$tmp_list"; then
  fail "Генерация списка файлов не удалась."
fi

if [ ! -s "$tmp_list" ]; then
  fail "Список файлов пуст. Проверьте путь или .ddsignore."
fi

# --- Step 3: Content Processing Logic ---

cat_content() {
  _path="$1"
  _type="$2"

  # 1. Проверка на бинарный файл
  if od -N 1024 -t x1 "$_path" 2>/dev/null | grep -q ' 00 '; then
    printf "[BINARY CONTENT OMITTED]\n"
    return
  fi

  # 2. Чтение
  if [ "$_type" = "MANIFEST" ] || [ "$_type" = "SPEC" ] || [ "$_type" = "META" ]; then
    cat "$_path"
  else
    # AWK Data Density Heuristic
    awk '
      {
        line_len = length($0)
        limit = 400  # Увеличим порог срабатывания

        # Если строка короткая, выводим как есть
        if (line_len <= limit) {
          print $0
          next
        }

        # --- Эвристический анализ ---
        
        # Создаем копию строки для анализа
        clean = $0
        
        # Удаляем все, что НЕ похоже на числовые данные.
        # Оставляем: цифры 0-9, запятую, точку, минус, пробел и x (для 0xFF)
        gsub(/[^0-9,.\- x]/, "", clean)
        
        data_len = length(clean)
        density = data_len / line_len

        # Если более 60% строки состоит из чисел и разделителей -> это данные (LUT, Mesh)
        if (density > 0.6) {
          head = substr($0, 1, 100)
          tail = substr($0, line_len - 50)
          # Выводим с мета-информацией для LLM, чтобы она понимала природу скрытого
          printf "%s ... [DATA REDUCED: %d chars, density %.0f%%] ... %s\n", head, line_len, density * 100, tail
        } else {
          # Это код (минифицированный JS, длинный SQL с текстом, Base64 и т.д.)
          print $0
        }
      }
    ' "$_path"
  fi
}

# --- Step 4: Stream Generation ---

generate_stream() {
  manifest_processed=false
  
  # Читаем список файлов (дескриптор 3)
  while IFS= read -r line <&3; do
    meta="${line%%: *}"
    path="${line#*: }"
    type="${meta%% *}"
    
    is_protected=0
    case "$meta" in
      *"PROTECTED"*) is_protected=1 ;;
    esac

    # Формирование заголовка блока
    ctx_label="$type"
    if [ "$type" = "CONTENT" ]; then ctx_label="CONTENT OF"; fi
    
    header="--- DDS-CONTEXT ${ctx_label}: "
    if [ "$is_protected" -eq 1 ]; then header="${header}PROTECTED: "; fi
    header="${header}${path} ---"

    # === SPECIAL HANDLING: MANIFEST ===
    # Манифест обязан быть первым и содержать вложенные контексты структуры
    if [ "$type" = "MANIFEST" ]; then
      printf '%s\n' "$header"
      if [ -f "$path" ]; then cat "$path"; else printf "[File Not Found]\n"; fi
      printf '\n'

      # Вставка статических контекстов сразу после Манифеста
      printf '%s\n' "--- DDS-CONTEXT PROJECT STRUCTURE ---"
      cat "$tmp_tree"
      printf '\n'

      printf '%s\n' "--- DDS-CONTEXT SNAPSHOT LIST ---"
      cat "$tmp_list"
      printf '\n'

      if [ -s "$tmp_linter" ]; then
        printf '%s\n' "--- DDS-CONTEXT LINTER REPORT ---"
        cat "$tmp_linter"
        printf '\n'
      fi

      manifest_processed=true
      continue
    fi

    # Защита: Если Манифест еще не обработан, а пошли другие файлы - это нарушение протокола.
    # Но dds-list гарантирует порядок, поэтому здесь мы просто ждем.
    if [ "$manifest_processed" = "false" ]; then
      # В реальной ситуации это может случиться, если манифеста нет в списке (ошибка dds-list/linter)
      continue 
    fi

    # === STANDARD CONTENT ===
    printf '%s\n' "$header"
    if [ -f "$path" ]; then
      cat_content "$path" "$type"
    else
      printf "[File Not Found]\n"
    fi
    printf '\n'

  done 3< "$tmp_list"

  # === REQUEST BLOCK ===
  if [ -n "$request_content" ]; then
    printf '%s\n' "--- DDS-CONTEXT REQUEST ---"
    printf '%s\n' "$request_content"
    printf '\n'
  fi

  printf '%s\n' "--- DDS-CONTEXT END ---"
}

# Вывод в файл или stdout
if [ -n "$output_file" ]; then
  generate_stream > "$output_file"
else
  generate_stream
fi
