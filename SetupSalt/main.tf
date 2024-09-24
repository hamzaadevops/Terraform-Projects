resource "aws_instance" "master_salt" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = var.subnet_id[0]
  vpc_security_group_ids = [var.security_group]

  tags = {
    Name = "NTP-Server"
  }
}

resource "aws_instance" "minion_salt" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = var.subnet_id[0]
  vpc_security_group_ids = [var.security_group]

  tags = {
    Name = "NTP-Client"
  }
}

resource "null_resource" "configure_master_salt" {
  depends_on = [aws_instance.master_salt]

  provisioner "remote-exec" {
    inline = [
      "sudo curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg",
      "echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/latest jammy main" | sudo tee /etc/apt/sources.list.d/salt.list",
      "sudo apt update",
      "sudo apt install salt-master -y",
      " ",
      " "
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu" # Change if needed
      private_key = file("~/.ssh/test.pem") # Path to your private key
      host        = aws_instance.master_salt.public_ip # Use private IP for connection
    }
  }
}

resource "null_resource" "configure_minion_salt" {
  depends_on = [aws_instance.minion_salt, null_resource.configure_master_salt]

  provisioner "remote-exec" {
    inline = [
      "sudo curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg",
      "echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/latest jammy main" | sudo tee /etc/apt/sources.list.d/salt.list",
      "sudo apt update",
      "sudo apt install salt-minion -y",
      " ",
      " "
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu" # Change if needed
      private_key = file("~/.ssh/test.pem") # Path to your private key
      host        = aws_instance.minion_salt.public_ip # Use private IP for connection
    }
  }
}

