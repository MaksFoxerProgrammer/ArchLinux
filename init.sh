#!/bin/bash

device='/dev/sda'
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
