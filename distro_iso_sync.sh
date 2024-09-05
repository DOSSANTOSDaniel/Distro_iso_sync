#!/usr/bin/env bash

#--------------------------------------------------#
# Script_Name: distro_iso_sync.sh
#
# Author:  'dossantosjdf@gmail.com'
#
# Date: 15/07/2024
# Modif: 05/09/2024
# Version: 1.0
# Bash_Version: 5.1.16
#--------------------------------------------------#
# Description:
#
# Script non interactif, il permet : 
# - Télécharger les images ISOs des principales distributions Linux et FreeBSD. 
# - Tester et valider l'accessibilité au site de téléchargement de la distribution.
# - Mettre à jour quand une nouvelle image ISO est disponible sur le serveur distant.
# - La mise en place de la journalisation des erreurs.
#

# Global Variables
iso_dir="$HOME/Isos"

# Fichier où seront stockées les empreintes de chaque iso
init_sum="/tmp/.init_iso_sum"
final_sum="$iso_dir/.iso_sum"

# Options Wget
# --tries : Tentatives en cas d'échec.
wget_tries='3'
# --timeout : Délai d'attente max pour la réponse d'un serveur.
wget_timeout='60'
# --limit-rate : Limite la bande passante.
wget_limit_rate='13m'
# --wait : Attendre entre chaque téléchargement.
wget_wait='3'

