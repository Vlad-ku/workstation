#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

if sys.version_info.major != 3:
    raise Exception('Необходим python3')

stat = {
    'update':   False,
    'yay':      False,
    'progs':    False,
    'homeconf': False,
    'nicevim':  False,
    'vnc':      False,
}

if len(sys.argv) == 2:                  # если режим запуска указан ...
    arg = sys.argv[1]                   # режим запуска
    if arg == 'all':                    # если режим полного скрипта ...
        for k in stat.keys():           # цикл по всем режимам ...
            stat[k] = True              # все активируем
    elif arg in stat.keys():            # если нужен какой то конкретный режим ...
        stat[arg] = True                # активируем только его
else:
    print('укажите режим запуска')

def myinstall_pac(x):
    return 'sudo pacman -S --noconfirm --needed '+x
def myinstall_yay(x):
    return 'yay -S --noconfirm --needed '+x

# ------------------------------------------------------------------

# --- BEGIN обновляемся ---
if stat['update']:
    os.system('sudo pacman -Syu --noconfirm')
    os.system(myinstall_pac('reflector'))
    os.system('sudo reflector -l 200 -p https --sort rate --save /etc/pacman.d/mirrorlist')
    os.system('sudo pacman -Syu --noconfirm')
    os.system(myinstall_pac('git'))
# --- END обновляемся ---

# --- BEGIN установка yay ---
if stat['yay']:
    os.system(myinstall_pac('base-devel')) # base-devel для fakeroot, который для makepkg
    os.system('cd ~ && git clone https://aur.archlinux.org/yay-git.git')
    os.system('cd ~/yay-git && makepkg -si --noconfirm')
    os.system('rm -rf ~/yay-git')
# --- END установка yay ---

# --- BEGIN основное ПО ---
if stat['progs']:
    progs_list = [
        # X-ы, шрифты и VNC
        ['xorg-server',         'pac'],
        ['ttf-dejavu',          'pac'],
        ['tigervnc expect',     'pac'],
        # топ
        ['vim neovim',          'pac'],
        ['htop',                'pac'],
        ['tmux',                'pac'],
        ['ranger',              'pac'],
        ['w3m',                 'pac'],
        ['thunar',              'pac'],
        ['termite',             'pac'],
        ['fzf',                 'pac'],
        ['cryfs',               'pac'],
        ['pass',                'pac'],
        # разработка
        ['nodejs npm',          'pac'],
        ['docker',              'pac'],
        ['docker-compose',      'pac'],
        # рабочий стол
        ['i3-gaps',             'pac'],
        ['dmenu',               'pac'],
        ['i3blocks',            'pac'],
        ['i3lock',              'pac'],
        # перехват клавиш / эмуляция клавиатуры / эмуляция мышки
        ['xdotool',             'pac'],
        ['xbindkeys',           'yay'],
        ['keynav',              'pac'],
        ['unclutter',           'pac'],
        # работа с архивами
        ['zip',                 'pac'],
        ['unzip',               'pac'],
        # создание скриншота / работа с буфером
        ['scrot',               'pac'],
        ['xclip',               'pac'],
        # звук
        #  ['alsa-utils',          'pac'],
        #  ['alsa-plugins',        'pac'],
        #  ['pulseaudio',          'pac'],
        #  ['pulseaudio-alsa',     'pac'],
        # 'плюшки'
        #  ['vlc',                 'pac'],
        #  ['xorg-xbacklight',     'pac'], # управление подсветкой
        #  ['nitrogen',            'pac'], # фон рабочего стола
        #  ['dosfstools',          'pac'], # mkfs форматирование fat
        #  ['ntfsprogs',           'pac'], # mkfs форматирование ntfs
        #  ['dunst',               'pac'], # уведомления на рабочий стол
        #  ['cronie',              'pac'], # cron
        # другое крупное ПО
        ['chromium',            'pac'],
    ]
    os.system(myinstall_pac( ' '.join([ x[0] for x in progs_list if x[1] == 'pac' ]) ))
    os.system(myinstall_yay( ' '.join([ x[0] for x in progs_list if x[1] == 'yay' ]) ))
# --- END основное ПО ---

# --- BEGIN настройка дот файлов ---
if stat['homeconf']:
    os.system('cd ~ && git clone https://github.com/vlad-ku/home-conf.git')
    os.system('mv ~/home-conf/.git ~/')
    os.system('rm -rf ~/home-conf')
    os.system('cd ~ && git reset --hard')
# --- END настройка дот файлов ---

# --- BEGIN иконочный шрифт NERDtree и powerline для vim / ссылки nvim / emoji шрифт ---
if stat['nicevim']:
    # шрифты
    os.system('mkdir -p ~/.local/share/fonts')
    os.system('cd ~/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf"')
    # ссылки
    os.system('mkdir ~/.vim')
    os.system('ln -s ~/.vim ~/.config/nvim')
    os.system('ln -s ~/.vimrc ~/.vim/init.vim')
    # emoji
    os.system(myinstall_pac('noto-fonts-emoji'))
# --- END иконочный шрифт NERDtree и powerline для vim / ссылки nvim / emoji шрифт ---

# --- BEGIN настройка VNC ---
if stat['vnc']:
    # VNC
    filehandle = open(os.path.expanduser('~/startvnc.sh'), 'w')
    filehandle.write('\n'.join([
        '#!/usr/bin/expec',
        'spawn /usr/sbin/vncserver',
        'expect "Password:"',
        'send   "vivaldi8\\r"',
        'expect "Verify:"',
        'send   "vivaldi8\\r"',
        'expect "Would you like to enter a view-only password (y/n)?"',
        'send   "n\\r"',
        'set timeout -1',
        'expect eof', ''
    ]))
    filehandle.close()
    os.system('expect ~/startvnc.sh')
    os.system('rm -rf ~/startvnc.sh')
    os.system('vncserver -kill :1')
    # i3 (при запуске VNC)
    filehandle = open(os.path.expanduser('~/.vnc/xstartup'), 'w')
    filehandle.write('\n'.join([
        '#!/bin/sh',
        'exec i3', ''
    ]))
    filehandle.close()
# --- END настройка VNC ---

# пароли
# echo "root:vivaldi8"    | sudo chpasswd
# echo "vagrant:vivaldi8" | sudo chpasswd
# запуск VNS (на работающей системе)
#  vncserver
