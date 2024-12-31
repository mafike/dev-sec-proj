resource "aws_instance" "nexus" {
  ami             = data.aws_ami.amzlinux2.id
  instance_type   = var.instance_type
  subnet_id       = element(data.terraform_remote_state.eks.outputs.public_subnets, 0)
  key_name        = aws_key_pair.generated.key_name
  security_groups = [aws_security_group.nexus_sonarqube_sg.id]

  user_data = <<-EOT
  #!/bin/bash
# Nexus Installation Script
# Compatible with RHEL 7 & 8
# Ensure the server has at least 4GB of RAM.

set -e

# 1. Add the 'nexus' user
echo "Creating 'nexus' user..."
sudo useradd -m -s /bin/bash nexus

# 2. Grant sudo access to the 'nexus' user
echo "Granting sudo access to 'nexus' user..."
echo "nexus ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nexus

# 3. Install prerequisites
echo "Installing prerequisites..."
sudo yum install -y wget git nano unzip java-11-openjdk-devel java-1.8.0-openjdk-devel

# 4. Download and extract Nexus
echo "Downloading and extracting Nexus..."
cd /opt
sudo wget -q http://download.sonatype.com/nexus/3/nexus-3.15.2-01-unix.tar.gz
sudo tar -xzf nexus-3.15.2-01-unix.tar.gz
sudo mv nexus-3.15.2-01 nexus
sudo rm -f nexus-3.15.2-01-unix.tar.gz

# 5. Set ownership and permissions
echo "Setting ownership and permissions..."
sudo chown -R nexus:nexus /opt/nexus
sudo mkdir -p /opt/sonatype-work
sudo chown -R nexus:nexus /opt/sonatype-work
sudo chmod -R 775 /opt/nexus /opt/sonatype-work

# 6. Configure Nexus to run as 'nexus' user
echo "Configuring Nexus to run as 'nexus' user..."
sudo sed -i 's/#run_as_user=/run_as_user="nexus"/g' /opt/nexus/bin/nexus.rc

# 7. Create systemd service for Nexus
echo "Creating Nexus systemd service..."
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOF
[Unit]
Description=Nexus Service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# 8. Enable and start Nexus service
echo "Enabling and starting Nexus service..."
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

# 9. Check Nexus service status
echo "Checking Nexus service status..."
sudo systemctl status nexus

echo "Nexus installation completed successfully!"
echo "Access Nexus at: http://<your-instance-ip>:8081"


  EOT

  tags = {
    Name = "Nexus Server"
  }
}


# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}