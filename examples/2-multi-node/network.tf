resource "yandex_vpc_subnet" "foo" {
  zone           = "ru-central1-a"
  network_id     = var.network_id
  v4_cidr_blocks = ["10.1.0.0/24"]
}

resource "yandex_vpc_subnet" "bar" {
  zone           = "ru-central1-b"
  network_id     = var.network_id
  v4_cidr_blocks = ["10.2.0.0/24"]
}
