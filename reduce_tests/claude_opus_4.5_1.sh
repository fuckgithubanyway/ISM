#!/bin/sh
# reduce_arrays.sh - Reduce literal arrays in source code
# POSIX-compatible script

# Configuration
MIN_ELEMENTS=8
KEEP_START=3
KEEP_END=3
SHOW_STATS=1

# Cleanup on exit
TMPFILE="${TMPDIR:-/tmp}/reduce_arrays.$"
trap 'rm -f "$TMPFILE" "$TMPFILE".*' EXIT INT TERM

# Main AWK processor
process_code() {
    awk -v min_elem="$MIN_ELEMENTS" \-v keep_start="$KEEP_START" \
        -v keep_end="$KEEP_END" \
        -v show_stats="$SHOW_STATS" '
    # Check if content looks like data literals (not type annotations)
    function is_data_content(content,    tmp, num_count) {
        tmp = content
        
        # Must have commas
        if (index(tmp, ",") == 0) return 0
        
        # Count numeric/string literals
        num_count = 0
        # Floats with suffix
        num_count += gsub(/-?[0-9]+\.[0-9]*([eE][+-]?[0-9]+)?[fFdDlL]?/, "@", tmp)
        # Integers with suffix  
        num_count += gsub(/-?[0-9]+[uUlL]*/, "@", tmp)
        # Hex
        num_count += gsub(/0[xX][0-9a-fA-F]+[uUlL]*/, "@", tmp)
        # Binary
        num_count += gsub(/0[bB][01]+[uUlL]*/, "@", tmp)
        # Strings
        num_count += gsub(/"[^"]*"/, "@", tmp)
        num_count += gsub(/\047[^\047]*\047/, "@", tmp)
        
        return (num_count >=3)
    }
    
    # Check if bracket is part of type annotation
    function is_type_bracket(str, pos,    before, after, chunk) {
        before = substr(str, 1, pos - 1)
        after = substr(str, pos)
        
        # Go style: []int, []float64 - empty brackets before type
        if (match(after, /^\[\][a-zA-Z]/)) return 1
        
        # Java/C style: int[], String[] - brackets after type name
        if (match(before, /[a-zA-Z_][a-zA-Z0-9_]*$/) && match(after, /^\[\]/)) return 1
        
        # Rust: [f64; 16] - type with size
        chunk = substr(str, pos, 20)
        if (match(chunk, /^\[[a-zA-Z][a-zA-Z0-9]*;[]*[0-9]+\]/)) return 1
        
        # Swift: [Int], [Double] - single capitalized type
        if (match(chunk, /^\[[A-Z][a-zA-Z]*\]([^,0-9]|$)/)) return 1
        
        return 0
    }
    
    # Extract content between balanced brackets starting at pos
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
    
    # Find end position of bracket group
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
    
    # Split comma-separated content into elements array
    function split_elements(content, arr,    n, i, c, elem, in_str, qch, prev, depth) {
        n = 0
        elem = ""
        in_str = 0
        depth = 0
        
        for (i = 1; i <= length(content); i++) {
            c = substr(content, i, 1)
            prev = (i > 1) ? substr(content, i - 1, 1) : ""
            
            if (!in_str) {
                if (c == "\"" || c == "\047") { in_str = 1; qch = c; elem = elem c }
                else if (c == "[" || c == "(" || c == "{") { depth++; elem = elem c }
                else if (c == "]" || c == ")" || c == "}") { depth--; elem = elem c }
                else if (c == "," && depth == 0) {
                    gsub(/^[ \t]+|[ \t]+$/, "", elem)
                    if (elem != "") arr[n++] = elem
                    elem = ""
                }
                else { elem = elem c }
            } else {
                elem = elem c
                if (c == qch && prev != "\\") in_str = 0
            }
        }
        gsub(/^[ \t]+|[ \t]+$/, "", elem)
        if (elem != "") arr[n++] = elem
        return n
    }
    
    # Process a single line
    function process_line(line,    i, c, pos, content, n, elements, prefix, suffix, result, j, reduced_n, reduced_b, open_ch, close_ch, end_pos) {
        result = ""
        i = 1
        
        while (i <= length(line)) {
            c = substr(line, i, 1)
            
            # Check for opening bracket
            if (c == "[" || c == "(" || c == "{") {
                # Skip if type annotation
                if (is_type_bracket(line, i)) {
                    result = result c
                    i++
                    continue
                }
                
                content = get_bracket_content(line, i)
                # Check if reducible
                if (is_data_content(content)) {
                    n = split_elements(content, elements)
                    
                    if (n >= min_elem) {
                        open_ch = c
                        if (c == "[") close_ch = "]"
                        else if (c == "(") close_ch = ")"
                        else close_ch = "}"
                        
                        # Build reduced version
                        result = result open_ch
                        for (j = 0; j < keep_start && j < n; j++) {
                            if (j > 0) result = result ", "
                            result = result elements[j]
                        }
                        # Stats
                        reduced_n = n - keep_start - keep_end
                        reduced_b = 0
                        for (j = keep_start; j < n - keep_end; j++) {
                            reduced_b += length(elements[j]) + 2
                        }
                        
                        if (show_stats) {
                            if (reduced_b >= 1024)
                                result = result ", .... REDUCED [" reduced_n " el, " int(reduced_b/1024) "KiB] ...."
                            else
                                result = result ", .... REDUCED [" reduced_n " el, " reduced_b "B] ...."
                        } else {
                            result = result ", .... REDUCED ...."
                        }
                        
                        for (j = n - keep_end; j < n; j++) {
                            result = result ", " elements[j]
                        }
                        result = result close_ch
                        
                        # Skip past the bracket group
                        end_pos = find_bracket_end(line, i)
                        i = end_pos + 1
                        continue
                    }
                }}
            
            result = result c
            i++
        }
        return result
    }
    
    # Main: process each line individually (preserve line structure)
    {
        print process_line($0)
    }
    '
}

# Help
show_help() {
    cat << 'EOF'
Usage: reduce_arrays.sh [OPTIONS] [FILE]

Reduce literal arrays in source code.
Reads from FILE or stdin, outputs to stdout.

Options:
  -m, --min-elements NMinimum elements to trigger reduction (default: 8)
  -s, --keep-start N     Elements to keep at start (default: 3)
  -e, --keep-end N       Elements to keep at end (default: 3)
  -q, --quiet            Don't show stats in marker
  -h, --help             Show this help

Examples:
  cat code.py | reduce_arrays.sh
  reduce_arrays.sh -m 10 source.c
  reduce_arrays.sh --quiet data.json
EOF
}

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -m|--min-elements) MIN_ELEMENTS="$2"; shift 2 ;;
        -s|--keep-start) KEEP_START="$2"; shift 2 ;;
        -e|--keep-end) KEEP_END="$2"; shift 2 ;;
        -q|--quiet) SHOW_STATS=0; shift ;;
        -h|--help) show_help; exit 0 ;;
        --) shift; break ;;
        -*) echo "Unknown option: $1" >&2; show_help>&2; exit 1 ;;
        *) break ;;
    esac
done

# Main
if [ $# -eq 0 ] || [ "$1" = "-" ]; then
    cat | process_code
elif [ -f "$1" ]; then
    process_code < "$1"
else
    echo "Error: file not found: $1" >&2
    exit 1
fi
