# Table to JSON transformation script usable in [Zabbix](www.zabbix.com) as an external check.
Script to transform any table to JSON that can be used in Zabbix LLD with removal of empty or lines containing dashes. 

Two output types Data(default) or LLD formated, controled by first parameter 0=data; 1=LLD
## How to use this script: 

### 1. pipe the data if
```sh
df | table_to_json.sh`
```
### 2. use script to open files with data:
`./table_to_json.sh file.with.data.txt`
### to get LLD 
`./table_to_json.sh 1 file.with.data.txt`
### 3. ssh connect and grap the output, use 4 or 5 parameters:
 - $1 - format output for {#LLD} 
 - $2 - IP/DNS, 
 - $3 - username, 
 - $4 - password; 
 - $5 - cmd to exec
 
`./table_to_json.sh <1> IP/DNS username password "CMD to exec"`

### Column names will be transformed to Capital leters:
`./table_to_json.sh 192.168.1.1 root toor "df -m"`
### to get LLD:
`./table_to_json.sh 1 192.168.1.1 root toor "df -m"`
### 4. Usage in  zabbix: 
### Create discovery rule, 
 - Type: external check
 - Item key: table_to_json.sh[1,IP,user,pass,"CMD to exec"]
 
### Create it, use it, like it, share it, benefit!
