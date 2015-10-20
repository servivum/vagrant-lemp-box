# Use one of the following values to use the right LEMP configuration for your app:
# Blank: "blank"
# Magento (1.9.1): "magento"
# Symfony (2.7): "symfony"
# TYPO3 (6.2): "typo3"
# WordPress (4.3): "wordpress"
app = "blank"

# Define subfolder within your project for using as webserver root. Show manual of your application for more details.
docroot = "public"

Vagrant.configure(2) do |config|
  config.vm.box = "debian/jessie64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 80, host: 8080
  # Use this line instead, if you want to use the standard HTTP port, but
  # be sure that this port is not taken by another application, e. g. Skype.
  # config.vm.network "forwarded_port", guest: 80, host: 80

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.

  config.vm.network "private_network", ip: "192.168.13.37"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Set domain name for host machine
  config.vm.hostname = "servivum.dev"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL

  # Fix "stdin: is not a tty" message
  config.vm.provision "fix-no-tty", type: "shell" do |s|
      s.privileged = false
      s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  # Installing and configuring LEMP stack and utilities
  config.vm.provision :shell, path: "vagrant/10_base.sh", args: [app, docroot]

  # Configuring the LEMP stack for selected application
  config.vm.provision :shell, path: "vagrant/20_magento.sh", args: [app, docroot]
  config.vm.provision :shell, path: "vagrant/20_symfony.sh", args: [app, docroot]
  config.vm.provision :shell, path: "vagrant/20_typo3.sh", args: [app, docroot]
  config.vm.provision :shell, path: "vagrant/20_wordpress.sh", args: [app, docroot]

  # Custom tasks from inline Shell commands
  config.vm.provision "shell", inline: <<-SHELL
      # Put your Shell commands here ...
      echo "Running inline custom tasks ..."
  SHELL

  # Custom tasks from external file. Recommended for many commands.
  config.vm.provision :shell, path: "vagrant/30_custom.sh", args: [app, docroot]

  # Restart relevant services on each boot up
  config.vm.provision "shell", inline: "service nginx restart", run: "always"
  config.vm.provision "shell", inline: "service php5-fpm restart", run: "always"
  config.vm.provision "shell", inline: "service mysql restart", run: "always"

  # Show IP address and hostname
  config.vm.provision "shell", inline: "
  echo \" \"
  echo \"--- PUT THIS LINE IN YOUR HOST FILE ---\"
  echo \" \"
  echo `/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'` `hostname -f`
  echo \" \"
  echo \"---------------------------------------\"
  echo \" \"
  ", run: "always"

  # Introduction message
  config.vm.post_up_message = "Servivum look-alike environment is up and running! See https://github.com/Servivum/vagrant-box of project for more details."
end
