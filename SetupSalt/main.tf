resource "aws_instance" "master_salt" {
  ami           = var.ami_id
  instance_type = "t2.medium"
  key_name      = var.key_name
  subnet_id     = var.subnet_id[0]
  vpc_security_group_ids = [var.security_group]

  tags = {
    Name = "Master_Salt"
  }
}

resource "aws_instance" "minion_salt" {
  ami           = var.ami_id
  instance_type = "t2.medium"
  key_name      = var.key_name
  subnet_id     = var.subnet_id[0]
  vpc_security_group_ids = [var.security_group]

  tags = {
    Name = "Minion_Salt"
  }
}

resource "null_resource" "configure_master_salt" {
  depends_on = [aws_instance.master_salt]

  provisioner "remote-exec" {
    inline = [
      "sudo curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg] https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/latest jammy main' | sudo tee /etc/apt/sources.list.d/salt.list",
      "sudo apt update",
      "sudo apt install -y salt-master",
      "echo 'interface: ${aws_instance.master_salt.public_ip}' | sudo tee /etc/salt/master.d/master.conf",
      "sudo systemctl restart salt-master"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu" # Change if needed
      private_key = file("~/.ssh/test.pem") # Path to your private key
      host        = aws_instance.master_salt.private_ip # Use public IP for connection
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
      "echo 'master: ${aws_instance.minion_salt.private_ip}' | sudo tee /etc/salt/minion.d/master.conf",
      "sudo systemctl restart salt-minion"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu" # Change if needed
      private_key = file("~/.ssh/test.pem") # Path to your private key
      host        = aws_instance.minion_salt.public_ip # Use private IP for connection
    }
  }
}

