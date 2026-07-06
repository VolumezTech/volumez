# Matrix cluster Active Directory Domain Controller (optional).
#
# Windows Server 2022, management network only (the DC reaches the cluster
# over the management VPC, so it carries no service NIC). WinRM (5985) and
# RDP (3389) are enabled via user-data, and the local Administrator password
# is set from var.admin_password.

data "aws_ami" "windows_server_2022" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
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

resource "aws_instance" "dc" {
  count = var.enabled ? 1 : 0

  ami                         = data.aws_ami.windows_server_2022.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.mgmt_subnet_id
  vpc_security_group_ids      = [var.mgmt_sg_id]
  associate_public_ip_address = var.assign_public_ip
  iam_instance_profile        = var.iam_instance_profile != "" ? var.iam_instance_profile : null

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_size           = var.root_volume_size_gb
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = base64encode(<<-EOF
    <powershell>
    # Enable WinRM for remote management
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force
    Enable-PSRemoting -Force -SkipNetworkProfileCheck
    Set-Service -Name WinRM -StartupType Automatic
    Start-Service -Name WinRM
    Remove-Item -Path WSMan:\Localhost\listener\* -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -Path WSMan:\LocalHost\Listener -Transport HTTP -Address * -Force
    Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true
    Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true
    Set-Item WSMan:\localhost\MaxTimeoutms -Value 1800000
    Set-Item WSMan:\localhost\Service\MaxMemoryPerShellMB -Value 1024
    New-NetFirewallRule -DisplayName 'WinRM HTTP' -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow -Enabled True -ErrorAction SilentlyContinue
    New-NetFirewallRule -DisplayName 'RDP' -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow -Enabled True -ErrorAction SilentlyContinue
    Restart-Service -Name WinRM -Force

    # Set and enable the local Administrator account
    $Password = ConvertTo-SecureString '${var.admin_password}' -AsPlainText -Force
    Set-LocalUser -Name 'Administrator' -Password $Password
    Enable-LocalUser -Name 'Administrator'
    </powershell>
    <persist>true</persist>
    EOF
  )

  tags = {
    Name      = var.hostname
    Terraform = "true"
  }

  lifecycle {
    precondition {
      condition     = var.admin_password != ""
      error_message = "admin_password must be set when the AD Domain Controller is enabled."
    }
  }
}
