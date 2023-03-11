variable yc_folder_id {
  type = string
}

variable yc_subnet_v4_cidr_blocks {
  type = list(string)
}

variable yc_zone {
  type = string
}

variable yc_certificate_ids {
  type = list(string)
}

variable db_user_name {
  type = string
}

variable db_user_password {
  type = string
}

variable record_txt {
  type = string
}

variable dns_zone {
  type = string
}

variable host {
  type = string
}

resource "yandex_compute_instance" "vm-1" {
  folder_id   = var.yc_folder_id
  name        = "my-vm-1"
  platform_id = "standard-v1"
  zone        = var.yc_zone
  resources {
    core_fraction = 5
    cores  = 2
    memory = 1
  }
  boot_disk {
    initialize_params {
      image_id = "fd8v0s6adqu3ui3rsuap" # ОС (Ubuntu, 22.04 LTS)
      size = 15
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "vm-2" {
  folder_id   = var.yc_folder_id
  name        = "my-vm-2"
  platform_id = "standard-v1"
  zone        = var.yc_zone
  resources {
    core_fraction = 5
    cores         = 2
    memory        = 1
  }
  boot_disk {
    initialize_params {
      image_id = "fd8v0s6adqu3ui3rsuap" # ОС (Ubuntu, 22.04 LTS)
      size = 15
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_alb_load_balancer" "balancer-1" {
  folder_id   = var.yc_folder_id
  name        = "my-load-balancer"
  network_id  = yandex_vpc_network.network-1.id

  allocation_policy {
    location {
      zone_id   = var.yc_zone
      subnet_id = yandex_vpc_subnet.subnet-1.id
    }
  }

  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 443 ]
    }
    tls {
      default_handler {
        http_handler {
          http_router_id = yandex_alb_http_router.router-1.id
        }
        certificate_ids = var.yc_certificate_ids
      }
    }
  }
}

resource "yandex_alb_http_router" "router-1" {
  folder_id = var.yc_folder_id
  name      = "my-http-router"
  labels = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "virtual-host-1" {
  name           = "my-virtual-host"
  authority      = [var.host]
  http_router_id = yandex_alb_http_router.router-1.id
  route {
    name = "my-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group-1.id
      }
    }
  }
}

resource "yandex_alb_backend_group" "backend-group-1" {
  folder_id = var.yc_folder_id
  name      = "my-backend-group"

  http_backend {
    name             = "test-http-backend"
    weight           = 1
    port             = 80
    target_group_ids = ["${yandex_alb_target_group.target-group-1.id}"]
  }
}

resource "yandex_alb_target_group" "target-group-1" {
  folder_id = var.yc_folder_id
  name      = "my-target-group"

  target {
    subnet_id  = "${yandex_vpc_subnet.subnet-1.id}"
    ip_address = "${yandex_compute_instance.vm-1.network_interface.0.ip_address}"
  }

  target {
    subnet_id  = "${yandex_vpc_subnet.subnet-1.id}"
    ip_address = "${yandex_compute_instance.vm-2.network_interface.0.ip_address}"
  }
}


resource "yandex_mdb_mysql_cluster" "db-1" {
  folder_id   = var.yc_folder_id
  name        = "my-mysql"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.network-1.id
  version     = "8.0"

  resources {
    resource_preset_id = "b2.nano"
    disk_type_id       = "network-ssd"
    disk_size          = 10
  }

  host {
    zone      = var.yc_zone
    subnet_id = yandex_vpc_subnet.subnet-1.id
  }
}

resource "yandex_mdb_mysql_user" "db-user-1" {
    cluster_id = yandex_mdb_mysql_cluster.db-1.id
    name       = var.db_user_name
    password   = var.db_user_password

    permission {
      database_name = yandex_mdb_mysql_database.db-1.name
      roles = ["ALL"]
    }
}

resource "yandex_mdb_mysql_database" "db-1" {
  cluster_id = yandex_mdb_mysql_cluster.db-1.id
  name       = "redmine"
}

resource "yandex_vpc_network" "network-1" {
  folder_id = var.yc_folder_id
  name      = "my-network"
}

resource "yandex_vpc_subnet" "subnet-1" {
  folder_id      = var.yc_folder_id
  name           = "my-subnet"
  zone           = var.yc_zone
  network_id     = "${yandex_vpc_network.network-1.id}"
  v4_cidr_blocks = var.yc_subnet_v4_cidr_blocks
}

resource "yandex_dns_zone" "zone-1" {
  folder_id   = var.yc_folder_id
  name        = "my-public-zone"
  description = "public zone"

  zone    = var.dns_zone
  public  = true
}

resource "yandex_dns_recordset" "rs-1" {
  zone_id = yandex_dns_zone.zone-1.id
  name    = var.dns_zone
  type    = "A"
  ttl     = 600
  data    = [yandex_alb_load_balancer.balancer-1.listener[0].endpoint[0].address[0].external_ipv4_address[0].address]
}

resource "yandex_dns_recordset" "rs-2" {
  zone_id = yandex_dns_zone.zone-1.id
  name    = var.dns_zone
  type    = "TXT"
  ttl     = 600
  data    = [var.record_txt]
}
