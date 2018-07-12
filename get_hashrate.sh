LOG_NAME=logs.log
MHS="MH/s"

get_cards_hashes(){
	# hs is global
	hs=''
  local MHS=`cat $LOG_NAME | tail -n 10 | grep "Statistics" | sed -e "s/\x1b\[.\{1,5\}m//g" \
       | tail -n 1 | sed "s/GPU [0-9]*//g" | cut -f2 -d"]"` 
  local count=`echo $MHS | grep -oE "[0-9]*\.[0-9]*" | wc -l`
  MHS=`echo $MHS | grep -oE "[1-9]*\.[0-9]*"`
  for (( i=0; i < $count; i++ )); do
    hs[$i]=`echo $MHS | cut -f$(($i+1)) -d" " | awk '{ printf("%.3f",$1) }'`
	done
}

get_nvidia_cards_temp(){
	echo $(jq -c "[.temp$nvidia_indexes_array]" <<< $gpu_stats)
}

get_nvidia_cards_fan(){
	echo $(jq -c "[.fan$nvidia_indexes_array]" <<< $gpu_stats)
}

get_miner_uptime(){
	local tmp=$(cat $LOG_NAME |  head -n 20 | grep "20[0-9-]*" | tail -n 1 | sed -e "s/\x1b\[.\{1,5\}m//g" | awk '{print $1,$2}' | cut -c1-19)
	local start=$(date +%s -d "${tmp}")
	local now=$(date +%s)
	echo $((now - start))
}

get_miner_algo(){
	local algo=""
	
	for i in "${algo_avail[@]}"
	do
		if [[ ! -z $(echo $CUSTOM_USER_CONFIG | grep $i) ]]; then
			algo=$i
			break
		fi
	done
	echo $algo
}

get_miner_shares_ac(){
	# hs is global
  local MHS=`cat $LOG_NAME | tail -n 20 | grep "Total shares" | sed -e "s/\x1b\[.\{1,5\}m//g" \
       | tail -n 1 | sed "s/GPU [0-9]*//g" | cut -f2 -d"]" | cut -f3 -d":" | grep -oE "[0-9]*" ` 
	#[[ -z $tmp ]] && echo "0"
	echo $MHS
  #MHS=`echo $MHS | grep -oE "[0-9]*\.[0-9]*"`
}

get_miner_shares_rj(){
	# hs is global
  local MHS=`cat $LOG_NAME | tail -n 20 | grep "Total shares" | sed -e "s/\x1b\[.\{1,5\}m//g" \
       | tail -n 1 | sed "s/GPU [0-9]*//g" | cut -f2 -d"]" | cut -f4 -d":" | grep -oE "[0-9]*" ` 
	#[[ -z $tmp ]] 
	echo $MHS
  #MHS=`echo $MHS | grep -oE "[0-9]*\.[0-9]*"`
}

get_total_hashes(){
	# khs is global
	local tmp=`cat $LOG_NAME | tail -n 20 | grep "Total shares" | sed -e "s/\x1b\[.\{1,5\}m//g" \
       | tail -n 1 | sed "s/GPU [0-9]*//g" | cut -f2 -d"]" | grep -oE "[0-9]*\.[0-9]* [A-Z]*\/s" ` 
	local units=`echo $tmp | awk '{ print $2 }'`
	local Total=0
	case $units in
		kH/s)
			Total=`echo $tmp | awk '{ printf("%.3f\n", $0) }'`
		;;
		MH/s)
			Total=`echo $tmp | awk '{ printf("%.3f\n", $0*1000) }'`
		;;
		*)
			Total=0
		;;
	esac
	echo Total = $Total
}

get_log_time_diff(){
	local tmp=$(cat $LOG_NAME | tail -n 20 | sed -e "s/\x1b\[.\{1,5\}m//g" \
		 | grep "20[0-9-]*" | tail -n 1 | awk '{print $1,$2}' | cut -c1-19)
	local logTime=`date +%s -d "${tmp}"`
	local curTime=`date +%s`
	echo `expr $curTime - $logTime`
}

echo get_log_time_diff $(get_log_time_diff)
echo get_miner_uptime $(get_miner_uptime)
echo get_total_hashes $(get_total_hashes)
echo get_miner_shares_rj $(get_miner_shares_rj)
echo get_miner_shares_ac $(get_miner_shares_ac)
echo get_miner_uptime $(get_miner_uptime)
echo get_miner_algo $(get_miner_algo)
