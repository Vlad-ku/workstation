# --- BEGIN обновляемся ---
sudo pacman -Syu --noconfirm
# sudo pacman -S --noconfirm reflector
sudo reflector -l 200 -p https --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm git
# --- END обновляемся ---


# --- BEGIN установка yay ---
# base-devel для fakeroot
sudo pacman -S --noconfirm base-devel
cd ~            && git clone https://aur.archlinux.org/yay-git.git
cd ~/yay-git    && makepkg -si --noconfirm
cd ~            && rm -rf yay-git
# --- END установка yay ---


# --- BEGIN остальное ПО ---
# X-ы, шрифты и VNC
sudo pacman -S --noconfirm  \
    xorg-server             \
    ttf-dejavu              \
    tigervnc expect
# топ
sudo pacman -S --noconfirm  \
    vim neovim              \
    htop                    \
    tmux                    \
    ranger                  \
    w3m                     \
    thunar                  \
    termite
# рабочий стол
sudo pacman -S --noconfirm  \
    i3                      \
    dmenu                   \
    i3blocks                \
    i3lock
# перехват клавиш / эмуляция клавиатуры
sudo pacman -S --noconfirm  \
    xdotool
yay -S --noconfirm          \
    xbindkeys
# работа с архивами
sudo pacman -S --noconfirm  \
    zip                     \
    unzip
# создание скриншота / работа с буфером
sudo pacman -S --noconfirm  \
    scrot                   \
    xclip
# другое крупное ПО
sudo pacman -S --noconfirm  \
    chromium
# --- END остальное ПО ---


# --- BEGIN настройка дот файлов ---
cd ~
git clone https://github.com/Vlad-ku/home-conf.git
mv ~/home-conf/.git ~/
rm -rf ~/home-conf
git reset --hard
# --- END настройка дот файлов ---


# --- BEGIN иконочный шрифт NERDtree и powerline для vim / ссылки nvim / emoji шрифт ---
# шрифты
mkdir -p ~/.local/share/fonts
cd       ~/.local/share/fonts
curl -fLo \
    "Droid Sans Mono for Powerline Nerd Font Complete.otf" \
    "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf"
# ссылки
mkdir ~/.vim
ln -s ~/.vim ~/.config/nvim
ln -s ~/.vimrc ~/.vim/init.vim
# emoji
sudo pacman -S --noconfirm noto-fonts-emoji
# --- END иконочный шрифт NERDtree и powerline для vim / ссылки nvim / emoji шрифт ---


# --- BEGIN настройка VNC и i3 ---
# VNC
cd ~
echo '#!/usr/bin/expec'                                                  > startvnc.sh
echo 'spawn /usr/sbin/vncserver'                                        >> startvnc.sh
echo 'expect "Password:"'                                               >> startvnc.sh
echo 'send   "vivaldi8\r"'                                              >> startvnc.sh
echo 'expect "Verify:"'                                                 >> startvnc.sh
echo 'send   "vivaldi8\r"'                                              >> startvnc.sh
echo 'expect "Would you like to enter a view-only password (y/n)?"'     >> startvnc.sh
echo 'send   "n\r"'                                                     >> startvnc.sh
echo 'set timeout -1'                                                   >> startvnc.sh
echo 'expect eof'                                                       >> startvnc.sh
expect startvnc.sh
rm -rf startvnc.sh
vncserver -kill :1
# i3
echo '#!/bin/sh'        > ~/.vnc/xstartup
echo 'exec i3'         >> ~/.vnc/xstartup
# --- END настройка VNC и i3 ---


# пароли
# echo "root:vivaldi8"    | sudo chpasswd
# echo "vagrant:vivaldi8" | sudo chpasswd

vncserver
