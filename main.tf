terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.34.1"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.21.0"
    }
    sops = {
      source = "carlpett/sops"
      version = "1.0.0"
    }
  }
}

# locals {
#   config_content = file("${path.module}/secrets.yaml")
#   config = yamldecode(local.config_content)
# }

provider "sops" {}

data "sops_file" "secrets" {
  source_file = "secrets.yaml"
}

provider "digitalocean" {
  # token = local.config.digitalocean_dev_board
  token = data.sops_file.secrets.data["digitalocean_dev_board"]
}

provider "cloudflare" {
  # email     = local.config.cloudflare_email
  # api_key   = local.config.cloudflare_api_key
  email     = data.sops_file.secrets.data["cloudflare_email"]
  api_key   = data.sops_file.secrets.data["cloudflare_api_key"]
}

# nyc1    New York 1     
# sgp1    Singapore 1    
# lon1    London 1       
# nyc3    New York 3     
# ams3    Amsterdam 3    
# fra1    Frankfurt 1    
# tor1    Toronto 1      
# sfo2    San Francisco 2
# blr1    Bangalore 1    
# sfo3    San Francisco 3
# syd1    Sydney 1    

# DigitalOcean Droplet
resource "digitalocean_droplet" "on-demand-droplet" {
  name   = "on-demand-droplet-terraform"
  region = "ams3"
  size   = "s-1vcpu-1gb"
  image  = "ubuntu-23-10-x64"
  ssh_keys = [41493313, 41493296, 41493279, 39465090, 39465076] # run `doctl compute ssh-key list` to get numbers
  graceful_shutdown = false
  backups = false
  # monitoring = true
}

# Cloudflare DNS record
resource "cloudflare_record" "on-demand-droplet-record" {
  # zone_id = local.config.cloudflare_zone_id  # You can find this in your Cloudflare dashboard
  zone_id = data.sops_file.secrets.data["cloudflare_zone_id"]
  name    = "droplet"
  value   = digitalocean_droplet.on-demand-droplet.ipv4_address
  type    = "A"
  proxied = false
  ttl     = 1  # You can adjust the TTL as needed
}
