#!/usr/bin/env bash


argc=$#
argv=()

for parameter in $@; do
    argv[${#argv[@]}]=$parameter
done

deter_unix_time() {
    var=$1

    if [ -n "$var" ] && [ "$var" -eq "$var" ] 2>/dev/null && [ 0 -le $var ]; then
        exit_value=0
    else
        exit_value=1
    fi

    return $exit_value
}

deter_para() {
    if [[ (! ${argv[0]} == "-s" || ! ${argv[2]} == "-e") && (! ${argv[0]} == "-e" || ! ${argv[2]} == "-s") ]]; then
        echo "usage: ./p1.sh -s <Unix timestamp > -e <Unix timestamp > <input file>"
        exit 
    elif [[ ${#argv[@]} -lt 5 || ${#argv[@]} -gt 7 ]]; then
        echo "usage: ./p1.sh -s <Unix timestamp > -e <Unix timestamp > <input file>"
        exit 
    elif ! deter_unix_time ${argv[1]} || ! deter_unix_time ${argv[3]} ; then
        echo "usage: ./p1.sh -s <Unix timestamp > -e <Unix timestamp > <input file>"
        exit 
    fi
}

read_file() {
    filename=$1
    exec < $filename
    while read line 
    do
        real_time=$(echo $line | cut -d "]" -f 1 | cut -d "[" -f 2)
        timestamp=$(date -d "$real_time" +%s)
        if [[ $timestamp -ge ${argv[1]} && $timestamp -le ${argv[3]} ]]; then
             array[${#array[@]}]=$(printf "%020d %s\n" "$timestamp" "${line:27:100}")
        fi
    done
}

deter_para

if [[ ${argv[0]} == "-e" ]]; then
    tmp=${argv[1]}
    argv[1]=${argv[3]}
    argv[3]=$tmp
fi

if [[ ${argv[1]} -gt ${argv[3]} ]]; then
    echo "usage: ./p1.sh -s <Unix timestamp > -e <Unix timestamp > <input file>"
    exit
fi

array=()

for ((i=4;i<${#argv[@]};i++)); do
    read_file ${argv[i]}
done


IFS=$'\n' LC_ALL=C sorted=($(sort <<<"${array[*]}"))

if [[ ${#sorted[@]} -gt 0 ]]; then
    # printf "%s\n" "${sorted[@]}"
    for str in ${sorted[@]}
    do
        t=$(echo ${str:1:19} | bc)
        tmp=$(echo $str | cut -d "[" -f 2)
        printf "%d %s\n" "$t" "[$tmp"
    done
fi