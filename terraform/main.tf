provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "etech" {
  cidr_block = "10.244.0.0/24"
  tags {
    Name = "etech"
  }
}

resource "aws_subnet" "etech_main" {
  vpc_id = "${aws_vpc.etech.id}"
  availability_zone = "ap-northeast-1a"
  cidr_block = "10.244.0.0/25"
  map_public_ip_on_launch = true
  tags {
    Name = "etech_main"
  }
}

resource "aws_subnet" "etech_backup" {
  vpc_id = "${aws_vpc.etech.id}"
  availability_zone = "ap-northeast-1c"
  cidr_block = "10.244.0.128/25"
  map_public_ip_on_launch = true
  tags {
    Name = "etech_backup"
  }
}

resource "aws_internet_gateway" "etech_gw" {
  vpc_id = "${aws_vpc.etech.id}"
  tags {
    Name = "etech_gw"
  }
}

resource "aws_network_acl" "etech_nacl" {
  vpc_id = "${aws_vpc.etech.id}"
  egress {
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    protocol = -1
    from_port = 0
    to_port = 0
  }
  ingress {
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    protocol = -1
    from_port = 0
    to_port = 0
  }
  tags {
    Name = "etech_nacl"
  }
}

resource "aws_route_table" "etech_r" {
  vpc_id = "${aws_vpc.etech.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.etech_gw.id}"
  }
  tags {
    Name = "etech_r"
  }
}

resource "aws_route_table_association" "etech_r_assoc_main" {
  subnet_id = "${aws_subnet.etech_main.id}"
  route_table_id = "${aws_route_table.etech_r.id}"
}

resource "aws_route_table_association" "etech_r_assoc_backup" {
  subnet_id = "${aws_subnet.etech_backup.id}"
  route_table_id = "${aws_route_table.etech_r.id}"
}

resource "aws_vpc_dhcp_options" "etech_dhcp_default" {
  domain_name_servers = ["10.244.0.2"]
  tags {
    Name = "etech_dhcp_default"
  }
}

resource "aws_vpc_dhcp_options_association" "etech_dhcp_assoc" {
  vpc_id = "${aws_vpc.etech.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.etech_dhcp_default.id}"
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.etech.id}"
  ingress {
    protocol = -1
    self = true
    from_port = 0
    to_port = 0
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "default"
  }
}

output "vpc_id" {
  value = "${aws_vpc.etech.id}"
}

output "main subnet" {
  value = "${aws_subnet.etech_main.id}"
}
output "backup subnet" {
  value = "${aws_subnet.etech_backup.id}"
}