ord() {
  LC_CTYPE=C printf '%d' "'$1"
}

compare_str() {
    local ret=0
    local min=0
    local flag=0
    if [[ ${#1} < ${#2} ]]; then
        min=${#1}
        ret=0
    else 
        min=${#2}
        ret=1
    fi
    for ((i=0;i<min;i++)); do
        local a=$(ord ${1:$i:1})
        local b=$(ord ${2:$i:1})
        if [[ $a -lt $b ]]; then
            return 0
        elif [[ $a -gt $b ]]; then
            return 1
        fi
    done

    return $ret
}

str1="123"
str2=".567"
compare_str $str1 $str2

echo $?
