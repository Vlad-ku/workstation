FROM archlinux

MAINTAINER vladv8


# --- BEGIN обновляемся ---
RUN pacman -Sy --noconfirm archlinux-keyring && pacman -Syyu --noconfirm
RUN pacman -S  --noconfirm git sudo
# --- END обновляемся ---


# --- BEGIN создаем пользователя ---
RUN useradd -m user
# пользователь с sudo фактически root
RUN echo "user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/user
# --- END создаем пользователя ---


# --- BEGIN установка yay ---
# base-devel для fakeroot
RUN pacman -S --noconfirm base-devel
# т.к. под root makepkg не работает (без sudo тоже не работает)
USER user
RUN \
    cd ~                                            && \
    git clone https://aur.archlinux.org/yay-git.git && \
    cd yay-git                                      && \
    makepkg -si --noconfirm                         && \
    cd ~                                            && \
    rm -rf yay-git
USER root
# --- END установка yay ---


# --- BEGIN настройка дот файлов ---
USER user
RUN \
    cd ~                                                && \
    git clone https://github.com/Vlad-ku/home-conf.git  && \
    mv ./home-conf/.git ./                              && \
    rm -rf home-conf                                    && \
    git reset --hard
USER root
# --- END настройка дот файлов ---


# --- BEGIN ставим X-ы, ssh и шрифты ---
RUN pacman -S --noconfirm xorg-xauth
RUN pacman -S --noconfirm openssh
RUN pacman -S --noconfirm ttf-dejavu
# генерируем ключ сервера для SSH
RUN ssh-keygen -t ecdsa -b 521 -N '' -f /etc/ssh/ssh_host_ecdsa_key
# --- END ставим X-ы, ssh и шрифты ---


# --- BEGIN ставим необходимое ПО ---
RUN pacman -S --noconfirm vim neovim
RUN pacman -S --noconfirm tigervnc
RUN pacman -S --noconfirm i3
# для ответов на вопросы при настройке VNC
RUN pacman -S --noconfirm expect
# --- END ставим необходимое ПО ---


# --- BEGIN остальное ПО ---
RUN pacman -S --noconfirm   \
    htop                    \
    tmux                    \
    ranger                  \
    w3m                     \
    thunar                  \
    termite
# рабочий стол
RUN pacman -S --noconfirm   \
    dmenu                   \
    i3blocks                \
    i3lock
# перехват клавиш / эмуляция клавиатуры
RUN pacman -S --noconfirm   \
    xbindkeys               \
    xdotool
# работа с архивами
RUN pacman -S --noconfirm   \
    zip                     \
    unzip
# создание скриншота / работа с буфером
RUN pacman -S --noconfirm   \
    scrot                   \
    xclip
# аналог net-tools
RUN pacman -S --noconfirm   \
    iproute2
# другое крупное ПО
RUN pacman -S --noconfirm   \
    chromium
# --- END остальное ПО ---


# --- BEGIN иконочный шрифт NERDtree и powerline для vim / ссылки nvim / emoji шрифт ---
USER user
RUN \
    mkdir -p ~/.local/share/fonts   && \
    cd ~/.local/share/fonts         && \
    curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf"
RUN \
    mkdir ~/.vim                    && \
    ln -s ~/.vim ~/.config/nvim     && \
    ln -s ~/.vimrc ~/.vim/init.vim
USER root
RUN pacman -S --noconfirm noto-fonts-emoji
# --- END иконочный шрифт NERDtree и powerline для vim / ссылки nvim / emoji шрифт ---


# --- BEGIN ставим систему инициализации ---
USER user
RUN yay -S --noconfirm sysvinit
USER root
# --- END ставим систему инициализации ---


# --- BEGIN настройка VNC, i3, и паролей ---
USER user
RUN \
    cd ~                                                                                    && \
    echo '#!/usr/bin/expec'                                                > startvnc.sh    && \
    echo 'spawn /usr/sbin/vncserver'                                      >> startvnc.sh    && \
    echo 'expect "Password:"'                                             >> startvnc.sh    && \
    echo 'send   "vivaldi8\r"'                                            >> startvnc.sh    && \
    echo 'expect "Verify:"'                                               >> startvnc.sh    && \
    echo 'send   "vivaldi8\r"'                                            >> startvnc.sh    && \
    echo 'expect "Would you like to enter a view-only password (y/n)?"'   >> startvnc.sh    && \
    echo 'send   "n\r"'                                                   >> startvnc.sh    && \
    echo 'set timeout -1'                                                 >> startvnc.sh    && \
    echo 'expect eof'                                                     >> startvnc.sh    && \
    expect startvnc.sh                                                                      && \
    rm -rf startvnc.sh                                                                      && \
    vncserver -kill :1                                                                      && \
    echo '#!/bin/sh'        > /home/user/.vnc/xstartup                                      && \
    echo 'exec i3'         >> /home/user/.vnc/xstartup                                      && \
    echo "root:vivaldi8" | sudo chpasswd                                                    && \
    echo "user:vivaldi8" | sudo chpasswd
USER root
# --- END настройка VNC, i3, и паролей ---


# --- BEGIN настраиваем службы ---
RUN \
    echo "ab:123:Once:su user -c vncserver"     >> /etc/inittab     && \
    echo "ac:123:Once:/usr/sbin/sshd -D"        >> /etc/inittab
# --- END настраиваем службы ---


# TODO не работает dmenu
# TODO домашнюю папку в том
# TODO тема для thunar и остального
# TODO прокинуть docker


# USER user
EXPOSE 22
EXPOSE 5901

ENTRYPOINT ["/usr/sbin/init", "1"]
