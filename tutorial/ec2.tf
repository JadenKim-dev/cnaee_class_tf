# AWS에서 AMI 데이터를 조회
data "aws_ami" "my_amazonlinux2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "myec2" {

  depends_on = [
    aws_internet_gateway.myigw
  ]

  ami                         = data.aws_ami.my_amazonlinux2.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.mysg.id}"]
  subnet_id                   = aws_subnet.mysubnet1.id

  user_data = <<-EOF2
              #!/bin/bash
              wget https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64
              mv busybox-x86_64 busybox
              chmod +x busybox
              echo "<h1>Web Server</h1>" > index.html
              nohup ./busybox httpd -f -p 80 &
              EOF2

  user_data_replace_on_change = true

  tags = {
    Name = "t101-myec2"
  }
}

output "myec2_public_ip" {
  value       = aws_instance.myec2.public_ip
  description = "The public IP of the Instance"
}
