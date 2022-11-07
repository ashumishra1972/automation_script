#! /usr/bin/env bash

RED="\e[31m"
GREEN="\e[32m"
END="\e[0m"
echo -e "${GREEN} Enter your Target Name ${END}"
read targetname
echo -e "Your Target Name is ${RED} $targetname ${END}"
sleep 2

echo -e "${RED} Configuring Your System, Wait a Moment...${END}"
sleep 2
shopt -s extglob
rm -- !(myscript.sh)
echo -e "${GREEN} Configuration Completed ${END}"
sleep 2



echo -e "${RED} Performing Subdomain enumeration ${END}"
sleep 2
subfinder -d $targetname > subfinder_results
wait


echo -e "${RED} Gathering Live Domains from Subdomains ${END}"
sleep 2
httpx -l subfinder_results -o live_domain_httpx 2 >/dev/null
wait


echo -e "${RED} Checking Subdomain Takeovers ${END}"
rm -rf /root/fingerprints.json
subzy -targets live_domain_httpx > subdomain_takeover
wait


echo -e "${RED} Sending Domains to Nuclei && Updating Nuclei ${END}"
sleep 2
nuclei --update-templates
wait
nuclei -l live_domain_httpx -t nuclei-templates/ -o nuclei_results 2 >/dev/null
wait

echo -e "${RED} Gathering Data from Shodan ${END}"
sleep 2
shodan domain $targetname > shodanresutls
wait

echo -e "${RED} Running Knockpy , Gathering results ${END}"
sleep 2
python3 /root/knock/knockpy.py $targetname > knockpy_results
wait

echo -e "${RED} Running Waybackurls ${END}"
sleep 2
waybackurls $targetname > waybackurl_list
wait
echo -e "${RED} Extracting patterns for xss ${END}"
sleep 2
cat waybackurl_list | gf xss > pattern_xss
wait
echo -e "${RED} Extracting patterns for ssrf ${END}"
sleep 2
cat waybackurl_list | gf ssrf > pattern_ssrf
wait
echo -e "${RED} Extracting patterns for sqli ${END}"
sleep 2
cat waybackurl_list |gf sqli > pattern_sqli
wait
echo -e "${RED} Extracting patterns for redirect ${END}" 
sleep 2
cat waybackurl_list | gf redirect > pattern_redirect
wait
echo -e "${RED} Extracting patterns for idor ${END}"
sleep 2
cat waybackurl_list | gf idor > pattern_idor
wait
echo -e "${RED} Extracting patterns for img-traversal ${END}"
sleep 2
cat waybackurl_list | gf img-traversal > pattern_img_traversal
wait
echo -e "${RED} Extracting patterns for lfi ${END}"
sleep 2
cat waybackurl_list | gf lfi > pattern_lfi
wait
echo -e "${RED} Extracting patterns for rce ${END}"
sleep 2
cat waybackurl_list | gf rce > pattern_rce
wait
