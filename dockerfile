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
RUN ssh-keygen -N '' -f /etc/ssh/ssh_host_rsa_key
# --- END ставим X-ы, ssh и шрифты ---


# --- BEGIN ставим необходимое ПО ---
RUN pacman -S --noconfirm vim neovim
RUN pacman -S --noconfirm tigervnc
RUN pacman -S --noconfirm i3
# для ответов на вопросы при настройке VNC
RUN pacman -S --noconfirm expect
# --- END ставим необходимое ПО ---


# --- BEGIN настройка VNC ---
USER user
RUN \
    cd ~                                                                                        &&  \
    echo '#!/usr/bin/expec'                                                  > startvnc.sh      &&  \
    echo "spawn /usr/sbin/vncserver"                                        >> startvnc.sh      &&  \
    echo "expect \"Password:\""                                             >> startvnc.sh      &&  \
    echo "send   \"Pn2LpHJkfkBSBZa3ZBr76FoC4\r\""                           >> startvnc.sh      &&  \
    echo "expect \"Verify:\""                                               >> startvnc.sh      &&  \
    echo "send   \"Pn2LpHJkfkBSBZa3ZBr76FoC4\r\""                           >> startvnc.sh      &&  \
    echo "expect \"Would you like to enter a view-only password (y/n)?\""   >> startvnc.sh      &&  \
    echo "send   \"n\r\""                                                   >> startvnc.sh      &&  \
    echo "set timeout -1"                                                   >> startvnc.sh      &&  \
    echo "expect eof"                                                       >> startvnc.sh      &&  \
    expect startvnc.sh                                                                          &&  \
    vncserver -kill :1                                                                          &&  \
    echo '#!/bin/sh'                                                         > ~/.vnc/xstartup  &&  \
    echo "exec i3"                                                          >> ~/.vnc/xstartup
USER root
# --- END настройка VNC ---


# RUN \
    # mkdir -p ~/.vnc                   && \
    # echo "exec i3" > ~/.vnc/xstartup

# 1. настройка vncserver (что бы инициализировать папку, и перезаписать запускаемую оболочку)
# 2. настройка паролей (админ и рут) для ssh
# 3. настройка авто включения vnc (с настройкой пароля и ответа на вопросы)
#       https://habr.com/ru/post/498004/
# 4. vnc запуск endpoint-ом

# RUN pacman -S --noconfirm nodejs npm


# --- BEGIN назначаем всем пароли ---
# RUN echo "root:KYPafEy9UpnzZ3kW4PYu6vbdk" | chpasswd
# RUN echo "user:PMRpPJJ9CGtDKr4KefkxT9Hpi" | chpasswd
# --- END назначаем всем пароли ---

USER user
EXPOSE 22
EXPOSE 5901
