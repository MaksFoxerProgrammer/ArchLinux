#!/bin/bash

packages=(
    base
    base-devel
    btrfs-progs
    docker-compose
    efibootmgr
    fd
    fzf
    gimp
    git
    gparted
    grub
    gvm
    htop
    jq
    libldm
    linux
    linux-firmware
    linux-headers
    man-db
    man-pages
    mc
    mlocate
    mpv
    nano
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
    vim
    wget
    whois
    xorg
    zsh
  )

  set +e
  pacstrap "$mount" "${packages[@]}"
  set -e

  echo 'Completed!'