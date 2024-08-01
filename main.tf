# Create Resource For Connect Via SSH Keys
resource "digitalocean_ssh_key" "terraform" {
  name       = "k3s-ssh-key-pub"
  public_key = file(var.LOCATION_SSH_PUBLIC_KEY)
}

resource "digitalocean_droplet" "web" {
  # Resource Connection
  image    = "ubuntu-20-04-x64"
  name     = "k3s-tf-do-${count.index}"
  region   = "SGP1"
  size     = "s-2vcpu-2gb"
  count    = var.VM_COUNT
  ssh_keys = [digitalocean_ssh_key.terraform.fingerprint]

  # Create Connection
  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.LOCATION_SSH_PRIVATE_KEY)
    timeout     = "5m"
  }

  # RCE (Remote Command Execution)
  provisioner "remote-exec" {
    inline = [
      "apt update -y",
      "apt install apt-transport-https ca-certificates curl software-properties-common -y",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'",
      "apt-cache policy docker-ce",
      "apt install docker-ce -y",
      "systemctl enable docker",
      "systemctl start docker",
      "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server'  --docker sh -s - --flannel-backend wireguard-native",
      "systemctl enable k3s",
    "systemctl start k3s", ]
  }
}

output "show_ip_address" {
  value = {
    for idx, droplet in digitalocean_droplet.web :
    idx => droplet.ipv4_address
  }
  description = "IP Public V4 Droplet DigitalOcean"
}

