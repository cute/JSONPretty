#!/bin/sh
# Based: https://github.com/dominictarr/JSON.sh

tabs=""
indent=0
newline="
"

throw () {
    echo "$*" >&2
    exit 1
}

gen_tabs () {
    if [ $indent -gt 0 ]; then
        tabs=`printf '%*s' "$indent" ' ' | tr ' ' "\t"`
    else
        tabs=''
    fi
}

tokenize () {
    local ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    local CHAR='[^[:cntrl:]"\\]'
    local STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
    local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
    local KEYWORD='null|false|true'
    local SPACE='[[:space:]]+'
    grep -E -ao "$STRING|$NUMBER|$KEYWORD|$SPACE|."|grep -E -v "^$SPACE$"
}

parse_array () {
    local index=0
    local ary="["
    read -r token
    case "$token" in
        ']') ;;
        *)
            while :
            do
                parse_value "$1" "$index"
                index=`expr $index + 1`
                ary="$ary$value"
                read -r token
                case "$token" in
                    ']') break ;;
                    ',') ary="$ary," ;;
                    *) throw "EXPECTED , or ] GOT ${token:-EOF}" ;;
                esac
                read -r token
            done
            ;;
    esac
    value="$ary]"
}

parse_object () {
    gen_tabs
    local key
    local obj="{$newline"
    read -r token
    case "$token" in
        '}') ;;
        *)
            while :
            do
                case "$token" in
                    '"'*'"') key=$token ;;
                    *) throw "EXPECTED string GOT ${token:-EOF}" ;;
                esac
                read -r token
                case "$token" in
                    ':') ;;
                    *) throw "EXPECTED : GOT ${token:-EOF}" ;;
                esac
                read -r token
                parse_value "$1" "$key"
                obj="$obj$tabs$key:$value"
                read -r token
                case "$token" in
                    '}')
                        indent=`expr $indent - 1`;
                        gen_tabs
                        obj="$obj$newline$tabs"
                        break ;;
                    ',')
                        obj="$obj,$newline" ;;
                    *) throw "EXPECTED , or } GOT ${token:-EOF}" ;;
                esac
                read -r token
            done
            ;;
    esac
    value="$obj}"
}

parse_value () {
    local expr="${1:+$1,}$2"
    gen_tabs
    case "$token" in
        '{')
            indent=`expr $indent + 1`;
            parse_object "$expr" ;;
        '[')
            parse_array  "$expr" ;;
        ''|[^0-9]) throw "EXPECTED value GOT ${token:-EOF}" ;;
        *) value=$token ;;
    esac
}

parse () {
    read -r token
    parse_value
    echo "$value"
    read -r token
    case "$token" in
        '') ;;
        *) throw "EXPECTED EOF GOT $token" ;;
    esac
}

tokenize | parse
