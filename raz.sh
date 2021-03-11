#!/bin/bash

loadkeys ru
setfont cyr-sun16
timedatectl set-ntp true
#######################################

(
  echo o;

  echo n;
  echo;
  echo;
  echo;
  echo +300M;

  #echo n;
  #echo;
  #echo;
  #echo;
  #echo +20G;

  #echo n;
  #echo;
  #echo;
  #echo;
  #echo +2048M;

  echo n;
  echo;
  echo;
  echo;
  echo;
  echo a;
  echo 1;

  echo w;
) | fdisk /dev/vda

lsblk


mkfs.ext2 /dev/vda1
echo;
mkfs.ext4 /dev/vda2 
echo;
