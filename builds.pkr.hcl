source "qemu" "centos8" {
  iso_url              = "https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-20220913.0.x86_64.qcow2"
  iso_checksum         = "file:https://cloud.centos.org/centos/8-stream/x86_64/images/CHECKSUM"
  disk_image           = true
  output_directory     = "output_centos_8"
  disk_size            = "10G"
  memory               = 2048
  format               = "qcow2"
  accelerator          = "kvm"
  ssh_username         = "centos"
  ssh_private_key_file = "${path.root}/ssh_key"
  ssh_timeout          = "20m"
  vm_name              = "centos8"
  net_device           = "virtio-net"
  disk_interface       = "virtio"
  boot_wait            = "10s"
  cd_files             = [
    "./cloud-init/meta-data",
    "./cloud-init/vendor-data",
  ]
  cd_content           = {
    "user-data" = templatefile("${path.root}/cloud-init/user-data.pkrtpl.hcl", { ssh_pubkey = file("${path.root}/ssh_key.pub") })
  }
  cd_label             = "cidata"
}

build {
  sources = ["source.qemu.centos8"]

  provisioner "shell" {
    inline = [
      "sudo yum -y install https://yum.puppet.com/puppet-release-el-$(rpm -E '%rhel').noarch.rpm",
      "sudo yum -y install puppet-bolt puppet-agent",
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo touch /.unconfigured",
      "sudo yum clean all",
      "sudo rm -f /etc/udev/rules.d/* /var/lib/NetworkManager/* /etc/ssh/ssh_host_* /etc/sysconfig/network-scripts/ifcfg-e*",
      "sudo truncate -s 0 /etc/machine-id ~/.ssh/authorized_keys /root/.ssh/authorized_keys",
      "sudo find /var/log -type f -exec truncate -s 0 {} \\;",
    ]
  }
}
