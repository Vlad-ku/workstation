# --- BEGIN обновляемся ---
sudo pacman -Syu
sudo pacman -S --noconfirm git
# --- END обновляемся ---


# --- BEGIN установка yay ---
# base-devel для fakeroot
sudo pacman -S --noconfirm base-devel
cd ~            && git clone https://aur.archlinux.org/yay-git.git
cd ~/yay-git    && makepkg -si --noconfirm
cd ~            && rm -rf yay-git
# --- END установка yay ---


# --- BEGIN настройка дот файлов ---
cd ~
git clone https://github.com/Vlad-ku/home-conf.git
mv ~/home-conf/.git ~/
rm -rf ~/home-conf
git reset --hard
# --- END настройка дот файлов ---


# --- BEGIN ставим X-ы и шрифты ---
sudo pacman -S --noconfirm xorg-xauth
sudo pacman -S --noconfirm ttf-dejavu
# --- END ставим X-ы и шрифты ---


# --- BEGIN ставим необходимое ПО ---
sudo pacman -S --noconfirm vim neovim
sudo pacman -S --noconfirm tigervnc
sudo pacman -S --noconfirm i3
# для ответов на вопросы при настройке VNC
sudo pacman -S --noconfirm expect
# --- END ставим необходимое ПО ---


# --- BEGIN остальное ПО ---
sudo pacman -S --noconfirm  \
    htop                    \
    tmux                    \
    ranger                  \
    w3m                     \
    thunar                  \
    termite
# рабочий стол
sudo pacman -S --noconfirm  \
    dmenu                   \
    i3blocks                \
    i3lock
# перехват клавиш / эмуляция клавиатуры
sudo pacman -S --noconfirm  \
    xbindkeys               \
    xdotool
# работа с архивами
sudo pacman -S --noconfirm  \
    zip                     \
    unzip
# создание скриншота / работа с буфером
sudo pacman -S --noconfirm  \
    scrot                   \
    xclip
# аналог net-tools
sudo pacman -S --noconfirm  \
    iproute2
# другое крупное ПО
sudo pacman -S --noconfirm  \
    chromium
# --- END остальное ПО ---

exit 0

# --- BEGIN иконочный шрифт NERDtree и powerline для vim / ссылки nvim / emoji шрифт ---
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf"
mkdir ~/.vim
ln -s ~/.vim ~/.config/nvim
ln -s ~/.vimrc ~/.vim/init.vim
pacman -S --noconfirm noto-fonts-emoji
# --- END иконочный шрифт NERDtree и powerline для vim / ссылки nvim / emoji шрифт ---


# --- BEGIN настройка VNC, i3, и паролей ---
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
echo '#!/bin/sh'        > /home/user/.vnc/xstartup
echo 'exec i3'         >> /home/user/.vnc/xstartup
echo "root:vivaldi8" | sudo chpasswd
echo "user:vivaldi8" | sudo chpasswd
# --- END настройка VNC, i3, и паролей ---


# --- BEGIN настраиваем службы ---
echo "ab:123:Once:su user -c vncserver"     >> /etc/inittab
echo "ac:123:Once:/usr/sbin/sshd -D"        >> /etc/inittab
# --- END настраиваем службы ---


# TODO не работает dmenu
# TODO домашнюю папку в том
# TODO тема для thunar и остального
# TODO прокинуть docker
