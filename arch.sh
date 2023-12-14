#!/bin/bash

# Partitioning
parted /dev/sda mklabel gpt
parted /dev/sda mkpart primary 1MiB 1GiB
parted /dev/sda set 1 esp on
parted /dev/sda mkpart primary 1GiB 184GiB
parted /dev/sda mkpart primary 184GiB 200GiB

# Format partitions
mkfs.ext4 /dev/sda2
mkfs.ext4 /dev/sda3
mkswap /dev/sda4
swapon /dev/sda4

# Mount partitions
mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot

# Install base system
pacstrap /mnt base linux linux-firmware nano dhcpcd net-tools grub

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the installed system
arch-chroot /mnt

# Set up locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

# Set time zone
ln -sf /usr/share/zoneinfo/Europe/Helsinki /etc/localtime

# Set hardware clock
hwclock --systohc --utc

# Set hostname
echo "arindam-pc" > /etc/hostname

# Enable dhcpcd service
systemctl enable dhcpcd

# Set root password
passwd

# Create a user
useradd -m -G wheel -s /bin/bash atoof
passwd atoof

# Install and configure GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Exit chroot and unmount partitions
exit
umount -R /mnt

# Reboot
reboot
