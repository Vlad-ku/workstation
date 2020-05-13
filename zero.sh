# под root
pacman -S --noconfirm reflector glibc
reflector -l 200 -p https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy --noconfirm archlinux-keyring && pacman -Syyu --noconfirm
pacman -Syu --noconfirm
pacman -S --noconfirm sudo

useradd -m user
# пользователь с sudo фактически root
echo "user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/user
echo "user:helloworld" | chpasswd
