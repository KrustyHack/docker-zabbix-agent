# Zabbix Agent Docker Image with PSK encryption

This is a docker image with Zabbix Agent and PSK encryption. It's based on CentOS-7 official image.  

The Zabbix agent has been patched to read system informations from these directories:  

`/data/proc` mapped from `/proc` on the real host  
`/data/dev` mapped from `/dev` on the real host  
`/data/sys` mapped from `/sys` on the real host  

**Zabbix agent is running in foreground.**

## Build the image

    docker build -t krustyhack/docker-zabbix-agent .

## ENV variables

`ZABBIX_SERVER` - Zabbix Server address  
`HOSTNAME` - hostname  (will check /etc/hostname if not manually configured)
`HOST_METADATA` - the metadata value shared by all servers on the same cluster. This value will match the autoregistration action  
`CONFIG_FILE` - config file path. (Used if custom file and path needed)
`ZABBIX_PSK` - enabled PSK encryption. "yes" by default. Can be "yes" or "no"

## Usage
### Basic
	docker run \
	-d \
	--privileged=true \
	--net=host \
	--name=zabbix-agent \
	-p 10050:10050 \
	-v /proc:/data/proc \
	-v /sys:/data/sys \
	-v /dev:/data/dev \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--env="ZABBIX_SERVER=my.zabbix.server" \
	--env="HOSTNAME=$(hostname)" \
	krustyhack/docker-zabbix-agent

### Get PSK
	root@KrustyKali:~# docker logs zabbix-agent |grep "GENERATED ZABBIX RAND HEX"
	LOG 15:27:20] GENERATED ZABBIX RAND HEX to xxxxxxxxxxxxxxxxxxxxxxxxxxx[...]xxxx.

Copy xxxxx[...]xxx into your zabbix host encryption panel on your zabbix server interface and you're done.

## Author  
Author : Przemyslaw Ozgo (<linux@ozgo.info>) 
Mod : KrustyHack (<webmaster@nicolashug.com>)
This work is inspired by [million12](https://github.com/million12).