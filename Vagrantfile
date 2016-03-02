Vagrant.configure(2) do |config|
  NAME="npm" # !!! CHANGE IT TO YOUR PROJECT NAME !!!
  DATABASE_NAME="npm" # !!! CHANGE IT TO DB NAME !!!
  DATABASE_USER="npm" # !!! CHANGE IT TO DB USER NAME !!!
  DATABASE_PASSWORD="npm" # !!! CHANGE IT TO DB USER PASSWORD!!!

  HOSTNAME=NAME+".loc"

  config.vm.hostname = HOSTNAME
  config.vm.network "private_network", type: "dhcp"

  # Hostnamager configuration
  config.hostmanager.enabled           = true
  config.hostmanager.manage_host       = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline   = false

  # Dinamic ip resolver for vagrant hostmanager plugin
  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
    begin
      buffer = '';
        vm.communicate.execute("/sbin/ifconfig") do |type, data|
        buffer += data if type == :stdout
      end

      ips = []
        ifconfigIPs = buffer.scan(/inet addr:(\d+\.\d+\.\d+\.\d+)/)
        ifconfigIPs[0..ifconfigIPs.size].each do |ip|
          ip = ip.first

          next if /^(10|127)\.\d+\.\d+\.\d+$/.match ip

          if Vagrant::Util::Platform.windows?
            next unless system "ping #{ip} -n 1 -w 100>nul 2>&1"
          else
            next unless system "ping -c1 -t1 #{ip} > /dev/null"
          end

          ips.push(ip) unless ips.include? ip
        end
        ips.first
      rescue StandardError => exc
        return
      end
  end

  # Avoid possible request "vagrant@127.0.0.1's password:" when "up" and "ssh"
  config.ssh.password = "vagrant"

  # Env
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Virtualbox provider
  config.vm.provider "virtualbox" do |v, override|
    override.vm.box = "ubuntu/trusty64"
    v.memory = 2048
    v.cpus = 2

    # Shared folders configuration
    if Vagrant::Util::Platform.windows?
      override.vm.synced_folder "www", "/www"
    else
      override.nfs.map_uid = Process.uid
      override.nfs.map_gid = Process.gid
      override.vm.synced_folder "www", "/www", type: "nfs", mount_options: ['rw', 'vers=3', 'tcp', 'fsc', 'async', 'nolock', 'noacl', 'nosuid']
    end

    # Setup vagrant base system
    override.vm.provision :shell, :path => "vagrant-virtualbox/enable-swap.sh"
    override.vm.provision :shell, :path => "vagrant-virtualbox/bootstrap.sh"

    # Install environment
    override.vm.provision :shell, :path => "install-1404.sh", :args => ["--www-root", "/www", "--www-user", "vagrant", "--www-group", "vagrant"]
  end

  # Docker provider
  config.vm.provider "docker" do |d, override|
    # d.image    = 'ubuntu:14.04'
    d.build_dir  = "vagrant-docker"
    d.privileged = true
    d.has_ssh    = true
    override.vm.synced_folder "www", "/www"
    override.nfs.functional = false
    override.ssh.port = 22

    # Install environment
    override.vm.provision :shell, :path => "install-1404.sh", :args => ["--www-root", "/www", "--www-user", "vagrant", "--www-group", "vagrant"]
  end
end
