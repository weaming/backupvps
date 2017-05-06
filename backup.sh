#!/bin/bash

src=$HOME/src
dir=$src/backupvps
extract_dir=$dir/tmp

[ -d $src ] || mkdir -p $src
[ -d $dir ] || git clone https://github.com/weaming/backupvps $dir

# backup
if [[ $1 == '' ]]; then
	[ -d $extract_dir ] || mkdir -p $extract_dir

	# etc
	[ -d $extract_dir/etc ] || mkdir $extract_dir/etc
	cp /etc/sysctl.conf $extract_dir/etc/sysctl.conf
	cp /etc/shadowsocks.json $extract_dir/etc/shadowsocks.json
	cp /etc/supervisord.conf $extract_dir/etc/supervisord.conf

	# nginx
	[ -d $extract_dir/nginx ] || mkdir -p $extract_dir/nginx &&
		cp /usr/local/nginx/nginx.conf $extract_dir/nginx/nginx.conf
	[ -d $extract_dir/nginx/sites-enabled ] || cp -rf /usr/local/nginx/sites-enabled/ $extract_dir/nginx/sites-enabled

	# tar ball
	name="vps.backup.`date '+%Y-%m-%d_%H'`.tar.gz"
	cd $dir && tar zcf $name tmp && rm -rf $extract_dir && echo $name
	printf "\nYou need 'git push' by yourself\n"
fi


# recover. only for Ubuntu/Debian
if [[ $1 == 'install' ]]; then
	ngx_dir=~/Downloads/ngx

	# start from here
	sudo apt update && sudo apt upgrade
	sudo apt install vim git tree htop tmux -y

	# build basic
	sudo apt install gcc g++ build-essential -y

	# optional: only for vim
	sudo apt install vim-gtk exuberant-ctags -y

	# for python2 dev
	sudo apt install python-dev python-pip -y
	sudo pip install -U pip
	sudo pip install setuptools
	sudo pip install requests supervisor flask tornado

	# for python3 dev
	sudo apt install python3-dev python3-pip -y
	sudo pip3 install -U pip
	sudo pip3 install setuptools

	# dotfiles
	[ -d $src ] || mkdir -p $src && cd $src &&
		[ -d dotfiles ]  || git clone https://github.com/weaming/dotfiles && cd dotfiles
	bash install.sh product && bash install.sh fix
	bash ./shadowsocks/install-kcptun.sh

	# nginx install
	[ -d $ngx_dir ] || mkdir -p $ngx_dir && cd $ngx_dir &&
		curl -sSL https://raw.githubusercontent.com/weaming/dotfiles/master/scripts/shell/install_nginx.sh | bash

	# update kernel to 4.10
	kernel_name='linux-image-4.10.0-041000-generic_4.10.0-041000.201702191831_amd64.deb'
	kernel_link="http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.10/$kernel_name"
	cd ~/Downloads && [ -f $kernel_name ] || wget $kernel_link
	dpkg -i $kernel_name
	dpkg -l | grep linux-image
	#apt-get purge 旧内核
	#更新 grub 系统引导文件
	update-grub
fi

# extracte configuration files
if [[ $1 == 'restore' ]];then
	[[ $2 == '' ]] && echo '... restore *backup.tar.gz' && exit 1
	[ -f $2 ] || exit 1

	# clean exists tmp
	[ -d $extract_dir ] && rm -rf $extract_dir

	tar xf $2 &&
		cp -r $extract_dir/etc/* /etc/
	if [ -d /usr/local/nginx ]; then
		cp -r $extract_dir/nginx/* /usr/local/nginx/
	else
		echo 'nginx not installed yet!'
		exit 2
	fi

	# clean tmp
	[ -d $extract_dir ] && rm -rf $extract_dir
fi
