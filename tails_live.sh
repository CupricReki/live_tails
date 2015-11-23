#!/bin/bash
# Skyler Ogden
# Cupricreki@gmail.com
# Description: This script is ran from a tails dist to appropriate the necessary tools for working within tails comforitably 
# 
#======CAUTION======
# This script should never exist anywhere permanently unencrypted


# Options:

# What needs to be done:
# 2. Add lastpass_cli function
# 3. Add VeraCrypt download
# 4. Add VeraCrypt decryption prompt of secrets (additional metadata generating activity scripts, ssh keys)
# 4. Create system for indicating if any cached packages are out of date and offer to download to cache
# 5. Option to overwrite cached downloads
# 6. Allow limited functionality if no root privelages are given
# 7. Allow to specify heirarch for install locations (internet only, repo priority, internet priority)
# 8. Remove user prompts in favor of script arguments
# 9. Sublime-text retrieval method to be none-specific to version


clear

# Programs to be installed:
# ----------------------------apt-get & aptitude------------------------------------------
# 1. Aptitude: Better package manager which gives us the option to actually download and cache deb files
# 2. gparted: Good for being able to modify partitions
# 3. guake: Great hotkey enabled terminal
install_programs=(aptitude gparted guake)

# ----------------------------Wget----------------------------------------------
# 1. Sublime-text 3: Great text editor with language recognition and auto-formatting

# Save working direcory - always use quotes when referencing in case of white space
cur_dir="$PWD"

# Pre-downloaded files location
download_cache="download_cache"; download_cache_dir="$cur_dir/$download_cache"

root_shell_test () { 
	# Test to make sure script was run as root user
	if [ "$EUID" -ne 0 ]; then
		echo "Please run $0 as root, now exitting"
		exit 1
	fi
}

fn_distro() {
	# Make sure the script is being run on the correct distro
	arch=$(uname -m)
	kernel=$(uname -r)
	if [ -f /etc/lsb-release ]; then
		os=$(lsb_release -s -d)
	elif [ -f /etc/debian_version ]; then
		os="Debian $(cat /etc/debian_version)"
	elif [ -f /etc/redhat-release ]; then
		os=`cat /etc/redhat-release`
	else
		os="$(uname -s) $(uname -r)"
	fi
}

downloaded_packages_check () { 
	# Testing to see which package(s) are pre-downloaded in the chosen directory
	cd "$download_cache_dir"
	downloaded_debs=(*.deb)
	echo "In the download cache: <$download_cache_dir>, the following program(s) were found:"
	for var in "${downloaded_debs[@]}"; do
		echo "${var}"
	done
	echo ""
}

user_conf () {
	# User configuration prompt 
	echo "Are you sure you would like to install the following software?:"
	echo ""
	for var in "${install_programs[@]}"; do
		echo "${var}"
	done
	echo ""
	read -p "[Yy/Nn]"
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		echo "---- exitting ----"
		exit 1
	fi
	downloaded_packages_check
	echo "Would you like to use cached[Cc] packages for install or install from repositories[Rr]?"
	echo ""
	read -p "[Cc/Rr]"
	if [[ $REPLY =~ ^[Cc]$ ]]; then
		echo ""
		echo "---- Using cached data ----"
		echo ""
		install_cache
	elif [[ $REPLY =~ ^[Rr]$ ]]; then
		install_internet
	fi
}

install_cache () {
	for var in "${downloaded_debs[@]}"; do
		dpkg -i "${var}"
	done
}

install_internet () {
	# Utilize the in
	internet_access_test
	#apt-get update	
	# Make sure we can actually add repositories 
	apt-get -y install software-properties-common python-software-properties

	# Add any necessary repositories (distro specific)
	install_repositories

	# Download i386 version of sublime text 3083 only if it doesn't already exist
	wget http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3083_i386.deb
	dpkg -i sublime-text_build-3083_i386.deb
	for var in "${install_programs[@]}"; do
		apt-get install -y "${var}"
	done

	# Start any background processes
	guake	# This should check the install_programs variable to make sure guake is installed
}

internet_access_test () { 
	# Queries google for connection confirmation --spider tag used to send a HEAD request instead of a GET request
	
	echo "---- Checking for internet connectivity using HEAD request to google.com ----"

	wget --tries=10 --timeout=20 --spider http://google.com 
	if [[ $? -ne 0 ]]; then
		echo "---- FATAL: No internet connection, exitting ----"
		exit 1
	fi
	echo "---- Internet connection verified ----"
	echo ""
}

install_repositories () {
	echo "---- repos would be added here ----"
	# Add repositories for further program installs (distro specific)
}

PIA_VPN_access () {
	# Download ubuntu install script from PIA repo
	echo "---- Installing Private Internet Access with openVPN ----"
	wget https://www.privateinternetaccess.com/installer/install_ubuntu.sh 
	sh ./install_ubuntu.sh
}

lastpass_CLI_install () {
	# Start with installing dependancies for lastpass_CLI
	apt-get -y install openssl libcurl3 libxml2 libssl-dev libxml2-dev libcurl4-openssl-dev pinentry-curses xclip

	# Install build-essentials to be able to execute the make command to build the lastpass_CLI package
	apt-get -y install build-essentials

	# Clone the lastpass cli repository - Needed for decrypting secrets
	git clone https://github.com/lastpass/lastpass-cli.git
}

install_exit () {
	# Completion information
	install_type=1
	if [[ "$install_type" = "1" ]]; then
		echo ""
		echo "Programs installed using apt-get/aptitude:"
		for var in "${install_programs[@]}"; do
			echo "${var}"
		done
	elif [[ "$install_type" = "2" ]]; then
		echo ""
		echo "Programs installed from download cache:"
		for var in "${downloaded_debs[@]}"; do
			echo "${var}"
		done
	fi
}

build_cache () {
	# Here the downloaded files will be moved to the download_cache directory for future safe keeping
	echo "---- cache would be built here ----"
}

#--------------Universal functions-----------------
containsElement () {
	# See if given argument exists in given array
	local e
	for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
	return 1
}
echo "This has been changed since the file was sourced"

root_shell_test
user_conf
install_exit

exit
