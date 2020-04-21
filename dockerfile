FROM archlinux

MAINTAINER vladv8

# обновляемся
RUN pacman -Sy --noconfirm archlinux-keyring && pacman -Syyu --noconfirm
RUN pacman -S  --noconfirm git

# --- BEGIN установка yay ---
# base-devel для fakeroot, makepkg без sudo не работает
RUN pacman -S --noconfirm base-devel sudo
# т.к. под root makepkg не работает
RUN useradd -m user
# пользователь с sudo фактически root
RUN echo "user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/user
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

# --- BEGIN ставим X-ы, ssh и шрифты ---
RUN pacman -S  --noconfirm xorg-xauth
RUN pacman -S  --noconfirm openssh inetutils
RUN pacman -S  --noconfirm ttf-dejavu
# генерируем ключ сервера для SSH
RUN ssh-keygen -N '' -f /etc/ssh/ssh_host_rsa_key
# --- END ставим X-ы, ssh и шрифты ---

# --- BEGIN ставим необходимое ПО ---
RUN pacman -S --noconfirm tigervnc
RUN pacman -S --noconfirm i3

RUN pacman -S --noconfirm vim neovim
RUN pacman -S --noconfirm nodejs npm
# --- END ставим необходимое ПО ---

# --- BEGIN настройка дот файлов ---
USER user
RUN \
    cd ~                                                && \
    git clone https://github.com/Vlad-ku/home-conf.git  && \
    mv ./home-conf/.git ./                              && \
    rm -rf home-conf                                    && \
    git reset --hard
# --- END настройка дот файлов ---

# RUN \
    # mkdir -p ~/.vnc                                     && \
    # echo "exec i3" > ~/.vnc/xstartup

# 1. настройка vncserver (что бы инициализировать папку, и перезаписать запускаемую оболочку)
# 2. настройка паролей (админ и рут) для ssh
# 3. настройка авто включения vnc (с настройкой пароля и ответа на вопросы)
#       https://habr.com/ru/post/498004/

EXPOSE 22
EXPOSE 5901
