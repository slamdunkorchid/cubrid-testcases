set -x
for file in `find ./ -name "*.ctl"`
do
    grep -ri 'C[0-9]: create index' $file|sed "s/;//g" >a.txt
    sort -n a.txt |uniq >b.txt 
	while read line
	do
		if [ x"$line" != x"" ]
		then
		sed -i "s#$line#${line} with online parallel 2#g" $file
			if [ $? -ne 0 ]
			then
			   break
			   
			fi
		fi
	done<b.txt
done

