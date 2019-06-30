data "aws_subnet" "environment" {
  vpc_id = var.vpc_id
  id     = var.public_subnet_id
}

data "template_file" "master" {
  template = file("${path.module}/files/master.json.tpl")

  vars = {
    environment    = var.environment
    token          = var.token
    encryption_key = var.encryption_key
  }
}

resource "aws_instance" "server" {
  ami           = var.ami[var.region]
  instance_type = var.instance_type
  key_name      = var.key_name
  count         = var.servers
  subnet_id     = var.public_subnet_id

  vpc_security_group_ids = [
    aws_security_group.consul.id,
  ]

  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
  }

  tags = {
    Name = "${var.environment}-consul-server-${count.index}"
  }

  provisioner "file" {
    content     = data.template_file.master.rendered
    destination = "/tmp/master.json"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/systemd/system/consul.d",
      "sudo mv /tmp/master.json /etc/systemd/system/consul.d",
      "echo ${var.servers} > /tmp/consul-server-count",
      "echo ${aws_instance.server[0].private_dns} > /tmp/consul-server-addr",
      "echo ${aws_instance.server[0].private_ip} > /tmp/consul-server-ip",
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/files/install.sh",
      "${path.module}/files/service.sh",
      "${path.module}/files/ip_tables.sh",
    ]
  }
}

resource "aws_security_group" "consul" {
  name        = "${var.environment}-consul"
  description = "Consul internal traffic + maintenance."
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
  }

  // allow traffic for TCP 53 (DNS)
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // allow traffic for UDP 53 (DNS)
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // allow traffic for TCP 8300 (Server RPC)
  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.environment.cidr_block]
  }

  // allow traffic for TCP 8301 (Serf LAN)
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.environment.cidr_block]
  }

  // allow traffic for UDP 8301 (Serf LAN)
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = [data.aws_subnet.environment.cidr_block]
  }

  // allow traffic for TCP 8400 (Consul RPC)
  ingress {
    from_port   = 8400
    to_port     = 8400
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // allow traffic for TCP 8500 (Consul Web UI)
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-consul-sg"
  }
}

