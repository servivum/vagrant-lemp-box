# Use one of the following values to use the right LEMP configuration for your app:
# Blank: "blank"
# Laravel (5.2): "laravel"
# Magento (1.9.1): "magento"
# Symfony (2.8): "symfony"
# TYPO3 (7.6): "typo3"
# WordPress (4.3): "wordpress"
app = "blank"

# Define subfolder within your project for using as webserver root. Show manual of your application for more details.
docroot = "public"

Vagrant.configure(2) do |config|
    # See Vagrant documentation for more information.
    config.vm.box = "debian/jessie64"
    config.vm.network "private_network", ip: "192.168.13.37"
    config.vm.hostname = "servivum.dev"

    if OS.windows?
        config.vm.synced_folder ".", "/vagrant", type: "smb"
    elsif OS.mac?
        config.vm.synced_folder ".", "/vagrant", type: "nfs"
    end

    # Fix "stdin: is not a tty" message
    config.vm.provision "fix-no-tty", type: "shell" do |s|
        s.privileged = false
        s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
    end

    # Installing and configuring LEMP stack and utilities
    config.vm.provision :shell, path: "vagrant/10_base.sh", args: [app, docroot]

    # Configuring the LEMP stack for selected application
    config.vm.provision :shell, path: "vagrant/20_laravel.sh", args: [app, docroot]
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

module OS
    def OS.windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def OS.mac?
        (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    def OS.unix?
        !OS.windows?
    end

    def OS.linux?
        OS.unix? and not OS.mac?
    end
end