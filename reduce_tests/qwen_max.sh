#!/bin/sh
# POSIX-compliant array reduction script - STABLE VERSION
# Usage: ./qwen_max.sh [input_file]

MIN_ELEMENTS=6
KEEP_START=3
KEEP_END=3

# Read input
if [ $# -eq 1 ] && [ -f "$1" ]; then
    cat "$1"
else
    cat
fi | awk -v min_elements="$MIN_ELEMENTS" -v keep_start="$KEEP_START" -v keep_end="$KEEP_END" '
BEGIN {
    max_line_length = 10000  # Safety limit to prevent hangs
}

length($0) > max_line_length {
    print $0  # Skip very long lines to prevent hangs
    next
}

# Process simple square bracket arrays [1, 2, 3, ...]
{
    line = $0
    changed = 1
    
    # Process only one array per line to prevent hangs
    if (match(line, /\[[^][]*,[^][]*,[^][]*,[^][]*,[^][]*,[^][]*\]/)) {
        full_match = substr(line, RSTART, RLENGTH)
        content = substr(full_match, 2, length(full_match) - 2)
        
        # Count commas to estimate elements
        comma_count = 0
        temp = content
        while ((pos = index(temp, ",")) > 0) {
            comma_count++
            temp = substr(temp, pos + 1)
        }
        element_count = comma_count + 1
        
        if (element_count >= min_elements) {
            # Simple split by commas
            split(content, elements, ",")
            
            # Build start part
            start_part = ""
            for (i = 1; i <= keep_start && i <= length(elements); i++) {
                if (start_part != "") start_part = start_part ", "
                start_part = start_part elements[i]
            }
            
            # Build end part
            end_part = ""
            start_idx = length(elements) - keep_end + 1
            if (start_idx < 1) start_idx = 1
            
            for (i = start_idx; i <= length(elements); i++) {
                if (end_part != "") end_part = end_part ", "
                gsub(/^[ \t]+|[ \t]+$/, "", elements[i])  # Trim whitespace
                end_part = end_part elements[i]
            }
            
            replacement = "[" start_part ", .... REDUCED ...., " end_part "]"
            line = substr(line, 1, RSTART-1) replacement substr(line, RSTART+RLENGTH)
        }
    }
    print line
}
'
