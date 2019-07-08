provider "aws" {
  version = "~> 2.0"
  region = "eu-central-1"
}

resource "aws_vpc" "ANSIBLE-KURS-VPC-1" {
  cidr_block = "10.150.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
}

resource "aws_internet_gateway" "ANSIBLE-KURS-IGW-1" {
  vpc_id = "${aws_vpc.ANSIBLE-KURS-VPC-1.id}"
}

resource "aws_route_table" "ANSIBLE-KURS-ROUTETABLE-1" {
    vpc_id     = "${aws_vpc.ANSIBLE-KURS-VPC-1.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.ANSIBLE-KURS-IGW-1.id}"
    }
}

resource "aws_subnet" "ANSIBLE-KURS-SUBNET-1" {
    vpc_id                  = "${aws_vpc.ANSIBLE-KURS-VPC-1.id}"
    cidr_block              = "10.150.0.0/24"
    availability_zone       = "eu-central-1a"
    map_public_ip_on_launch = false
}

resource "aws_route_table_association" "ANSIBLE-KURS-ROUTETABLEASSOC-1" {
    route_table_id = "${aws_route_table.ANSIBLE-KURS-ROUTETABLE-1.id}"
    subnet_id = "${aws_subnet.ANSIBLE-KURS-SUBNET-1.id}"
}

resource "aws_security_group" "ANSIBLE-KURS-SG-1" {
    name        = "ANSIBLE-KURS-SG-1"
    description = "Created with Terraform"
    vpc_id      = "${aws_vpc.ANSIBLE-KURS-VPC-1.id}"
    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
    ingress {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        ipv6_cidr_blocks     = ["::/0"]
    }
}

resource "aws_key_pair" "ANSIBLE-KURS-KEYPAIR-1" {
  key_name   = "ANSIBLE-KURS-KEYPAIR-1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMofp3C6RyZCr1NJd4hwCxppdyA4X2Al8imVNbZch30OfcH+A9IY2n5UYiKYRhID58x4T7tzQug+47t+GSDFZot4rKzoBFebQ/PthwHyfKBD18g8PCPiX6fzpoMvl4gANMlUD1bq8lk3rb3CtXZyehQ5SKQw10GQgXyj0ADHTky0ErUl3RLrQDnD6Ku0TBVEOSbexCplwpJf2Bjrob8qj04RIykHNYoddJ1X8W9VlUG9KSnZo0CScLjk0zzxs8kebh0E0gWeZPBUVwW5n0GnynFvGO0ANZVAQzo6cTGPkbA+3VrhOsW3HayRwgKTaSGh0j+pY/QH696MqUlEG5qSpsY0b3b8Pe3+Ap/P9tRRn6kFIVQo7rdXicsLSLGHVqA0exdF9zrXo+95pzOhNmVHD8r+nY34VHGQzD8plSy4y87oZt+O3b9MDg+ovjcl4+bYtCnQE5+gJHZ2nuVBkJpNelDKI6eoOnMDYRiDtjTk03UZ8/0TE21oMfeLfOm/bLETFfS7D5jsSW3JoXyAquBF30b0N6aZ/BT/XT4laOF9fChWlKSVc7RZ3Eu8KpPbxh5/ZXeQURosA9ECt5zwbHieaIHJep7iawST064JBunLZxD2b5SdY6v8zUskt+jPJTDkVx2HdJrlroTIpU5CUqDyEKIM8bB3BpjEm2khGn4EPp7w== TEMP AWS ANSIBLE KURS"
}

resource "aws_instance" "ANSIBLE-KURS-EC2-BASTION" {
    count = 20
    ami                         = "ami-04cf43aca3e6f3de3"
    availability_zone           = "eu-central-1a"
    ebs_optimized               = false
    instance_type               = "m4.large"
    monitoring                  = false
    key_name                    = "${aws_key_pair.ANSIBLE-KURS-KEYPAIR-1.id}"
    subnet_id                   = "${aws_subnet.ANSIBLE-KURS-SUBNET-1.id}"
    vpc_security_group_ids      = ["${aws_security_group.ANSIBLE-KURS-SG-1.id}"]
    #associate_public_ip_address = false
    associate_public_ip_address = true
    #private_ip                  = "10.150.0.10"
    source_dest_check           = true

    root_block_device {
        volume_type           = "gp2"
        volume_size           = 8
        delete_on_termination = true
    }
}

#resource "aws_instance" "ANSIBLE-KURS-EC2-SERVER" {
#    count = 16
#    ami                         = "ami-04cf43aca3e6f3de3"
#    availability_zone           = "eu-central-1a"
#    ebs_optimized               = false
#    instance_type               = "m4.large"
#    monitoring                  = false
#    key_name                    = "${aws_key_pair.ANSIBLE-KURS-KEYPAIR-1.id}"
#    subnet_id                   = "${aws_subnet.ANSIBLE-KURS-SUBNET-1.id}"
#    vpc_security_group_ids      = ["${aws_security_group.ANSIBLE-KURS-SG-1.id}"]
#    associate_public_ip_address = false
#    source_dest_check           = true
#
#    root_block_device {
#        volume_type           = "gp2"
#        volume_size           = 8
#        delete_on_termination = true
#    }

#    provisioner "remote-exec" {
#      inline = ["sudo yum -y install ansible"]
#    
#      connection {
#        type        = "ssh"
#        host        = self.public_ip
#        user        = "centos"
#        private_key = "${file("aws-kurs")}"
#      }
#    }
#    provisioner "local-exec" {
#      command = "ansible-playbook -u centos -i '${self.public_ip},' --private-key aws-kurs provision.yml" 
#    }
#
#}

output "instance_ip_addr_public" {
  value       = ["${aws_instance.ANSIBLE-KURS-EC2-BASTION.*.public_dns}"]
  description = "Instance public IP"
}

#output "instance_ip_addr_private" {
#  value       = ["${aws_instance.ANSIBLE-KURS-EC2-SERVER.*.private_dns}"]
#  description = "Instance private IP"
#}
