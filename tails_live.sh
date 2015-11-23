#!/bin/bash
# Skyler Ogden
# Cupricreki@gmail.com
# Description: This script is ran from a tails dist to appropriate the necessary tools for working within tails comforitably 
# Installed utilities: 
# 1. 
# Options:

# What needs to be done:
# 1. Finish download_packages_check
# 2. Add lastpass_cli function

clear
install_programs=(aptitude gparted guake)


# Save working direcory - always use quotes when referencing in case of white space
cur_dir="$PWD"

# Pre-downloaded files location
download_cache="download_cache"
download_cache_dir="$cur_dir/$download_cache"


root_shell ()
{ # Test to make sure script was run as root user
	if [ "$EUID" -ne 0 ]; then
		echo "Please run $0 as root, now exitting"
		exit 1
	fi
}

internet_access ()
{ # Queries google for connection confirmation --spider tag used to send a HEAD request instead of a GET request
	echo "Checking for internet connectivity using GET request to google.com"
	wget -v --tries=10 --timeout=20 --spider http://google.com 
	if [[ $? -ne 0 ]]; then
		echo "No internet connection, exitting"
		exit 1
	fi
	echo "Internet connection verified"
	echo ""
}

downloaded_packages_check ()
{ # Testing to see which packages are pre-downloaded in the chosen directory
	# if deb file exists then create an array to be printed out later
	# List .deb files in download cache
	cd "$download_cache_dir"
	downloaded_deb=(*.deb)
	echo "In the download cache: <$download_cache_dir>, the following programs were found"
		for var in "${downloaded_deb[@]}"; do
		echo "${var}"
	done
	echo ""
}

user_conf ()
{ 
	echo "Are you sure you would like to install the following software?:"
	echo ""
	for var in "${install_programs[@]}"; do
		echo "${var}"
	done
	echo ""
	read -p "[Yy/Nn]"
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		echo "exitting"
		exit 1
	fi

	echo "Would you like to use cached[Cc] packages for install or install from repositories[Rr]?"
	echo ""
	read -p "[Cc/Rr]"
	if [[ $REPLY =~ ^[Cc]$ ]]; then
		echo "using cached data"
		install_cache
	fi
}

install_cache ()
{
	for var in "${downloaded_deb[@]}"; do
		dpkg -i "${var}"
	done
}

install_internet ()
{
	# Aplications deemed 'basic' in their necessity
	# Boot repair utility
	# Sublime text - beautiful text editor
	# Aptitude - Better, more flexible package manager for debian
	
	# Make sure we can actually add repositories 
	apt-get -y install software-properties-common python-software-properties

	# Download i386 version of sublime text 3083 only if it doesn't already exist
	wget http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3083_i386.deb
	dpkg -i sublime-text_build-3083_i386.deb

	apt-get update
	for var in "${install_programs[@]}"; do
		apt-get install -y "${var}"
	done
}

PIA_VPN_access ()
{
	# Download ubuntu install script from PIA repo
	echo "installing Private Internet Access with openVPN"
	wget https://www.privateinternetaccess.com/installer/install_ubuntu.sh 
	sh ./install_ubuntu.sh
}

lastpass_CLI_install ()
{
	# Start with installing dependancies for lastpass_CLI
	apt-get -y install openssl libcurl3 libxml2 libssl-dev libxml2-dev libcurl4-openssl-dev pinentry-curses xclip

	# Install build-essentials to be able to execute the make command to build the lastpass_CLI package
	apt-get -y install build-essentials

	# Clone the lastpass cli repository - Needed for decrypting secrets
	git clone https://github.com/lastpass/lastpass-cli.git
}

install_basic ()
{
	post_install
	echo "The following programs have been installed:"
	echo ""
	for var in "${install_programs[@]}"; do
		echo "${var}"
	done
	echo ""

	# Start software 
	guake
}

root_shell
internet_access
downloaded_packages_check
user_conf
#install_internet


exit