# Rocky Linux
rocky_ver="$(curl -sL https://download.rockylinux.org/pub/rocky | grep -oP '(?<=href=")[0-9]*\.[0-9]*(?=/">)' | sort -Vr | head -1)"
rocky_url="https://download.rockylinux.org/pub/rocky/${rocky_ver}/isos/x86_64"
rocky_regex='(?<=href=")Rocky\-[0-9]*\-latest\-x86_64\-dvd\.iso(?=">)'

# Alma Linux
alma_ver="$(curl -sL https://repo.almalinux.org/almalinux/ | grep -oP '(?<=href=")[0-9]*(?=/">)' | sort -nr | head -1)"
alma_url="https://repo.almalinux.org/almalinux/${alma_ver}/isos/x86_64"
alma_regex='(?<=href=")[A-Za-z]*\-[0-9]*\-latest\-x86_64\-dvd\.iso(?=">)'

# Fedora
fedora_ver="$(curl -sL https://mirror.in2p3.fr/pub/fedora/linux/releases/ | grep -oP '(?<=href=")[0-9]*(?=/">)' | sort -Vr | head -1)"
fedora_url="https://mirror.in2p3.fr/pub/fedora/linux/releases/${fedora_ver}/Workstation/x86_64/iso"
fedora_regex='(?<=href=")Fedora\-Workstation\-Live\-x86_64\-[0-9]*\-([0-9]*\.){2}iso(?=">)'

# FreeBSD
freebsd_ver="$(curl -sL https://download.freebsd.org/ftp/releases/ISO-IMAGES/ | grep -oP '(?<=href=")[0-9]*\.[0-9]*(?=/" )' | sort -Vr | head -1)"
freebsd_url="https://download.freebsd.org/ftp/releases/ISO-IMAGES/${freebsd_ver}"
freebsd_regex='(?<=href=")FreeBSD\-[0-9]*\.[0-9]*\-RELEASE\-amd64\-dvd1\.iso(?=")'

# Ubuntu Server
ubuntusrv_ver="$(curl -s -L https://releases.ubuntu.com/ | grep -oP '(?<=href=")[0-9]*\.[0-9]*(?=/">)' | sort -Vr | head -1)"
ubuntusrv_url="https://releases.ubuntu.com/${ubuntusrv_ver}"
ubuntusrv_regex='(?<=href=")ubuntu\-[0-9]*(\.*[0-9]*){2}\-live\-server\-amd64\.iso(?=">)'

# Ubuntu
ubuntu_regex='(?<=href=")ubuntu\-[0-9]*(\.*[0-9]*){2}\-desktop\-amd64\.iso(?=">)'
ubuntu_url="$ubuntusrv_url"

# OpenSUSE
opensuse_ver="$(curl -sL https://get.opensuse.org/leap | grep -oP '(?<=url=/leap/)[^/]+(?=/)')"
opensuse_url="https://download.opensuse.org/distribution/leap/${opensuse_ver}/iso"
opensuse_regex='(?<=href="\./)openSUSE\-[A-Za-z]*\-[0-9]*\.[0-9]*\-DVD\-x86_64\-Current\.iso(?=">)'

# Proxmox
proxmox_ver="$(curl -sL https://enterprise.proxmox.com/iso/ | grep -oP '(?<=href="proxmox-ve_)[0-9]*\.[0-9]\-[0-9](?=.iso">)' | sort -Vr | head -1)"
proxmox_url="https://enterprise.proxmox.com/iso/proxmox-ve_${proxmox_ver}.iso"
proxmox_regex=""

# LinuxMint
mint_ver="$(curl -sL https://ftp.heanet.ie/mirrors/linuxmint.com/stable/ | grep -oP '(?<=href=")[0-9]*\.[0-9]*(?=/">)' | sort -Vr | head -n 1)"
mint_url="https://ftp.heanet.ie/mirrors/linuxmint.com/stable/${mint_ver}"
mint_regex='(?<=href=")linuxmint\-[0-9]*\.[0-9]*\-cinnamon\-64bit\.iso(?=">)'

# Debian
debian_ver="$(curl -sL https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/ | grep -oP '(?<=href="debian-)([0-9]*\.){2}[0-9]*(?=-amd64-DVD-1.iso">)' | sort -Vr | head -n 1)"
debian_url="https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-${debian_ver}-amd64-DVD-1.iso"
debian_regex=""

# ArchLinux
arch_url="https://archlinux.mirrors.ovh.net/archlinux/iso/latest/archlinux-x86_64.iso"
arch_regex=""

# Kali Linux
kali_ver="$(curl -sL https://cdimage.kali.org/kali-images/current/ | grep -oP '(?<=href="kali-linux-)[0-9]*\.[0-9]*(?=-live-amd64.iso")' | sort -rV | head -n 1)"
kali_url="https://cdimage.kali.org/kali-images/current/kali-linux-${kali_ver}-live-amd64.iso"
kali_regex=""

# Alpine
alpine_ver="$(curl -sL https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/ | grep -oP '(?<=href="alpine\-extended\-)([0-9]*\.){2}[0-9]*(?=\-x86_64\.iso">)' | sort -rV | head -n 1)"
alpine_url="https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/alpine-extended-${alpine_ver}-x86_64.iso"
alpine_regex=""

# Déclaration du tableau associatif pour stocker les expressions régulières et les URLs de chaque distribution
declare -A distros

distros=(
  [rockylinux]="$rocky_regex $rocky_url"
  [almalinux]="$alma_regex $alma_url"
  [fedora]="$fedora_regex $fedora_url"
  [freebsd]="$freebsd_regex $freebsd_url"
  [ubuntusrv]="$ubuntusrv_regex $ubuntusrv_url"
  [ubuntu]="$ubuntu_regex $ubuntu_url"
  [opensuse]="$opensuse_regex $opensuse_url"
  [proxmox]="$proxmox_regex $proxmox_url"
  [linuxmint]="$mint_regex $mint_url"
  [debian]="$debian_regex $debian_url"
  [archlinux]="$arch_regex $arch_url"
  [kalilinux]="$kali_regex $kali_url"
  [alpine]="$alpine_regex $alpine_url"
)

# Fonctions
# Fonction pour obtenir la dernière version de l'ISO pour une distribution donnée
get_latest_iso_url() {
  local regex="$1"
  local url="$2"
  if [ -n "$regex" ]; then
    curl -sL "$url" | grep -oP "$regex" | head -n 1
  else
    basename "$url"
  fi
}

message_log() {
  script_name="${0##\.\/}"
  script_name="${script_name%%\.sh}"

  message="$1"

  logger -t "$script_name" "$message !"
}

# Main
if [ ! -d "$iso_dir" ]; then
    mkdir -p "$iso_dir"
fi

if [ -n "$(find "$iso_dir" -mindepth 1 -print -quit)" ]; then
  # création des hash de début
  if [ -f "$final_sum" ]
  then
    temp_sum_file="$(find "$iso_dir" -type f -name "$(basename "$final_sum")")"
    mv "$temp_sum_file" "$init_sum"
  fi
fi

# Boucle sur les distributions pour afficher la dernière version de chaque ISO
for distro in "${!distros[@]}"; do
  regex_url="${distros[$distro]}"
  regex=$(echo "$regex_url" | cut -d ' ' -f 1)
  url=$(echo "$regex_url" | cut -d ' ' -f 2)
  latest_iso=$(get_latest_iso_url "$regex" "$url")
  if [ -z "$regex" ]; then
    url="$(dirname "$url")"
  fi
  url_response="$(curl -o /dev/null -s -w "%{http_code}\n" "$url")"
if [[ $url_response =~ ^(200|301|302)$ ]]; then
    if [ -n "$latest_iso" ]; then
      # Description des options de wget
      # --continue : Permet de reprendre le téléchargement là ou il a été interrompu.
      # --tries= : Tentatives en cas d'échec.
      # --timestamping : Télécharge seulement si les fichiers dans le serveur distant sont plus récents que ceux en local.
      # --no-netrc : Ignore les informations d'authentification.
      # --timeout= : Délai d'attente max pour la réponse d'un serveur.
      # --limit-rate= : Limite la bande passante.
      # --wait= : Attendre entre chaque téléchargement.
      # --no-http-keep-alive : Désactiver les connexions persistantes.
      # --no-cache : Ignore le cache proxy.
      # --recursive : Télécharge récursivement.
      # --no-parent : Ne remonte pas sur les dossiers parents.
      # --no-directories : Télécharge seulement les fichiers ne crée pas de repertoire.
      # --no-host-directories : Ne crée pas de dossier pour le nom de domaine du site.
      # --directory-prefix : Dossier dans lequel sera stocké le fichier.
      wget --continue \
        --quiet \
        --tries="$wget_tries" \
        --timestamping \
        --no-netrc \
        --timeout="$wget_timeout" \
        --limit-rate="$wget_limit_rate" \
        --wait="$wget_wait" \
        --no-http-keep-alive \
        --no-cache \
        --recursive \
        --no-parent \
        --no-directories \
        --no-host-directories \
        --directory-prefix="$iso_dir" "${url%/}/$latest_iso"
        
        if [ "$?" != "0" ]; then
        message_log "Erreur Téléchargement : $latest_iso !"
        fi
    else
      message_log "Erreur: Pas d'isos dans le serveur distant ! $url "
    fi
  else
    message_log "Url inacessible : $url, code HTTP :$url_response !"
  fi
done

#Créer les empreintes MD5 après actualisation
find "$iso_dir" -type f -not -name ".*" -exec cksum {} \; > "$final_sum"

# Comparer les deux fichiers d'empreintes et afficher les différences
if [ -f "$init_sum" ] && [ -f "$final_sum" ]; then
  diff_output="$(diff "$init_sum" "$final_sum")"
  
  if [ -n "$diff_output" ]; then
    output_download="$(basename "$(echo "$diff_output" | grep "^<" | awk '{print $4}')")"
  else
    output_download="Pas de mises à jour des isos."
  fi
  # Supprimer le fichier temporaire
  rm -rf "$init_sum"
  message_log "$output_download"
fi
