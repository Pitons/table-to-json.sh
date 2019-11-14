# table-to-json.sh
Script to transform any table to JSON that can be used in Zabbix LLD

Two output types Data(default) or LLD formated, controled by first parameter 0=data; 1=LLD
# How to use this script: 

1. pipe the data if
$ df | table_to_json.sh

2. use script to open files with data:
$ ./table_to_json.sh file.with.data.txt
to get LLD 
$ ./table_to_json.sh 1 file.with.data.txt

3. ssh connect and grap the output, use 4 or 5 parameters
options $1 - format output for {#LLD} $2 - IP, $3 - username, $4 - password; 
$5 - cmd to exec (must be table, emty lines and lines beggining with 
$ ./table_to_json.sh <1> IP/DNS username password "CMD to exec"
$ ./table_to_json.sh 192.168.1.1 root toor "df -m"
to get LLD:
$ ./table_to_json.sh 1 192.168.1.1 root toor "df -m"
Usage in  zabbix: 
create discovery rule, 
Type: external check 
item key: table_to_json.sh[1,IP,user,pass,"CMD to exec"]
 
Create it, use it, like it, share it, benefit!
