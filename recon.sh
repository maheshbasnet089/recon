#!/bin/bash
#source ./scan.lib
nmap_scan()
{
 nmap $DOMAIN > $DIRECTORY/nmap
 echo "The results of nmap scan are stored in $DIRECTORY/nmap."
}
dirsearch_scan()
{
 dirsearch.py -u $DOMAIN -e php --output=$DIRECTORY/dirsearch
 echo "The results of dirsearch scan are stored in $DIRECTORY/dirsearch."
}
crt_scan()
{
 curl "https://crt.sh/?q=$DOMAIN&output=json" -o $DIRECTORY/crt
 echo "The results of cert parsing is stored in $DIRECTORY/crt."
}

while getopts "m:i" OPTION; do
 case $OPTION in
 m)
 MODE=$OPTARG
 ;;
 i)
 INTERACTIVE=true
 ;;
 esac
done
scan_domain(){
 DOMAIN=$1
 DIRECTORY=${DOMAIN}_recon
 echo "Creating directory $DIRECTORY."
 mkdir $DIRECTORY
 case $MODE in
 nmap-only)
 nmap_scan
 ;;
 dirsearch-only)
 dirsearch_scan
 ;;
 crt-only)
 crt_scan
 ;;
 *)
 nmap_scan
 dirsearch_scan
 crt_scan
 ;;
 esac
}
report_domain(){
 DOMAIN=$1
 DIRECTORY=${DOMAIN}_recon
 echo "Generating recon report for $DOMAIN..."
 TODAY=$(date)
 echo "This scan was created on $TODAY" > $DIRECTORY/report
 if [ -f $DIRECTORY/nmap ];then
 echo "Results for Nmap:" >> $DIRECTORY/report
 grep -E "^\s*\S+\s+\S+\s+\S+\s*$" $DIRECTORY/nmap >> $DIRECTORY/report
 fi
 if [ -f $DIRECTORY/dirsearch ];then
 echo "Results for Dirsearch:" >> $DIRECTORY/report
 cat $DIRECTORY/dirsearch >> $DIRECTORY/report
 fi
 if [ -f $DIRECTORY/crt ];then
 echo "Results for crt.sh:" >> $DIRECTORY/report
 jq -r ".[] | .name_value" $DIRECTORY/crt >> $DIRECTORY/report
 fi
}
if [ $INTERACTIVE ];then 1
 INPUT="BLANK"
 while [ $INPUT != "quit" ];do 2
 echo "Please enter a domain!"
 read INPUT
 if [ $INPUT != "quit" ];then 3
 scan_domain $INPUT
 report_domain $INPUT
 fi
 done
else
 for i in "${@:$OPTIND:$#}";do
 scan_domain $i
 report_domain $i

 done
fi
