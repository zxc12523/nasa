myvar='Généralia56ds1f65a1df65a1tés'
chrlen=0123
oLang=$LANG oLcAll=$LC_ALL
LANG=C LC_ALL=C
bytlen=${#myvar}
LANG=$oLang LC_ALL=$oLcAll
printf "%s is %d char len, but %d bytes len.\n" "${myvar}" $chrlen $bytlen

d1=00123
d2=0

echo "$d1 - $d2" | bc