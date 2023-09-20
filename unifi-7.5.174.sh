#!/bin/bash

# UniFi Network Application Easy Installation Script.

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                        List of supported Distributions/Operating Systems                                                                        #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

#                       | Ubuntu Precise Pangolin ( 12.04 )
#                       | Ubuntu Trusty Tahr ( 14.04 )
#                       | Ubuntu Xenial Xerus ( 16.04 )
#                       | Ubuntu Bionic Beaver ( 18.04 )
#                       | Ubuntu Cosmic Cuttlefish ( 18.10 )
#                       | Ubuntu Disco Dingo ( 19.04 )
#                       | Ubuntu Eoan Ermine ( 19.10 )
#                       | Ubuntu Focal Fossa ( 20.04 )
#                       | Ubuntu Groovy Gorilla ( 20.10 )
#                       | Ubuntu Hirsute Hippo ( 21.04 )
#                       | Ubuntu Impish Indri ( 21.10 )
#                       | Ubuntu Jammy Jellyfish ( 22.04 )
#                       | Ubuntu Kinetic Kudu ( 22.10 )
#                       | Ubuntu Lunar Lobster ( 23.04 )
#                       | Ubuntu Mantic Minotaur ( 23.10 )
#                       | Debian Jessie ( 8 )
#                       | Debian Stretch ( 9 )
#                       | Debian Buster ( 10 )
#                       | Debian Bullseye ( 11 )
#                       | Debian Bookworm ( 12 )
#                       | Debian Trixie ( 13 )
#                       | Debian Forky ( 14 )
#                       | Linux Mint 13 ( Maya )
#                       | Linux Mint 17 ( Qiana | Rebecca | Rafaela | Rosa )
#                       | Linux Mint 18 ( Sarah | Serena | Sonya | Sylvia )
#                       | Linux Mint 19 ( Tara | Tessa | Tina | Tricia )
#                       | Linux Mint 20 ( Ulyana | Ulyssa | Uma | Una )
#                       | Linux Mint 21 ( Vanessa | Vera | Victoria )
#                       | Linux Mint 4 ( Debbie )
#                       | Linux Mint 5 ( Elsie )
#                       | MX Linux 18 ( Continuum )
#                       | Progress-Linux ( Engywuck )
#                       | Parrot OS
#                       | Elementary OS
#                       | Deepin Linux
#                       | Kali Linux ( rolling )

###################################################################################################################################################################################################

# Version               | 5.6.9
# Application version   | 7.5.174-e258d1dd8c
# Debian Repo version   | 7.5.174-22700-1
# Author                | Glenn Rietveld
# Email                 | glennrietveld8@hotmail.nl
# Website               | https://GlennR.nl

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                           Color Codes                                                                                           #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

RESET='\033[0m'
YELLOW='\033[1;33m'
#GRAY='\033[0;37m'
#WHITE='\033[1;37m'
GRAY_R='\033[39m'
WHITE_R='\033[39m'
RED='\033[1;31m' # Light Red.
GREEN='\033[1;32m' # Light Green.
#BOLD='\e[1m'

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                           Start Checks                                                                                          #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

header() {
  clear
  clear
  echo -e "${GREEN}#########################################################################${RESET}\\n"
}

header_red() {
  clear
  clear
  echo -e "${RED}#########################################################################${RESET}\\n"
}

# Check for root (SUDO).
if [[ "$EUID" -ne 0 ]]; then
  header_red
  echo -e "${WHITE_R}#${RESET} The script need to be run as root...\\n\\n"
  echo -e "${WHITE_R}#${RESET} For Ubuntu based systems run the command below to login as root"
  echo -e "${GREEN}#${RESET} sudo -i\\n"
  echo -e "${WHITE_R}#${RESET} For Debian based systems run the command below to login as root"
  echo -e "${GREEN}#${RESET} su\\n\\n"
  exit 1
fi

if ! env | grep "LC_ALL\\|LANG" | grep -iq "en_US\\|C.UTF-8"; then
  header
  echo -e "${WHITE_R}#${RESET} Your language is not set to English ( en_US ), the script will temporarily set the language to English."
  echo -e "${WHITE_R}#${RESET} Information: This is done to prevent issues in the script.."
  export LC_ALL=C &> /dev/null
  set_lc_all=true
  sleep 3
fi

abort() {
  remove_glennr_source_list
  if [[ "${set_lc_all}" == 'true' ]]; then unset LC_ALL; fi
  echo -e "\\n\\n${RED}#########################################################################${RESET}\\n"
  echo -e "${WHITE_R}#${RESET} An error occurred. Aborting script..."
  echo -e "${WHITE_R}#${RESET} Please contact Glenn R. (AmazedMender16) on the Community Forums!\\n"
  echo -e "${WHITE_R}#${RESET} Creating support file..."
  mkdir -p "/tmp/EUS/support" &> /dev/null
  if dpkg -l lsb-release 2> /dev/null | grep -iq "^ii\\|^hi"; then lsb_release -a &> "/tmp/EUS/support/lsb-release"; fi
  df -h &> "/tmp/EUS/support/df"
  free -hm &> "/tmp/EUS/support/memory"
  uname -a &> "/tmp/EUS/support/uname"
  dpkg -l | grep "mongo\\|oracle\\|openjdk\\|unifi\\|temurin" &> "/tmp/EUS/support/unifi-packages"
  if ! dpkg -l | grep -iq "mongo"; then if [[ -n "$(command -v mongo)" ]]; then "$(which mongo)" --quiet --eval "db.version()" &>/tmp/EUS/support/mongodb_version; fi; fi
  dpkg -l &> "/tmp/EUS/support/dpkg-list"
  echo "${architecture}" &> "/tmp/EUS/support/architecture"
  # shellcheck disable=SC2129
  sed -n '3p' "${script_location}" &>> "/tmp/EUS/support/script"
  grep -i "# Version" "${script_location}" | head -n1 &>> "/tmp/EUS/support/script"
  grep -i "# Application version" "${script_location}" | head -n1 &>> "/tmp/EUS/support/script"
  if dpkg -l tar 2> /dev/null | grep -iq "^ii\\|^hi"; then
    tar czvfh /tmp/eus_support.tar.gz --exclude="${eus_dir}/unifi_db" "/tmp/EUS" "${eus_dir}" "/usr/lib/unifi/logs" &> /dev/null
    support_file="/tmp/eus_support.tar.gz"
  elif dpkg -l zip 2> /dev/null | grep -iq "^ii\\|^hi"; then
    zip -r /tmp/eus_support.zip "/tmp/EUS/" "${eus_dir}/" "/usr/lib/unifi/logs/" -x "${eus_dir}/unifi_db/*" &> /dev/null
    support_file="/tmp/eus_support.zip"
  fi
  if [[ -n "${support_file}" ]]; then echo -e "${WHITE_R}#${RESET} Support file has been created here: ${support_file} \\n"; fi
  if [[ -f /tmp/EUS/services/stopped_list && -s /tmp/EUS/services/stopped_list ]]; then
    while read -r service; do
      echo -e "\\n${WHITE_R}#${RESET} Starting ${service}.."
      systemctl start "${service}" && echo -e "${GREEN}#${RESET} Successfully started ${service}!" || echo -e "${RED}#${RESET} Failed to start ${service}!"
    done < /tmp/EUS/services/stopped_list
  fi
  exit 1
}

if uname -a | tr '[:upper:]' '[:lower:]' | grep -iq "cloudkey\\|uck\\|ubnt-mtk"; then
  eus_dir='/srv/EUS'
  is_cloudkey=true
elif grep -iq "UCKP\\|UCKG2\\|UCK" /usr/lib/version &> /dev/null; then
  eus_dir='/srv/EUS'
  is_cloudkey=true
else
  eus_dir='/usr/lib/EUS'
  is_cloudkey=false
fi
if [[ "${is_cloudkey}" == "true" ]]; then
  if grep -iq "UCK.mtk7623" /usr/lib/version &> /dev/null; then
    cloudkey_generation="1"
  fi
fi

script_logo() {
  cat << "EOF"

  _______________ ___  _________  .___                 __         .__  .__   
  \_   _____/    |   \/   _____/  |   | ____   _______/  |______  |  | |  |  
   |    __)_|    |   /\_____  \   |   |/    \ /  ___/\   __\__  \ |  | |  |  
   |        \    |  / /        \  |   |   |  \\___ \  |  |  / __ \|  |_|  |__
  /_______  /______/ /_______  /  |___|___|  /____  > |__| (____  /____/____/
          \/                 \/            \/     \/            \/           

EOF
}

start_script() {
  script_location="${BASH_SOURCE[0]}"
  script_name=$(basename "${BASH_SOURCE[0]}")
  mkdir -p "${eus_dir}/logs" 2> /dev/null
  mkdir -p /tmp/EUS/ 2> /dev/null
  mkdir -p /tmp/EUS/upgrade/ 2> /dev/null
  mkdir -p /tmp/EUS/dpkg/ 2> /dev/null
  header
  script_logo
  echo -e "    Easy UniFi Network Application Install Script"
  echo -e "\\n${WHITE_R}#${RESET} Starting the Easy UniFi Install Script.."
  echo -e "${WHITE_R}#${RESET} Thank you for using my Easy UniFi Install Script :-)\\n\\n"
  sleep 4
}
start_script

help_script() {
  if [[ "${script_option_help}" == 'true' ]]; then header; script_logo; else echo -e "${WHITE_R}----${RESET}\\n"; fi
  echo -e "    Easy UniFi Network Application Install Script assistance\\n"
  echo -e "
  Script usage:
  bash ${script_name} [options]
  
  Script options:
    --skip                                  Skip any kind of manual input.
    --skip-swap                             Skip swap file check/creation.
    --add-repository                        Add UniFi Repository if --skip is used.
    --local-install                         Inform script that it's a local UniFi Network installation, to open port 10001/udp ( discovery ).
    --custom-url [argument]                 Manually provide a UniFi Network Application download URL.
                                            example:
                                            --custom-url https://dl.ui.com/unifi/7.4.162/unifi_sysvinit_all.deb
    --help                                  Shows this information :)\\n\\n
  Script options for UniFi Easy Encrypt:
    --v6                                    Run the script in IPv6 mode instead of IPv4.
    --email [argument]                      Specify what email address you want to use
                                            for renewal notifications.
                                            example:
                                            --email glenn@glennr.nl
    --fqdn [argument]                       Specify what domain name ( FQDN ) you want to use, you
                                            can specify multiple domain names with : as seperator, see
                                            the example below:
                                            --fqdn glennr.nl:www.glennr.nl
    --server-ip [argument]                  Specify the server IP address manually.
                                            example:
                                            --server-ip 1.1.1.1
    --retry [argument]                      Retry the unattended script if it aborts for X times.
                                            example:
                                            --retry 5
    --external-dns [argument]               Use external DNS server to resolve the FQDN.
                                            example:
                                            --external-dns 1.1.1.1
    --force-renew                           Force renew the certificates.
    --dns-challenge                         Run the script in DNS mode instead of HTTP.
                                            example:
                                            --private-key /tmp/PRIVATE.key
    --signed-certificate [argument]         Specify path to your signed certificate (paid certificate)
                                            example:
                                            --signed-certificate /tmp/SSL_CERTIFICATE.cer
    --chain-certificate [argument]          Specify path to your chain certificate (paid certificate)
                                            example:
                                            --chain-certificate /tmp/CHAIN.cer
    --intermediate-certificate [argument]   Specify path to your intermediate certificate (paid certificate)
                                            example:
                                            --intermediate-certificate /tmp/INTERMEDIATE.cer
    --own-certificate                       Requirement if you want to import your own paid certificates
                                            with the use of --skip.\\n\\n"
  exit 0
}

rm --force /tmp/EUS/script_options &> /dev/null
rm --force /tmp/EUS/le_script_options &> /dev/null
script_option_list=(-skip --skip --skip-swap --add-repository --local --local-controller --local-install --custom-url --help --v6 --ipv6 --email --mail --fqdn --domain-name --server-ip --server-address --retry --external-dns --force-renew --renew --dns --dns-challenge)

while [ -n "$1" ]; do
  case "$1" in
  -skip | --skip)
       script_option_skip=true
       echo "--skip" &>> /tmp/EUS/script_options
       echo "--skip" &>> /tmp/EUS/le_script_options;;
  --skip-swap)
       script_option_skip_swap=true
       echo "--skip-swap" &>> /tmp/EUS/script_options;;
  --add-repository)
       script_option_add_repository=true
       echo "--add-repository" &>> /tmp/EUS/script_options;;
  --local | --local-controller | --local-install)
       script_option_local_install=true
       echo "--local-install" &>> /tmp/EUS/script_options;;
  --custom-url)
       if [[ -n "${2}" ]]; then if echo "${2}" | grep -ioq ".deb"; then custom_url_down_provided=true; custom_download_url="${2}"; else header_red; echo -e "${RED}#${RESET} Provided URL does not have the 'deb' extension...\\n"; help_script; fi; fi
       script_option_custom_url=true
       if [[ "${custom_url_down_provided}" == 'true' ]]; then echo "--custom-url ${2}" &>> /tmp/EUS/script_options; else echo "--custom-url" &>> /tmp/EUS/script_options; fi;;
  --help)
       script_option_help=true
       help_script;;
  --v6 | --ipv6)
       echo "--v6" &>> /tmp/EUS/le_script_options;;
  --email | --mail)
       for option in "${script_option_list[@]}"; do
         if [[ "${2}" == "${option}" ]]; then header_red; echo -e "${WHITE_R}#${RESET} Option ${1} requires a command argument... \\n\\n"; help_script; fi
       done
       echo -e "--email ${2}" &>> /tmp/EUS/le_script_options
       shift;;
  --fqdn | --domain-name)
       for option in "${script_option_list[@]}"; do
         if [[ "${2}" == "${option}" ]]; then header_red; echo -e "${WHITE_R}#${RESET} Option ${1} requires a command argument... \\n\\n"; help_script; fi
       done
       echo -e "--fqdn ${2}" &>> /tmp/EUS/le_script_options
       fqdn_specified=true
       shift;;
  --server-ip | --server-address)
       for option in "${script_option_list[@]}"; do
         if [[ "${2}" == "${option}" ]]; then header_red; echo -e "${WHITE_R}#${RESET} Option ${1} requires a command argument... \\n\\n"; help_script; fi
       done
       echo -e "--server-ip ${2}" &>> /tmp/EUS/le_script_options
       shift;;
  --retry)
       for option in "${script_option_list[@]}"; do
         if [[ "${2}" == "${option}" ]]; then header_red; echo -e "${WHITE_R}#${RESET} Option ${1} requires a command argument... \\n\\n"; help_script; fi
       done
       echo -e "--retry ${2}" &>> /tmp/EUS/le_script_options
       shift;;
  --external-dns)
       for option in "${script_option_list[@]}"; do
         if [[ "${2}" == "${option}" ]]; then echo -e "--external-dns" &>> /tmp/EUS/le_script_options; else echo -e "--external-dns ${2}" &>> /tmp/EUS/le_script_options; fi
       done;;
  --force-renew | --renew)
       echo -e "--force-renew" &>> /tmp/EUS/le_script_options;;
  --dns | --dns-challenge)
       echo -e "--dns-challenge" &>> /tmp/EUS/le_script_options;;
  --priv-key | --private-key)
       for option in "${script_option_list[@]}"; do
         if [[ "${2}" == "${option}" ]]; then header_red; echo -e "${WHITE_R}#${RESET} Option ${1} requires a command argument... \\n\\n"; help_script; fi
       done
       echo "--private-key ${2}" &>> /tmp/EUS/le_script_options
       shift;;
  --signed-crt | --signed-certificate)
       for option in "${script_option_list[@]}"; do
         if [[ "${2}" == "${option}" ]]; then header_red; echo -e "${WHITE_R}#${RESET} Option ${1} requires a command argument... \\n\\n"; help_script; fi
       done
       echo "--signed-certificate ${2}" &>> /tmp/EUS/le_script_options
       shift;;
  --chain-crt | --chain-certificate)
       for option in "${script_option_list[@]}"; do
         if [[ "${2}" == "${option}" ]]; then header_red; echo -e "${WHITE_R}#${RESET} Option ${1} requires a command argument... \\n\\n"; help_script; fi
       done
       echo "--chain-certificate ${2}" &>> /tmp/EUS/le_script_options
       shift;;
  --intermediate-crt | --intermediate-certificate)
       for option in "${script_option_list[@]}"; do
         if [[ "${2}" == "${option}" ]]; then header_red; echo -e "${WHITE_R}#${RESET} Option ${1} requires a command argument... \\n\\n"; help_script; fi
       done
       echo "--intermediate-certificate ${2}" &>> /tmp/EUS/le_script_options
       shift;;
  --own-certificate)
       echo "--own-certificate" &>> /tmp/EUS/le_script_options;;
  esac
  shift
done

# Check script options.
if [[ -f /tmp/EUS/script_options && -s /tmp/EUS/script_options ]]; then IFS=" " read -r script_options <<< "$(tr '\r\n' ' ' < /tmp/EUS/script_options)"; fi

if [[ "$(find /etc/apt/ -name "*.list" -type f -print0 | xargs -0 cat | grep -c "downloads-distro.mongodb.org")" -gt 0 ]]; then
  grep -riIl "downloads-distro.mongodb.org" /etc/apt/ &>> /tmp/EUS/repository/dead_mongodb_repository
  while read -r glennr_mongo_repo; do
    sed -i '/downloads-distro.mongodb.org/d' "${glennr_mongo_repo}" 2> /dev/null
	if ! [[ -s "${glennr_mongo_repo}" ]]; then
      rm --force "${glennr_mongo_repo}" 2> /dev/null
    fi
  done < /tmp/EUS/repository/dead_mongodb_repository
  rm --force /tmp/EUS/repository/dead_mongodb_repository
fi

# Check if DST_ROOT certificate exists
if grep -siq "^mozilla/DST_Root" /etc/ca-certificates.conf; then
  echo -e "${WHITE_R}#${RESET} Detected DST_Root certificate..."
  if sed -i '/^mozilla\/DST_Root_CA_X3.crt$/ s/^/!/' /etc/ca-certificates.conf; then
    echo -e "${GREEN}#${RESET} Successfully commented out the DST_Root certificate! \\n"
    update-ca-certificates &> /dev/null
  else
    echo -e "${RED}#${RESET} Failed to comment out the DST_Root certificate... \\n"
  fi
fi

# Check if apt-key is deprecated
aptkey_depreciated() {
  apt-key list >/tmp/EUS/aptkeylist 2>&1
  if grep -ioq "apt-key is deprecated" /tmp/EUS/aptkeylist; then apt_key_deprecated=true; fi
  rm --force /tmp/EUS/aptkeylist
}
aptkey_depreciated

if [[ "${apt_key_deprecated}" != 'true' ]]; then
  if apt-key list 2>/dev/null | grep mongodb -B1 | grep -iq "expired:"; then
    wget -qO - https://www.mongodb.org/static/pgp/server-3.4.asc | apt-key add - &> /dev/null
  fi
fi

find "${eus_dir}/logs/" -printf "%f\\n" | grep '.*.log' | awk '!a[$0]++' &> /tmp/EUS/log_files
while read -r log_file; do
  if [[ -f "${eus_dir}/logs/${log_file}" ]]; then
    log_file_size=$(stat -c%s "${eus_dir}/logs/${log_file}")
    if [[ "${log_file_size}" -gt "10485760" ]]; then
      tail -n1000 "${eus_dir}/logs/${log_file}" &> "${log_file}.tmp"
      mv "${eus_dir}/logs/${log_file}.tmp" "${eus_dir}/logs/${log_file}"
    fi
  fi
done < /tmp/EUS/log_files
rm --force /tmp/EUS/log_files

run_apt_get_update() {
  if ! [[ -d /tmp/EUS/keys ]]; then mkdir -p /tmp/EUS/keys; fi
  if ! [[ -f /tmp/EUS/keys/missing_keys && -s /tmp/EUS/keys/missing_keys ]]; then
    if [[ "${hide_apt_update}" == 'true' ]]; then
      echo -e "${WHITE_R}#${RESET} Running apt-get update..."
      if apt-get update &> /tmp/EUS/keys/apt_update; then echo -e "${GREEN}#${RESET} Successfully ran apt-get update! \\n"; else echo -e "${YELLOW}#${RESET} Something went wrong during running apt-get update! \\n"; fi
      unset hide_apt_update
    else
      apt-get update 2>&1 | tee /tmp/EUS/keys/apt_update
    fi
    grep -o 'NO_PUBKEY.*' /tmp/EUS/keys/apt_update | sed 's/NO_PUBKEY //g' | tr ' ' '\n' | awk '!a[$0]++' &> /tmp/EUS/keys/missing_keys
  fi
  if [[ -f /tmp/EUS/keys/missing_keys && -s /tmp/EUS/keys/missing_keys ]]; then
    #header
    #echo -e "${WHITE_R}#${RESET} Some keys are missing.. The script will try to add the missing keys."
    #echo -e "\\n${WHITE_R}----${RESET}\\n"
    while read -r key; do
      echo -e "${WHITE_R}#${RESET} Key ${key} is missing.. adding!"
      http_proxy=$(env | grep -i "http.*Proxy" | cut -d'=' -f2 | sed 's/[";]//g')
      if [[ -n "$http_proxy" ]]; then
        apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --keyserver-options http-proxy="${http_proxy}" --recv-keys "$key" &> /dev/null && echo -e "${GREEN}#${RESET} Successfully added key ${key}!\\n" || fail_key=true
      elif [[ -f /etc/apt/apt.conf ]]; then
        apt_http_proxy=$(grep "http.*Proxy" /etc/apt/apt.conf | awk '{print $2}' | sed 's/[";]//g')
        if [[ -n "${apt_http_proxy}" ]]; then
          apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --keyserver-options http-proxy="${apt_http_proxy}" --recv-keys "$key" &> /dev/null && echo -e "${GREEN}#${RESET} Successfully added key ${key}!\\n" || fail_key=true
        fi
      else
        apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv "$key" &> /dev/null && echo -e "${GREEN}#${RESET} Successfully added key ${key}!\\n" || fail_key=true
      fi
      if [[ "${fail_key}" == 'true' ]]; then
        echo -e "${RED}#${RESET} Failed to add key ${key}!"
        echo -e "${WHITE_R}#${RESET} Trying different method to get key: ${key}"
        gpg -vvv --debug-all --keyserver keyserver.ubuntu.com --recv-keys "${key}" &> /tmp/EUS/keys/failed_key
        debug_key=$(grep "KS_GET" /tmp/EUS/keys/failed_key | grep -io "0x.*")
        wget -q "https://keyserver.ubuntu.com/pks/lookup?op=get&search=${debug_key}" -O- | gpg --dearmor > "/tmp/EUS/keys/EUS-${key}.gpg"
        mv "/tmp/EUS/keys/EUS-${key}.gpg" /etc/apt/trusted.gpg.d/ && echo -e "${GREEN}#${RESET} Successfully added key ${key}!\\n"
      fi
      sleep 1
    done < /tmp/EUS/keys/missing_keys
    rm --force /tmp/EUS/keys/missing_keys
    rm --force /tmp/EUS/keys/apt_update
    #header
    #echo -e "${WHITE_R}#${RESET} Running apt-get update again.\\n\\n"
    #sleep 2
    apt-get update &> /tmp/EUS/keys/apt_update
    if grep -qo 'NO_PUBKEY.*' /tmp/EUS/keys/apt_update; then
      if [[ "${hide_apt_update}" != 'true' ]]; then hide_apt_update=true; fi
      run_apt_get_update
    fi
  fi
}

