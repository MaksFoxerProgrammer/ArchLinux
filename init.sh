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
  echo '# Step 1: format device and mount partitions                           #'
  echo '#                                                                      #'
  echo '########################################################################'
  echo

  # чтобы случайно не убить данные на диске
  exit 1

  # РАЗМЕТКА
  # ----------------------------------------------------------
  parted -a optimal $device  	# выравнивание разделов
  unit mib
  mklabel gpt

  mkpart primary 2 258		#1 /dev/sda1 256MB EFI (FAT32)
  set 1 boot on

  mkpart primary 258 514	#2 /dev/sda2 256MB boot (ext2)
  name 2 boot

  mkpart primary 514 4610	#3 /dev/sda3 4GB (SWAP)
  name 3 swap

  mkpart primary 4610 -1	#4 /dev/sda4 (ext4)
  name 4 root

  print						#чё вышло?
  quit

  # ФОРМАТИРОВАНИЕ
  # -----------------------------------------
  mkfs.fat -F32 /dev/sda1		#EFI  (FAT32)
  mkfs.ext2 /dev/sda2			#boot (ext2)
  mkfs.ext4 /dev/sda4			#root (ext4)
  # mkswap /dev/sda3			#swap
  # swapon /dev/sda3

  # МОНТИРОВАНИЕ
  # ---------------------------
  mount /dev/sda4 /mnt
  mkdir -p /mnt/{home,boot}
  mount /dev/sda2 /mnt/boot

  echo 'Completed!'
  step=2
fi