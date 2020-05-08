all:
	vagrant destroy -f && vagrant up && vagrant ssh
