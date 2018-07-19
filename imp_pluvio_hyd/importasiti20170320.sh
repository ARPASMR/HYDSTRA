#dir="C:\lavlinux\imp_pluvio_hyd" #Directory corrente
dir="C:\Users\mranci\Documents\HYDSTRA\imp_pluvio_hyd" #Directory corrente


#dos2unix intervallo.txt 

{
read bs
read bs mi hi ggi mmi aai bs
read bs mf hf ggf mmf aaf bs
read bs F_siti
read bs HYD_source
read bs HYD_var
read bs F_qual
}< intervallo.txt

#dos2unix $F_siti


{

read bs n

for (( i=1; i<=n; i++ ))
do
	read SITE[$i] ID_SITE[$i] 
	echo " nome sito " $i ${SITE[$i]} ${ID_SITE[$i]}
done

}< ${F_siti}



{

read bs nq
for (( ii=1; ii<=nq; ii++ ))
do
	read Qual_REM[$ii] Qual_HYD[$ii] 
	echo " codici qualità " $ii ${Qual_REM[$ii]} ${Qual_HYD[$ii]}
done

}< ${F_qual}


{
for (( i=1; i<=n; i++ ))
do
	echo "R	${ID_SITE[$i]}	${aai}/$mmi/$ggi $hi:$mi	$aaf/$mmf/$ggf $hf:$mf"

done
} > ./estrattore/In/Richiesta.txt

#unix2dos estrattore/In/Richiesta.txt


rm ./estrattore/Out/*.*
cd ./estrattore
./EstrazioneDati.exe
cd ./Out
#dos2unix *.txt


for (( i=1; i<=n; i++ ))
do
		chmod a+wrx ${ID_SITE[$i]}_R_4.txt
		echo processing site ${SITE[$i]} ${ID_SITE[$i]}
		awk '{ print ($5)}' ${ID_SITE[$i]}_R_4.txt > ${SITE[$i]}_qual.tmp 
		for (( ii=1; ii<=nq; ii++ ))
		do
			sed -i "s/^${Qual_REM[$ii]}$/${Qual_HYD[$ii]}/g" ${SITE[$i]}_qual.tmp
		done
		dos2unix ${ID_SITE[$i]}_R_4.txt
		paste ${ID_SITE[$i]}_R_4.txt ${SITE[$i]}_qual.tmp > ${SITE[$i]}_completo.tmp
		awk '{ printf ("%6.f %-10s %-12s %8.2f %3.f \n", $1, $2, $3, $4, $6)}' ${SITE[$i]}_completo.tmp > ${SITE[$i]}_HYD.tmp
		unix2dos  ${SITE[$i]}_HYD.tmp
		
done



for (( i=1; i<=n; i++ ))
do
		echo "${SITE[$i]} ${HYD_source} ${HYD_var} 1 TOT 1.00000000 0.00000000 ERASE 0 ${dir}\ESTRATTORE\OUT\\${SITE[$i]}_HYD.tmp ${dir}\template_hyd_import.txt DEFAULT REPORT.TXT" > ${SITE[$i]}.PRM
		echo "start /w H:\Prod\hyd\sys\run\HYCREATE.exe @${dir}\estrattore\Out\\${SITE[$i]}.PRM" > a.bat
		chmod +x a.bat
		unix2dos a.bat *.PRM
		./a.bat
#		rm *.PRM
done
#rm *.tmp a.bat
