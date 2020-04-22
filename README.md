# Docker рабочая станция на archlinux

![docker-badge](http://dockeri.co/image/vladv8/workstation)

## Запуск

	docker run --rm -it \
        -e passv='password VNC' \
        -e passr='password SSH root' \
        -e passu='password SSH user' \
        -p 5901:5901 \
        -p 23:22 \
        vladv8/workstation

