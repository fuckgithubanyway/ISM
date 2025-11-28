#!/usr/bin/env sh

# DDS LIST BUILDER
#
# Назначение:
#   Является единым источником истины о составе и статусе файлов проекта (Context Awareness).
#   Преобразует "сырой" список файлов в типизированный и проверенный DDS-контекст.
#
# Архитектурные принципы:
#   1. Rule Engine: Реализует собственный механизм сопоставления путей (Glob-to-Regex)
#      для поддержки .ddsignore и .ddsprotect, совместимый с gitignore-стандартом.
#   2. Smart Classification: На лету определяет роль файла в методологии DDS:
#      - MANIFEST (Rank 1): __*.spec.*
#      - META (Rank 2):     _*.spec.*
#      - SPEC (Rank 3):     *.spec.*
#      - CONTENT (Rank 4):  Остальные файлы
#   3. Access Control: Вычисляет статус защиты (PROTECTED) на основе правил и типа файла.
#
# Контракт вывода:
#   TYPE [PROTECTED]: PATH
#   Пример: "SPEC: dds/specs/main.c.spec.md" или "CONTENT PROTECTED: .env"


usage() {
  cat << EOF
DDS Context Builder — Формирователь семантического списка файлов.

Инструмент фильтрует, классифицирует и сортирует файлы проекта для формирования
контекста Исполнителя. Он преобразует "сырой" список файлов в приоритизированную
последовательность артефактов.

Принципы работы:
  1. Сканирование: Использует dds-tree для получения полного списка.
  2. Фильтрация: Применяет исключения из .ddsignore (синтаксис glob).
  3. Защита: Определяет защищенные файлы на основе .ddsprotect.
  4. Классификация: Определяет тип файла (Manifest, Meta, Spec, Content).
  5. Приоритизация: Сортирует вывод для правильной подачи в LLM (Manifest -> Meta -> Spec -> Content).

Использование: $(basename "$0") [--help] [--all] [путь ...]

Опции:
  --help    Показать справку.
  --all     Включать скрытые файлы (транслируется в dds-tree).

Формат вывода (Протокол):
  TYPE [PROTECTED]: PATH

  Где TYPE может быть:
  - MANIFEST: Главный файл описания протокола (dds/specs/__*.spec.*).
  - META:     Глобальные спецификации проекта (dds/specs/_*.spec.*).
  - SPEC:     Спецификации конкретных артефактов.
  - CONTENT:  Исходный код и другие файлы проекта.
EOF
}

fail() {
  printf "CRITICAL ERROR: %s\n" "$1" >&2
  exit 1
}

# --- Configuration ---
SHOW_ALL=0
TARGET_PATHS=""

# --- Dependencies ---
script_dir=$(CDPATH="" cd -- "$(dirname -- "$0")" && pwd)
DDS_TREE="$script_dir/dds-tree"

if ! [ -x "$DDS_TREE" ]; then fail "Зависимость '$DDS_TREE' не найдена."; fi

# --- Argument Parsing ---
while [ "$#" -gt 0 ]; do
  case "$1" in
    --help) usage; exit 0 ;;
    --all)  SHOW_ALL=1; shift ;;
    -*)     fail "Неизвестная опция $1" ;;
    *)      TARGET_PATHS="$TARGET_PATHS \"$1\""; shift ;;
  esac
done

if [ -z "$TARGET_PATHS" ]; then TARGET_PATHS="."; fi

# --- AWK Logic ---
awk_script='
function glob_to_regex(pat,   res) {
  gsub(/[.+^$(){}|]/, "\\\\&", pat)
  gsub(/\*\*/, "\001", pat)
  gsub(/\*/, "[^/]*", pat)
  gsub(/\?/, "[^/]", pat)
  gsub(/\001/, ".*", pat)
  return pat
}

BEGIN {
  ic = 0; pc = 0
}

