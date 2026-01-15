#!/bin/sh

awk '
function trim(s) {
    gsub(/^[ \t\n]+/, "", s);
    gsub(/[ \t\n]+$/, "", s);
    return s;
}

function is_number(s) {
    if (s ~ /^[-+]?0[xX][0-9a-fA-F]+[uUlL]*$/) return 1;
    if (s ~ /^[-+]?0[bB][01]+[uUlL]*$/) return 1;
    if (s ~ /^[-+]?[0-9]+[uUlL]*$/) return 1;
    if (s ~ /^[-+]?([0-9]*\.[0-9]+|[0-9]+\.?)([eE][-+]?[0-9]+)?[fFdDlL]*$/) return 1;
    return 0;
}

function is_base64(s) {
    if (s ~ /^["\047][A-Za-z0-9+\/=]+["\047]$/) return 1;
    return 0;
}

function is_reducible_elem(s) {
    return is_number(s) || is_base64(s);
}

{ full = full $0 "\n"; }

END {
    i = 1;
    output = "";
    len = length(full);
    while (i <= len) {
        ch = substr(full, i, 1);
        if (ch == "[" || ch == "(" || ch == "{") {
            start = i;
            bracket = ch;
            endbracket = (ch == "[") ? "]" : ((ch == "(") ? ")" : "}");
            depth = 1;
            j = i + 1;
            while (j <= len && depth > 0) {
                chj = substr(full, j, 1);
                if (chj == bracket) depth++;
                else if (chj == endbracket) depth--;
                j++;
            }
            if (depth == 0) {
                array_len = j - start;
                array_str = substr(full, start, array_len);
                # Extract elements
                num_elems = 0;
                delete elems_arr;
                k = 2;  # after opening bracket
                while (k < array_len) {
                    # Skip whitespace
                    while (k < array_len && substr(array_str, k, 1) ~ /[ \t\n]/) k++;
                    if (substr(array_str, k, 1) == endbracket) break;
                    # Parse element (handling nested brackets and strings)
                    elem_start = k;
                    elem_depth = 0;
                    in_string = 0;
                    while (k < array_len) {
                        ch_k = substr(array_str, k, 1);
                        if (in_string == 0 && ch_k == "\"") in_string = 1;
                        else if (in_string == 1 && ch_k == "\"") in_string = 0;
                        else if (in_string == 0) {
                            if (ch_k == "(" || ch_k == "[" || ch_k == "{") elem_depth++;
                            else if (ch_k == ")" || ch_k == "]" || ch_k == "}") elem_depth--;
                            if (ch_k == "," && elem_depth == 0) break;
                        }
                        k++;
                    }
                    elem = substr(array_str, elem_start, k - elem_start);
                    num_elems++;
                    elems_arr[num_elems] = elem;
                    if (substr(array_str, k, 1) == ",") k++;
                }
                # Check if reducible
                all_good = 1;
                for (m = 1; m <= num_elems; m++) {
                    trimmed = trim(elems_arr[m]);
                    if (!is_reducible_elem(trimmed)) {
                        all_good = 0;
                        break;
                    }
                }
                if (all_good && num_elems > 6) {
                    # Build reduced
                    reduced = bracket;
                    for (m = 1; m <= 3; m++) {
                        if (m > 1) reduced = reduced ", ";
                        reduced = reduced trim(elems_arr[m]);
                    }
                    reduced = reduced ", .... REDUCED .... ";
                    reduced = reduced trim(elems_arr[num_elems-2]);
                    for (m = num_elems-1; m <= num_elems; m++) {
                        reduced = reduced ", " trim(elems_arr[m]);
                    }
                    reduced = reduced endbracket;
                    output = output reduced;
                } else {
                    output = output array_str;
                }
                i = j;
                continue;
            }
        }
        output = output ch;
        i++;
    }
    printf "%s", output;
}'
