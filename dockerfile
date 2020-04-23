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
# RUN ssh-keygen -N '' -f /etc/ssh/ssh_host_rsa_key
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
    tmux                    \
    thunar                  \
    ranger                  \
    w3m                     \
    termite                 \
    zip                     \
    unzip

RUN pacman -S --noconfirm   \
    i3lock                  \
    dmenu                   \
    i3blocks                \
    scrot                   \
    xclip                   \
    compton                 \
    nitrogen                \
    xbindkeys               \
    xdotool

RUN pacman -S --noconfirm   \
    iproute2
# --- BEGIN остальное ПО ---


# TODO не работает dmenu
# TODO поставить шрифты (для vim)
# TODO домашнюю папку в том

USER user
EXPOSE 22
EXPOSE 5901

ENV passv='vivaldi8'
ENV passr='vivaldi8'
ENV passu='vivaldi8'

ENTRYPOINT \
    cd ~                                                                                      && \
    echo '#!/usr/bin/expec'                                                > startvnc.sh      && \
    echo 'spawn /usr/sbin/vncserver'                                      >> startvnc.sh      && \
    echo 'expect "Password:"'                                             >> startvnc.sh      && \
    echo 'send   "$env(passv)\r"'                                         >> startvnc.sh      && \
    echo 'expect "Verify:"'                                               >> startvnc.sh      && \
    echo 'send   "$env(passv)\r"'                                         >> startvnc.sh      && \
    echo 'expect "Would you like to enter a view-only password (y/n)?"'   >> startvnc.sh      && \
    echo 'send   "n\r"'                                                   >> startvnc.sh      && \
    echo 'set timeout -1'                                                 >> startvnc.sh      && \
    echo 'expect eof'                                                     >> startvnc.sh      && \
    expect startvnc.sh                                                                        && \
    rm -rf startvnc.sh                                                                        && \
    vncserver -kill :1                                                                        && \
    echo '#!/bin/sh'                                                       > ~/.vnc/xstartup  && \
    echo 'exec i3'                                                        >> ~/.vnc/xstartup  && \
    echo "root:$passr" | sudo chpasswd                                                        && \
    echo "user:$passu" | sudo chpasswd                                                        && \
    vncserver                                                                                 && \
    sudo /usr/sbin/sshd                                                                       && \
    bash
