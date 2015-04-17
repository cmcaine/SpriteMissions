#!/bin/bash

templatefile=cfg.template
#
# The following are the values to be replaced in the file:
#
#	<CONTRACT_NAME>
#	<CONTRACT_TITLE>
#	<DESCRIPTION>
#	<SYNOPSIS>
#	<PRESTIGE>
#	<TARGETBODY>
#	<SCIENCE>
#	<REPUTATION>
#	<REWARD_FUNDS>
#	<VESSEL>
#	<TARGETBODY>


#targets (T1, T2...)
#	contract name = Visit-T1-T2
#	contract title = "Land on t1, t2 and return"
#description = Do a round trip to T1, T2.., land on each and return safely to Kerbin
#difficulty = 1-5, translated to:  easy/somewhat difficult/very difficult/extremely difficult/a nightmare
#Notes =  copied from notes.txt
#
#synopsis = "This is (difficulty text). Do a roundtrip to T1,T2"
#prestige = difficulty 1 = Trivial, 2 = Significant, all other Exceptional
#reputation = 20 * difficulty level
#rewardfunds = difficultylevel squared * 10000
#vessel = "Sprite - Light SSTO Dropship (T).craft", "Sprite - Light SSTO Dropship.craft", "Sprite - Light SSTO Dropship (R).craft"

difficultyText=(
	"easy"
	"somewhat difficult"
	"very difficult"
	"extremely difficult"
	"a nightmare"
)
prestigeText=(
	"Trivial"
	"Significant"
	"Exceptional"
	"Exceptional"
	"Exceptional"
)

vesselURL=("Sprite - Light SSTO Dropship (T).craft" "Sprite - Light SSTO Dropship.craft" "Sprite - Light SSTO Dropship (R).craft")


#difficulty,ships (123),target(s)
missions=(
	"1,123,Minmus"
	"1,123,Mun"
	"2,123,Mun,Minmus"
	"2,123,Duna,orbit"
	"3,123,Laythe"
	"4,123,Duna"
	"5,123,Duna,Ike"
	"5,123,Eve,Gilly"
)

numMissions=${#missions[@]}
for i in `seq 0 $((numMissions-1))`; do
	s=${missions[$i]}
	ar=(${s//,/ })

	ships=${ar[1]}

	contractname="Visit-"
	contractTitle="Visit and land on "
	contractTitle=""
	cnt=${#ar[@]}
	orbit=0
	for ia in `seq 2 $((cnt-1))`; do
		if [ "${ar[ia]}" != "orbit" ]; then
			contractname="${contractname}${ar[ia]}"
			if [ $ia -gt 2 ]; then
				contractTitle="${contractTitle}, "
			fi
			contractTitle="${contractTitle}${ar[ia]}"

		else
			orbit=1
			contractname="${contractname}Orbit"
		fi
	done
	d=${ar[0]}
	difficulty=${difficultyText[$((d-1))]}
	synopsis="This is ${difficulty}"	
	prestige=${prestigeText[$((d-1))]}
	reputation=$((20*d))
	rewardfunds=$((d*d*10000))
	if [ $orbit -eq 0 ]; then
		contractTitle="Land on $contractTitle and return safely to Kerbin"
		description="Do a round trip to $contractTitle and return safely to Kerbin"
		synopsis="${synopsis}. Do a round trip to $contractTitle"
	else
		contractTitle="Land on $contractTitle and make it back to orbit"
		description="Do a round trip to $contractTitle and return safely to orbit"
		synopsis="${synopsis}. Go to $contractTitle and return to orbit"
	fi
	echo $contractname

	[ -f ${contractname}.cfg ] && rm ${contractname}.cfg

	for (( s=0; s<${#ships}; s++ )); do
		crafturl=${vesselURL[$s]}
		vessel=`grep 'ship = ' "${crafturl}"  | cut -f3- -d' ' | tr -d '\r' | tr -d '\n'`

echo $crafturl
echo $vessel

		ContractName="${contractname}${vessel}"
		for targetbody in `seq 2 $((cnt-1))`; do
			if [ "${ar[targetbody]}" != "orbit" ]; then
				target="${contractname}${ar[targetbody]}"

				while IFS=$'\n' read -r var ; do
					if [[ "$var" =~ ^(.*)\<TARGETS\>.* ]]; then
						while IFS=$'\n' read -r tvar ; do
							oIFS=$IFS
							IFS=
							echo $tvar | sed "s/<TARGETBODY>/${ar[targetbody]}/g" >>${contractname}.cfg
							IFS=$oIFS
						done < target.template
					elif [[ "$var" =~ ^(.*)\<CONCLUSION\>.* ]]; then
						oIFS=$IFS
						IFS=
						if [ $orbit -eq 0 ]; then
							cat returnhome.template >>${contractname}.cfg
						else
							cat orbiting.template >>${contractname}.cfg
						fi
						IFS=$oIFS
					else
						oIFS=$IFS
						IFS=
						echo $var | sed "s/<CONTRACT_NAME>/$ContractName/g" | sed "s/<CONTRACT_TITLE>/$contractTitle/g" | sed "s/<DESCRIPTION>/$description/g" | sed "s/<SYNOPSIS>/$synopsis/g" | sed "s/<PRESTIGE>/$prestige/g" | sed "s/<TARGETBODY>/$target/g" | sed "s/<SCIENCE>/0/g" | sed "s/<REPUTATION>/$reputation/g" | sed "s/<REWARD_FUNDS>/$rewardfunds/g" | sed "s/<CRAFT_URL>/$crafturl/g" | sed "s/<VESSEL>/$vessel/g" >>${contractname}.cfg
						IFS=$oIFS
					fi

				done <$templatefile
			fi
		done
#exit
	done
done
