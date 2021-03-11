#!/bin/bash

device='/dev/sda0'
mount='/mnt'
root=20
boot=300
home=0

hostname='ArchLinux'
username='ArchLinuxUser'
password='toor'

step=1

#./p3.sh $mount

usage() {
cat << EOF
    _             _       ___           _        _ _
   / \   _ __ ___| |__   |_ _|_ __  ___| |_ __ _| | | ___ _ __
  / _ \ | '__/ __| '_ \   | || '_ \/ __| __/ _\ | | |/ _ \ '__|
 / ___ \| | | (__| | | |  | || | | \__ \ || (_| | | |  __/ |
/_/   \_\_|  \___|_| |_| |___|_| |_|___/\__\__,_|_|_|\___|_|
Usage:
  bash `basename "$0"` [options]
Args:
  -h, --help      Show help and exit
  -u, --username  Username
  -p, --password  Password
  -H, --hostname  Hostname
  -d, --device    Device
  -m, --mount     Mountpoint
  -s, --step      Start from step
Steps:
  1) localization
  1) format device and mount partitions
  2) install base packages and WM
  3) generate /etc/fstab
  4) configure system
  5) install AUR packages and configure user
EOF
}



while [ $# -gt 0 ]
do
  case "$1" in
    -h | --help)
      usage
      exit 0;;

    -u | --username)
      username="$2"
      shift;;

    -p | --password)
      password="$2"
      shift;;

    -H | --hostname)
      hostname="$2"
      shift;;

    -d | --device)
      device="$2"
      shift;;

    -m | --mount | --mount)
      mount="$2"
      shift;;

    -s | --step)
      step="$2"
      shift;;

    *)
      die "Bed argument";;
  esac
  shift
done






if [[ $step -le 1 ]]
then
  echo '########################################################################'
  echo '#                                                                      #'
  echo '# Step 1: localization                                                 #'
  echo '#                                                                      #'
  echo '########################################################################'
  echo

  loadkeys ru
  setfont cyr-sun16
  # nano /etc/locale.gen     ####  add   ru_RU.UTF-8 UTF-8
  locale-gen
  export LANG="ru_RU.UTF-8"

  echo 'Completed!'
  step=2
fi







if [[ $step -le 1 ]]
then
  echo '########################################################################'
  echo '#                                                                      #'
  echo '# Step 2: format device and mount partitions                           #'
  echo '#                                                                      #'
  echo '########################################################################'
  echo

  # чтобы случайно не убить данные на диске
  exit 1

  # РАЗМЕТКА
  # ----------------------------------------------------------
  (
  echo 'unit mib';
  echo 'mklabel gpt';
  echo 'mkpart primary 2 258';		#1 /dev/vda1 256MB EFI (FAT32)
  echo 'set 1 boot on';
  echo 'mkpart primary 258 514';		#2 /dev/vda2 256MB boot (ext2)
  echo 'name 2 boot';
  echo 'mkpart primary 514 4610';		#3 /dev/vda3 4GB (SWAP)
  echo 'name 3 swap';
  echo 'mkpart primary 4610 -1';		#4 /dev/vda4 (ext4)
  echo 'name 4 root';
  print

  ) | parted -a optimal $device  # выравнивание разделов

  # ФОРМАТИРОВАНИЕ
  # ----------------------------------------------------------
  mkfs.fat -F32 ${device}1	&&		#EFI  (FAT32)
  mkfs.ext2 ${device}2 &&			#boot (ext2)
  mkfs.ext4 ${device}4 &&			#root (ext4)
  mkswap ${device}3 &&			#swap
  swapon ${device}3 &&
  # cfdisk /dev/vda
  

  # МОНТИРОВАНИЕ
  # ---------------------------
  mount ${device}4 /mnt
  mkdir -p /mnt/{home,boot}
  mount ${device}2 /mnt/boot

  echo 'Completed!'
  step=3
fi





if [[ $step -le 2 ]]
then
  echo '########################################################################'
  echo '#                                                                      #'
  echo '# Step 3: install base packages                                        #'
  echo '#                                                                      #'
  echo '########################################################################'
  echo

  packages=(
  	# База
    linux-firmware
    linux-zen-headers
    linux-zen
    base
    base-devel
    nano 
    vim 
    dhcpcd 
    dialog 
    wpa_supplicant 
    netctl 
    mc 
    git 
    wget
    net-tools
    htop

    # Для ядра и загрузчика
    grub 
    efibootmgr 
    dosfstools 
    os-prober 
    mtools


    # Из интеренета
    btrfs-progs
    docker-compose
    efibootmgr
    fd
    fzf
    gimp
    gparted
    grub
    gvm
    jq
    libldm
    linux
    linux-headers
    man-db
    man-pages
    mc
    mlocate
    mpv
    neofetch
    networkmanager-openvpn
    networkmanager-pptp
    noto-fonts
    noto-fonts-emoji
    ntfs-3g
    pkgfile
    pass
    qt5ct
    reflector
    rsync
    snapper
    systemd-swap
    whois
    xorg
    zsh
  )

  set +e
  pacstrap "$mount" "${packages[@]}"
  set -e

  echo 'Completed!'
fi








if [[ $step -le 3 ]]
then
  echo '########################################################################'
  echo '#                                                                      #'
  echo '# Step 4: generate /etc/fstab                                          #'
  echo '#                                                                      #'
  echo '########################################################################'
  echo

  genfstab -U "$mount" >> "$mount/etc/fstab"
  echo 'Completed!'
fi