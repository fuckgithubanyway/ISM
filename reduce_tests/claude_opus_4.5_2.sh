#!/bin/sh
# reduce_arrays.sh - Reduce literal arrays in source code
# POSIX-compatible script

MIN_ELEMENTS=8
KEEP_START=3
KEEP_END=3
SHOW_STATS=1

trap 'rm -f /tmp/reduce_arrays.$.*' EXIT INT TERM

process_code() {
    awk -v min_elem="$MIN_ELEMENTS" \
        -v keep_start="$KEEP_START" \
        -v keep_end="$KEEP_END" \
        -v show_stats="$SHOW_STATS" '
    function bracket_depth(str,    i, c, depth, in_str, qch, prev) {
        depth = 0
        in_str = 0
        for (i = 1; i <= length(str); i++) {
            c = substr(str, i, 1)
            prev = (i > 1) ? substr(str, i - 1, 1) : ""
            if (!in_str) {
                if (c == "\"" || c == "\047") { in_str = 1; qch = c }
                else if (c == "[" || c == "(" || c == "{") depth++
                else if (c == "]" || c == ")" || c == "}") depth--} else if (c == qch && prev != "\\") {
                in_str = 0
            }
        }
        return depth
    }
    
    function is_reducible_content(content,    tmp, lit_count) {
        tmp = content
        if (index(tmp, ",") == 0) return 0
        
        lit_count = 0
        lit_count += gsub(/"[^"]*"/, "@S@", tmp)
        lit_count += gsub(/\047[^\047]*\047/, "@S@", tmp)
        lit_count += gsub(/-?[0-9]+\.[0-9]*([eE][+-]?[0-9]+)?[fFdDlL]?/, "@N@", tmp)
        lit_count += gsub(/-?[0-9]*\.[0-9]+([eE][+-]?[0-9]+)?[fFdDlL]?/, "@N@", tmp)
        lit_count += gsub(/-?[0-9]+[eE][+-]?[0-9]+[fFdDlL]?/, "@N@", tmp)
        lit_count += gsub(/0[xX][0-9a-fA-F_]+[uUlL]*/, "@N@", tmp)
        lit_count += gsub(/0[bB][01_]+[uUlL]*/, "@N@", tmp)
        lit_count += gsub(/0[oO][0-7_]+[uUlL]*/, "@N@", tmp)
        lit_count += gsub(/-?[0-9_]+[uUlL]*/, "@N@", tmp)
        lit_count += gsub(/:[a-zA-Z_][a-zA-Z0-9_]*/, "@Y@", tmp)
        gsub(/[ \t\n,@SNY]/, "", tmp)
        
        return (lit_count >= 3 && length(tmp) < lit_count * 3)
    }
    
    function is_type_bracket(str, pos,    before, after, chunk) {
        before = substr(str, 1, pos - 1)
        after = substr(str, pos)
        
        if (match(after, /^\[\][a-zA-Z]/)) return 1
        if (match(before, /[a-zA-Z_][a-zA-Z0-9_<>]*[ \t]*$/) && match(after, /^\[\]([^=]|$)/)) return 1
        
        chunk = substr(str, pos, 30)
        if (match(chunk, /^\[[a-zA-Z_][a-zA-Z0-9_]*[ \t]*;[ \t]*[0-9]+\]/)) return 1
        if (match(chunk, /^\[[A-Z][a-zA-Z0-9]*\][ \t]*=/)) return 1
        if (match(before, /<[ \t]*$/) && match(chunk, /^\[[A-Z][a-zA-Z0-9]*\][ \t]*>/)) return 1
        
        return 0
    }
    
    function get_bracket_content(str, pos,    open_ch, close_ch, depth, i, c, content, in_str, qch, prev) {
        open_ch = substr(str, pos, 1)
        if (open_ch == "[") close_ch = "]"
        else if (open_ch == "(") close_ch = ")"
        else if (open_ch == "{") close_ch = "}"
        else return ""
        
        depth = 0
        content = ""
        in_str = 0
        
        for (i = pos; i <= length(str); i++) {
            c = substr(str, i, 1)
            prev = (i > 1) ? substr(str, i - 1, 1) : ""
            
            if (!in_str) {
                if (c == "\"" || c == "\047") { in_str = 1; qch = c }
                else if (c == open_ch) depth++
                else if (c == close_ch) {
                    depth--
                    if (depth == 0) return content
                }
            } else if (c == qch && prev != "\\") {
                in_str = 0
            }
            if (depth >= 1 && i > pos) content = content c
        }
        return content
    }
    
    function find_bracket_end(str, pos,    open_ch, close_ch, depth, i, c, in_str, qch, prev) {
        open_ch = substr(str, pos, 1)
        if (open_ch == "[") close_ch = "]"
        else if (open_ch == "(") close_ch = ")"
        else if (open_ch == "{") close_ch = "}"
        else return pos
        
        depth = 0
        in_str = 0
        
        for (i = pos; i <= length(str); i++) {
            c = substr(str, i, 1)
            prev = (i > 1) ? substr(str, i - 1, 1) : ""
            
            if (!in_str) {
                if (c == "\"" || c == "\047") { in_str = 1; qch = c }
                else if (c == open_ch) depth++
                else if (c == close_ch) {
                    depth--
                    if (depth == 0) return i
                }
            } else if (c == qch && prev != "\\") {
                in_str = 0
            }
        }
        return length(str)
    }
    
    function split_elements(content, arr,    n, i, c, elem, in_str, qch, prev, depth) {
        n = 0
        elem = ""
        in_str = 0
        depth = 0
        
        for (i = 1; i <= length(content); i++) {
            c = substr(content, i, 1)
            prev = (i > 1) ? substr(content, i - 1, 1) : ""
            
            if (!in_str) {
                if (c == "\"" || c == "\047") {
                    in_str = 1
                    qch = c
                    elem = elem c
                } else if (c == "[" || c == "(" || c == "{") {
                    depth++
                    elem = elem c
                } else if (c == "]" || c == ")" || c == "}") {
                    depth--
                    elem = elem c
                } else if (c == "," && depth == 0) {
                    gsub(/^[ \t\n]+|[ \t\n]+$/, "", elem)
                    if (elem != "") arr[n++] = elem
                    elem = ""
                } else {
                    elem = elem c
                }
            } else {
                elem = elem cif (c == qch && prev != "\\") in_str = 0
            }
        }
        gsub(/^[ \t\n]+|[ \t\n]+$/, "", elem)
        if (elem != "") arr[n++] = elem
        return n
    }
    
    function reduce_array(buf, pos,    content, n, elements, j, reduced_n, reduced_b, open_ch, close_ch, result, kb, frac) {
        open_ch = substr(buf, pos, 1)
        if (open_ch == "[") { close_ch = "]" }
        else if (open_ch == "(") { close_ch = ")" }
        else { close_ch = "}" }
        
        content = get_bracket_content(buf, pos)
        n = split_elements(content, elements)
        
        result = open_ch
        for (j = 0; j < keep_start && j < n; j++) {
            if (j > 0) result = result ", "
            result = result elements[j]
        }
        
        reduced_n = n - keep_start - keep_end
        reduced_b = 0
        for (j = keep_start; j < n - keep_end; j++) {
            reduced_b += length(elements[j]) + 2
        }
        
        if (show_stats) {
            if (reduced_b >= 1024) {
                kb = int(reduced_b / 1024)
                frac = int((reduced_b % 1024) * 10 / 1024)
                result = result ", .... REDUCED [" reduced_n " el, " kb "." frac "KiB] ...."
            } else {
                result = result ", .... REDUCED [" reduced_n " el, " reduced_b "B] ...."
            }
        } else {
            result = result ", .... REDUCED ...."
        }
        
        for (j = n - keep_end; j < n; j++) {
            result = result ", " elements[j]
        }
        result = result close_ch
        
        return result
    }
    
    function process_buffer(buf,    i, c, content, n, elements, result, end_pos, skip_to, did_reduce) {
        result = ""
        skip_to = 0
        
        for (i = 1; i <= length(buf); i++) {
            if (i < skip_to) continue
            
            c = substr(buf, i, 1)
            did_reduce = 0
            
            if (c == "[" || c == "(" || c == "{") {
                if (!is_type_bracket(buf, i)) {
                    content = get_bracket_content(buf, i)
                    if (is_reducible_content(content)) {
                        n = split_elements(content, elements)
                        if (n >= min_elem) {
                            result = result reduce_array(buf, i)
                            skip_to = find_bracket_end(buf, i) + 1
                            did_reduce = 1
                        }
                    }
                }
            }
            
            if (!did_reduce) {
                result = result c
            }
        }
        return result
    }
    
    {
        if (buffer != "") {
            buffer = buffer "\n" $0
        } else {
            buffer = $0
        }
        
        depth = bracket_depth(buffer)
        
        if (depth <= 0) {
            print process_buffer(buffer)
            buffer = ""
        }
    }
    
    END {
        if (buffer != "") {
            print process_buffer(buffer)
        }
    }
    '
}

show_help() {
    cat << 'EOF'
Usage: reduce_arrays.sh [OPTIONS] [FILE]

Reduce literal arrays in source code.

Options:
  -m, --min-elements NMinimum elements for reduction (default: 8)
  -s, --keep-start N     Elements to keep at start (default: 3)
  -e, --keep-end N       Elements to keep at end (default: 3)
  -q, --quiet            Don't show stats in marker
  -h, --help             Show this help
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        -m|--min-elements) MIN_ELEMENTS="$2"; shift 2 ;;
        -s|--keep-start) KEEP_START="$2"; shift 2 ;;
        -e|--keep-end) KEEP_END="$2"; shift 2 ;;
        -q|--quiet) SHOW_STATS=0; shift ;;
        -h|--help) show_help; exit 0 ;;
        --) shift; break ;;
        -*) echo "Unknown option: $1" >&2; exit 1 ;;
        *) break ;;
    esac
done

if [ $# -eq 0 ] || [ "$1" = "-" ]; then
    cat | process_code
elif [ -f "$1" ]; then
    process_code < "$1"
else
    echo "Error: file not found: $1" >&2
    exit 1
fi
