#!/usr/bin/env bash

problem_id=$1
file_name=$2

header1="------ JudgeGuest ------"
header2="Problem ID: "
header3="Test on: "
header4="------------------------"

mkdir tmp

for (( i=0;i<1000;i++)); do
    wget --no-check-certificate https://judgegirl.csie.org/downloads/testdata/${problem_id}/$i.in -O ./tmp/$i.in &>> ./tmp/log
    wget --no-check-certificate https://judgegirl.csie.org/downloads/testdata/${problem_id}/$i.out -O ./tmp/$i.out &>> ./tmp/log
    if [[ $? -ne 0 ]]; then
        rm -f ./tmp/$i.in ./tmp/$i.out
        break;
    fi
done

echo $header1
echo $header2 $problem_id
echo $header3 $file_name
echo $header4

gcc ${file_name} -O0 -o ./tmp/a.out &>> ./tmp/log


if [[ $? -ne 0 ]]; then
    echo "Compile Error"
else
    for (( i=0; i<1000 ; i++)); do
        if [[ -e ./tmp/$i.in ]]; then
            cp ./tmp/$i.in ./tmp/file.in
            timeout 1 bash -c './tmp/a.out < ./tmp/file.in > ./tmp/file.out'
            
            if [[ $? -ne 0 ]]; then
                echo "$i        Time Limit Exceeded"
                continue;
            fi

            diff ./tmp/file.out ./tmp/$i.out &>> ./tmp/log
            if [[ $? -ne 0 ]]; then
                echo "$i        Wrong Answer"
            else
                echo "$i        Accepted"
            fi
        else
            break;
        fi
    done
fi

rm -rf tmp