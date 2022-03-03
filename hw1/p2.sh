#!/usr/bin/env bash

layer=1000000
all=0
rev=0
dont_follow_sym=0
myflag=${@:2:100}
find_include=0
stack=()
declare -A dict
end=0

traverse() {
    # echo $1 $2 $3
    if [[  $3 -gt $layer ]]; then
        return 0
    fi

    local directory=$1
    local prefix=$2
    local return_val=0

    if [[ $all -eq 0 ]]; then
        local children=(`ls $directory | LC_ALL=C sort`)
    else
        local children=(`ls -a $directory | LC_ALL=C sort`)        
    fi

    local child_count=${#children[@]}

    if [ $rev -eq 1 ]; then
        for ((i=0, j=$(($child_count - 1));$j > $i;i++, j--)); do
            local tmp=${children[$i]}
            children[$i]=${children[$j]}
            children[$j]=$tmp
        done
    fi

    for idx in ${!children[@]} 
    do 
        local child="${children[$idx]##*/}"
        local inode_num=$(stat -L -c '%i' "$directory/$child")

        if [ $child = "." ] ; then
            continue
        elif [ $child = ".." ]; then
            continue
        fi        

        if [ -d "$directory/$child" ]; then
            local type=`file "$directory/$child" | cut -d ' ' -f 2`
            if [ $type = "symbolic" ] ; then
                if [[ $dont_follow_sym -eq 1 ]]; then
                    local sym_path=`file "$directory/$child" | cut -d ' ' -f 5`
                    stack_push "${prefix} $child -> $sym_path"
                    flag_i $find_include $include $child 1 1
                else
                    dict_find_key $inode_num
                    if [[ $? -eq 0 ]]; then
                        stack_push "$prefix $child"
                        dict_add_key $inode_num
                        traverse "$directory/$child" "$prefix---" $(( $3 + 1 ))
                        flag_i $find_include $include $child 0 $?
                        return_val=$(($return_val || $?))
                        dict_rm_key $inode_num
                    else
                        if [[ $3 -eq $layer ]]; then
                            stack_push "$prefix $child"
                            flag_i $find_include $include $child 1 1
                        else
                            stack_push "$prefix $child (loop)"
                            flag_i $find_include $include $child 1 1
                        fi
                    fi
                fi
            else
                dict_find_key $inode_num
                if [[ $? -eq 0 ]]; then
                    stack_push "$prefix $child" 
                    dict_add_key $inode_num
                    traverse "$directory/$child" "$prefix---" $(( $3 + 1 ))
                    flag_i $find_include $include $child 0 $?
                    return_val=$(($return_val || $?))
                    dict_rm_key $inode_num
                else
                    if [[ $3 -eq $layer ]]; then
                        stack_push "$prefix $child"
                        flag_i $find_include $include $child 1 1
                    else
                        stack_push "$prefix $child (loop)"
                        flag_i $find_include $include $child 1 1
                    fi
                fi
            fi
        else
            stack_push "$prefix $child"
            flag_i $find_include $include $child 1 1
        fi
        return_val=$(($return_val || $?))

    done
    echo $1 $2 $3 $return_val
    return $return_val

}

dict_add_key() {
    dict[$1]=1
}

dict_rm_key() {
    unset dict[$1]
}

dict_find_key() {
    if [[ -v dict[$1] ]]; then
        return 1
    else
        return 0
    fi
}

stack_pop() {
    if [[ $end -gt 0 ]]; then
        end=$(($end - 1))
    fi
}

stack_push() {
    stack[$end]="$1"
    end=$(($end + 1))
}

find_substr() {
    if [[ "$2" == *"$1"* ]]; then
        return 1
    else
        return 0
    fi
}

flag_i() {
    echo $3 $4 $5
    if [[ $4 -eq 1 ]]; then
        if [[ $1 -eq 1 ]]; then
            find_substr $2 $3
            if [[ $? -eq 1 ]]; then
                return 1
            else
                stack_pop
                return 0
            fi
        else
            return 1
        fi
    else
        if [[ $1 -eq 1 ]]; then
            find_substr $2 $3
            if [[ $? -eq 1 || $5 -eq 1 ]]; then
                return 1
            else
                stack_pop
                return 0
            fi
        else
            return 1
        fi
    fi
}

while getopts l:ari:s flag ${myflag}; do
    case "${flag}" in
        l) layer=${OPTARG};;
        a) all=1;;
        r) rev=1;;
        i) include=${OPTARG}
            find_include=1;;
        s) dont_follow_sym=1;;
    esac
done

[ $1 ] && path=$1 || path="."

stack_push $path
tmp=$(stat -L -c '%i' "$path")
dict_add_key $tmp

traverse $path "|" 0

for ((i=0;i<$end;i++)); do
    echo ${stack[i]}
done