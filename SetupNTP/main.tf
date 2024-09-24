resource "aws_instance" "ntp_server" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = var.subnet_id[0]
  vpc_security_group_ids = [var.security_group]

  tags = {
    Name = "NTP-Server"
  }
}

resource "aws_instance" "ntp_client" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = var.subnet_id[0]
  vpc_security_group_ids = [var.security_group]

  tags = {
    Name = "NTP-Client"
  }
}

resource "null_resource" "configure_ntp_server" {
  depends_on = [aws_instance.ntp_server]

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install ntp ntpstat sntp -y",
      "echo 'restrict ${aws_instance.ntp_client.private_ip} nomodify notrap noquery' | sudo tee -a /etc/ntpsec/ntp.conf",
      "sudo systemctl restart ntp"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu" # Change if needed
      private_key = file("~/.ssh/test.pem") # Path to your private key
      host        = aws_instance.ntp_server.public_ip # Use Public IP for connection
    }
  }
}

resource "null_resource" "configure_ntp_client" {
  depends_on = [aws_instance.ntp_client, null_resource.configure_ntp_server]

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install ntp ntpstat sntp ntpdate -y",
      "sleep 30", # Wait for server to be fully up and running
      "ntpdate -q ${aws_instance.ntp_server.private_ip}",
      "ntpdate -u ${aws_instance.ntp_server.private_ip}",
      "echo 'server ${aws_instance.ntp_server.private_ip} prefer iburst' | sudo tee -a /etc/ntpsec/ntp.conf",
      "sudo systemctl restart ntp"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu" # Change if needed
      private_key = file("~/.ssh/test.pem") # Path to your private key
      host        = aws_instance.ntp_client.public_ip # Use Public IP for connection
    }
  }
}

