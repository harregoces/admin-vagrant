# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	# Every Vagrant virtual environment requires a box to build off of.
    config.vm.box = "bento/ubuntu-16.04"

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    config.vm.network "private_network", ip: "192.168.39.103"


	if Vagrant::Util::Platform.linux?
        config.vm.synced_folder   "./provision","/var/provision", create: true, :nfs => { :mount_options => ["dmode=777","fmode=666"] }
        config.vm.synced_folder   "../projecto/","/shared/development/backend/", create: true, :nfs => { :mount_options => ["dmode=777","fmode=666"] }
        config.vm.synced_folder   "../frontend/","/shared/development/frontend/", create: true, :nfs => { :mount_options => ["dmode=777","fmode=666"] }
	else
        config.vm.synced_folder   "./provision","/var/provision", create: true
        config.vm.synced_folder   "../projecto/","/shared/development/backend/", create: true, group: "www-data", owner: "www-data"
        config.vm.synced_folder   "../frontend/","/shared/development/frontend/", create: true, group: "www-data", owner: "www-data"

	end

    config.vm.provider "virtualbox" do |vb|

        vb.name = "myProject"
        vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
        vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
        vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate//opt", "1"]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
        vb.customize ["storagectl", :id, "--name", "SATA Controller", "--hostiocache", "on"]

    end

    config.vm.provision "fix-no-tty", type: "shell" do |s|
        s.privileged = false
        s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
    end

   config.vm.provision "shell" do |s|
        s.path = "provision/setup.sh"
   end

	# Disable automatic box update checking. If you disable this, then
	# boxes will only be checked for updates when the user runs
	# `vagrant box outdated`. This is not recommended.
	#config.vm.box_check_update = false

	# Create a forwarded port mapping which allows access to a specific port
	# within the machine from a port on the host machine. In the example belhow,
	# accessing "localhost:8080" will access port 80 on the guest machine.
	config.vm.network "forwarded_port", guest: 22, host: 2224
	config.vm.network "public_network", bridge: "en1: Wi-Fi (AirPort)"

	# Create a private network, which allows host-only access to the machine
	# using a specific IP.
	#config.vm.network "private_network", ip: "192.168.56.101", bridge: "en1: Wi-Fi (AirPort)"

	# Create a public network, which generally matched to bridged network.
	# Bridged networks make the machine appear as another physical device on
	# your network.
	#config.vm.network "public_network"

	# If true, then any SSH connections made will enable agent forwarding.
	# Default value: false
	#config.ssh.forward_agent = true

	# Share an additional folder to the guest VM. The first argument is
	# the path on the host to the actual folder. The second argument is
	# the path on the guest to mount the folder. And the optional third
	# argument is a set of non-required options.

	# Provider-specific configuration so you can fine-tune various
	# backing providers for Vagrant. These expose provider-specific options.
	# Example for VirtualBox:
	#config.vm.provider "virtualbox" do |vb|
	#	# Don't boot with headless mode
	#	vb.gui = false
	#	vb.name = "nginx"
#
#		# Use VBoxManage to customize the VM. For example to change memory:
#		vb.customize ["modifyvm", :id, "--memory", "1536"]
#		vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
#	end

	# View the documentation for the provider you're using for more
	# information on available options.

config.vm.provision :shell, path: "provision/angular.sh", run: 'always'
end