add_mongodb_repo() {
  mongodb_org_v=$(dpkg -l | grep "mongodb-org-server" | grep -i "^ii\\|^hi" | awk '{print $3}' | sed 's/\.//g' | sed 's/.*://' | sed 's/-.*//g' | sort -V | tail -n 1)
  if [[ "${mongodb_org_v::2}" == '32' ]] || [[ "${add_mongodb_32_repo}" == 'true' ]]; then
    mongodb_version_major_minor="3.2"
    if [[ "${os_codename}" =~ (trusty|qiana|rebecca|rafaela|rosa) ]]; then
      mongodb_codename="ubuntu trusty"
      mongodb_repo_type="multiverse"
    elif [[ "${os_codename}" == "jessie" ]]; then
      mongodb_codename="debian jessie"
      mongodb_repo_type="main"
    else
      mongodb_codename="ubuntu xenial"
      mongodb_repo_type="multiverse"
    fi
  fi
  if [[ "${mongodb_org_v::2}" == '34' ]] || [[ "${add_mongodb_34_repo}" == 'true' ]]; then
    mongodb_version_major_minor="3.4"
    if [[ "${os_codename}" =~ (trusty|qiana|rebecca|rafaela|rosa) ]]; then
      mongodb_codename="ubuntu trusty"
      mongodb_repo_type="multiverse"
    elif [[ "${os_codename}" == "jessie" ]]; then
      mongodb_codename="debian jessie"
      mongodb_repo_type="main"
    else
      mongodb_codename="ubuntu xenial"
      mongodb_repo_type="multiverse"
    fi
  fi
  if [[ "${mongodb_org_v::2}" == '36' ]] || [[ "${add_mongodb_36_repo}" == 'true' ]]; then
    mongodb_version_major_minor="3.6"
    if [[ "${try_different_mongodb_repo}" == 'true' ]] || [[ "${architecture}" != "amd64" ]]; then
      if [[ "${os_codename}" =~ (trusty|qiana|rebecca|rafaela|rosa) ]]; then
        mongodb_codename="ubuntu trusty"
        mongodb_repo_type="multiverse"
      elif [[ "${os_codename}" =~ (xenial|sarah|serena|sonya|sylvia|bionic|tara|tessa|tina|tricia|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic|stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
        mongodb_codename="ubuntu xenial"
        mongodb_repo_type="multiverse"
      elif [[ "${os_codename}" =~ (bionic|tara|tessa|tina|tricia|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic|bullseye|bookworm|trixie|forky) ]]; then
        mongodb_codename="ubuntu bionic"
        mongodb_repo_type="multiverse"
      else
        mongodb_codename="ubuntu xenial"
        mongodb_repo_type="multiverse"
      fi
    else
      if [[ "${os_codename}" =~ (trusty|qiana|rebecca|rafaela|rosa) ]]; then
        mongodb_codename="ubuntu xenial"
        mongodb_repo_type="multiverse"
      elif [[ "${os_codename}" =~ (xenial|sarah|serena|sonya|sylvia|bionic|tara|tessa|tina|tricia|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
        mongodb_codename="ubuntu xenial"
        mongodb_repo_type="multiverse"
      elif [[ "${os_codename}" == "jessie" ]]; then
        mongodb_codename="debian jessie"
        mongodb_repo_type="main"
      elif [[ "${os_codename}" =~ (stretch|continuum|buster|bullseye|bookworm|trixie|forky) ]]; then
        mongodb_codename="debian stretch"
        mongodb_repo_type="main"
      else
        mongodb_codename="ubuntu xenial"
        mongodb_repo_type="multiverse"
      fi
    fi
  fi
  if [[ "${mongodb_org_v::2}" == '44' ]] || [[ "${add_mongodb_44_repo}" == 'true' ]]; then
    mongodb_version_major_minor="4.4"
    if [[ "${try_different_mongodb_repo}" == 'true' ]] || [[ "${architecture}" != "amd64" ]]; then
      if [[ "${os_codename}" =~ (stretch|buster|bullseye|bookworm|trixie|forky|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
        mongodb_codename="ubuntu focal"
        mongodb_repo_type="multiverse"
      else
        mongodb_codename="ubuntu xenial"
        mongodb_repo_type="multiverse"
      fi
    else
      if [[ "${os_codename}" =~ (stretch|continuum) ]]; then
        mongodb_codename="debian stretch"
        mongodb_repo_type="main"
      elif [[ "${os_codename}" =~ (buster|bullseye|bookworm|trixie|forky) ]]; then
        mongodb_codename="debian buster"
        mongodb_repo_type="main"
      elif [[ "${os_codename}" =~ (xenial|sarah|serena|sonya|sylvia|loki) ]]; then
        mongodb_codename="ubuntu xenial"
        mongodb_repo_type="multiverse"
      elif [[ "${os_codename}" =~ (bionic|tara|tessa|tina|tricia|hera|juno) ]]; then
        mongodb_codename="ubuntu bionic"
        mongodb_repo_type="multiverse"
      elif [[ "${os_codename}" =~ (focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
        mongodb_codename="ubuntu focal"
        mongodb_repo_type="multiverse"
      else
        mongodb_codename="ubuntu xenial"
        mongodb_repo_type="multiverse"
      fi
    fi
  fi
  if [[ "${try_different_mongodb_repo}" == 'true' ]]; then try_different_mongodb_repo_test="a different"; try_different_mongodb_repo_test_2="different "; else try_different_mongodb_repo_test="the"; try_different_mongodb_repo_test_2=""; fi
  if [[ -n "${mongodb_version_major_minor}" ]]; then
    if ! [[ -e "/usr/share/keyrings/mongodb-server-${mongodb_version_major_minor}.gpg" ]]; then
      echo -e "${WHITE_R}#${RESET} Adding key for MongoDB ${mongodb_version_major_minor}..."
      aptkey_depreciated
      if [[ "${apt_key_deprecated}" == 'true' ]]; then
        if wget -qO - "https://www.mongodb.org/static/pgp/server-${mongodb_version_major_minor}.asc" | gpg --dearmor | tee -a "/usr/share/keyrings/mongodb-server-${mongodb_version_major_minor}.gpg" &> /dev/null; then echo -e "${GREEN}#${RESET} Successfully added the key for MongoDB ${mongodb_version_major_minor}! \\n"; signed_by_value=" signed-by=/usr/share/keyrings/mongodb-server-${mongodb_version_major_minor}.gpg"; else echo -e "${RED}#${RESET} Failed to add the key for MongoDB ${mongodb_version_major_minor}...\\n"; abort; fi
      else
        if wget -qO - "https://www.mongodb.org/static/pgp/server-${mongodb_version_major_minor}.asc" | apt-key add - &> /dev/null; then echo -e "${GREEN}#${RESET} Successfully added the key for MongoDB ${mongodb_version_major_minor}! \\n"; else echo -e "${RED}#${RESET} Failed to add the key for MongoDB ${mongodb_version_major_minor}...\\n"; abort; fi
      fi
    fi
    echo -e "${WHITE_R}#${RESET} Adding ${try_different_mongodb_repo_test} MongoDB ${mongodb_version_major_minor} repository..."
    if [[ "${architecture}" == 'arm64' ]]; then arch="arch=arm64"; elif [[ "${architecture}" == 'amd64' ]]; then arch="arch=amd64"; else arch="arch=amd64,arm64"; fi
    if echo "deb [ ${arch}${signed_by_value} ] https://repo.mongodb.org/apt/${mongodb_codename}/mongodb-org/${mongodb_version_major_minor} ${mongodb_repo_type}" &> "/etc/apt/sources.list.d/mongodb-org-${mongodb_version_major_minor}.list"; then
      echo -e "${GREEN}#${RESET} Successfully added the ${try_different_mongodb_repo_test_2}MongoDB ${mongodb_version_major_minor} repository!\\n" && sleep 2
      hide_apt_update=true
      run_apt_get_update
    else
      echo -e "${RED}#${RESET} Failed to add the ${try_different_mongodb_repo_test_2}MongoDB ${mongodb_version_major_minor} repository..."
      abort
    fi
  fi
}

# Check if system runs Unifi OS
if dpkg -l unifi-core 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  unifi_core_system=true
  if [[ -f /proc/ubnthal/system.info ]]; then if grep -iq "shortname" /proc/ubnthal/system.info; then unifi_core_device=$(grep "shortname" /proc/ubnthal/system.info | sed 's/shortname=//g'); fi; fi
  if [[ -f /etc/motd && -s /etc/motd && -z "${unifi_core_device}" ]]; then unifi_core_device=$(grep -io "welcome.*" /etc/motd | sed -e 's/Welcome //g' -e 's/to //g' -e 's/the //g' -e 's/!//g'); fi
  if [[ -f /usr/lib/version && -s /usr/lib/version && -z "${unifi_core_device}" ]]; then unifi_core_device=$(cut -d'.' -f1 /usr/lib/version); fi
  if [[ -z "${unifi_core_device}" ]]; then unifi_core_device='Unknown device'; fi
fi

cancel_script() {
  if [[ "${set_lc_all}" == 'true' ]]; then unset LC_ALL &> /dev/null; fi
  if [[ "${script_option_skip}" == 'true' ]]; then
    echo -e "\\n${WHITE_R}#########################################################################${RESET}\\n"
  else
    header
  fi
  echo -e "${WHITE_R}#${RESET} Cancelling the script!\\n\\n"
  exit 0
}

http_proxy_found() {
  header
  echo -e "${GREEN}#${RESET} HTTP Proxy found. | ${WHITE_R}${http_proxy}${RESET}\\n\\n"
}

remove_yourself() {
  if [[ "${set_lc_all}" == 'true' ]]; then unset LC_ALL &> /dev/null; fi
  if [[ "${delete_script}" == 'true' || "${script_option_skip}" == 'true' ]]; then if [[ -e "${script_location}" ]]; then rm --force "${script_location}" 2> /dev/null; fi; fi
}

christmass_new_year() {
  date_d=$(date '+%d' | sed "s/^0*//g; s/\.0*/./g")
  date_m=$(date '+%m' | sed "s/^0*//g; s/\.0*/./g")
  if [[ "${date_m}" == '12' && "${date_d}" -ge '18' && "${date_d}" -lt '26' ]]; then
    echo -e "\\n${WHITE_R}----${RESET}\\n"
    echo -e "${WHITE_R}#${RESET} GlennR wishes you a Merry Christmas! May you be blessed with health and happiness!"
    christmas_message=true
  fi
  if [[ "${date_m}" == '12' && "${date_d}" -ge '24' && "${date_d}" -le '30' ]]; then
    if [[ "${christmas_message}" != 'true' ]]; then echo -e "\\n${WHITE_R}----${RESET}\\n"; fi
    if [[ "${christmas_message}" == 'true' ]]; then echo -e ""; fi
    date_y=$(date -d "+1 year" +"%Y")
    echo -e "${WHITE_R}#${RESET} HAPPY NEW YEAR ${date_y}"
    echo -e "${WHITE_R}#${RESET} May the new year turn all your dreams into reality and all your efforts into great achievements!"
    new_year_message=true
  elif [[ "${date_m}" == '12' && "${date_d}" == '31' ]]; then
    if [[ "${christmas_message}" != 'true' ]]; then echo -e "\\n${WHITE_R}----${RESET}\\n"; fi
    if [[ "${christmas_message}" == 'true' ]]; then echo -e ""; fi
    date_y=$(date -d "+1 year" +"%Y")
    echo -e "${WHITE_R}#${RESET} HAPPY NEW YEAR ${date_y}"
    echo -e "${WHITE_R}#${RESET} Tomorrow, is the first blank page of a 365 page book. Write a good one!"
    new_year_message=true
  fi
  if [[ "${date_m}" == '1' && "${date_d}" -le '5' ]]; then
    if [[ "${christmas_message}" != 'true' ]]; then echo -e "\\n${WHITE_R}----${RESET}\\n"; fi
    if [[ "${christmas_message}" == 'true' ]]; then echo -e ""; fi
    date_y=$(date '+%Y')
    echo -e "${WHITE_R}#${RESET} HAPPY NEW YEAR ${date_y}"
    echo -e "${WHITE_R}#${RESET} May this new year all your dreams turn into reality and all your efforts into great achievements"
    new_year_message=true
  fi
}

remove_glennr_source_list() {
  if [[ -f "/etc/apt/sources.list.d/glennr-install-script.list" ]]; then
    get_distro
    awk '{print $3}' /etc/apt/sources.list.d/glennr-install-script.list | awk '!a[$0]++' | sed "/${os_codename}/d" | sed 's/ //g' &> /tmp/EUS/sourcelist
    while read -r sourcelist_os_codename; do
      sed -i "/${sourcelist_os_codename}/d" /etc/apt/sources.list.d/glennr-install-script.list &> /dev/null
    done < /tmp/EUS/sourcelist
    rm --force /tmp/EUS/sourcelist &> /dev/null
    if ! [[ -s "/etc/apt/sources.list.d/glennr-install-script.list" ]]; then
      rm --force /etc/apt/sources.list.d/glennr-install-script.list &> /dev/null
    fi
  fi
}

author() {
  remove_glennr_source_list
  christmass_new_year
  if [[ "${new_year_message}" == 'true' || "${christmas_message}" == 'true' ]]; then echo -e "\\n${WHITE_R}----${RESET}\\n"; fi
  if [[ "${archived_repo}" == 'true' && "${unifi_core_system}" != 'true' ]]; then echo -e "\\n${WHITE_R}----${RESET}\\n\\n${RED}# ${RESET}Looks like you're using a ${RED}EOL/unsupported${RESET} OS Release (${os_codename})\\n${RED}# ${RESET}Please update to a supported release...\\n"; fi
  if [[ "${archived_repo}" == 'true' && "${unifi_core_system}" == 'true' ]]; then echo -e "\\n${WHITE_R}----${RESET}\\n\\n${RED}# ${RESET}Please update to the latest UniFi OS Release!\\n"; fi
  echo -e "${WHITE_R}#${RESET} ${GRAY_R}Author   |  ${WHITE_R}Glenn R.${RESET}"
  echo -e "${WHITE_R}#${RESET} ${GRAY_R}Email    |  ${WHITE_R}glennrietveld8@hotmail.nl${RESET}"
  echo -e "${WHITE_R}#${RESET} ${GRAY_R}Website  |  ${WHITE_R}https://GlennR.nl${RESET}"
  echo -e "\\n\\n"
}

# Get distro.
get_distro() {
  if [[ -z "$(command -v lsb_release)" ]]; then
    if [[ -f "/etc/os-release" ]]; then
      if grep -iq VERSION_CODENAME /etc/os-release; then
        os_codename=$(grep VERSION_CODENAME /etc/os-release | sed 's/VERSION_CODENAME//g' | tr -d '="' | tr '[:upper:]' '[:lower:]')
      elif ! grep -iq VERSION_CODENAME /etc/os-release; then
        os_codename=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="' | awk '{print $4}' | sed 's/\((\|)\)//g' | sed 's/\/sid//g' | tr '[:upper:]' '[:lower:]')
        if [[ -z "${os_codename}" ]]; then
          os_codename=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="' | awk '{print $3}' | sed 's/\((\|)\)//g' | sed 's/\/sid//g' | tr '[:upper:]' '[:lower:]')
        fi
      fi
    fi
  else
    os_codename=$(lsb_release -cs | tr '[:upper:]' '[:lower:]')
    if [[ "${os_codename}" == 'n/a' ]]; then
      os_codename=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
    fi
  fi
  if [[ "${os_codename}" =~ ^(precise|maya|luna)$ ]]; then repo_codename=precise; os_codename=precise
  elif [[ "${os_codename}" =~ ^(trusty|qiana|rebecca|rafaela|rosa|freya)$ ]]; then repo_codename=trusty; os_codename=trusty
  elif [[ "${os_codename}" =~ ^(xenial|sarah|serena|sonya|sylvia|loki)$ ]]; then repo_codename=xenial; os_codename=xenial
  elif [[ "${os_codename}" =~ ^(bionic|tara|tessa|tina|tricia|hera|juno)$ ]]; then repo_codename=bionic; os_codename=bionic
  elif [[ "${os_codename}" =~ ^(focal|ulyana|ulyssa|uma|una)$ ]]; then repo_codename=focal; os_codename=focal
  elif [[ "${os_codename}" =~ ^(jammy|vanessa|vera|victoria)$ ]]; then repo_codename=jammy; os_codename=jammy
  elif [[ "${os_codename}" =~ ^(stretch|continuum)$ ]]; then repo_codename=stretch; os_codename=stretch
  elif [[ "${os_codename}" =~ ^(buster|debbie|parrot|engywuck-backports|engywuck|deepin)$ ]]; then repo_codename=buster; os_codename=buster
  elif [[ "${os_codename}" =~ ^(bullseye|kali-rolling|elsie|ara)$ ]]; then repo_codename=bullseye; os_codename=bullseye
  else
    repo_codename="${os_codename}"
  fi
}
get_distro

get_repo_url() {
  unset archived_repo
  if dpkg -l curl 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
    if [[ "${os_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      if curl -s http://old-releases.ubuntu.com/ubuntu/dists/ | grep -iq "${os_codename}" 2> /dev/null; then archived_repo=true; fi
      if [[ "${archived_repo}" == "true" ]]; then repo_url="http://old-releases.ubuntu.com/ubuntu"; else repo_url="http://archive.ubuntu.com/ubuntu"; fi
    elif [[ "${os_codename}" =~ (jessie|stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
      if curl -s http://archive.debian.org/debian/dists/ | grep -iq "${os_codename}" 2> /dev/null; then archived_repo=true; fi
      if [[ "${archived_repo}" == "true" ]]; then repo_url="https://archive.debian.org/debian"; else repo_url="https://ftp.debian.org/debian"; fi
    fi
  else
    if [[ "${os_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      repo_url="http://archive.ubuntu.com/ubuntu"
    elif [[ "${os_codename}" =~ (jessie|stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
      repo_url="https://archive.debian.org/debian"
    fi
  fi
}
get_repo_url

add_repositories() {
  if [[ $(find /etc/apt/ -name "*.list" -type f -print0 | xargs -0 cat | grep -c "^deb http[s]*://$(echo "${repo_url}" | sed -e 's/https\:\/\///g' -e 's/http\:\/\///g') ${repo_codename}${repo_arguments}") -eq 0 ]]; then
    if ! echo -e "deb ${repo_url} ${repo_codename}${repo_arguments}" &>> /etc/apt/sources.list.d/glennr-install-script.list; then
      echo -e "${RED}#{WHITE_R} Failed to add repository...\\n"
      abort
    fi
    if [[ -n "${missing_key}" ]]; then if ! echo -e "${missing_key}" &>> /tmp/EUS/keys/missing_keys; then echo "${RED}#{WHITE_R} Failed to add missing key \"${missing_key}\" to \"/tmp/EUS/keys/missing_keys\"...\\n"; fi; fi
    unset missing_key
  fi
}

if ! [[ "${os_codename}" =~ (precise|maya|trusty|qiana|rebecca|rafaela|rosa|xenial|sarah|serena|sonya|sylvia|bionic|tara|tessa|tina|tricia|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic|jessie|stretch|continuum|buster|bullseye|bookworm|trixie|forky) ]]; then
  clear
  header_red
  echo -e "${WHITE_R}#${RESET} This script is not made for your OS.."
  echo -e "${WHITE_R}#${RESET} Feel free to contact Glenn R. (AmazedMender16) on the Community Forums if you need help with installing your UniFi Network Application."
  echo -e ""
  echo -e "OS_CODENAME = ${os_codename}"
  echo -e ""
  echo -e ""
  exit 1
fi

if ! grep -iq '^127.0.0.1.*localhost' /etc/hosts; then
  clear
  header_red
  echo -e "${WHITE_R}#${RESET} '127.0.0.1   localhost' does not exist in your /etc/hosts file."
  echo -e "${WHITE_R}#${RESET} You will most likely see application startup issues if it doesn't exist..\\n\\n"
  read -rp $'\033[39m#\033[0m Do you want to add "127.0.0.1   localhost" to your /etc/hosts file? (Y/n) ' yes_no
  case "$yes_no" in
      [Yy]*|"")
          echo -e "${WHITE_R}----${RESET}\\n"
          echo -e "${WHITE_R}#${RESET} Adding '127.0.0.1       localhost' to /etc/hosts"
          sed  -i '1i # ------------------------------' /etc/hosts
          sed  -i '1i 127.0.0.1       localhost' /etc/hosts
          sed  -i '1i # Added by GlennR EUS script' /etc/hosts && echo -e "${WHITE_R}#${RESET} Done..\\n\\n"
          sleep 3;;
      [Nn]*) ;;
  esac
fi

if [[ $(echo "${PATH}" | grep -c "/sbin") -eq 0 ]]; then
  #PATH=/sbin:/bin:/usr/bin:/usr/sbin:/usr/local/sbin:/usr/local/bin
  #PATH=$PATH:/usr/sbin
  PATH="$PATH:/sbin:/bin:/usr/bin:/usr/sbin:/usr/local/sbin:/usr/local/bin"
fi

if ! [[ -d /etc/apt/sources.list.d ]]; then mkdir -p /etc/apt/sources.list.d; fi
if ! [[ -d /tmp/EUS/keys ]]; then mkdir -p /tmp/EUS/keys; fi

unifi_package=$(dpkg -l | grep "unifi " | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
if [[ -n "${unifi_package}" ]]; then
  if [[ "${unifi_package}" != "ii" ]]; then
    header_red
    echo -e "${RED}#${RESET} You have a broken UniFi Network Application installation...\\n\\n${WHITE}#${RESET} Removing the broken UniFi Network Application installation..."
    if dpkg --remove --force-remove-reinstreq unifi &>> "${eus_dir}/logs/broken_unifi.log"; then echo -e "${GREEN}#${RESET} Successfully removed the broken UniFi Network Application installation!"; else echo -e "${RED}#${RESET} Failed to remove the broken UniFi Network Application installation!"; fi
    sleep 3  
  fi
fi

# Check if --show-progrss is supported in wget version
if wget --help | grep -q '\--show-progress'; then if ! grep -q "show-progress" /tmp/EUS/wget_option &> /dev/null; then echo "--show-progress" &>> /tmp/EUS/wget_option; fi; fi
if [[ -f /tmp/EUS/wget_option && -s /tmp/EUS/wget_option ]]; then IFS=" " read -r -a wget_progress <<< "$(tr '\r\n' ' ' < /tmp/EUS/wget_option)"; rm --force /tmp/EUS/wget_option &> /dev/null; fi

# Check if --allow-change-held-packages is supported in apt
# Disabled for arm64 due to MongoDB 4.4 issues
architecture=$(dpkg --print-architecture)
if [[ "${architecture}" == 'i686' ]]; then architecture="i386"; fi
if ! [[ "${architecture}" == "arm64" ]]; then
  if [[ "$(dpkg -l apt | grep ^"ii" | awk '{print $2,$3}' | awk '{print $2}' | cut -d'.' -f1)" -ge "1" ]] || [[ "$(dpkg -l apt | grep ^"ii" | awk '{print $2,$3}' | awk '{print $2}' | cut -d'.' -f1)" == "1" ]] && [[ "$(dpkg -l apt | grep ^"ii" | awk '{print $2,$3}' | awk '{print $2}' | cut -d'.' -f2)" -ge "1" ]]; then if ! grep -q "allow-change-held-packages" /tmp/EUS/apt_option &> /dev/null; then echo "--allow-change-held-packages" &>> /tmp/EUS/apt_option; fi; fi
  if [[ -f /tmp/EUS/apt_option && -s /tmp/EUS/apt_option ]]; then IFS=" " read -r -a apt_options <<< "$(tr '\r\n' ' ' < /tmp/EUS/apt_option)"; rm --force /tmp/EUS/apt_option &> /dev/null; fi
fi

# Check if UniFi is already installed.
if dpkg -l | grep "unifi " | grep -q "^ii\\|^hi"; then
  header
  echo -e "${WHITE_R}#${RESET} UniFi is already installed on your system!${RESET}"
  echo -e "${WHITE_R}#${RESET} You can use my Easy Update Script to update your UniFi Network Application.${RESET}\\n\\n"
  read -rp $'\033[39m#\033[0m Would you like to download and run my Easy Update Script? (Y/n) ' yes_no
  case "$yes_no" in
      [Yy]*|"")
        rm --force "${script_location}" 2> /dev/null
        wget -q "${wget_progress[@]}" https://get.glennr.nl/unifi/update/unifi-update.sh && bash unifi-update.sh; exit 0;;
      [Nn]*) exit 0;;
  esac
fi

dpkg_locked_message() {
  header_red
  echo -e "${WHITE_R}#${RESET} dpkg is locked.. Waiting for other software managers to finish!"
  echo -e "${WHITE_R}#${RESET} If this is everlasting please contact Glenn R. (AmazedMender16) on the Community Forums!\\n\\n"
  sleep 5
  if [[ -z "$dpkg_wait" ]]; then
    echo "glennr_lock_active" >> /tmp/glennr_lock
  fi
}

dpkg_locked_60_message() {
  header
  echo -e "${WHITE_R}#${RESET} dpkg is already locked for 60 seconds..."
  echo -e "${WHITE_R}#${RESET} Would you like to force remove the lock?\\n\\n"
}

# Check if dpkg is locked
if dpkg -l psmisc 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  while fuser /var/lib/dpkg/lock /var/lib/apt/lists/lock /var/cache/apt/archives/lock >/dev/null 2>&1; do
    dpkg_locked_message
    if [[ $(grep -c "glennr_lock_active" /tmp/glennr_lock) -ge 12 ]]; then
      rm --force /tmp/glennr_lock 2> /dev/null
      dpkg_locked_60_message
      if [[ "${script_option_skip}" != 'true' ]]; then read -rp $'\033[39m#\033[0m Do you want to proceed with removing the lock? (Y/n) ' yes_no; fi
      case "$yes_no" in
          [Yy]*|"")
            killall apt apt-get 2> /dev/null
            rm --force /var/lib/apt/lists/lock 2> /dev/null
            rm --force /var/cache/apt/archives/lock 2> /dev/null
            rm --force /var/lib/dpkg/lock* 2> /dev/null
            dpkg --configure -a 2> /dev/null
            DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install --fix-broken 2> /dev/null;;
          [Nn]*) dpkg_wait=true;;
      esac
    fi
  done;
else
  dpkg -i /dev/null 2> /tmp/glennr_dpkg_lock; if grep -q "locked.* another" /tmp/glennr_dpkg_lock; then dpkg_locked=true; rm --force /tmp/glennr_dpkg_lock 2> /dev/null; fi
  while [[ "${dpkg_locked}" == 'true'  ]]; do
    unset dpkg_locked
    dpkg_locked_message
    if [[ $(grep -c "glennr_lock_active" /tmp/glennr_lock) -ge 12 ]]; then
      rm --force /tmp/glennr_lock 2> /dev/null
      dpkg_locked_60_message
      if [[ "${script_option_skip}" != 'true' ]]; then read -rp $'\033[39m#\033[0m Do you want to proceed with force removing the lock? (Y/n) ' yes_no; fi
      case "$yes_no" in
          [Yy]*|"")
            pgrep "apt" >> /tmp/EUS/apt
            while read -r glennr_apt; do
              kill -9 "$glennr_apt" 2> /dev/null
            done < /tmp/EUS/apt
            rm --force /tmp/EUS/apt 2> /dev/null
            rm --force /var/lib/apt/lists/lock 2> /dev/null
            rm --force /var/cache/apt/archives/lock 2> /dev/null
            rm --force /var/lib/dpkg/lock* 2> /dev/null
            dpkg --configure -a 2> /dev/null
            DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install --fix-broken 2> /dev/null;;
          [Nn]*) dpkg_wait=true;;
      esac
    fi
    dpkg -i /dev/null 2> /tmp/glennr_dpkg_lock; if grep -q "locked.* another" /tmp/glennr_dpkg_lock; then dpkg_locked=true; rm --force /tmp/glennr_dpkg_lock 2> /dev/null; fi
  done;
  rm --force /tmp/glennr_dpkg_lock 2> /dev/null
fi

script_version_check() {
  if dpkg -l curl 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
    version=$(grep -i "# Application version" "${script_location}" | head -n 1 | cut -d'|' -f2 | sed 's/ //g' | cut -d'-' -f1)
    script_online_version_dots=$(curl -s "https://get.glennr.nl/unifi/install/unifi-${version}.sh" | grep -i "# Version" | head -n 1 | cut -d'|' -f2 | sed 's/ //g')
    script_local_version_dots=$(grep -i "# Version" "${script_location}" | head -n 1 | cut -d'|' -f2 | sed 's/ //g' | cut -d'-' -f1)
    script_online_version="${script_online_version_dots//./}"
    script_local_version="${script_local_version_dots//./}"
    # Script version check.
    if [[ "${script_online_version::3}" -gt "${script_local_version::3}" ]]; then
      header_red
      echo -e "${WHITE_R}#${RESET} You're currently running script version ${script_local_version_dots} while ${script_online_version_dots} is the latest!"
      echo -e "${WHITE_R}#${RESET} Downloading and executing version ${script_online_version_dots} of the Easy Installation Script..\\n\\n"
      sleep 3
      rm --force "${script_location}" 2> /dev/null
      rm --force "unifi-${version}.sh" 2> /dev/null
      # shellcheck disable=SC2068
      wget -q "${wget_progress[@]}" "https://get.glennr.nl/unifi/install/unifi-${version}.sh" && bash "unifi-${version}.sh" ${script_options[@]}; exit 0
    fi
  fi
}
script_version_check

armhf_recommendation() {
  print_architecture=$(dpkg --print-architecture)
  if [[ "${print_architecture}" == 'armhf' && "${is_cloudkey}" == "false" ]]; then
    header_red
    echo -e "${WHITE_R}#${RESET} Your installation might fail, please consider getting a Cloud Key Gen2 or go with a VPS at OVH/DO/AWS."
    if [[ "${os_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      echo -e "${WHITE_R}#${RESET} You could try using Debian Bullseye before going with a UCK G2 ( PLUS ) or VPS"
    fi
    echo -e "\\n${WHITE_R}#${RESET} UniFi Cloud Key Gen2       | https://store.ui.com/products/unifi-cloud-key-gen2"
    echo -e "${WHITE_R}#${RESET} UniFi Cloud Key Gen2 Plus  | https://store.ui.com/products/unifi-cloudkey-gen2-plus\\n\\n"
    sleep 20
  fi
}

armhf_recommendation

check_service_overrides() {
  if [[ -e "/etc/systemd/system/unifi.service" ]] || [[ -e "/etc/systemd/system/unifi.service.d/" ]]; then
    echo -e "${WHITE_R}#${RESET} UniFi Network Application service overrides detected... Removing them..."
    if ! [[ -d "${eus_dir}/unifi-service-overrides/${unifi_clean}/" ]]; then if ! mkdir -p "${eus_dir}/unifi-service-overrides/${unifi_clean}/"; then echo -e "${RED}#${RESET} Failed to create required EUS UniFi Service Overrides directory..."; fi; fi
    if [[ -d "${eus_dir}/unifi-service-overrides/${unifi_clean}/" ]]; then
      if [[ -e "/etc/systemd/system/unifi.service" ]]; then
        mv "/etc/systemd/system/unifi.service" "${eus_dir}/unifi-service-overrides/${unifi_clean}/unifi.service" &>> "${eus_dir}/logs/service-override.log"
      fi
      if [[ -e "/etc/systemd/system/unifi.service.d/" ]]; then
        find /etc/systemd/system/unifi.service.d/ -type f &> "${eus_dir}/unifi-service-overrides/override-files-tmp.list"
        while read -r override_file; do
          override_file_name="$(basename "${override_file}")"
          mv "${override_file}" "${eus_dir}/unifi-service-overrides/${unifi_clean}/${override_file_name}" &>> "${eus_dir}/logs/service-override.log"
        done < "${eus_dir}/unifi-service-overrides/override-files-tmp.list"
        rm --force "${eus_dir}/unifi-service-overrides/override-files-tmp.list" &> /dev/null
      fi
    fi
    if systemctl revert unifi &>> "${eus_dir}/logs/service-override.log"; then
      echo -e "${GREEN}#${RESET} Successfully reverted the UniFi Network Application service overrides! \\n"
    else
      echo -e "${RED}#${RESET} Failed to revert the UniFi Network Application service overrides...\\n"
    fi
    sleep 3
  fi
}

custom_url_question() {
  header
  echo -e "${WHITE_R}#${RESET} Please enter the application download URL below."
  read -rp $'\033[39m#\033[0m ' custom_download_url
  custom_url_download_check
}

custom_url_upgrade_check() {
  echo -e "\\n${WHITE_R}----${RESET}\\n"
  echo -e "${YELLOW}#${RESET} The script will now install application version: ${unifi_clean}!" && sleep 3
  custom_url_check=success
}

custom_url_download_check() {
  mkdir -p /tmp/EUS/downloads &> /dev/null
  unifi_temp="$(mktemp --tmpdir=/tmp/EUS/downloads unifi_sysvinit_all_XXXXX.deb)"
  header
  echo -e "${WHITE_R}#${RESET} Downloading the application release..."
  echo -e "\\n------- $(date +%F-%R) -------\\n" &>> "${eus_dir}/logs/unifi_custom_url_download.log"
  if ! wget -O "$unifi_temp" "${custom_download_url}" &>> "${eus_dir}/logs/unifi_custom_url_download.log"; then
    header_red
    echo -e "${WHITE_R}#${RESET} The URL you provided cannot be downloaded.. Please provide a working URL."
    sleep 3
    custom_url_question
  else
    dpkg -I "${unifi_temp}" | awk '{print tolower($0)}' &> "${unifi_temp}.tmp"
    package_maintainer=$(awk '/maintainer/{print$2}' "${unifi_temp}.tmp")
    unifi_clean=$(awk '/version/{print$2}' "${unifi_temp}.tmp" | grep -io "5.*\\|6.*\\|7.*\\|8.*" | cut -d'-' -f1 | cut -d'/' -f1)
    rm --force "${unifi_temp}.tmp" &> /dev/null
    if [[ "${package_maintainer}" =~ (unifi|ubiquiti) ]]; then
      echo -e "${GREEN}#${RESET} Successfully downloaded the application release!"
      sleep 2
      custom_url_upgrade_check
    else
      header_red
      echo -e "${WHITE_R}#${RESET} You did not provide a UniFi Network Application that is maintained by Ubiquiti ( UniFi )..."
      read -rp $'\033[39m#\033[0m Do you want to provide the script with another URL? (Y/n) ' yes_no
      case "$yes_no" in
          [Yy]*|"") custom_url_question;;
          [Nn]*) ;;
      esac
    fi
  fi
}

if [[ "${script_option_custom_url}" == 'true' ]]; then if [[ "${custom_url_down_provided}" == 'true' ]]; then custom_url_download_check; else custom_url_question; fi; fi

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                        Required Packages                                                                                        #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

# Install needed packages if not installed
install_required_packages() {
  sleep 2
  installing_required_package=yes
  header
  echo -e "${WHITE_R}#${RESET} Installing required packages for the script..\\n"
  hide_apt_update=true
  run_apt_get_update
  sleep 2
}
apt_get_install_package() {
  if [[ "${old_openjdk_version}" == 'true' ]]; then
    apt_get_install_package_variable="update"
    apt_get_install_package_variable_2="updated"
  else
    apt_get_install_package_variable="install"
    apt_get_install_package_variable_2="installed"
  fi
  hide_apt_update=true
  run_apt_get_update
  echo -e "\\n------- ${required_package} installation ------- $(date +%F-%R) -------\\n" &>> "${eus_dir}/logs/apt.log"
  echo -e "${WHITE_R}#${RESET} Trying to ${apt_get_install_package_variable} ${required_package}..."
  if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg6::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install "${required_package}" &>> "${eus_dir}/logs/apt.log"; then
    echo -e "${GREEN}#${RESET} Successfully ${apt_get_install_package_variable_2} ${required_package}! \\n"
    sleep 2
  else
    echo -e "${RED}#${RESET} Failed to ${apt_get_install_package_variable} ${required_package}...\\n"
    if [[ "${required_package}" == "openjdk-11-jre-headless" ]] && [[ "${repo_codename}" =~ (stretch|continuum) ]]; then
      if grep -Eiq "openjdk-11-jre-headless.*Depends.*libjpeg8" "${eus_dir}/logs/apt.log"; then
        repo_codename="stretch"
        repo_arguments="-backports main"
        add_repositories
        hide_apt_update="true"
        run_apt_get_update
        get_distro
        get_repo_url
        if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg6::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install "${required_package}" -t stretch-backports &>> "${eus_dir}/logs/apt.log"; then
          echo -e "${GREEN}#${RESET} Successfully ${apt_get_install_package_variable_2} ${required_package}! \\n"
          sleep 2
          unset required_package
          return
        fi
      fi
    fi
    if [[ "${required_package}" =~ (openjdk-11-jre-headless|openjdk-17-jre-headless) ]]; then
      if ! [[ -f "/etc/java-${required_java_version_short}-openjdk/security/java.security" ]]; then
        echo -e "\\n------- ${required_package} installation ------- $(date +%F-%R) -------\\n" &>> "${eus_dir}/logs/java.security-fix-required.log"
        echo -e "$(date +%F-%R) | \"/etc/java-${required_java_version_short}-openjdk/security/java.security\" is missing..." &>> "${eus_dir}/logs/java.security-fix-required.log"
        if [[ -f "/etc/java-${required_java_version_short}-openjdk/security/java.security.dpkg-new" ]]; then
          echo -e "$(date +%F-%R) | \"/etc/java-${required_java_version_short}-openjdk/security/java.security.dpkg-new\" exists, copying it to \"/etc/java-${required_java_version_short}-openjdk/security/java.security\"..." &>> "${eus_dir}/logs/java.security-fix-required.log"
          if cp "/etc/java-${required_java_version_short}-openjdk/security/java.security.dpkg-new" "/etc/java-${required_java_version_short}-openjdk/security/java.security" &>> "${eus_dir}/logs/java.security-fix-required.log"; then
            echo -e "$(date +%F-%R) | Successfully copied \"/etc/java-${required_java_version_short}-openjdk/security/java.security.dpkg-new\" to \"/etc/java-${required_java_version_short}-openjdk/security/java.security\"!" &>> "${eus_dir}/logs/java.security-fix-required.log"
            if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg6::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install "${required_package}" &>> "${eus_dir}/logs/apt.log"; then
              echo -e "${GREEN}#${RESET} Successfully ${apt_get_install_package_variable_2} ${required_package}! \\n"
              sleep 2
              unset required_package
              return
            fi
          else
            echo -e "$(date +%F-%R) | Failed to copy \"/etc/java-${required_java_version_short}-openjdk/security/java.security.dpkg-new\" to \"/etc/java-${required_java_version_short}-openjdk/security/java.security\"..." &>> "${eus_dir}/logs/java.security-fix-required.log"
          fi
        fi
      fi
    fi
    if [[ "${required_package}" =~ (openjdk-8-jre-headless|openjdk-11-jre-headless|openjdk-17-jre-headless) ]]; then
      adoptium_java
      if [[ "${added_adoptium}" == 'true' ]]; then
        echo -e "${WHITE_R}#${RESET} Trying to ${apt_get_install_package_variable} temurin-${required_java_version_short}-jdk..."
        if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg6::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install "temurin-${required_java_version_short}-jdk" &>> "${eus_dir}/logs/apt.log"; then
          echo -e "${GREEN}#${RESET} Successfully ${apt_get_install_package_variable_2} temurin-${required_java_version_short}-jdk! \\n"
          sleep 2
          unset required_package
          return
        else
          required_package="${required_package} or temurin-${required_java_version_short}-jdk"
        fi
      fi
    fi
    abort
  fi
  unset required_package
}

if ! dpkg -l curl 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  if [[ "${installing_required_package}" != 'yes' ]]; then install_required_packages; fi
  echo -e "${WHITE_R}#${RESET} Installing curl..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install curl &>> "${eus_dir}/logs/required.log"; then
    echo -e "${RED}#${RESET} Failed to install curl in the first run...\\n"
    if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic) ]]; then repo_arguments="-security main"; fi
      if [[ "${repo_codename}" =~ (disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then repo_arguments=" main"; fi
    elif [[ "${repo_codename}" == "jessie" ]]; then
      repo_arguments="/updates main"
    elif [[ "${repo_codename}" =~ (stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
      repo_arguments=" main"
    fi
    add_repositories
    required_package="curl"
    apt_get_install_package
  else
    echo -e "${GREEN}#${RESET} Successfully installed curl! \\n" && sleep 2
  fi
  script_version_check
  get_repo_url
fi
if ! dpkg -l sudo 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  if [[ "${installing_required_package}" != 'yes' ]]; then install_required_packages; fi
  echo -e "${WHITE_R}#${RESET} Installing sudo..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install sudo &>> "${eus_dir}/logs/required.log"; then
    echo -e "${RED}#${RESET} Failed to install sudo in the first run...\\n"
    repo_arguments=" main"
    add_repositories
    required_package="sudo"
    apt_get_install_package
  else
    echo -e "${GREEN}#${RESET} Successfully installed sudo! \\n" && sleep 2
  fi
fi
if ! dpkg -l jq 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  if [[ "${installing_required_package}" != 'yes' ]]; then
    install_required_packages
  fi
  echo -e "${WHITE_R}#${RESET} Installing jq..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install jq &>> "${eus_dir}/logs/required.log"; then
    echo -e "${RED}#${RESET} Failed to install jq in the first run...\\n"
    if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      repo_arguments="-security main universe"
    elif [[ "${repo_codename}" =~ (jessie|stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
      repo_arguments=" main"
    fi
    add_repositories
    required_package="jq"
    apt_get_install_package
  else
    echo -e "${GREEN}#${RESET} Successfully installed jq! \\n" && sleep 2
  fi
fi
if ! dpkg -l lsb-release 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  if [[ "${installing_required_package}" != 'yes' ]]; then install_required_packages; fi
  echo -e "${WHITE_R}#${RESET} Installing lsb-release..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install lsb-release &>> "${eus_dir}/logs/required.log"; then
    echo -e "${RED}#${RESET} Failed to install lsb-release in the first run...\\n"
    if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      repo_arguments=" main universe"
    elif [[ "${repo_codename}" =~ (jessie|stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
      repo_arguments=" main"
    fi
    add_repositories
    required_package="lsb-release"
    apt_get_install_package
  else
    echo -e "${GREEN}#${RESET} Successfully installed lsb-release! \\n" && sleep 2
  fi
fi
if ! dpkg -l net-tools 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  if [[ "${installing_required_package}" != 'yes' ]]; then install_required_packages; fi
  echo -e "${WHITE_R}#${RESET} Installing net-tools..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install net-tools &>> "${eus_dir}/logs/required.log"; then
    echo -e "${RED}#${RESET} Failed to install net-tools in the first run...\\n"
    repo_arguments=" main"
    add_repositories
    required_package="net-tools"
    apt_get_install_package
  else
    echo -e "${GREEN}#${RESET} Successfully installed net-tools! \\n" && sleep 2
  fi
fi
if dpkg -l apt 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  apt_version_1=$(dpkg -l apt | grep ^"ii" | awk '{print $3}' | cut -d'.' -f1)
  if [[ "${apt_version_1}" -le "1" ]]; then
    apt_version_2=$(dpkg -l apt | grep ^"ii" | awk '{print $3}' | cut -d'.' -f2)
    if [[ "${apt_version_1}" == "0" ]] || [[ "${apt_version_2}" -le "4" ]]; then
      if ! dpkg -l apt-transport-https 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
        if [[ "${installing_required_package}" != 'yes' ]]; then install_required_packages; fi
        echo -e "${WHITE_R}#${RESET} Installing apt-transport-https..."
        if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install apt-transport-https &>> "${eus_dir}/logs/required.log"; then
          echo -e "${RED}#${RESET} Failed to install apt-transport-https in the first run...\\n"
          if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
            if [[ "${repo_codename}" =~ (precise|trusty|xenial) ]]; then repo_arguments="-security main"; fi
            if [[ "${repo_codename}" =~ (bionic|cosmic) ]]; then repo_arguments="-security main universe"; fi
            if [[ "${repo_codename}" =~ (disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then repo_arguments=" main universe"; fi
          elif [[ "${repo_codename}" == "jessie" ]]; then
            repo_arguments="/updates main"
          elif [[ "${repo_codename}" =~ (stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
            repo_arguments=" main"
          fi
          add_repositories
          required_package="apt-transport-https"
          apt_get_install_package
        else
          echo -e "${GREEN}#${RESET} Successfully installed apt-transport-https! \\n" && sleep 2
        fi
      fi
    fi
  fi
fi
if ! dpkg -l software-properties-common 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  if [[ "${installing_required_package}" != 'yes' ]]; then install_required_packages; fi
  echo -e "${WHITE_R}#${RESET} Installing software-properties-common..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install software-properties-common &>> "${eus_dir}/logs/required.log"; then
    echo -e "${RED}#${RESET} Failed to install software-properties-common in the first run...\\n"
    if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      if [[ "${repo_codename}" =~ (precise) ]]; then repo_arguments="-security main"; fi
      if [[ "${repo_codename}" =~ (trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then repo_arguments=" main"; fi
    elif [[ "${repo_codename}" =~ (jessie|stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
      repo_arguments=" main"
    fi
    add_repositories
    required_package="software-properties-common"
    apt_get_install_package
  else
    echo -e "${GREEN}#${RESET} Successfully installed software-properties-common! \\n" && sleep 2
  fi
fi
if ! dpkg -l dirmngr 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  if [[ "${installing_required_package}" != 'yes' ]]; then install_required_packages; fi
  echo -e "${WHITE_R}#${RESET} Installing dirmngr..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install dirmngr &>> "${eus_dir}/logs/required.log"; then
    echo -e "${RED}#${RESET} Failed to install dirmngr in the first run...\\n"
    if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      repo_arguments=" universe"
      add_repositories
      repo_arguments=" main restricted"
    elif [[ "${repo_codename}" =~ (jessie|stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
      repo_arguments=" main"
    fi
    add_repositories
    required_package="dirmngr"
    apt_get_install_package
  else
    echo -e "${GREEN}#${RESET} Successfully installed dirmngr! \\n" && sleep 2
  fi
fi
if ! dpkg -l wget 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  if [[ "${installing_required_package}" != 'yes' ]]; then install_required_packages; fi
  echo -e "${WHITE_R}#${RESET} Installing wget..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install wget &>> "${eus_dir}/logs/required.log"; then
    echo -e "${RED}#${RESET} Failed to install wget in the first run...\\n"
    if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic) ]]; then repo_arguments="-security main"; fi
      if [[ "${repo_codename}" =~ (disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then repo_arguments=" main"; fi
    elif [[ "${repo_codename}" == "jessie" ]]; then
      repo_arguments="/updates main"
    elif [[ "${repo_codename}" =~ (stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
      repo_arguments=" main"
    fi
    add_repositories
    required_package="wget"
    apt_get_install_package
  else
    echo -e "${GREEN}#${RESET} Successfully installed wget! \\n" && sleep 2
  fi
fi
if ! dpkg -l netcat netcat-traditional 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  if [[ "${installing_required_package}" != 'yes' ]]; then install_required_packages; fi
  echo -e "${WHITE_R}#${RESET} Installing netcat..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install netcat &>> "${eus_dir}/logs/required.log"; then
    echo -e "${RED}#${RESET} Failed to install netcat in the first run...\\n"
    if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      repo_arguments=" universe"
    elif [[ "${repo_codename}" =~ (jessie|stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
      repo_arguments=" main"
    fi
    add_repositories
    if apt-cache search netcat | grep "^netcat\b" | awk '{print$1}' | grep -iq "traditional"; then
      required_package="netcat-traditional"
    else
      required_package="netcat"
    fi
    apt_get_install_package
  else
    echo -e "${GREEN}#${RESET} Successfully installed netcat! \\n" && sleep 2
  fi
  netcat_installed=true
fi
if ! dpkg -l psmisc 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  if [[ "${installing_required_package}" != 'yes' ]]; then install_required_packages; fi
  echo -e "${WHITE_R}#${RESET} Installing psmisc..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install psmisc &>> "${eus_dir}/logs/required.log"; then
    echo -e "${RED}#${RESET} Failed to install psmisc in the first run...\\n"
    if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      if [[ "${repo_codename}" =~ (precise) ]]; then repo_arguments="-updates main restricted"; fi
      if [[ "${repo_codename}" =~ (trusty|xenial|bionic|cosmicdisco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then repo_arguments=" universe"; fi
    elif [[ "${repo_codename}" =~ (jessie|stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
      repo_arguments=" main"
    fi
    add_repositories
    required_package="psmisc"
    apt_get_install_package
  else
    echo -e "${GREEN}#${RESET} Successfully installed psmisc! \\n" && sleep 2
  fi
fi
if ! dpkg -l gnupg 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  if [[ "${installing_required_package}" != 'yes' ]]; then install_required_packages; fi
  echo -e "${WHITE_R}#${RESET} Installing gnupg..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install gnupg &>> "${eus_dir}/logs/required.log"; then
    echo -e "${RED}#${RESET} Failed to install gnupg in the first run...\\n"
    if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      if [[ "${repo_codename}" =~ (precise|trusty|xenial) ]]; then repo_arguments="-security main"; fi
      if [[ "${repo_codename}" =~ (bionic|cosmic) ]]; then repo_arguments="-security main universe"; fi
      if [[ "${repo_codename}" =~ (disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then repo_arguments=" main universe"; fi
    elif [[ "${repo_codename}" =~ (jessie|stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
      repo_arguments=" main"
    fi
    add_repositories
    required_package="gnupg"
    apt_get_install_package
  else
    echo -e "${GREEN}#${RESET} Successfully installed gnupg! \\n" && sleep 2
  fi
fi
if ! dpkg -l perl 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  if [[ "${installing_required_package}" != 'yes' ]]; then
    install_required_packages
  fi
  echo -e "${WHITE_R}#${RESET} Installing perl..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install perl &>> "${eus_dir}/logs/required.log"; then
    echo -e "${RED}#${RESET} Failed to install perl in the first run...\\n"
    if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic) ]]; then repo_arguments="-security main"; fi
      if [[ "${repo_codename}" =~ (disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then repo_arguments=" main"; fi
    elif [[ "${repo_codename}" == "jessie" ]]; then
      repo_arguments="/updates main"
    elif [[ "${repo_codename}" =~ (stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
      repo_arguments=" main"
    fi
    add_repositories
    required_package="perl"
    apt_get_install_package
  else
    echo -e "${GREEN}#${RESET} Successfully installed perl! \\n" && sleep 2
  fi
fi
if [[ "${fqdn_specified}" == 'true' ]]; then
  if ! dpkg -l dnsutils 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
    if [[ "${installing_required_package}" != 'yes' ]]; then install_required_packages; fi
    echo -e "${WHITE_R}#${RESET} Installing dnsutils..."
    if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install dnsutils &>> "${eus_dir}/logs/required.log"; then
      echo -e "${RED}#${RESET} Failed to install dnsutils in the first run...\\n"
      if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
        if [[ "${repo_codename}" =~ (precise|trusty|xenial) ]]; then repo_arguments="-security main"; fi
        if [[ "${repo_codename}" =~ (bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then repo_arguments=" main"; fi
      elif [[ "${repo_codename}" == "jessie" ]]; then
        repo_arguments="/updates main"
      elif [[ "${repo_codename}" =~ (stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
        repo_arguments=" main"
      fi
      add_repositories
      required_package="dnsutils"
      apt_get_install_package
    else
      echo -e "${GREEN}#${RESET} Successfully installed dnsutils! \\n" && sleep 2
    fi
  fi
fi
if ! dpkg -l adduser 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  if [[ "${installing_required_package}" != 'yes' ]]; then
    install_required_packages
  fi
  echo -e "${WHITE_R}#${RESET} Installing adduser..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install adduser &>> "${eus_dir}/logs/required.log"; then
    echo -e "${RED}#${RESET} Failed to install adduser in the first run...\\n"
    if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      repo_arguments=" universe"
    elif [[ "${repo_codename}" =~ (jessie|stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
      repo_arguments=" main"
    fi
    add_repositories
    required_package="adduser"
    apt_get_install_package
  else
    echo -e "${GREEN}#${RESET} Successfully installed adduser! \\n" && sleep 2
  fi
fi
if ! dpkg -l logrotate 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then
  if [[ "${installing_required_package}" != 'yes' ]]; then
    install_required_packages
  fi
  echo -e "${WHITE_R}#${RESET} Installing logrotate..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install logrotate &>> "${eus_dir}/logs/required.log"; then
    echo -e "${RED}#${RESET} Failed to install logrotate in the first run...\\n"
    if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
      repo_arguments=" universe"
    elif [[ "${repo_codename}" =~ (jessie|stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
      repo_arguments=" main"
    fi
    add_repositories
    required_package="logrotate"
    apt_get_install_package
  else
    echo -e "${GREEN}#${RESET} Successfully installed logrotate! \\n" && sleep 2
  fi
fi

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                            Variables                                                                                            #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

dpkg -l | grep "mongodb-server\\|mongodb-org-server" | grep "^ii\\|^hi" | awk '{print $3}' | sed 's/.*://' | sed 's/-.*//g' &> /tmp/EUS/mongodb_versions
if ! [[ -s "/tmp/EUS/mongodb_versions" ]]; then if [[ -n "$(command -v mongo)" ]]; then "$(which mongo)" --quiet --eval "db.version()" &> /tmp/EUS/mongodb_versions; fi; fi
mongodb_version_installed=$(sort -V /tmp/EUS/mongodb_versions | tail -n 1)
if [[ -n "${mongodb_version_installed}" ]]; then mongodb_installed="true"; fi
if dpkg -l | grep "^ii\\|^hi" | grep -iq "mongodb-server\\|mongodb-org-server"; then mongodb_installed="true"; fi
rm --force /tmp/EUS/mongodb_versions &> /dev/null
first_digit_mongodb_version_installed=$(echo "${mongodb_version_installed}" | cut -d'.' -f1)
second_digit_mongodb_version_installed=$(echo "${mongodb_version_installed}" | cut -d'.' -f2)
#
system_memory=$(awk '/MemTotal/ {printf( "%.0f\n", $2 / 1024 / 1024)}' /proc/meminfo)
system_swap=$(awk '/SwapTotal/ {printf( "%.0f\n", $2 / 1024 / 1024)}' /proc/meminfo)
system_free_disk_space=$(df -k / | awk '{print $4}' | tail -n1)
#
SERVER_IP=$(ip addr | grep -A8 -m1 MULTICAST | grep -m1 inet | cut -d' ' -f6 | cut -d'/' -f1)
if [[ -z "${SERVER_IP}" ]]; then SERVER_IP=$(hostname -I | head -n 1 | awk '{ print $NF; }'); fi
PUBLIC_SERVER_IP=$(curl https://ip.glennr.nl/ -s)
#
if [[ "${custom_url_check}" == 'success' ]]; then
  if [[ -z "${unifi_clean}" ]]; then
    unifi_clean=$(echo "${custom_download_url}" | grep -io "5.*\\|6.*\\|7.*\\|8.*" | cut -d'-' -f1 | cut -d'/' -f1)
  fi
  unifi_secret=$(echo "${custom_download_url}" | grep -io "5.*\\|6.*\\|7.*\\|8.*" | cut -d'/' -f1)
else
  unifi_clean=$(grep -i "# Application version" "${script_location}" | head -n 1 | cut -d'|' -f2 | sed 's/ //g' | cut -d'-' -f1)
  unifi_secret=$(grep -i "# Application version" "${script_location}" | head -n 1 | cut -d'|' -f2 | sed 's/ //g')
  unifi_repo_version=$(grep -i "# Debian repo version" "${script_location}" | head -n 1 | cut -d'|' -f2 | sed 's/ //g')
fi
first_digit_unifi=$(echo "${unifi_clean}" | cut -d'.' -f1)
second_digit_unifi=$(echo "${unifi_clean}" | cut -d'.' -f2)
third_digit_unifi=$(echo "${unifi_clean}" | cut -d'.' -f3)
#
if [[ "${cloudkey_generation}" == "1" ]]; then
  if [[ "${first_digit_unifi}" -gt '7' ]] || [[ "${first_digit_unifi}" == '7' && "${second_digit_unifi}" -ge '3' ]]; then
    header_red
    unifi_latest_72=$(curl -s "https://get.glennr.nl/unifi/latest-versions/7.2/latest.version")
    echo -e "${WHITE_R}#${RESET} UniFi Network Application ${unifi_clean} is not supported on your Gen1 UniFi Cloudkey (UC-CK)."
    echo -e "${WHITE_R}#${RESET} The latest supported version on your Cloudkey is ${unifi_latest_72} and older.. \\n\\n"
    echo -e "${WHITE_R}#${RESET} Consider upgrading to a Gen2 Cloudkey:"
    echo -e "${WHITE_R}#${RESET} UniFi Cloud Key Gen2       | https://store.ui.com/products/unifi-cloud-key-gen2"
    echo -e "${WHITE_R}#${RESET} UniFi Cloud Key Gen2 Plus  | https://store.ui.com/products/unifi-cloudkey-gen2-plus\\n\\n"
    author
    exit 0
  fi
fi
#
if [[ "${first_digit_unifi}" -gt '7' ]] || [[ "${first_digit_unifi}" == '7' && "${second_digit_unifi}" -ge '5' ]]; then
  if [[ "$(getconf LONG_BIT)" == '32' ]]; then
    header_red
    if [[ "${first_digit_mongodb_version_installed}" -le "2" && "${second_digit_mongodb_version_installed}" -le "5" ]]; then unifi_latest_supported_version="7.3"; else unifi_latest_supported_version="7.4"; fi
    unifi_latest_supported_version=$(curl -s "https://get.glennr.nl/unifi/latest-versions/${unifi_latest_supported_version}/latest.version")
    echo -e "${WHITE_R}#${RESET} Your 32-bit system/OS is no longer supported by UniFi Network Application ${unifi_clean}!"
    echo -e "${WHITE_R}#${RESET} The latest supported version on your system/OS is ${unifi_latest_supported_version} and older..."
    echo -e "${WHITE_R}#${RESET} Consider upgrading to a 64-bit system/OS!\\n\\n"
    author
    exit 0
  fi
fi
#
mongo_version_supported="3.6.999"
add_mongodb_36_repo="true"
first_digit_mongodb_version_supported="3"
second_digit_mongodb_version_supported="6"
mongo_version_supported_2="4.0"
mongo_version_supported_3="36"
# MongoDB Version override
if [[ "${first_digit_unifi}" -le '5' && "${second_digit_unifi}" -le '13' ]]; then
  mongo_version_supported="3.4.999"
  add_mongodb_34_repo="true"
  first_digit_mongodb_version_supported="3"
  second_digit_mongodb_version_supported="4"
  mongo_version_supported_2="3.6"
  mongo_version_supported_3="34"
fi
if [[ "${first_digit_unifi}" == '5' && "${second_digit_unifi}" == '13' && "${third_digit_unifi}" -gt '10' ]]; then
  mongo_version_supported="3.6.999"
  add_mongodb_36_repo="true"
  first_digit_mongodb_version_supported="3"
  second_digit_mongodb_version_supported="6"
  mongo_version_supported_2="4.0"
  mongo_version_supported_3="36"
fi
# JAVA/MongoDB Version override
if [[ "${first_digit_unifi}" -gt '7' ]] || [[ "${first_digit_unifi}" == '7' && "${second_digit_unifi}" -ge "5" ]]; then
  mongo_version_supported="4.4.999"
  add_mongodb_44_repo="true"
  first_digit_mongodb_version_supported="4"
  second_digit_mongodb_version_supported="4"
  mongo_version_supported_2="4.5"
  mongo_version_supported_3="44"
  required_java_version="openjdk-17"
  required_java_version_short="17"
elif [[ "${first_digit_unifi}" == '7' && "${second_digit_unifi}" =~ (3|4) ]]; then
  required_java_version="openjdk-11"
  required_java_version_short="11"
else
  required_java_version="openjdk-8"
  required_java_version_short="8"
fi
#
# arm64 specific issue? They stick to 4.4.18
# https://www.mongodb.com/community/forums/t/core-dump-on-mongodb-4-4-19-on-rpi-4/215223/4
if [[ "${mongo_version_supported}" == "4.4.999" ]]; then
  if [[ "${architecture}" == "arm64" ]]; then arm64_mongodb_version="=4.4.18"; fi
  if ! dpkg -l libssl1.1 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then libssl_install_required="true"; fi
  libssl_version="1.1.1"
  libssl_url_arg="openssl"
  libssl_grep_arg="libssl1.1.1.*${architecture}.deb"
  if [[ "${os_codename}" =~ (jessie|stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
    libssl_repo_url="https://ftp.debian.org/debian"
  else
    libssl_arm64_url="https://launchpad.net/~ubuntu-security/+archive/ubuntu/ppa/+build/26217085/+files/libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb"
    libssl_repo_url="http://security.ubuntu.com/ubuntu"
  fi
else
  if ! dpkg -l libssl1.0.0 2> /dev/null | awk '{print $1}' | grep -iq "^ii\\|^hi"; then libssl_install_required="true"; fi
  libssl_version="1.0.2"
  libssl_url_arg="openssl1.0"
  libssl_grep_arg="libssl1.0.0.*${architecture}.deb"
  libssl_arm64_url="https://launchpad.net/ubuntu/+source/openssl1.0/1.0.2n-1ubuntu5/+build/14503127/+files/libssl1.0.0_1.0.2n-1ubuntu5_arm64.deb"
  libssl_repo_url="http://security.ubuntu.com/ubuntu"
fi

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                             Checks                                                                                              #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

if [[ "${system_free_disk_space}" -lt "5000000" && "${unifi_core_system}" != 'true' && "${is_cloudkey}" != 'true' ]]; then
  header_red
  echo -e "${WHITE_R}#${RESET} Free disk space is below 5GB.. Please expand the disk size!"
  echo -e "${WHITE_R}#${RESET} I recommend expanding to atleast 10GB\\n\\n"
  if [[ "${script_option_skip}" != 'true' ]]; then
    read -rp "Do you want to proceed at your own risk? (Y/n)" yes_no
    case "$yes_no" in
        [Yy]*|"") ;;
        [Nn]*) cancel_script;;
    esac
  else
    cancel_script
  fi
fi

# MongoDB version check.
if [[ "${first_digit_mongodb_version_installed}" -gt "${first_digit_mongodb_version_supported}" ]] || [[ "${first_digit_mongodb_version_installed}" -gt "${first_digit_mongodb_version_supported}" && "${second_digit_mongodb_version_installed}" -gt "${second_digit_mongodb_version_supported}" ]]; then
  header_red
  echo -e "${WHITE_R}#${RESET} UniFi does not support MongoDB ${mongo_version_supported_2} or newer.."
  echo -e "${WHITE_R}#${RESET} Do you want to uninstall the unsupported MongoDB version?\\n"
  echo -e "${WHITE_R}#${RESET} This will also uninstall any other package depending on MongoDB!"
  echo -e "${WHITE_R}#${RESET} I highly recommend creating a backup/snapshot of your machine/VM\\n\\n"
  read -rp "Do you want to proceed with uninstalling MongoDB? (Y/n)" yes_no
  case "$yes_no" in
      [Yy]*|"")
        header
        echo -e "${WHITE_R}#${RESET} Preparing unsupported mongodb uninstall... \\n"
        if dpkg -l | grep "unifi " | grep -q "^ii\\|^hi"; then echo -e "${WHITE_R}#${RESET} Removing UniFi to keep system files! \\n"; fi
        if dpkg -l | grep "unifi-video" | grep -q "^ii\\|^hi"; then echo -e "${WHITE_R}#${RESET} Removing UniFi-Video to keep system files! \\n"; fi
        sleep 3
        rm --force /etc/apt/sources.list.d/mongo*.list &> /dev/null
        if dpkg -l | grep "unifi " | grep -q "^ii\\|^hi"; then dpkg --remove --force-remove-reinstreq unifi || abort; fi
        if dpkg -l | grep "unifi-video" | grep -q "^ii\\|^hi"; then dpkg --remove --force-remove-reinstreq unifi-video || abort; fi
        mkdir -p /tmp/EUS/mongodb/
        rm --force /tmp/EUS/mongodb/uninstall_failed &> /dev/null
        dpkg -l | grep -i "mongo" | awk '{print $2}' &> /tmp/EUS/mongodb/uninstall
        while read -r mongodb_package_purge; do
          echo -e "${WHITE_R}#${RESET} Purging ${mongodb_package_purge}..."
          if apt-get purge "${mongodb_package_purge}" -y &> /tmp/EUS/mongodb/uninstall.log; then echo -e "${GREEN}#${RESET} Successfully purged ${mongodb_package_purge}! \\n"; else echo "${mongodb_package_purge}" &>> /tmp/EUS/mongodb/uninstall_failed; fi
        done < /tmp/EUS/mongodb/uninstall
        if [[ -f /tmp/EUS/mongodb/uninstall_failed && -s /tmp/EUS/mongodb/uninstall_failed ]]; then
          header_red
          echo -e "${WHITE_R}#${RESET} Uninstalling MongoDB with different actions!\\n\\n"
          sleep 2
          apt-get --fix-broken install -y || apt-get install -f -y
          apt-get autoremove -y
          while read -r mongodb_package; do
            echo -e "${WHITE_R}#${RESET} Force removing ${mongodb_package}..."
            if dpkg --remove --force-remove-reinstreq "${mongodb_package}" &> /tmp/EUS/mongodb/uninstall.log; then echo -e "${GREEN}#${RESET} Successfully removed ${mongodb_package}! \\n"; else  echo -e "${RED}#${RESET} Failed to remove ${mongodb_package}... \\n"; abort; fi
          done < /tmp/EUS/mongodb/uninstall_failed
        fi
        echo -e "${WHITE_R}#${RESET} Running apt-get autoremove..."
        if apt-get -y autoremove &>> "${eus_dir}/logs/apt-cleanup.log"; then echo -e "${GREEN}#${RESET} Successfully ran apt-get autoremove! \\n"; else echo -e "${RED}#${RESET} Failed to run apt-get autoremove"; fi
        echo -e "${WHITE_R}#${RESET} Running apt-get autoclean..."
        if apt-get -y autoclean &>> "${eus_dir}/logs/apt-cleanup.log"; then echo -e "${GREEN}#${RESET} Successfully ran apt-get autoclean! \\n"; else echo -e "${RED}#${RESET} Failed to run apt-get autoclean"; fi
        sleep 3;;
      [Nn]*) cancel_script;;
  esac
fi

# Memory and Swap file.
if [[ "${system_swap}" == "0" && "${script_option_skip_swap}" != 'true' && "${unifi_core_system}" != 'true' && "${is_cloudkey}" != 'true' ]]; then
  header_red
  if [[ "${system_memory}" -lt "2" ]]; then echo -e "${WHITE_R}#${RESET} System memory is lower than recommended!"; fi
  echo -e "${WHITE_R}#${RESET} Creating swap file.\\n"
  sleep 2
  if [[ "${system_free_disk_space}" -ge "10000000" ]]; then
    echo -e "${WHITE_R}---${RESET}\\n"
    echo -e "${WHITE_R}#${RESET} You have more than 10GB of free disk space!"
    echo -e "${WHITE_R}#${RESET} We are creating a 2GB swap file!\\n"
    dd if=/dev/zero of=/swapfile bs=2048 count=1048576 &>/dev/null
    chmod 600 /swapfile &>/dev/null
    mkswap /swapfile &>/dev/null
    swapon /swapfile &>/dev/null
    echo "/swapfile swap swap defaults 0 0" | tee -a /etc/fstab &>/dev/null
  elif [[ "${system_free_disk_space}" -ge "5000000" ]]; then
    echo -e "${WHITE_R}---${RESET}\\n"
    echo -e "${WHITE_R}#${RESET} You have more than 5GB of free disk space."
    echo -e "${WHITE_R}#${RESET} We are creating a 1GB swap file..\\n"
    dd if=/dev/zero of=/swapfile bs=1024 count=1048576 &>/dev/null
    chmod 600 /swapfile &>/dev/null
    mkswap /swapfile &>/dev/null
    swapon /swapfile &>/dev/null
    echo "/swapfile swap swap defaults 0 0" | tee -a /etc/fstab &>/dev/null
  elif [[ "${system_free_disk_space}" -ge "4000000" ]]; then
    echo -e "${WHITE_R}---${RESET}\\n"
    echo -e "${WHITE_R}#${RESET} You have more than 4GB of free disk space."
    echo -e "${WHITE_R}#${RESET} We are creating a 256MB swap file..\\n"
    dd if=/dev/zero of=/swapfile bs=256 count=1048576 &>/dev/null
    chmod 600 /swapfile &>/dev/null
    mkswap /swapfile &>/dev/null
    swapon /swapfile &>/dev/null
    echo "/swapfile swap swap defaults 0 0" | tee -a /etc/fstab &>/dev/null
  elif [[ "${system_free_disk_space}" -lt "4000000" ]]; then
    echo -e "${WHITE_R}---${RESET}\\n"
    echo -e "${WHITE_R}#${RESET} Your free disk space is extremely low!"
    echo -e "${WHITE_R}#${RESET} There is not enough free disk space to create a swap file..\\n"
    echo -e "${WHITE_R}#${RESET} I highly recommend upgrading the system memory to atleast 2GB and expanding the disk space!"
    echo -e "${WHITE_R}#${RESET} The script will continue the script at your own risk..\\n"
   sleep 10
  fi
else
  header
  echo -e "${WHITE_R}#${RESET} A swap file already exists!\\n\\n"
  sleep 2
fi

if [[ -d /tmp/EUS/services ]]; then
  if [[ -f /tmp/EUS/services/stopped_list ]]; then cat /tmp/EUS/services/stopped_list &>> /tmp/EUS/services/stopped_services; fi
  find /tmp/EUS/services/ -type f -printf "%f\\n" | sed 's/ //g' | sed '/file_list/d' | sed '/stopped_services/d' &> /tmp/EUS/services/file_list
  while read -r file; do
    rm --force "/tmp/EUS/services/${file}" &> /dev/null
  done < /tmp/EUS/services/file_list
  rm --force /tmp/EUS/services/file_list &> /dev/null
fi

if netstat -tulpn | grep -q ":8080\\b"; then
  port_8080_pid=$(netstat -tulpn | grep ":8080\\b" | awk '{print $7}' | sed 's/[/].*//g' | head -n1)
  port_8080_service=$(head -n1 "/proc/${port_8080_pid}/comm")
  # shellcheck disable=SC2012
  if [[ "$(ls -l "/proc/${port_8080_pid}/exe" 2> /dev/null | awk '{print $3}')" != "unifi" ]]; then
    port_8080_in_use=true
    if ! [[ -d /tmp/EUS/services ]]; then mkdir -p /tmp/EUS/services; fi
    echo -e "${port_8080_service}" &>> /tmp/EUS/services/list
    echo -e "${port_8080_pid}" &>> /tmp/EUS/services/pid_list
  fi
fi
if netstat -tulpn | grep -q ":8443\\b"; then
  port_8443_pid=$(netstat -tulpn | grep ":8443\\b" | awk '{print $7}' | sed 's/[/].*//g' | head -n1)
  port_8443_service=$(head -n1 "/proc/${port_8443_pid}/comm")
  # shellcheck disable=SC2012
  if [[ "$(ls -l "/proc/${port_8443_pid}/exe" 2> /dev/null | awk '{print $3}')" != "unifi" ]]; then
    port_8443_in_use=true
    if ! [[ -d /tmp/EUS/services ]]; then mkdir -p /tmp/EUS/services; fi
    echo -e "${port_8443_service}" &>> /tmp/EUS/services/list
    echo -e "${port_8443_pid}" &>> /tmp/EUS/services/pid_list
  fi
fi

check_port() {
  if ! [[ "${port}" =~ ${reg} ]]; then
    header_red
    echo -e "${WHITE_R}#${RESET} '${port}' is not a valid format, please only use numbers ( 0-9 )" && sleep 3
    change_default_ports
  elif [[ "${port}" -le "1024" || "${port}" -gt "65535" ]]; then
    header_red
    echo -e "${WHITE_R}#${RESET} '${port}' needs to be between 1025 and 65535.." && sleep 3
    change_default_ports
  else
    if netstat -tulpn | grep -q ":${port}\\b"; then
      header_red
      echo -e "${WHITE_R}#${RESET} '${port}' Is already in use by another process.." && sleep 3
      change_default_ports
    elif grep "${port}" /tmp/EUS/services/new_ports 2> /dev/null; then
      header_red
      echo -e "${WHITE_R}#${RESET} '${port}' will already be used for the UniFi Network Application.." && sleep 3
      change_default_ports
    elif [[ "${change_unifi_ports}" == 'true' && "${port}" == "${port_number}" ]]; then
      header_red
      echo -e "${WHITE_R}#${RESET} '${port}' Is already used by the service we stopped.." && sleep 3
      change_default_ports
    else
      echo -e "${WHITE_R}#${RESET} '${port}' Is available, we will use this for the ${port_usage}.."
      echo -e "${port_number}" &>> /tmp/EUS/services/success_port_change
      echo -e "${port}" &>> /tmp/EUS/services/new_ports
    fi
  fi
}

change_default_ports() {
  if [[ "${port_8080_in_use}" == 'true' ]] && ! grep "8080" /tmp/EUS/services/success_port_change 2> /dev/null; then
    port_usage="Device Inform"
    port_number="8080"
    reg='^[0-9]'
    echo -e "\\n${WHITE_R}----${RESET}\\n\\n${WHITE_R}#${RESET} Changing the default Device Inform port..\\n${WHITE_R}#${RESET} Please enter an alternate port below!"
	if [[ "${script_option_skip}" != 'true' ]]; then
      read -n 5 -rp $'\033[39m#\033[0m Device Inform Port | \033[39m' port
    else
      netstat -tulpn  &> /tmp/EUS/services/netstat
      if ! grep -q ":8081\\b" /tmp/EUS/services/netstat; then
        port="8081"
      elif ! grep -q ":8082\\b" /tmp/EUS/services/netstat; then
        port="8082"
      elif ! grep -q ":8083\\b" /tmp/EUS/services/netstat; then
        port="8083"
      elif ! grep -q ":8084\\b" /tmp/EUS/services/netstat; then
        port="8084"
      fi
    fi
    check_port
    if ! grep "^unifi.http.port=" /usr/lib/unifi/data/system.properties; then echo -e "unifi.http.port=${port}" &>> /usr/lib/unifi/data/system.properties && echo -e "${GREEN}#${RESET} Successfully changed the Device Inform port to '${port}'!"; else echo -e "${RED}#${RESET} Failed to change the Device Inform port."; fi
  fi
  if [[ "${port_8443_in_use}" == 'true' ]] && ! grep "8443" /tmp/EUS/services/success_port_change 2> /dev/null; then
    port_usage="Management Dashboard"
    port_number="8443"
    reg='^[0-9]'
    echo -e "\\n${WHITE_R}----${RESET}\\n\\n${WHITE_R}#${RESET} Changing the default UniFi Network Application Dashboard port..\\n${WHITE_R}#${RESET} Please enter an alternate port below!"
	if [[ "${script_option_skip}" != 'true' ]]; then
      read -n 5 -rp $'\033[39m#\033[0m UniFi Network Application Dashboard Port | \033[39m' port
    else
      netstat -tulpn  &> /tmp/EUS/services/netstat
      if ! grep -q ":1443\\b" /tmp/EUS/services/netstat; then
        port="1443"
      elif ! grep -q ":2443\\b" /tmp/EUS/services/netstat; then
        port="2443"
      elif ! grep -q ":3443\\b" /tmp/EUS/services/netstat; then
        port="3443"
      elif ! grep -q ":4443\\b" /tmp/EUS/services/netstat; then
        port="4443"
      fi
    fi
    check_port
    if ! grep "^unifi.https.port=" /usr/lib/unifi/data/system.properties; then echo -e "unifi.https.port=${port}" &>> /usr/lib/unifi/data/system.properties && echo -e "${GREEN}#${RESET} Successfully changed the Management Dashboard port to '${port}'!"; else echo -e "${RED}#${RESET} Failed to change the Management Dashboard port."; fi
  fi
  sleep 3
  if [[ -f /tmp/EUS/services/success_port_change && -s /tmp/EUS/services/success_port_change ]]; then
    header
    echo -e "${WHITE_R}#${RESET} Starting the UniFi Network Application.."
    systemctl start unifi
    if systemctl status unifi | grep -iq "Active: active (running)"; then
      echo -e "${GREEN}#${RESET} Successfully started the UniFi Network Application!"
    else
      echo -e "${RED}#${RESET} Failed to start the UniFi Network Application." && abort
    fi
    sleep 3
  fi
  if [[ "${change_unifi_ports}" != 'false' ]]; then
    if [[ -f /tmp/EUS/services/stopped_list && -s /tmp/EUS/services/stopped_list ]]; then
      while read -r service; do
        echo -e "\\n${WHITE_R}#${RESET} Starting ${service}.."
        systemctl start "${service}" && echo -e "${GREEN}#${RESET} Successfully started ${service}!" || echo -e "${RED}#${RESET} Failed to start ${service}!"
      done < /tmp/EUS/services/stopped_list
      sleep 3
    fi
  fi
}

if [[ "${port_8080_in_use}" == 'true' || "${port_8443_in_use}" == 'true' ]]; then
  cp /tmp/EUS/services/pid_list /tmp/EUS/services/pid_list_tmp && awk '!a[$0]++' < /tmp/EUS/services/pid_list_tmp &> /tmp/EUS/services/pid_list && rm --force /tmp/EUS/services/pid_list_tmp
  cp /tmp/EUS/services/list /tmp/EUS/services/list_tmp && awk '!a[$0]++' < /tmp/EUS/services/list_tmp &> /tmp/EUS/services/list && rm --force /tmp/EUS/services/list_tmp
  header_red
  echo -e "${RED}#${RESET} The following service(s) is/are running on a port that the UniFi Network Application wants to use as well.."
  # shellcheck disable=SC2009
  while read -r service_pid; do service_on_pid=$(head -n1 "/proc/${service_pid}/comm" 2> /dev/null); ps_service_on_pid=$(ps aux | grep -e "${service_pid}" | grep -v " grep -e ${service_pid}" | awk '{print $1}' | head -n1 2> /dev/null); echo -e "${RED}-${RESET} ${service_on_pid} ( ${ps_service_on_pid} ) | PID: ${service_pid}"; done < /tmp/EUS/services/pid_list
  echo ""
  if [[ "${script_option_skip}" != 'true' ]]; then
    read -rp $'\033[39m#\033[0m Do you want the script to find other port(s) for the UniFi Network Application? (Y/n) ' yes_no
  else
    echo -e "${WHITE_R}#${RESET} Script will change the default UniFi Network Application Ports.."
    sleep 2
  fi
  case "$yes_no" in
      [Yy]*|"") change_unifi_ports=true;;
      [Nn]*) change_unifi_ports=false && echo -e "\\n${WHITE_R}----${RESET}\\n\\n${RED}#${RESET} The script will keep the services stopped, you need to manually change the conflicting ports of these services and then start them again..";;
  esac
  if [[ "${script_option_skip}" != 'true' ]]; then
    read -rp $'\033[39m#\033[0m Can we temporarily stop the service(s)? (Y/n) ' yes_no
  else
    echo -e "${WHITE_R}#${RESET} Temporarily stopping the services.."
    sleep 2
  fi
  case "$yes_no" in
      [Yy]*|"")
        echo -e "\\n${WHITE_R}----${RESET}\\n"
        while read -r service; do
          echo -e "${WHITE_R}#${RESET} Trying to stop ${service}..."
          systemctl stop "${service}" 2> /dev/null && echo -e "${service}" &>> /tmp/EUS/services/stopped_list
          if grep -iq "${service}" /tmp/EUS/services/stopped_list; then echo -e "${GREEN}#${RESET} Successfully stopped ${service}!"; else echo -e "${RED}#${RESET} Failed to stop ${service}.." && echo -e "${service}" &>> /tmp/EUS/services/stopped_failed_list; fi
        done < /tmp/EUS/services/list
        sleep 2
        if [[ -f /tmp/EUS/services/stopped_failed_list && -s /tmp/EUS/services/stopped_failed_list ]]; then
          echo -e "\\n${WHITE_R}----${RESET}\\n"
          echo -e "${RED}#${RESET} The script failed to stop the following service(s).."
          while read -r service; do echo -e "${RED}-${RESET} ${service}"; done < /tmp/EUS/services/stopped_failed_list
          echo -e "${RED}#${RESET} We can try to kill the PID(s) of these services(s) but the script won't be able to start the service(s) again after completion.."
          if [[ "${script_option_skip}" != 'true' ]]; then
            read -rp $'\033[39m#\033[0m Can we proceed with killing the PID? (y/N) ' yes_no
          else
            echo -e "${WHITE_R}#${RESET} Killing the PID(s).."
            sleep 2
          fi
          case "$yes_no" in
              [Yy]*)
                echo -e "\\n${WHITE_R}----${RESET}\\n"
                while read -r pid; do
                  echo -e "${WHITE_R}#${RESET} Trying to kill ${pid}..."
                  kill -9 "${pid}" 2> /dev/null && echo -e "${pid}" &>> /tmp/EUS/services/killed_pid_list
                  if grep -iq "${pid}" /tmp/EUS/services/killed_pid_list; then echo -e "${GREEN}#${RESET} Successfully killed PID ${pid}!"; else echo -e "${RED}#${RESET} Failed to kill PID ${pid}.." && echo -e "${pid}" &>> /tmp/EUS/services/failed_killed_pid_list; fi
                done < /tmp/EUS/services/pid_list
                sleep 2
                if [[ -f /tmp/EUS/services/failed_killed_pid_list && -s /tmp/EUS/services/failed_killed_pid_list ]]; then
                  while read -r failed_pid; do
                    echo -e "${RED}-${RESET} PID ${failed_pid}..."
                  done < /tmp/EUS/services/failed_killed_pid_list
                  echo -e "${RED}#${RESET} You will have to change the following default post(s) yourself after the installation completed.."
                  if [[ "${port_8080_in_use}" == 'true' ]]; then
                    echo -e "${RED}-${RESET} 8080 ( Device Inform )"
                  fi
                  if [[ "${port_8443_in_use}" == 'true' ]]; then
                    echo -e "${RED}-${RESET} 8443 ( Management Dashboard )"
                  fi
                  sleep 5
                fi;;
              [Nn]*|"") ;;
          esac
        fi
        sleep 2;;
      [Nn]*)
        header_red
        echo -e "${RED}#${RESET} Continuing your UniFi Network Application install."
        echo -e "${RED}#${RESET} Please be aware that your application won't be able to start.."
        sleep 5;;
  esac
fi

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                  Ask to keep script or delete                                                                                   #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

script_removal() {
  header
  read -rp $'\033[39m#\033[0m Do you want to keep the script on your system after completion? (Y/n) ' yes_no
  case "$yes_no" in
      [Yy]*|"") ;;
      [Nn]*) delete_script=true;;
  esac
}

if [[ "${script_option_skip}" != 'true' ]]; then
  script_removal
fi

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                 Installation Script starts here                                                                                 #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

apt_mongodb_check() {
  MONGODB_ORG_CACHE=$(apt-cache madison mongodb-org | awk '{print $3}' | sort -V | tail -n 1 | sed 's/\.//g')
  MONGODB_CACHE=$(apt-cache madison mongodb | awk '{print $3}' | sort -V | tail -n 1 | sed 's/-.*//' | sed 's/.*://' | sed 's/\.//g')
  MONGO_TOOLS_CACHE=$(apt-cache madison mongo-tools | awk '{print $3}' | sort -V | tail -n 1 | sed 's/-.*//' | sed 's/.*://' | sed 's/\.//g')
}

system_upgrade() {
  if [[ -f /tmp/EUS/upgrade/upgrade_list && -s /tmp/EUS/upgrade/upgrade_list ]]; then
    while read -r package; do
      echo -e "\\n------- updating ${package} ------- $(date +%F-%R) -------\\n" &>> "${eus_dir}/logs/upgrade.log"
      echo -ne "\\r${WHITE_R}#${RESET} Updating package ${package}..."
      if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' --only-upgrade install "${package}" &>> "${eus_dir}/logs/upgrade.log"; then
        echo -e "\\r${GREEN}#${RESET} Successfully updated package ${package}!"
      elif tail -n1 /usr/lib/EUS/logs/upgrade.log | grep -ioq "Packages were downgraded and -y was used without --allow-downgrades" "${eus_dir}/logs/upgrade.log"; then
        if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' --only-upgrade --allow-downgrades install "${package}" &>> "${eus_dir}/logs/upgrade.log"; then
          echo -e "\\r${GREEN}#${RESET} Successfully updated package ${package}!"
          continue
        else
          echo -e "\\r${RED}#${RESET} Something went wrong during the update of package ${package}... \\n${RED}#${RESET} The script will continue with an apt-get upgrade...\\n"
          break
        fi
        echo -e "\\r${RED}#${RESET} Something went wrong during the update of package ${package}... \\n${RED}#${RESET} The script will continue with an apt-get upgrade...\\n"
        break
      fi
    done < /tmp/EUS/upgrade/upgrade_list
    echo ""
  fi
  echo -e "\\n------- apt-get upgrade ------- $(date +%F-%R) -------\\n" &>> "${eus_dir}/logs/upgrade.log"
  echo -e "${WHITE_R}#${RESET} Running apt-get upgrade..."
  if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade &>> "${eus_dir}/logs/upgrade.log"; then echo -e "${GREEN}#${RESET} Successfully ran apt-get upgrade! \\n"; else echo -e "${RED}#${RESET} Failed to run apt-get upgrade"; abort; fi
  echo -e "\\n------- apt-get dist-upgrade ------- $(date +%F-%R) -------\\n" &>> "${eus_dir}/logs/upgrade.log"
  echo -e "${WHITE_R}#${RESET} Running apt-get dist-upgrade..."
  if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade &>> "${eus_dir}/logs/upgrade.log"; then echo -e "${GREEN}#${RESET} Successfully ran apt-get dist-upgrade! \\n"; else echo -e "${RED}#${RESET} Failed to run apt-get dist-upgrade"; abort; fi
  echo -e "${WHITE_R}#${RESET} Running apt-get autoremove..."
  if apt-get -y autoremove &>> "${eus_dir}/logs/apt-cleanup.log"; then echo -e "${GREEN}#${RESET} Successfully ran apt-get autoremove! \\n"; else echo -e "${RED}#${RESET} Failed to run apt-get autoremove"; fi
  echo -e "${WHITE_R}#${RESET} Running apt-get autoclean..."
  if apt-get -y autoclean &>> "${eus_dir}/logs/apt-cleanup.log"; then echo -e "${GREEN}#${RESET} Successfully ran apt-get autoclean! \\n"; else echo -e "${RED}#${RESET} Failed to run apt-get autoclean"; fi
  sleep 3
}

rm --force /tmp/EUS/dpkg/mongodb_list &> /dev/null
rm --force /tmp/EUS/upgrade/upgrade_list &> /dev/null
remove_glennr_source_list
header
echo -e "${WHITE_R}#${RESET} Checking if your system is up-to-date...\\n" && sleep 1
hide_apt_update=true
run_apt_get_update
apt_mongodb_check
if [[ "${MONGODB_ORG_CACHE::2}" -gt "${mongo_version_supported_3}" ]]; then
  dpkg -l | awk '/ii.*mongodb-org/ {print $2}' &> /tmp/EUS/dpkg/mongodb_list
  if [[ -f /tmp/EUS/dpkg/mongodb_list && -s /tmp/EUS/dpkg/mongodb_list ]]; then
    while read -r package; do
      echo "${package} hold" | dpkg --set-selections &> /dev/null
    done < /tmp/EUS/dpkg/mongodb_list
  fi
fi
if [[ "${MONGODB_CACHE::2}" -gt "${mongo_version_supported_3}" || "${MONGO_TOOLS_CACHE::2}" -gt "${mongo_version_supported_3}" ]]; then
  dpkg -l | grep -v 'mongodb-org' | awk '/ii.*mongodb-|ii.*mongo-tools/ {print $2}' &> /tmp/EUS/dpkg/mongodb_list
  if [[ -f /tmp/EUS/dpkg/mongodb_list && -s /tmp/EUS/dpkg/mongodb_list ]]; then
    while read -r package; do
      echo "${package} hold" | dpkg --set-selections &> /dev/null
    done < /tmp/EUS/dpkg/mongodb_list
  fi
fi
echo -e "${WHITE_R}#${RESET} The package(s) below can be upgraded!"
echo -e "\\n${WHITE_R}----${RESET}\\n"
rm --force /tmp/EUS/upgrade/upgrade_list &> /dev/null
{ apt-get --just-print upgrade 2>&1 | perl -ne 'if (/Inst\s([\w,\-,\d,\.,~,:,\+]+)\s\[([\w,\-,\d,\.,~,:,\+]+)\]\s\(([\w,\-,\d,\.,~,:,\+]+)\)? /i) {print "$1 ( \e[1;34m$2\e[0m -> \e[1;32m$3\e[0m )\n"}';} | while read -r line; do echo -en "${WHITE_R}-${RESET} $line\\n"; echo -en "$line\\n" | awk '{print $1}' &>> /tmp/EUS/upgrade/upgrade_list; done;
if [[ -f /tmp/EUS/upgrade/upgrade_list ]]; then number_of_updates=$(wc -l < /tmp/EUS/upgrade/upgrade_list); else number_of_updates='0'; fi
if [[ "${number_of_updates}" == '0' ]]; then echo -e "${WHITE_R}#${RESET} There are no packages that need an upgrade..."; fi
echo -e "\\n${WHITE_R}----${RESET}\\n"
if [[ "${script_option_skip}" != 'true' ]]; then
  read -rp $'\033[39m#\033[0m Do you want to proceed with updating your system? (Y/n) ' yes_no
else
  echo -e "${WHITE_R}#${RESET} Performing the updates!"
fi
case "$yes_no" in
    [Yy]*|"") echo -e "\\n${WHITE_R}----${RESET}\\n"; system_upgrade;;
    [Nn]*) ;;
esac
if [[ -f /tmp/EUS/dpkg/mongodb_list && -s /tmp/EUS/dpkg/mongodb_list ]]; then
  while read -r service; do
    echo "${service} install" | dpkg --set-selections 2> /dev/null
  done < /tmp/EUS/dpkg/mongodb_list
fi
rm --force /tmp/EUS/dpkg/mongodb_list &> /dev/null
rm --force /tmp/EUS/upgrade/upgrade_list &> /dev/null

mongodb_installation() {
  if [[ "${libssl_install_required}" == 'true' ]]; then
    libssl_temp="$(mktemp --tmpdir=/tmp libssl${libssl_version}_XXXXX.deb)" || abort
    if [[ "${architecture}" == "amd64" ]] || [[ -z "${libssl_arm64_url}" ]]; then
      libssl_url=$(curl -s "${libssl_repo_url}/pool/main/o/${libssl_url_arg}/?C=M;O=D" | grep -io "${libssl_grep_arg}" | cut -d'"' -f1 | head -n1)
      echo -e "${WHITE_R}#${RESET} Downloading libssl..."
      if wget "${wget_progress[@]}" -O "$libssl_temp" "${libssl_repo_url}/pool/main/o/${libssl_url_arg}/${libssl_url}" &>> "${eus_dir}/logs/libssl.log"; then echo -e "${GREEN}#${RESET} Successfully downloaded libssl!"; else echo -e "${RED}#${RESET} Failed to download libssl..."; abort; fi
    fi
    if [[ "${architecture}" == "arm64" ]] && [[ -n "${libssl_arm64_url}" ]]; then
      echo -e "${WHITE_R}#${RESET} Downloading libssl..."
      if wget "${wget_progress[@]}" -O "$libssl_temp" "${libssl_arm64_url}" &>> "${eus_dir}/logs/libssl.log"; then echo -e "${GREEN}#${RESET} Successfully downloaded libssl!"; else echo -e "${RED}#${RESET} Failed to download libssl..."; abort; fi
    fi
    echo -e "\\n${WHITE_R}#${RESET} Installing libssl..."
    if dpkg -i "$libssl_temp" &>> "${eus_dir}/logs/libssl.log"; then echo -e "${GREEN}#${RESET} Successfully installed libssl! \\n"; else echo -e "${RED}#${RESET} Failed to install libssl...\\n"; abort; fi
    rm --force "$libssl_temp" 2> /dev/null
  fi
  echo -e "${WHITE_R}#${RESET} Installing mongodb-org version ${mongo_version_supported::3}..."
  # shellcheck disable=SC2068
  if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install mongodb-org-server${arm64_mongodb_version} mongodb-org-shell${arm64_mongodb_version} mongodb-org-tools${arm64_mongodb_version} &>> "${eus_dir}/logs/mongodb-org-install.log"; then
    echo -e "${GREEN}#${RESET} Successfully installed mongodb-org version ${mongo_version_supported::3}! \\n"
    mongodb_installed="true"
  else
    echo -e "${RED}#${RESET} Failed to install mongodb-org version ${mongo_version_supported::3}...\\n"
    try_different_mongodb_repo=true
    add_mongodb_repo
    echo -e "${WHITE_R}#${RESET} Trying to install mongodb-org version ${mongo_version_supported::3} in the second run..."
    # shellcheck disable=SC2068
    if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install mongodb-org-server${arm64_mongodb_version} mongodb-org-shell${arm64_mongodb_version} mongodb-org-tools${arm64_mongodb_version} &>> "${eus_dir}/logs/mongodb-org-install.log"; then
      echo -e "${GREEN}#${RESET} Successfully installed mongodb-org version ${mongo_version_supported::3} in the second run! \\n"
      mongodb_installed="true"
    else
      echo -e "${RED}#${RESET} Failed to install mongodb-org version ${mongo_version_supported::3} in the second run...\\n"
      abort
    fi
  fi
  if [[ "${architecture}" == "arm64" && "${mongodb_version_major_minor}" == "4.4" ]]; then
    if ! [[ -d "/tmp/EUS/mongodb" ]]; then if ! mkdir -p /tmp/EUS/mongodb; then echo -e "${RED}#${RESET} Failed to create required EUS tmp directory..."; abort; fi; fi
    dpkg -l | grep mongodb-org | grep "^ii\\|^hi" | awk '{print $2}' &> /tmp/EUS/mongodb/packages_list
    while read -r mongodb_package; do
      echo -e "${WHITE_R}#${RESET} Preventing ${mongodb_package} from upgrading..."
      if echo "${mongodb_package} hold" | dpkg --set-selections; then
        echo -e "${GREEN}#${RESET} Successfully prevented ${mongodb_package} from upgrading! \\n"
      else
        echo -e "${RED}#${RESET} Failed to prevent ${mongodb_package} from upgrading...\\n"
        abort
      fi
    done < /tmp/EUS/mongodb/packages_list
    rm /tmp/EUS/mongodb/packages_list
  fi
}

mongodb_server_clients_installation() {
  echo -e "${WHITE_R}#${RESET} Installing mongodb-server and mongodb-clients..."
  if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install mongodb-server mongodb-clients &>> "${eus_dir}/logs/mongodb-server-client-install.log"; then
    echo -e "${RED}#${RESET} Failed to install mongodb-server and mongodb-clients in the first run...\\n"
    add_repositories
    hide_apt_update=true
    run_apt_get_update
    echo -e "${WHITE_R}#${RESET} Trying to install mongodb-server and mongodb-clients for the second time..."
    if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install mongodb-server mongodb-clients &>> "${eus_dir}/logs/mongodb-server-client-install.log"; then
      echo -e "${RED}#${RESET} Failed to install mongodb-server and mongodb-clients in the second run... \\n${WHITE_R}#${RESET} Trying to save the installation...\\n"
      echo -e "${WHITE_R}#${RESET} Running apt-get install -f..."
      if ! apt-get install -f &>> "${eus_dir}/logs/mongodb-server-client-install.log"; then
        echo -e "${RED}#${RESET} Failed to run \"apt-get install -f\"! \\n"
        abort
      else
        echo -e "${GREEN}#${RESET} Successfully ran \"apt-get install -f\"! \\n"
        echo -e "${WHITE_R}#${RESET} Trying to install mongodb-server and mongodb-clients again..."
        if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install mongodb-server mongodb-clients &>> "${eus_dir}/logs/mongodb-server-client-install.log"; then
          if [[ "${architecture}" == "armhf" ]]; then
            mongodb_installation_armhf
          else
            echo -e "${RED}#${RESET} Failed to install mongodb-server and mongodb-clients... Consider switching to a 64-bit platform and re-run the scripts...\\n"
            abort
          fi
        else
          echo -e "${GREEN}#${RESET} Successfully installed mongodb-server and mongodb-clients! \\n"
        fi
      fi
    else
      echo -e "${GREEN}#${RESET} Successfully installed mongodb-server and mongodb-clients! \\n"
    fi
  fi
}

mongodb_installation_armhf() {
  aptkey_depreciated
  if [[ "${apt_key_deprecated}" == 'true' ]]; then
    if wget -qO - "https://archive.raspbian.org/raspbian.public.key" | gpg --dearmor | tee -a "/usr/share/keyrings/raspbian.gpg" &> /dev/null; then echo -e "${GREEN}#${RESET} Successfully added key for the raspbian repository! \\n"; signed_by_value_raspbian="[ signed-by=/usr/share/keyrings/raspbian.gpg ] "; else echo -e "${RED}#${RESET} Failed to add the key for the raspbian repository...\\n"; abort; fi
  else
    if wget -qO - "https://archive.raspbian.org/raspbian.public.key" | apt-key add - &> /dev/null; then echo -e "${GREEN}#${RESET} Successfully added key for the raspbian repository! \\n"; else echo -e "${RED}#${RESET} Failed to add the key for the raspbian repository...\\n"; abort; fi
  fi
  echo "deb ${signed_by_value_raspbian}http://archive.raspbian.org/raspbian stretch main contrib non-free rpi" &> /etc/apt/sources.list.d/glennr_armhf.list
  hide_apt_update=true
  run_apt_get_update
  if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install mongodb-server mongodb-clients &>> "${eus_dir}/logs/mongodb-armhf-install.log"; then
    echo -e "${GREEN}#${RESET} Successfully installed mongodb-server and mongodb-clients! \\n"
  else
    echo -e "${RED}#${RESET} Failed to install mongodb-server and mongodb-clients in the first run... \\n${RED}#${RESET} Trying to save the installation...\\n"
    echo -e "${WHITE_R}#${RESET} Running \"apt-get install -f\"..."
    if apt-get install -f &>> "${eus_dir}/logs/mongodb-armhf-install.log"; then
      echo -e "${GREEN}#${RESET} Successfully ran \"apt-get install -f\"! \\n"
      echo -e "${WHITE_R}#${RESET} Trying to install mongodb-server and mongodb-clients again..."
      if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install mongodb-server mongodb-clients &>> "${eus_dir}/logs/mongodb-armhf-install.log"; then
        echo -e "${GREEN}#${RESET} Successfully installed mongodb-server and mongodb-clients! \\n"
      else
        echo -e "${RED}#${RESET} Failed to install mongodb-server and mongodb-clients... Consider switching to a 64-bit platform and re-run the scripts...\\n"
        abort
      fi
    else
      echo -e "${RED}#${RESET} Failed to run \"apt-get install -f\"! \\n"; abort
    fi
  fi
  sleep 3
}

header
echo -e "${WHITE_R}#${RESET} Preparing for MongoDB installation..."
sleep 2
if [[ "${mongodb_installed}" != 'true' ]]; then
  # Remove all current MongoDB Repository Entries
  echo -e "\\n${WHITE_R}#${RESET} Checking for MongoDB repository entries..."
  if grep -qriIl "mongo" /etc/apt/sources.list*; then
    echo -ne "${YELLOW}#${RESET} Removing repository entries for MongoDB..." && sleep 1
    sed -i '/mongodb/d' /etc/apt/sources.list
    if ls /etc/apt/sources.list.d/mongodb* > /dev/null 2>&1; then
      rm /etc/apt/sources.list.d/mongodb*  2> /dev/null
    fi
    echo -e "\\r${GREEN}#${RESET} Successfully removed all MongoDB repository entries! \\n"
  else
    echo -e "\\r${YELLOW}#${RESET} There were no MongoDB Repository entries! \\n"
  fi
  #
  if [[ "${os_codename}" =~ (trusty|qiana|rebecca|rafaela|rosa|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic|sarah|serena|sonya|sylvia|tara|tessa|tina|tricia) ]]; then
    if [[ "${architecture}" =~ (amd64|arm64) ]]; then
	  if [[ "${os_codename}" =~ (precise|maya) ]]; then add_mongodb_34_repo="true"; fi
      add_mongodb_repo
      mongodb_installation
    elif [[ ! "${architecture}" =~ (amd64|arm64) ]]; then
      repo_arguments=" main universe"
      repo_codename="xenial"
      os_codename="xenial"
      get_repo_url
      mongodb_server_clients_installation
      get_distro
      get_repo_url
    fi
  elif [[ "${os_codename}" =~ (jessie|stretch|continuum|buster|bullseye|bookworm|trixie|forky) ]]; then
    if [[ "${architecture}" =~ (amd64|arm64) ]]; then
      add_mongodb_repo
      mongodb_installation
    elif [[ ! "${architecture}" =~ (amd64|arm64) ]]; then
      repo_arguments=" main"
      repo_codename="stretch"
      os_codename="stretch"
      get_repo_url
      mongodb_server_clients_installation
      get_distro
      get_repo_url
    fi
  else
    header_red
    echo -e "${RED}#${RESET} The script is unable to grab your OS ( or does not support it )"
    echo "${architecture}"
    echo "${os_codename}"
  fi
else
  echo -e "${GREEN}#${RESET} MongoDB is already installed! \\n"
fi
sleep 3

# Check if MongoDB is newer than 2.6 (3.6 for 7.5.x) for UniFi Network application 7.4.x
if [[ "${first_digit_unifi}" -gt '7' ]] || [[ "${first_digit_unifi}" == '7' && "${second_digit_unifi}" -ge '4' ]] || [[ "${first_digit_unifi}" == '7' && "${second_digit_unifi}" -ge '5' ]]; then
  if [[ "${first_digit_unifi}" -gt '7' ]] || [[ "${first_digit_unifi}" == '7' && "${second_digit_unifi}" -ge '5' ]]; then minimum_required_mongodb_version_dot="3.6"; minimum_required_mongodb_version="36"; unifi_latest_supported_version_number="7.4"; fi
  if [[ "${first_digit_unifi}" == '7' && "${second_digit_unifi}" == '4' ]]; then minimum_required_mongodb_version_dot="2.6"; minimum_required_mongodb_version="26"; unifi_latest_supported_version_number="7.3"; fi
  mongodb_server_version="$(dpkg -l | grep "^ii\\|^hi" | grep "mongodb-server \\|mongodb-org-server " | awk '{print $3}' | sed 's/\.//g' | sed 's/.*://' | sed 's/-.*//g')"
  if [[ -z "${mongodb_server_version}" ]]; then if [[ -n "$(command -v mongo)" ]]; then mongodb_server_version="$("$(which mongo)" --quiet --eval "db.version()" | sed 's/\.//g' | sed 's/.*://' | sed 's/-.*//g')"; fi; fi
  if [[ "${mongodb_server_version::2}" -lt "${minimum_required_mongodb_version}" ]]; then
    header_red
    unifi_latest_supported_version=$(curl -s "https://get.glennr.nl/unifi/latest-versions/${unifi_latest_supported_version_number}/latest.version")
    echo -e "${WHITE_R}#${RESET} UniFi Network Application ${first_digit_unifi}.${second_digit_unifi}.${third_digit_unifi} requires MongoDB ${minimum_required_mongodb_version_dot} or newer."
    echo -e "${WHITE_R}#${RESET} The latest version that you can run with MongoDB version $(dpkg -l | grep "^ii\\|^hi" | grep "mongodb-server\\|mongodb-org-server" | awk '{print $3}' | sed 's/.*://') is ${unifi_latest_supported_version} and older.. \\n\\n"
    echo -e "${WHITE_R}#${RESET} Upgrade to MongoDB ${minimum_required_mongodb_version_dot} or newer, or perform a fresh install with the latest OS."
    echo -e "${WHITE_R}#${RESET} Installation Script   | https://community.ui.com/questions/ccbc7530-dd61-40a7-82ec-22b17f027776\\n\\n"
    if [[ "$(getconf LONG_BIT)" == '32' ]]; then
      echo -e "${WHITE_R}#${RESET} You're using a 32-bit OS.. please switch over to a 64-bit OS.\\n\\n"
    fi
    author
    exit 0
  fi
fi

adoptium_java() {
  if [[ "${os_codename}" =~ (trixie|forky) ]]; then
    if ! curl -s "https://packages.adoptium.net/artifactory/deb/dists/" | sed -e 's/<[^>]*>//g' -e '/^$/d' -e '/\/\//d' -e '/function/d' -e '/location/d' -e '/}/d' -e 's/\///g' -e '/Name/d' -e '/Index/d' -e '/\.\./d' -e '/Artifactory/d' | awk '{print $1}' | grep -iq "${os_codename}"; then
      os_codename="bookworm"
      adoptium_adjusted_os_codename=true
    fi
  fi
  if curl -s "https://packages.adoptium.net/artifactory/deb/dists/" | sed -e 's/<[^>]*>//g' -e '/^$/d' -e '/\/\//d' -e '/function/d' -e '/location/d' -e '/}/d' -e 's/\///g' -e '/Name/d' -e '/Index/d' -e '/\.\./d' -e '/Artifactory/d' | awk '{print $1}' | grep -iq "${os_codename}"; then
    echo -e "${WHITE_R}#${RESET} Adding the key for adoptium packages..."
    aptkey_depreciated
    if [[ "${apt_key_deprecated}" == 'true' ]]; then
      if wget -qO - "https://packages.adoptium.net/artifactory/api/gpg/key/public" | gpg --dearmor | tee -a "/usr/share/keyrings/packages-adoptium.gpg" &> /dev/null; then echo -e "${GREEN}#${RESET} Successfully added the key for adoptium packages! \\n"; signed_by_value_adoptium="[ signed-by=/usr/share/keyrings/packages-adoptium.gpg ] "; else echo -e "${RED}#${RESET} Failed to add the key for adoptium packages...\\n"; abort; fi
    else
      if wget -qO - "https://packages.adoptium.net/artifactory/api/gpg/key/public" | apt-key add - &> /dev/null; then echo -e "${GREEN}#${RESET} Successfully added the key for adoptium packages! \\n"; else echo -e "${RED}#${RESET} Failed to add the key for adoptium packages...\\n"; abort; fi
    fi
    echo -e "${WHITE_R}#${RESET} Adding the adoptium packages repository..."
    if echo "deb ${signed_by_value_adoptium}https://packages.adoptium.net/artifactory/deb ${os_codename} main" &> /etc/apt/sources.list.d/glennr-packages-adoptium.list; then
      echo -e "${GREEN}#${RESET} Successfully added the adoptium packages repository!\\n" && sleep 2
      hide_apt_update=true
      run_apt_get_update
      added_adoptium="true"
    else
      echo -e "${RED}#${RESET} Failed to add the adoptium packages repository..."
      abort
    fi
  else
    echo -e "${RED}#${RESET} \"${os_codename}\" could not be found on adoptium packages Artifactory..."
    echo "# Could not find \"${os_codename}\" on https://packages.adoptium.net/artifactory/deb/dists/" &>> "${eus_dir}/logs/adoptium.log"
    echo "# List of what was found:" &>> "${eus_dir}/logs/adoptium.log"
    curl -s "https://packages.adoptium.net/artifactory/deb/dists/" | sed -e 's/<[^>]*>//g' -e '/^$/d' -e '/\/\//d' -e '/function/d' -e '/location/d' -e '/}/d' -e 's/\///g' -e '/Name/d' -e '/Index/d' -e '/\.\./d' -e '/Artifactory/d' | awk '{print $1}' &>> "${eus_dir}/logs/adoptium.log"
  fi
  if [[ "${adoptium_adjusted_os_codename}" == 'true' ]]; then get_distro; fi
}

openjdk_version=$(dpkg -l | grep "^ii\\|^hi" | grep "openjdk-8" | awk '{print $3}' | grep "^8u" | sed 's/-.*//g' | sed 's/8u//g' | grep -o '[[:digit:]]*' | sort -V | tail -n 1)
if dpkg -l | grep "^ii\\|^hi" | grep -iq "openjdk-8"; then
  if [[ "${openjdk_version}" -lt '131' && "${required_java_version}" == "openjdk-8" ]]; then
    old_openjdk_version=true
  fi
fi
if ! dpkg -l | grep "^ii\\|^hi" | grep -iq "${required_java_version}\\|temurin-${required_java_version_short}" || [[ "${old_openjdk_version}" == 'true' ]]; then
  if [[ "${old_openjdk_version}" == 'true' ]]; then
    header_red
    echo -e "${RED}#${RESET} OpenJDK ${required_java_version_short} is to old...\\n" && sleep 2
    openjdk_variable="Updating"
    openjdk_variable_2="Updated"
    openjdk_variable_3="Update"
  else
    header
    echo -e "${GREEN}#${RESET} Preparing OpenJDK ${required_java_version_short} installation...\\n" && sleep 2
    openjdk_variable="Installing"
    openjdk_variable_2="Installed"
    openjdk_variable_3="Install"
  fi
  sleep 2
  if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic) ]]; then
    echo -e "${WHITE_R}#${RESET} ${openjdk_variable} ${required_java_version}-jre-headless..."
    if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install "${required_java_version}-jre-headless" &>> "${eus_dir}/logs/apt.log" || [[ "${old_openjdk_version}" == 'true' ]]; then
      echo -e "${RED}#${RESET} Failed to ${openjdk_variable_3} ${required_java_version}-jre-headless in the first run...\\n"
      repo_url="http://ppa.launchpad.net/openjdk-r/ppa/ubuntu"
      repo_arguments=" main"
      missing_key="EB9B1D8886F44E2A"
      add_repositories
      get_distro
      get_repo_url
      required_package="${required_java_version}-jre-headless"
      apt_get_install_package
    else
      echo -e "${GREEN}#${RESET} Successfully ${openjdk_variable_2} ${required_java_version}-jre-headless! \\n" && sleep 2
    fi
  elif [[ "${repo_codename}" =~ (disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
    echo -e "${WHITE_R}#${RESET} ${openjdk_variable} ${required_java_version}-jre-headless..."
    if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install "${required_java_version}-jre-headless" &>> "${eus_dir}/logs/apt.log" || [[ "${old_openjdk_version}" == 'true' ]]; then
      echo -e "${RED}#${RESET} Failed to ${openjdk_variable_3} ${required_java_version}-jre-headless in the first run...\\n"
      repo_url="http://security.ubuntu.com/ubuntu"
      repo_arguments="-security main universe"
      add_repositories
      get_distro
      get_repo_url
      required_package="${required_java_version}-jre-headless"
      apt_get_install_package
    else
      echo -e "${GREEN}#${RESET} Successfully ${openjdk_variable_2} ${required_java_version}-jre-headless! \\n" && sleep 2
    fi
  elif [[ "${os_codename}" == "jessie" ]]; then
    echo -e "${WHITE_R}#${RESET} ${openjdk_variable} ${required_java_version}-jre-headless..."
    if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install -t jessie-backports "${required_java_version}-jre-headless" &>> "${eus_dir}/logs/apt.log" || [[ "${old_openjdk_version}" == 'true' ]]; then
      echo -e "${RED}#${RESET} Failed to ${openjdk_variable_3} ${required_java_version}-jre-headless in the first run...\\n"
      if [[ $(find /etc/apt/ -name "*.list" -type f -print0 | xargs -0 cat | grep -P -c "^deb http[s]*://archive.debian.org/debian jessie-backports main") -eq 0 ]]; then
        echo "deb http://archive.debian.org/debian jessie-backports main" >>/etc/apt/sources.list.d/glennr-install-script.list || abort
        http_proxy=$(env | grep -i "http.*Proxy" | cut -d'=' -f2 | sed 's/[";]//g')
        if [[ -n "$http_proxy" ]]; then
          apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --keyserver-options http-proxy="${http_proxy}" --recv-keys 8B48AD6246925553 7638D0442B90D010 || abort
        elif [[ -f /etc/apt/apt.conf ]]; then
          apt_http_proxy=$(grep "http.*Proxy" /etc/apt/apt.conf | awk '{print $2}' | sed 's/[";]//g')
          if [[ -n "${apt_http_proxy}" ]]; then
            apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --keyserver-options http-proxy="${apt_http_proxy}" --recv-keys 8B48AD6246925553 7638D0442B90D010 || abort
          fi
        else
          apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8B48AD6246925553 7638D0442B90D010 || abort
        fi
        echo -e "${WHITE_R}#${RESET} Running apt-get update..."
        required_package="${required_java_version}-jre-headless"
        if apt-get update -o Acquire::Check-Valid-Until=false &> /dev/null; then echo -e "${GREEN}#${RESET} Successfully ran apt-get update! \\n"; else echo -e "${RED}#${RESET} Failed to ran apt-get update! \\n"; abort; fi
        echo -e "\\n------- ${required_package} installation ------- $(date +%F-%R) -------\\n" &>> "${eus_dir}/logs/apt.log"
        if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install -t jessie-backports "${required_java_version}-jre-headless" &>> "${eus_dir}/logs/apt.log"; then echo -e "${GREEN}#${RESET} Successfully installed ${required_package}! \\n" && sleep 2; else echo -e "${RED}#${RESET} Failed to install ${required_package}! \\n"; abort; fi
        sed -i '/jessie-backports/d' /etc/apt/sources.list.d/glennr-install-script.list
        unset required_package
      fi
    fi
  elif [[ "${os_codename}" =~ (stretch|continuum) ]]; then
    echo -e "${WHITE_R}#${RESET} ${openjdk_variable} ${required_java_version}-jre-headless..."
    if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install "${required_java_version}-jre-headless" &>> "${eus_dir}/logs/apt.log" || [[ "${old_openjdk_version}" == 'true' ]]; then
      echo -e "${RED}#${RESET} Failed to ${openjdk_variable_3} ${required_java_version}-jre-headless in the first run...\\n"
      repo_url="http://ppa.launchpad.net/openjdk-r/ppa/ubuntu"
      repo_codename="xenial"
      repo_arguments=" main"
      missing_key="EB9B1D8886F44E2A"
      add_repositories
      get_distro
      get_repo_url
      required_package="${required_java_version}-jre-headless"
      apt_get_install_package
    else
      echo -e "${GREEN}#${RESET} Successfully ${openjdk_variable_2} ${required_java_version}-jre-headless! \\n" && sleep 2
    fi
  elif [[ "${repo_codename}" =~ (buster|bullseye|bookworm|trixie|forky) ]]; then
    echo -e "${WHITE_R}#${RESET} ${openjdk_variable} ${required_java_version}-jre-headless..."
    if ! DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install "${required_java_version}-jre-headless" &>> "${eus_dir}/logs/apt.log" || [[ "${old_openjdk_version}" == 'true' ]]; then
      echo -e "${RED}#${RESET} Failed to ${openjdk_variable_3} ${required_java_version}-jre-headless in the first run...\\n"
      if [[ "${required_java_version}" == "openjdk-8" ]]; then
        repo_codename="stretch"
        repo_arguments=" main"
        get_repo_url
        add_repositories
        get_distro
      elif [[ "${required_java_version}" =~ (openjdk-11|openjdk-17) ]]; then
        if [[ "${repo_codename}" =~ (bookworm|trixie|forky) ]] && [[ "${required_java_version}" =~ (openjdk-11) ]]; then repo_codename="unstable"; fi
        if [[ "${repo_codename}" =~ (buster|trixie|forky) ]] && [[ "${required_java_version}" =~ (openjdk-17) ]]; then repo_codename="bookworm"; fi
        repo_arguments=" main"
        get_repo_url
        add_repositories
        get_distro
      fi
      required_package="${required_java_version}-jre-headless"
      apt_get_install_package
    else
      echo -e "${GREEN}#${RESET} Successfully ${openjdk_variable_2} ${required_java_version}-jre-headless! \\n" && sleep 2
    fi
  else
    header_red
    echo -e "${RED}Please manually install JAVA ${required_java_version_short} on your system!${RESET}\\n"
    echo -e "${RED}OS Details:${RESET}\\n"
    echo -e "${RED}$(lsb_release -a)${RESET}\\n"
    exit 0
  fi
else
  header
  echo -e "${GREEN}#${RESET} Preparing OpenJDK ${required_java_version_short} installation..."
  echo -e "${WHITE_R}#${RESET} OpenJDK ${required_java_version_short} is already installed! \\n"
fi
sleep 3

if dpkg -l | grep "^ii\\|^hi" | grep -iq "openjdk-${required_java_version_short}"; then
  required_java_version_installed=true
fi
if dpkg -l | grep "^ii\\|^hi" | grep -i "openjdk-.*-\\|oracle-java.*" | grep -vq "openjdk-8\\|oracle-java8\\|openjdk-11\\|openjdk-17"; then
  unsupported_java_version_installed=true
fi

if [[ "${required_java_version_installed}" == 'true' && "${unsupported_java_version_installed}" == 'true' && "${script_option_skip}" != 'true' && "${unifi_core_system}" != 'true' ]]; then
  header_red
  echo -e "${WHITE_R}#${RESET} Unsupported JAVA version(s) are detected, do you want to uninstall them?"
  echo -e "${WHITE_R}#${RESET} This may remove packages that depend on these java versions."
  read -rp $'\033[39m#\033[0m Do you want to proceed with uninstalling the unsupported JAVA version(s)? (y/N) ' yes_no
  case "$yes_no" in
       [Yy]*)
          rm --force /tmp/EUS/java/* &> /dev/null
          mkdir -p /tmp/EUS/java/ &> /dev/null
          mkdir -p "${eus_dir}/logs/" &> /dev/null
          header
          echo -e "${WHITE_R}#${RESET} Uninstalling unsupported JAVA versions..."
          echo -e "\\n${WHITE_R}----${RESET}\\n"
          sleep 3
          dpkg -l | grep "^ii\\|^hi" | awk '/openjdk-.*/{print $2}' | cut -d':' -f1 | grep -v "openjdk-8\\|openjdk-11" &>> /tmp/EUS/java/unsupported_java_list_tmp
          dpkg -l | grep "^ii\\|^hi" | awk '/oracle-java.*/{print $2}' | cut -d':' -f1 | grep -v "oracle-java8" &>> /tmp/EUS/java/unsupported_java_list_tmp
          awk '!a[$0]++' /tmp/EUS/java/unsupported_java_list_tmp >> /tmp/EUS/java/unsupported_java_list; rm --force /tmp/EUS/java/unsupported_java_list_tmp 2> /dev/null
          echo -e "\\n------- $(date +%F-%R) -------\\n" &>> "${eus_dir}/logs/java_uninstall.log"
          while read -r package; do
            apt-get remove "${package}" -y &>> "${eus_dir}/logs/java_uninstall.log" && echo -e "${WHITE_R}#${RESET} Successfully removed ${package}." || echo -e "${WHITE_R}#${RESET} Failed to remove ${package}."
          done < /tmp/EUS/java/unsupported_java_list
          rm --force /tmp/EUS/java/unsupported_java_list &> /dev/null
          echo -e "\\n" && sleep 3;;
       [Nn]*|"") ;;
  esac
fi

update_ca_certificates() {
  if [[ "${update_ca_certificates_ran}" != 'true' ]]; then
    echo -e "${WHITE_R}#${RESET} Updating the ca-certificates..."
    rm /etc/ssl/certs/java/cacerts 2> /dev/null
    if update-ca-certificates -f &> /dev/null; then
      echo -e "${GREEN}#${RESET} Successfully updated the ca-certificates\\n" && sleep 3
      /usr/bin/printf '\xfe\xed\xfe\xed\x00\x00\x00\x02\x00\x00\x00\x00\xe2\x68\x6e\x45\xfb\x43\xdf\xa4\xd9\x92\xdd\x41\xce\xb6\xb2\x1c\x63\x30\xd7\x92' > /etc/ssl/certs/java/cacerts
      /var/lib/dpkg/info/ca-certificates-java.postinst configure &> /dev/null
      update_ca_certificates_ran=true
    else
      echo -e "${RED}#${RESET} Failed to update the ca-certificates...\\n" && sleep 3
    fi
  fi
}

if dpkg -l | grep "^ii\\|^hi" | grep -iq "openjdk-${required_java_version_short}\\|temurin-${required_java_version_short}"; then
  update_java_alternatives=$(update-java-alternatives --list | grep "^java-1.${required_java_version_short}.*openjdk\\|temurin-${required_java_version_short}-jdk" | awk '{print $1}' | head -n1)
  if [[ -n "${update_java_alternatives}" ]]; then
    update-java-alternatives --set "${update_java_alternatives}" &> /dev/null
  fi
  update_alternatives=$(update-alternatives --list java | grep "java-${required_java_version_short}-openjdk\\|temurin-${required_java_version_short}-jdk" | awk '{print $1}' | head -n1)
  if [[ -n "${update_alternatives}" ]]; then
    update-alternatives --set java "${update_alternatives}" &> /dev/null
  fi
  header
  update_ca_certificates
fi

if dpkg -l | grep "^ii\\|^hi" | grep -iq "openjdk-${required_java_version_short}\\|temurin-${required_java_version_short}"; then
  java_home_readlink="JAVA_HOME=$( readlink -f "$( command -v java )" | sed "s:bin/.*$::" )"
  if [[ -f /etc/default/unifi ]]; then
    current_java_home=$(grep "^JAVA_HOME" /etc/default/unifi)
    if [[ -n "${java_home_readlink}" ]]; then
      if [[ "${current_java_home}" != "${java_home_readlink}" ]]; then
        sed -i 's/^JAVA_HOME/#JAVA_HOME/' /etc/default/unifi
        echo "${java_home_readlink}" >> /etc/default/unifi
      fi
    fi
  else
    current_java_home=$(grep "^JAVA_HOME" /etc/environment)
    if [[ -n "${java_home_readlink}" ]]; then
      if [[ "${current_java_home}" != "${java_home_readlink}" ]]; then
        sed -i 's/^JAVA_HOME/#JAVA_HOME/' /etc/environment
        echo "${java_home_readlink}" >> /etc/environment
        # shellcheck disable=SC1091
        source /etc/environment
      fi
    fi
  fi
fi

header
echo -e "${WHITE_R}#${RESET} Preparing installation of the UniFi Network Application dependencies...\\n"
sleep 2
echo -e "\\n------- dependency installation ------- $(date +%F-%R) -------\\n" &>> "${eus_dir}/logs/apt.log"
if [[ "${os_codename}" =~ (precise|maya|trusty|qiana|rebecca|rafaela|rosa|xenial|sarah|serena|sonya|sylvia|bionic|tara|tessa|tina|tricia|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic|stretch|continuum|buster|bullseye|bookworm|trixie|forky) ]]; then
  echo -e "${WHITE_R}#${RESET} Installing binutils, ca-certificates-java and java-common..."
  if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install binutils ca-certificates-java java-common &>> "${eus_dir}/logs/apt.log"; then echo -e "${GREEN}#${RESET} Successfully installed binutils, ca-certificates-java and java-common! \\n"; else echo -e "${RED}#${RESET} Failed to install binutils, ca-certificates-java and java-common in the first run...\\n"; unifi_dependencies=fail; fi
  if [[ "${required_java_version}" == "openjdk-8" ]]; then
    echo -e "${WHITE_R}#${RESET} Installing jsvc and libcommons-daemon-java..."
    if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install jsvc libcommons-daemon-java &>> "${eus_dir}/logs/apt.log"; then echo -e "${GREEN}#${RESET} Successfully installed jsvc and libcommons-daemon-java! \\n"; else echo -e "${RED}#${RESET} Failed to install jsvc and libcommons-daemon-java in the first run...\\n"; unifi_dependencies=fail; fi
  fi
elif [[ "${os_codename}" == 'jessie' ]]; then
  echo -e "${WHITE_R}#${RESET} Installing binutils, ca-certificates-java and java-common..."
  if DEBIAN_FRONTEND='noninteractive' apt-get -y --force-yes -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install binutils ca-certificates-java java-common &>> "${eus_dir}/logs/apt.log"; then echo -e "${GREEN}#${RESET} Successfully installed binutils, ca-certificates-java and java-common! \\n"; else echo -e "${RED}#${RESET} Failed to install binutils, ca-certificates-java and java-common in the first run...\\n"; unifi_dependencies=fail; fi
  if [[ "${required_java_version}" == "openjdk-8" ]]; then
    echo -e "${WHITE_R}#${RESET} Installing jsvc and libcommons-daemon-java..."
    if DEBIAN_FRONTEND='noninteractive' apt-get -y --force-yes -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install jsvc libcommons-daemon-java &>> "${eus_dir}/logs/apt.log"; then echo -e "${GREEN}#${RESET} Successfully installed jsvc and libcommons-daemon-java! \\n"; else echo -e "${RED}#${RESET} Failed to install jsvc and libcommons-daemon-java in the first run...\\n"; unifi_dependencies=fail; fi
  fi
fi
if [[ "${unifi_dependencies}" == 'fail' ]]; then
  if [[ "${repo_codename}" =~ (precise|trusty|xenial|bionic|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic) ]]; then
    repo_arguments=" main universe"
  elif [[ "${repo_codename}" =~ (jessie|stretch|buster|bullseye|bookworm|trixie|forky) ]]; then
    repo_arguments=" main"
  fi
  add_repositories
  hide_apt_update=true
  run_apt_get_update
  if [[ "${os_codename}" =~ (precise|maya|trusty|qiana|rebecca|rafaela|rosa|xenial|sarah|serena|sonya|sylvia|bionic|tara|tessa|tina|tricia|cosmic|disco|eoan|focal|groovy|hirsute|impish|jammy|kinetic|lunar|mantic|stretch|continuum|buster|bullseye|bookworm|trixie|forky) ]]; then
    echo -e "${WHITE_R}#${RESET} Installing binutils, ca-certificates-java and java-common..."
    if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install binutils ca-certificates-java java-common &>> "${eus_dir}/logs/apt.log"; then echo -e "${GREEN}#${RESET} Successfully installed binutils, ca-certificates-java and java-common! \\n"; else echo -e "${RED}#${RESET} Failed to install binutils, ca-certificates-java and java-common in the first run...\\n"; abort; fi
    if [[ "${required_java_version}" == "openjdk-8" ]]; then
      echo -e "${WHITE_R}#${RESET} Installing jsvc and libcommons-daemon-java..."
      if DEBIAN_FRONTEND='noninteractive' apt-get -y "${apt_options[@]}" -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install jsvc libcommons-daemon-java &>> "${eus_dir}/logs/apt.log"; then echo -e "${GREEN}#${RESET} Successfully installed jsvc and libcommons-daemon-java! \\n"; else echo -e "${RED}#${RESET} Failed to install jsvc and libcommons-daemon-java in the first run...\\n"; abort; fi
    fi
  elif [[ "${os_codename}" == 'jessie' ]]; then
    echo -e "${WHITE_R}#${RESET} Installing binutils, ca-certificates-java and java-common..."
    if DEBIAN_FRONTEND='noninteractive' apt-get -y --force-yes -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install binutils ca-certificates-java java-common &>> "${eus_dir}/logs/apt.log"; then echo -e "${GREEN}#${RESET} Successfully installed binutils, ca-certificates-java and java-common! \\n"; else echo -e "${RED}#${RESET} Failed to install binutils, ca-certificates-java and java-common in the first run...\\n"; abort; fi
    if [[ "${required_java_version}" == "openjdk-8" ]]; then
      echo -e "${WHITE_R}#${RESET} Installing jsvc and libcommons-daemon-java..."
      if DEBIAN_FRONTEND='noninteractive' apt-get -y --force-yes -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install jsvc libcommons-daemon-java &>> "${eus_dir}/logs/apt.log"; then echo -e "${GREEN}#${RESET} Successfully installed jsvc and libcommons-daemon-java! \\n"; else echo -e "${RED}#${RESET} Failed to install jsvc and libcommons-daemon-java in the first run...\\n"; abort; fi
    fi
  fi
fi
sleep 3

# Quick workaround for 7.2.91 and older 7.2 versions.
if [[ "${first_digit_unifi}" == "7" && "${second_digit_unifi}" == "2" && "${third_digit_unifi}" -le "91" ]]; then
  NAME="unifi"
  UNIFI_USER="${UNIFI_USER:-unifi}"
  DATADIR="${UNIFI_DATA_DIR:-/var/lib/$NAME}"
  if ! id "${UNIFI_USER}" >/dev/null 2>&1; then
    adduser --system --home "${DATADIR}" --no-create-home --group --disabled-password --quiet "${UNIFI_USER}"
  fi
  if ! [[ -d "/usr/lib/unifi/" ]]; then mkdir -p /usr/lib/unifi/ && chown -R unifi:unifi /usr/lib/unifi/; fi
  if ! [[ -d "/var/lib/unifi/" ]]; then mkdir -p /var/lib/unifi/ && chown -R unifi:unifi /var/lib/unifi/; fi
fi

header
echo -e "${WHITE_R}#${RESET} Installing your UniFi Network Application ( ${WHITE_R}${unifi_clean}${RESET} )...\\n"
sleep 2
if [[ "${script_option_custom_url}" != 'true' ]]; then
  unifi_temp="$(mktemp --tmpdir=/tmp unifi_sysvinit_all_"${unifi_clean}"_XXX.deb)"
  unifi_fwupdate="$(curl -s "https://fw-update.ui.com/api/firmware-latest?filter=eq~~version_major~~${first_digit_unifi}&filter=eq~~version_minor~~${second_digit_unifi}&filter=eq~~version_patch~~${third_digit_unifi}&filter=eq~~platform~~debian" | jq -r "._embedded.firmware[]._links.data.href")"
  echo -e "${WHITE_R}#${RESET} Downloading the UniFi Network Application..."
  echo -e "\\n------- $(date +%F-%R) -------\\n" &>> "${eus_dir}/logs/unifi_download.log"
  if wget "${wget_progress[@]}" -O "${unifi_temp}" "https://dl.ui.com/unifi/${unifi_secret}/unifi_sysvinit_all.deb" &>> "${eus_dir}/logs/unifi_download.log"; then
    echo -e "${GREEN}#${RESET} Successfully downloaded application version ${unifi_clean}! \\n"
  elif wget "${wget_progress[@]}" -O "${unifi_temp}" "https://dl.ui.com/unifi/${unifi_clean}/unifi_sysvinit_all.deb" &>> "${eus_dir}/logs/unifi_download.log"; then
    echo -e "${GREEN}#${RESET} Successfully downloaded application version ${unifi_clean}! \\n"
  elif wget "${wget_progress[@]}" -O "${unifi_temp}" "https://dl.ui.com/unifi/debian/pool/ubiquiti/u/unifi/unifi_${unifi_repo_version}_all.deb" &>> "${eus_dir}/logs/unifi_download.log"; then
    echo -e "${GREEN}#${RESET} Successfully downloaded application version ${unifi_clean}! \\n"
  elif wget "${wget_progress[@]}" -O "${unifi_temp}" "${unifi_fwupdate}" &>> "${eus_dir}/logs/unifi_download.log"; then
    echo -e "${GREEN}#${RESET} Successfully downloaded application version ${unifi_clean}! \\n"
  else
    echo -e "${RED}#${RESET} Failed to download application version ${unifi_clean}...\\n"
    abort
  fi
else
  echo -e "${WHITE_R}#${RESET} Downloading the UniFi Network Application..."
  echo -e "${GREEN}#${RESET} UniFi Network Application version ${WHITE_R}${unifi_clean}${RESET} has already been downloaded! \n"
fi
if dpkg -l | grep "^ii\\|^hi" | grep -iq "temurin-${required_java_version_short}-jdk"; then
  eus_temp_dir="$(mktemp -d --tmpdir=${eus_dir} unifi.deb.XXX)"
  echo -e "${WHITE_R}#${RESET} This setup is using temurin-${required_java_version_short}-jdk... Editing the UniFi Network Application dependencies..."
  if dpkg-deb -x "${unifi_temp}" "${eus_temp_dir}" &>> "${eus_dir}/logs/unifi-custom-deb-file.log"; then
    if dpkg-deb --control "${unifi_temp}" "${eus_temp_dir}/DEBIAN" &>> "${eus_dir}/logs/unifi-custom-deb-file.log"; then
      if [[ -e "${eus_temp_dir}/DEBIAN/control" ]]; then
        current_state_unifi_deb="$(stat -c "%y" "${eus_temp_dir}/DEBIAN/control")"
        if sed -i "s/openjdk-${required_java_version_short}-jre-headless/temurin-${required_java_version_short}-jdk/g" "${eus_temp_dir}/DEBIAN/control" &>> "${eus_dir}/logs/unifi-custom-deb-file.log"; then
          echo -e "${GREEN}#${RESET} Successfully edited the dependencies of the UniFi Network Application deb file! \\n"
          if [[ "${current_state_unifi_deb}" != "$(stat -c "%y" "${eus_temp_dir}/DEBIAN/control")" ]]; then
            unifi_new_deb="$(basename "${unifi_temp}" .deb).new.deb"
            echo -e "${WHITE_R}#${RESET} Building a new UniFi Network Application deb file... This may take a while..."
            if dpkg -b "${eus_temp_dir}" "${unifi_new_deb}" &>> "${eus_dir}/logs/unifi-custom-deb-file.log"; then
              unifi_temp="${unifi_new_deb}"
              echo -e "${GREEN}#${RESET} Successfully builded a new UniFi Network Application deb file! \\n"
            else
              echo -e "${RED}#${RESET} Failed to build a new UniFi Network Application deb file...\\n"
            fi
          else
            echo -e "${RED}#${RESET} Failed to edit the dependencies of the UniFi Network Application deb file...\\n"
          fi
        else
          echo -e "${RED}#${RESET} Failed to edit the dependencies of the UniFi Network Application deb file...\\n"
        fi
      else
        echo -e "${RED}#${RESET} Failed to detect the required files to edit the dependencies of the UniFi Network Application...\\n"
      fi
    else
      echo -e "${RED}#${RESET} Failed to unpack the current UniFi Network Application deb file...\\n"
    fi
  else
    echo -e "${RED}#${RESET} Failed to edit the dependencies of the UniFi Network Application deb file...\\n"
  fi
  rm -rf "${eus_temp_dir}" &> /dev/null
fi
if [[ -f "/tmp/EUS/ignore-depends" ]]; then rm --force /tmp/EUS/ignore-depends &> /dev/null; fi
if ! dpkg -l | grep "^ii\\|^hi" | grep -iq "mongodb-server\\|mongodb-org-server"; then echo -e "mongodb-server" &>> /tmp/EUS/ignore-depends; fi
if ! dpkg -l | grep "^ii\\|^hi" | grep -iq "${required_java_version}-jre-headless"; then echo -e "${required_java_version}-jre-headless" &>> /tmp/EUS/ignore-depends; fi
if [[ -f /tmp/EUS/ignore-depends && -s /tmp/EUS/ignore-depends ]]; then IFS=" " read -r -a ignored_depends <<< "$(tr '\r\n' ',' < /tmp/EUS/ignore-depends | sed 's/.$//')"; rm --force /tmp/EUS/ignore-depends &> /dev/null; dpkg_ignore_depends_flag="--ignore-depends=${ignored_depends[@]}"; fi
echo -e "${WHITE_R}#${RESET} Installing the UniFi Network Application..."
check_service_overrides
echo "unifi unifi/has_backup boolean true" 2> /dev/null | debconf-set-selections
# shellcheck disable=SC2086
if DEBIAN_FRONTEND=noninteractive dpkg -i ${dpkg_ignore_depends_flag} "${unifi_temp}" &>> "${eus_dir}/logs/unifi_install.log"; then
  echo -e "${GREEN}#${RESET} Successfully installed the UniFi Network Application! \\n"
else
  echo -e "${RED}#${RESET} Failed to install the UniFi Network Application...\\n"
  abort
fi
rm --force "${unifi_temp}" 2> /dev/null
systemctl start unifi || abort
sleep 3

dash_port=$(grep "unifi.https.port" /usr/lib/unifi/data/system.properties 2> /dev/null | cut -d'=' -f2 | tail -n1)
info_port=$(grep "unifi.http.port" /usr/lib/unifi/data/system.properties 2> /dev/null | cut -d'=' -f2 | tail -n1)
if [[ -z "${dash_port}" ]]; then dash_port="8443"; fi
if [[ -z "${info_port}" ]]; then info_port="8080"; fi

if [[ "${change_unifi_ports}" == 'true' ]]; then
  if [[ -f /usr/lib/unifi/data/system.properties && -s /usr/lib/unifi/data/system.properties ]]; then
    header
    echo -e "${WHITE_R}#${RESET} system.properties file got created!"
    echo -e "${WHITE_R}#${RESET} Stopping the UniFi Network Application.."
    systemctl stop unifi && echo -e "${GREEN}#${RESET} Successfully stopped the UniFi Network Application!" || echo -e "${RED}#${RESET} Failed to stop the UniFi Network Application."
    sleep 2
    change_default_ports
  else
    while sleep 3; do
      if [[ -f /usr/lib/unifi/data/system.properties && -s /usr/lib/unifi/data/system.properties ]]; then
        echo -e "${WHITE_R}#${RESET} system.properties got created!"
        echo -e "${WHITE_R}#${RESET} Stopping the UniFi Network Application.."
        systemctl stop unifi && echo -e "${GREEN}#${RESET} Successfully stopped the UniFi Network Application!" || echo -e "${RED}#${RESET} Failed to stop the UniFi Network Application."
        sleep 2
        change_default_ports
        break
      else
        header_red
        echo -e "${WHITE_R}#${RESET} system.properties file is not there yet.." && sleep 2
      fi
    done
  fi
fi

# Check if service is enabled
if ! [[ "${os_codename}" =~ (precise|maya|trusty|qiana|rebecca|rafaela|rosa) ]]; then
  if systemctl list-units --full -all | grep -Fioq "unifi.service"; then
    SERVICE_UNIFI=$(systemctl is-enabled unifi)
    if [[ "$SERVICE_UNIFI" = 'disabled' ]]; then
      if ! systemctl enable unifi 2>/dev/null; then
        echo -e "${RED}#${RESET} Failed to enable service | UniFi"
        sleep 3
      fi
    fi
  fi
fi

if [[ "${script_option_skip}" != 'true' || "${script_option_add_repository}" == 'true' ]] && [[ "${architecture}" == "amd64" ]]; then
  header
  echo -e "${WHITE_R}#${RESET} Would you like to update the UniFi Network Application via APT?"
  if [[ "${script_option_skip}" != 'true' ]]; then read -rp $'\033[39m#\033[0m Do you want the script to add the source list file? (Y/n) ' yes_no; fi
  case "$yes_no" in
      [Yy]*|"")
        header
        echo -e "${WHITE_R}#${RESET} Adding source list..."
        sleep 3
        sed -i '/unifi/d' /etc/apt/sources.list
        rm --force /etc/apt/sources.list.d/100-ubnt-unifi.list 2> /dev/null
        if ! wget -qO /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg; then echo "06E85760C0A52C50" &>> /tmp/EUS/keys/missing_keys; fi
        echo "deb https://www.ui.com/downloads/unifi/debian unifi-${first_digit_unifi}.${second_digit_unifi} ubiquiti" &> /etc/apt/sources.list.d/100-ubnt-unifi.list && repository_added=true && echo -e "${GREEN}#${RESET} Successfully added UniFi Network Application source list! \\n"
        hide_apt_update=true
        run_apt_get_update
        echo -ne "\\r${WHITE_R}#${RESET} Checking if repository is valid..." && sleep 1
        if grep -ioq "unifi-${first_digit_unifi}.${second_digit_unifi} Release' does not" /tmp/EUS/keys/apt_update; then if [[ "${repository_added}" == 'true' ]]; then rm -f /etc/apt/sources.list.d/100-ubnt-unifi.list &> /dev/null && repository_removed=true; fi; fi
        if [[ "${repository_removed}" == 'true' ]]; then echo -ne "\\r${RED}#${RESET} The added UniFi Repository is not valid/used, the repository list will be removed."; else echo -ne "\\r${GREEN}#${RESET} The added UniFi Repository is valid!"; fi
        sleep 3;;
      [Nn]*) ;;
  esac
fi

if dpkg -l ufw | grep -q "^ii\\|^hi"; then
  if ufw status verbose | awk '/^Status:/{print $2}' | grep -xq "active"; then
    if [[ "${script_option_skip}" != 'true' && "${script_option_local_install}" != 'true' ]]; then
      header
      read -rp $'\033[39m#\033[0m Is/will your application only be used locally ( regarding device discovery )? (Y/n) ' yes_no
      case "${yes_no}" in
          [Yy]*|"")
              echo -e "${WHITE_R}#${RESET} Script will ensure that 10001/udp for device discovery will be added to UFW."
              script_option_local_install=true
              sleep 3;;
          [Nn]*|*) ;;
      esac
    fi
    header
    echo -e "${WHITE_R}#${RESET} Uncomplicated Firewall ( UFW ) seems to be active."
    echo -e "${WHITE_R}#${RESET} Checking if all required ports are added!"
    rm -rf /tmp/EUS/ports/* &> /dev/null
    mkdir -p /tmp/EUS/ports/ &> /dev/null
    ssh_port=$(awk '/Port/{print $2}' /etc/ssh/sshd_config | head -n1)
    if [[ "${script_option_local_install}" == 'true' ]]; then
      unifi_ports=(3478/udp "${info_port}"/tcp "${dash_port}"/tcp 8880/tcp 8843/tcp 6789/tcp 10001/udp)
      echo -e "3478/udp\\n${info_port}/tcp\\n${dash_port}/tcp\\n8880/tcp\\n8843/tcp\\n6789/tcp\\n10001/udp" &>> /tmp/EUS/ports/all_ports
    else
      unifi_ports=(3478/udp "${info_port}"/tcp "${dash_port}"/tcp 8880/tcp 8843/tcp 6789/tcp)
      echo -e "3478/udp\\n${info_port}/tcp\\n${dash_port}/tcp\\n8880/tcp\\n8843/tcp\\n6789/tcp" &>> /tmp/EUS/ports/all_ports
    fi
    echo -e "${ssh_port}" &>> /tmp/EUS/ports/all_ports
    ufw status verbose &>> /tmp/EUS/ports/ufw_list
    while read -r port; do
      port_number_only=$(echo "${port}" | cut -d'/' -f1)
      # shellcheck disable=SC1117
      if ! grep "^${port_number_only}\b\\|^${port}\b" /tmp/EUS/ports/ufw_list | grep -iq "ALLOW IN"; then
        required_port_missing=true
      fi
      # shellcheck disable=SC1117
      if ! grep -v "(v6)" /tmp/EUS/ports/ufw_list | grep "^${port_number_only}\b\\|^${port}\b" | grep -iq "ALLOW IN"; then
        required_port_missing=true
      fi
    done < /tmp/EUS/ports/all_ports
    if [[ "${required_port_missing}" == 'true' ]]; then
      echo -e "\\n${WHITE_R}----${RESET}\\n\\n"
      echo -e "${WHITE_R}#${RESET} We are missing required ports.."
      if [[ "${script_option_skip}" != 'true' ]]; then
        read -rp $'\033[39m#\033[0m Do you want to add the required ports for your UniFi Network Application? (Y/n) ' yes_no
      else
        echo -e "${WHITE_R}#${RESET} Adding required UniFi ports.."
        sleep 2
      fi
      case "${yes_no}" in
         [Yy]*|"")
            echo -e "\\n${WHITE_R}----${RESET}\\n\\n"
            for port in "${unifi_ports[@]}"; do
              port_number=$(echo "${port}" | cut -d'/' -f1)
              ufw allow "${port}" &> "/tmp/EUS/ports/${port_number}"
              if [[ -f "/tmp/EUS/ports/${port_number}" && -s "/tmp/EUS/ports/${port_number}" ]]; then
                if grep -iq "added" "/tmp/EUS/ports/${port_number}"; then
                  echo -e "${GREEN}#${RESET} Successfully added port ${port} to UFW."
                fi
                if grep -iq "skipping" "/tmp/EUS/ports/${port_number}"; then
                  echo -e "${YELLOW}#${RESET} Port ${port} was already added to UFW."
                fi
              fi
            done
            if [[ -f /etc/ssh/sshd_config && -s /etc/ssh/sshd_config ]]; then
              if ! ufw status verbose | grep -v "(v6)" | grep "${ssh_port}" | grep -iq "ALLOW IN"; then
                echo -e "\\n${WHITE_R}----${RESET}\\n\\n${WHITE_R}#${RESET} Your SSH port ( ${ssh_port} ) doesn't seem to be in your UFW list.."
                if [[ "${script_option_skip}" != 'true' ]]; then
                  read -rp $'\033[39m#\033[0m Do you want to add your SSH port to the UFW list? (Y/n) ' yes_no
                else
                  echo -e "${WHITE_R}#${RESET} Adding port ${ssh_port}.."
                  sleep 2
                fi
                case "${yes_no}" in
                   [Yy]*|"")
                      echo -e "\\n${WHITE_R}----${RESET}\\n"
                      ufw allow "${ssh_port}" &> "/tmp/EUS/ports/${ssh_port}"
                      if [[ -f "/tmp/EUS/ports/${ssh_port}" && -s "/tmp/EUS/ports/${ssh_port}" ]]; then
                        if grep -iq "added" "/tmp/EUS/ports/${ssh_port}"; then
                          echo -e "${GREEN}#${RESET} Successfully added port ${ssh_port} to UFW."
                        fi
                        if grep -iq "skipping" "/tmp/EUS/ports/${ssh_port}"; then
                          echo -e "${YELLOW}#${RESET} Port ${ssh_port} was already added to UFW."
                        fi
                      fi;;
                   [Nn]*|*) ;;
                esac
              fi
            fi;;
         [Nn]*|*) ;;
      esac
    else
      echo -e "\\n${WHITE_R}----${RESET}\\n\\n${WHITE_R}#${RESET} All required ports already exist!"
    fi
    echo -e "\\n\\n" && sleep 2
  fi
fi

if [[ -z "${SERVER_IP}" ]]; then
  SERVER_IP=$(ip addr | grep -A8 -m1 MULTICAST | grep -m1 inet | cut -d' ' -f6 | cut -d'/' -f1)
fi

# Check if application is reachable via public IP.
timeout 1 nc -zv "${PUBLIC_SERVER_IP}" "${dash_port}" &> /dev/null && public_reachable=true

# Check if application is up and running + if it respond on public IP
if [[ "${public_reachable}" == 'true' ]]; then
  check_count=0
  while [[ "${check_count}" -lt '60' ]]; do
    if [[ "${check_count}" == '3' ]]; then
      header
      echo -e "${WHITE_R}#${RESET} Checking if the UniFi Network application is responding... (this can take up to 60 seconds)"
      unifi_api_message=true
    fi
    if [[ "$(curl -sk "https://localhost:${dash_port}/status" | jq -r '.meta.up' 2> /dev/null)" == 'true' ]]; then
      if [[ "${unifi_api_message}" == 'true' ]]; then echo -e "${GREEN}#${RESET} The application is up and running! \\n"; sleep 2; fi
      if [[ "${unifi_api_message}" == 'true' ]]; then echo -e "${WHITE_R}#${RESET} Checking if the application is also responding on it's public IP address..."; fi
      if [[ "$(curl -sk "https://${PUBLIC_SERVER_IP}:${dash_port}/status" | jq -r '.meta.up' 2> /dev/null)" == 'true' ]]; then
        if [[ "${unifi_api_message}" == 'true' ]]; then echo -e "${GREEN}#${RESET} The application is responding on it's public IP address! The script will continue with the SSL setup!"; sleep 4; fi
        public_reachable=true
      else
        if [[ "${unifi_api_message}" == 'true' ]]; then echo -e "${GREEN}#${RESET} The application does not respond on it's public IP address..."; sleep 4; fi
        public_reachable=false
      fi
      break
    fi
    ((check_count=check_count+1))
    sleep 1
  done
fi

if [[ "${public_reachable}" == 'true' ]] && [[ "${script_option_skip}" != 'true' || "${fqdn_specified}" == 'true' ]]; then
  echo -e "--install-script" &>> /tmp/EUS/le_script_options
  if [[ -f /tmp/EUS/le_script_options && -s /tmp/EUS/le_script_options ]]; then IFS=" " read -r le_script_options <<< "$(tr '\r\n' ' ' < /tmp/EUS/le_script_options)"; fi
  header
  le_script=true
  echo -e "${WHITE_R}#${RESET} Your application seems to be exposed to the internet. ( port 8443 is open )"
  echo -e "${WHITE_R}#${RESET} It's recommend to secure your application with a SSL certficate.\\n"
  echo -e "${WHITE_R}#${RESET} Requirements:"
  echo -e "${WHITE_R}-${RESET} A domain name and A record pointing to the server that runs the UniFi Network Application."
  echo -e "${WHITE_R}-${RESET} Port 80 needs to be open ( port forwarded )\\n\\n"
  if [[ "${script_option_skip}" != 'true' ]]; then read -rp $'\033[39m#\033[0m Do you want to download and execute my UniFi Easy Encrypt Script? (Y/n) ' yes_no; fi
  case "$yes_no" in
      [Yy]*|"")
          rm --force unifi-easy-encrypt.sh &> /dev/null
          # shellcheck disable=SC2068
          wget "${wget_progress[@]}" -q https://get.glennr.nl/unifi/extra/unifi-easy-encrypt.sh && bash unifi-easy-encrypt.sh ${le_script_options[@]};;
      [Nn]*) ;;
  esac
fi

if [[ "${netcat_installed}" == 'true' ]]; then
  header
  echo -e "${WHITE_R}#${RESET} The script installed netcat, we do not need this anymore.\\n"
  echo -e "${WHITE_R}#${RESET} Uninstalling netcat..."
  if dpkg --purge netcat netcat-traditional -y &> /dev/null; then
    echo -e "${GREEN}#${RESET} Successfully uninstalled netcat."
  else
    echo -e "${RED}#${RESET} Failed to uninstall netcat."
  fi
  sleep 2
fi

if dpkg -l | grep "unifi " | grep -q "^ii\\|^hi"; then
  inform_port=$(grep "^unifi.http.port" /usr/lib/unifi/data/system.properties | cut -d'=' -f2 | tail -n1)
  dashboard_port=$(grep "^unifi.https.port" /usr/lib/unifi/data/system.properties | cut -d'=' -f2 | tail -n1)
  header
  echo -e "${GREEN}#${RESET} UniFi Network Application ${unifi_clean} has been installed successfully"
  if [[ "${public_reachable}" = 'true' ]]; then
    echo -e "${GREEN}#${RESET} Your application address: ${WHITE_R}https://$PUBLIC_SERVER_IP:${dash_port}${RESET}"
    if [[ "${le_script}" == 'true' ]]; then
      if [[ -d /usr/lib/EUS/ ]]; then
        if [[ -f /usr/lib/EUS/server_fqdn_install && -s /usr/lib/EUS/server_fqdn_install ]]; then
          application_fqdn_le=$(tail -n1 /usr/lib/EUS/server_fqdn_install)
          rm --force /usr/lib/EUS/server_fqdn_install &> /dev/null
        fi
      elif [[ -d /srv/EUS/ ]]; then
        if [[ -f /srv/EUS/server_fqdn_install && -s /srv/EUS/server_fqdn_install ]]; then
          application_fqdn_le=$(tail -n1 /srv/EUS/server_fqdn_install)
          rm --force /srv/EUS/server_fqdn_install &> /dev/null
        fi
      fi
      if [[ -n "${application_fqdn_le}" ]]; then
        echo -e "${GREEN}#${RESET} Your application FQDN: ${WHITE_R}https://$application_fqdn_le:${dash_port}${RESET}"
      fi
    fi
  else
    echo -e "${GREEN}#${RESET} Your application address: ${WHITE_R}https://$SERVER_IP:${dash_port}${RESET}"
  fi
  echo -e "\\n"
  if [[ "${os_codename}" =~ (precise|maya|trusty|qiana|rebecca|rafaela|rosa) ]]; then
    if systemctl status unifi | grep -iq running; then echo -e "${GREEN}#${RESET} UniFi is active ( running )"; else echo -e "${RED}#${RESET} UniFi failed to start... Please contact Glenn R. (AmazedMender16) on the Community Forums!"; fi
  else
    if systemctl is-active -q unifi; then echo -e "${GREEN}#${RESET} UniFi is active ( running )"; else echo -e "${RED}#${RESET} UniFi failed to start... Please contact Glenn R. (AmazedMender16) on the Community Forums!"; fi
  fi
  if [[ "${change_unifi_ports}" == 'true' ]]; then
    echo -e "\\n${WHITE_R}---- ${RED}NOTE${WHITE_R} ----${RESET}\\n\\n${WHITE_R}#${RESET} Your default application port(s) have changed!\\n"
    if [[ -n "${inform_port}" ]]; then
      echo -e "${WHITE_R}#${RESET} Device Inform port: ${inform_port}"
    fi
    if [[ -n "${dashboard_port}" ]]; then
      echo -e "${WHITE_R}#${RESET} Management Dashboard port: ${dashboard_port}"
    fi
    echo -e "\\n${WHITE_R}--------------${RESET}\\n"
  else
    if [[ "${port_8080_in_use}" == 'true' && "${port_8443_in_use}" == 'true' && "${port_8080_pid}" == "${port_8443_pid}" ]]; then
      echo -e "\\n${RED}#${RESET} Port ${info_port} and ${dash_port} is already in use by another process ( PID ${port_8080_pid} ), your UniFi Network Controll will most likely not start.."
      echo -e "${RED}#${RESET} Disable the service that is using port ${info_port} and ${dash_port} ( ${port_8080_service} ) or kill the process with the command below"
      echo -e "${RED}#${RESET} sudo kill -9 ${port_8080_pid}\\n"
    else
      if [[ "${port_8080_in_use}" == 'true' ]]; then
        echo -e "\\n${RED}#${RESET} Port ${info_port} is already in use by another process ( PID ${port_8080_pid} ), your UniFi Network Controll will most likely not start.."
        echo -e "${RED}#${RESET} Disable the service that is using port ${info_port} ( ${port_8080_service} ) or kill the process with the command below"
        echo -e "${RED}#${RESET} sudo kill -9 ${port_8080_pid}\\n"
      fi
      if [[ "${port_8443_in_use}" == 'true' ]]; then
        echo -e "\\n${RED}#${RESET} Port ${dash_port} is already in use by another process ( PID ${port_8443_pid} ), your UniFi Network Controll will most likely not start.."
        echo -e "${RED}#${RESET} Disable the service that is using port ${dash_port} ( ${port_8443_service} ) or kill the process with the command below"
        echo -e "${RED}#${RESET} sudo kill -9 ${port_8443_pid}\\n"
      fi
    fi
  fi
  echo -e "\\n"
  author
  remove_yourself
else
  header_red
  echo -e "\\n${RED}#${RESET} Failed to successfully install UniFi Network Application ${unifi_clean}"
  echo -e "${RED}#${RESET} Please contact Glenn R. (AmazedMender16) on the Community Forums!${RESET}\\n\\n"
  remove_yourself
fi
