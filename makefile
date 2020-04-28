hello:
	echo "hello world"

rm:
	docker image rm vladv8/workstation || echo "ok"

build: #rm
	docker build -t vladv8/workstation .

run:
	docker run --rm -it -p 5901:5901 -p 23:22 --security-opt seccomp=unconfined vladv8/workstation

stop:
	docker stop $(docker ps | grep vladv8/workstation | awk '{ print $1 }')
