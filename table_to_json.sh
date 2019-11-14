# Zabbix LLD script to convert any table to json
# 2 output types Data(default) or LLD formated, controled by first parameter 0=data; 1=LLD
# 
# Made by Edmunds Vesmanis
# How to use this script: 
# 
# 1. pipe the data if
#  df | table_to_json.sh
#
# 2. use script to open files with data:
#  ./table_to_json.sh file.with.data.txt
#  #to get LLD 
#  ./table_to_json.sh 1 file.with.data.txt
#
# 3. ssh connect and grap the output, use 4 or 5 parameters
# options $1 - format output for {#LLD} $2 - IP, $3 - username, $4 - password; 
# $5 - cmd to exec (must be table, emty lines and lines beggining with 
#  ./table_to_json.sh <1> IP/DNS username password "CMD to exec"
#  ./table_to_json.sh 192.168.1.1 root toor "df -m"
#  to get LLD:
#  ./table_to_json.sh 1 192.168.1.1 root toor "df -m"
#  Usage in  zabbix: 
#  create discovery rule, Type: external check; item key: table_to_json.sh[1,IP,user,pass,"CMD to exec"]
#  
#!/bin/bash
linenum=1
IFS0=$IFS
IFS1=$'\n'
IFS=$IFS1
DOLLD=0
if [ -p /dev/stdin ]
then
  indata=$(cat)
#  echo "$indata" | head -1
#  if [ $(echo "$indata" | head -1) -eq 1 ]; then DOLLD=1 && indata=$(echo $indata | sed '1d'); fi
#  echo "$indata"
#  exit
elif [ $# -eq 2 -a -f "$2" ] # File input with parameter for LLD ( 1 - format json with {#LLD})
then 
  if [ "$1" -eq 1 ]; then DOLLD=1; fi
  indata=$(<${2})
elif [ $# -eq 1 -a -f "$1" ] # File input
then
  indata=$(<${1})
elif [ $# -eq 5  ]
then 
  if [ $1 -eq 1 ]; then DOLLD=1; fi
  indata=$(sshpass -p $4 ssh -oStrictHostKeyChecking=no -q $2 -l $3 $5)
elif [ $# -eq 4 ]
then
  indata=$(sshpass -p $3 ssh -oStrictHostKeyChecking=no -q $1 -l $2 $4)
else
  echo "Wrong you have done something!"
  echo "Check number and sequence of parameters."
  exit 
fi
# Remove emty lines, lines empty space and "----", lines with "total";
indata=$(echo "$indata" | sed '/^[ ]*---/d;/^$/d;/\d*[ ]*total/d')

linesmax=$(echo "$indata" | wc -l)
echo '{"data":['
for lldline in $(echo "$indata")
do
  if [ $linenum -gt 1 ]; then echo {; fi
  IFS=$IFS0
  varnum=1
  for lldvalue in $lldline
  do
     if [ $linenum == 1 ] 
     then
	head=$(echo "$lldline" | sed -e 's/[-(%)]//g' | tr '[:lower:]' '[:upper:]')
	varnummax=$(echo $head | wc -w)
        ((varnum++))
     else
	macro=$(awk -v var="$varnum" '{print $var}' <<< $head)
		if [ $DOLLD -eq '1' ]
		then
			echo \"{#${macro}}\" : \"$lldvalue\" $(if [ $varnum -lt $varnummax ]; then echo ,; fi)
		elif [ $DOLLD -eq '0' ]; then
			echo \"${macro}\" : \"$lldvalue\" $(if [ $varnum -lt $varnummax ]; then echo ,; fi)
		else
		echo ""
		fi
	((varnum++))
     fi
    IFS=$IFS1
  done
  echo $(if [ $linenum -gt 1 ]; then echo }; fi)$(if [ $linenum -gt 1 -a $linenum -lt $linesmax ]; then echo ,; fi)
  ((linenum++))
done
echo ]}