# --- PHASE 1: Load Rules ---
FNR == NR {
  type = $1
  root = $2
  pattern = $3
  
  sub(/^\.\//, "", root)
  if (root == ".") root = ""
  if (root != "" && substr(root, length(root)) != "/") root = root "/"

  is_neg = 0
  if (substr(pattern, 1, 1) == "!") {
    is_neg = 1
    pattern = substr(pattern, 2)
  }

  if (pattern == "" || substr(pattern, 1, 1) == "#") next

  sub(/^\.\//, "", pattern)

  dir_only = 0
  if (substr(pattern, length(pattern)) == "/") {
    dir_only = 1
    pattern = substr(pattern, 1, length(pattern) - 1)
  }

  is_anchored = 0
  if (substr(pattern, 1, 1) == "/") {
    is_anchored = 1
    pattern = substr(pattern, 2)
  } else if (index(pattern, "/") > 0) {
    is_anchored = 1
  }

  regex = glob_to_regex(pattern)
  full_regex = "^" root
  if (!is_anchored) full_regex = full_regex "(.*/)?"
  full_regex = full_regex regex
  if (dir_only) full_regex = full_regex "(/.*)?$"
  else full_regex = full_regex "(/.*)?$"

  if (type == "IGNORE") {
    i_roots[ic] = root; i_negs[ic] = is_neg; i_regex[ic] = full_regex
    ic++
  } else {
    p_roots[pc] = root; p_regex[pc] = full_regex
    pc++
  }
  next
}

# --- PHASE 2: Process Paths ---
{
  raw_line = $0
  
  # 1. Фильтр: Игнорируем директории (оканчиваются на /)
  if (substr(raw_line, length(raw_line)) == "/") next

  # 2. Фильтр: Игнорируем корневую точку (текущую директорию)
  if (raw_line == "." || raw_line == "./") next

  # Обработка ссылок: берем только путь до стрелки
  idx = index(raw_line, " -> ")
  if (idx > 0) {
    path = substr(raw_line, 1, idx - 1)
  } else {
    path = raw_line
  }

  sub(/^\.\//, "", path)

  # 3. Check IGNORE
  ignored = 0
  for (i = 0; i < ic; i++) {
    if (index(path, i_roots[i]) == 1) {
      if (path ~ i_regex[i]) {
        ignored = (i_negs[i] == 0) ? 1 : 0
      }
    }
  }
  if (ignored) next

  # 4. Check PROTECT
  protected = 0
  for (i = 0; i < pc; i++) {
    if (index(path, p_roots[i]) == 1) {
      if (path ~ p_regex[i]) {
        protected = 1
        break 
      }
    }
  }

  # 5. Classify & Rank
  rank = 4
  type = "CONTENT"

  if (path ~ /^dds\/specs\/__.*\.spec\..*/) {
    rank = 1
    type = "MANIFEST"
  } else if (path ~ /^dds\/specs\/_.*\.spec\..*/) {
    rank = 2
    type = "META"
  } else if (path ~ /^dds\/specs\/.*\.spec\..*/) {
    rank = 3
    type = "SPEC"
  }

  if (rank == 1) protected = 1

  # 6. Format Output
  prefix_str = type
  if (protected) prefix_str = prefix_str " PROTECTED"
  
  print rank "\t" prefix_str ": " path
}
'

# --- Execution ---

collect_rules() {
  find . -name ".ddsignore" -o -name ".ddsprotect" 2>/dev/null | \
  while read -r file; do
    base=$(basename "$file")
    if [ "$base" = ".ddsprotect" ]; then type="PROTECT"; else type="IGNORE"; fi
    dir=$(dirname "$file")
    while IFS= read -r line || [ -n "$line" ]; do
      clean_line=$(printf "%s" "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      if [ -n "$clean_line" ]; then
        printf "%s\t%s\t%s\n" "$type" "$dir" "$clean_line"
      fi
    done < "$file"
  done
}

tmp_dir="${TMPDIR:-/tmp}"
tmp_rules="$tmp_dir/dds_rules_$$.tmp"
trap 'rm -f "$tmp_rules"' EXIT

collect_rules > "$tmp_rules"

tree_args="--plain"
if [ "$SHOW_ALL" -eq 1 ]; then
  tree_args="$tree_args --all"
fi

eval set -- "$TARGET_PATHS"

"$DDS_TREE" $tree_args "$@" | \
awk -F"\t" "$awk_script" "$tmp_rules" - | \
sort -k1,1n -k2 | \
cut -f2-
