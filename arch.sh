#!/bin/bash

# Partitioning
gdisk /dev/sda <<EOF
o
Y
n
1

+1G
EF00
n
2

+183G
8300
n
3

+16G
8200
w
Y
EOF

# Format partitions
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda2
mkswap /dev/sda3
swapon /dev/sda3

# Mount system and create directories
mount /dev/sda2 /mnt
mkdir /mnt/boot /mnt/var /mnt/home
mount /dev/sda1 /mnt/boot

# Install base system
pacman -Syy
pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd net-tools grub

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Configure base system
arch-chroot /mnt

# Set locale
nano /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

# Set time zone
ln -s /usr/share/zoneinfo/Europe/Helsinki /etc/localtime

# Set hardware clock and hostname
hwclock --systohc --utc
echo arindam-pc > /etc/hostname
systemctl enable dhcpcd

# Set root password, create user, and add to sudoers
passwd root
useradd -m -g users -G wheel -s /bin/bash atoof
passwd atoof

# Edit sudoers file
nano /etc/sudoers
# Add the following lines:
# root ALL=(ALL) ALL
# atoof ALL=(ALL) ALL

# Install GRUB
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux
exit

# Unmount system and reboot
umount /mnt/boot
umount /mnt
reboot
