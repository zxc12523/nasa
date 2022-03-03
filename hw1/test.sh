declare -A animals=( ["moo"]="cow" ["woof"]="dog")

echo ${animals["moo"]}
if [[ ${animals["coo"]} == "" ]]; then
    echo empty
fi
animals[coo]=123
echo ${animals[coo]}
if [[ ${animals["coo"]} == "" ]]; then
    echo empty
fi