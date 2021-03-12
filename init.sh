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
  2) format device and mount partitions
  3) install base packages and WM
  4) generate /etc/fstab
  5) configure system
  #6) install AUR packages and configure user
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
  echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
  echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen
  echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf 
  echo "KEYMAP=ru" >> /etc/vconsole.conf
  echo "FONT=cyr-sun16" >> /etc/vconsole.conf
  export LANG="ru_RU.UTF-8"

  echo 'Completed!'
  step=2
fi







if [[ $step -le 2 ]]
then
  echo '########################################################################'
  echo '#                                                                      #'
  echo '# Step 2: format device and mount partitions                           #'
  echo '#                                                                      #'
  echo '########################################################################'
  echo

  # чтобы случайно не убить данные на диске
  # exit 1

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





if [[ $step -le 3 ]]
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
  step=4
fi








if [[ $step -le 4 ]]
then
  echo '########################################################################'
  echo '#                                                                      #'
  echo '# Step 4: generate /etc/fstab                                          #'
  echo '#                                                                      #'
  echo '########################################################################'
  echo

  genfstab -U "$mount" >> "$mount/etc/fstab"
  echo 'Completed!'
  step=5
fi





configure_system_commands=$(cat << COMMANDS
timedatectl set-ntp true
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf 
echo "KEYMAP=ru" >> /etc/vconsole.conf
echo "FONT=cyr-sun16" >> /etc/vconsole.conf
echo ""
echo " Укажите пароль для ROOT "
passwd

useradd -m -g users -G wheel -s /bin/bash $username

pacman -S reflector --noconfirm
reflector --verbose -l 50 -p http --sort rate --save /etc/pacman.d/mirrorlist
reflector --verbose -l 15 --sort rate --save /etc/pacman.d/mirrorlist



# UEFI(systemd-boot )
bootctl install 
clear
echo ' default arch ' > /boot/loader/loader.conf
echo ' timeout 10 ' >> /boot/loader/loader.conf
echo ' editor 0' >> /boot/loader/loader.conf
echo 'title   Arch Linux' > /boot/loader/entries/arch.conf
echo "linux  /vmlinuz-linux" >> /boot/loader/entries/arch.conf

# # GRUB(legacy)
# pacman -S grub   --noconfirm
# lsblk -f
# read -p "Укажите диск куда установить GRUB (sda/sdb): " x_boot
# grub-install /dev/$x_boot
# grub-mkconfig -o /boot/grub/grub.cfg
# echo " установка завершена "

# # UEFI-GRUB
# pacman -S grub os-prober --noconfirm
# grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
# grub-mkconfig -o /boot/grub/grub.cfg



mkinitcpio -p linux


echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

pacman -Sy xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils --noconfirm


pacman -S i3 i3-wm i3status  dmenu  --noconfirm
pacman -S lightdm lightdm-gtk-greeter-settings lightdm-gtk-greeter --noconfirm
systemctl enable lightdm.service -f


pacman -Sy networkmanager networkmanager-openvpn network-manager-applet ppp --noconfirm
systemctl enable NetworkManager.service

systemctl enable dhcpcd.service

pacman -Sy pulseaudio-bluetooth alsa-utils pulseaudio-equalizer-ladspa   --noconfirm
systemctl enable bluetooth.service

pacman -Sy exfat-utils ntfs-3g   --noconfirm

pacman -Sy unzip unrar  lha ark --noconfirm

pacman -S blueman --noconfirm

pacman -S htop xterm --noconfirm

pacman -S filezilla --noconfirm

pacman -S gwenview --noconfirm

pacman -S neofetch  --noconfirm

pacman -S vlc  --noconfirm

pacman -S gparted  --noconfirm

pacman -S telegram-desktop   --noconfirm

pacman -S flameshot --noconfirm

pacman -S  ttf-arphic-ukai git ttf-liberation ttf-dejavu ttf-arphic-uming ttf-fireflysung ttf-sazanami --noconfirm

pacman -S opera pepper-flash --noconfirm 

cd /home/$username
git clone https://aur.archlinux.org/yay.git
chown -R $username:users /home/$username/yay
chown -R $username:users /home/$username/yay/PKGBUILD 
cd /home/$username/yay  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/yay
clear

cd /home/$username
git clone https://aur.archlinux.org/gconf.git 
chown -R $username:users /home/$username/gconf
chown -R $username:users /home/$username/gconf/PKGBUILD 
cd /home/$username/gconf  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/gconf
###
cd /home/$username
git clone https://aur.archlinux.org/vk-messenger.git
chown -R $username:users /home/$username/vk-messenger
chown -R $username:users /home/$username/vk-messenger/PKGBUILD 
cd /home/$username/vk-messenger  
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/vk-messenger
#####
clear

cd /home/$username
 git clone https://aur.archlinux.org/pamac-aur.git
chown -R $username:users /home/$username/pamac-aur
chown -R $username:users /home/$username/pamac-aur/PKGBUILD 
cd /home/$username/pamac-aur
sudo -u $username  makepkg -si --noconfirm  
rm -Rf /home/$username/pamac-aur
clear


COMMANDS
)



if [[ $step -le 5 ]]
then
  echo '########################################################################'
  echo '#                                                                      #'
  echo '# Step 5: configure system                                             #'
  echo '#                                                                      #'
  echo '########################################################################'
  echo

  arch-chroot "$mount" bash <<< "$configure_system_commands"
  echo 'Completed!'
fi