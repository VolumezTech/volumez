# Matrix cluster network: dual-VPC / dual-NIC layout.
#
# - Management VPC (default 10.0.0.0/16): eth0, public IPs, internet access, SSH.
# - Service VPC (default 192.168.0.0/16): eth1, private, carries all cluster
#   node-to-node traffic (DAOS, Pacemaker VIPs). No routes out.
#
# Each VPC is self-contained — no peering/cross-VPC routing is needed because
# every node has an interface in both.

# Management VPC
resource "aws_vpc" "mgmt" {
  cidr_block           = var.mgmt_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "${var.resources_name_prefix}-mgmt-vpc"
    Terraform = "true"
    Network   = "management"
  }
}

# Service network VPC (cluster interconnect)
resource "aws_vpc" "service" {
  cidr_block           = var.service_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "${var.resources_name_prefix}-service-vpc"
    Terraform = "true"
    Network   = "service"
  }
}

resource "aws_internet_gateway" "mgmt" {
  vpc_id = aws_vpc.mgmt.id

  tags = {
    Name      = "${var.resources_name_prefix}-igw"
    Terraform = "true"
  }
}

# If the AWS account enforces VPC Block Public Access, this exclusion lets the
# management VPC keep public IPs. Harmless when BPA is not configured; set
# create_bpa_exclusion = false to skip it entirely.
resource "aws_vpc_block_public_access_exclusion" "mgmt" {
  count = var.create_bpa_exclusion ? 1 : 0

  vpc_id                          = aws_vpc.mgmt.id
  internet_gateway_exclusion_mode = "allow-bidirectional"

  tags = {
    Name      = "${var.resources_name_prefix}-bpa-exclusion"
    Terraform = "true"
  }
}

# Management subnet — nodes' eth0
resource "aws_subnet" "mgmt" {
  vpc_id                  = aws_vpc.mgmt.id
  cidr_block              = var.mgmt_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.assign_public_ips

  tags = {
    Name      = "${var.resources_name_prefix}-mgmt-subnet"
    Terraform = "true"
  }
}

resource "aws_route_table" "mgmt_public" {
  vpc_id = aws_vpc.mgmt.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mgmt.id
  }

  tags = {
    Name      = "${var.resources_name_prefix}-mgmt-rt"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "mgmt" {
  subnet_id      = aws_subnet.mgmt.id
  route_table_id = aws_route_table.mgmt_public.id
}

# Service subnet — nodes' eth1 (static cluster IPs live here)
resource "aws_subnet" "service" {
  vpc_id                  = aws_vpc.service.id
  cidr_block              = var.service_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name      = "${var.resources_name_prefix}-service-subnet"
    Terraform = "true"
  }
}

# Local-only route table: the service network never routes outside its VPC
resource "aws_route_table" "service" {
  vpc_id = aws_vpc.service.id

  tags = {
    Name      = "${var.resources_name_prefix}-service-rt"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "service" {
  subnet_id      = aws_subnet.service.id
  route_table_id = aws_route_table.service.id
}

# Management SG: cluster-internal traffic is fully open (the cluster runs many
# services — DAOS, Pacemaker/Corosync, NFS/SMB/S3, monitoring — inside these
# two private CIDRs); external ingress is limited to allowed_ssh_cidrs.
resource "aws_security_group" "mgmt" {
  name        = "${var.resources_name_prefix}-mgmt-sg"
  description = "Matrix cluster management network"
  vpc_id      = aws_vpc.mgmt.id

  ingress {
    description = "All traffic within the management VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.mgmt_vpc_cidr]
  }

  ingress {
    description = "All traffic from the service network VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.service_vpc_cidr]
  }

  ingress {
    description = "Operator access (SSH and cluster UIs)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.resources_name_prefix}-mgmt-sg"
    Terraform = "true"
  }
}

# Service SG: node-to-node only (both VPC CIDRs), nothing external
resource "aws_security_group" "service" {
  name        = "${var.resources_name_prefix}-service-sg"
  description = "Matrix cluster service network"
  vpc_id      = aws_vpc.service.id

  ingress {
    description = "All traffic within the service network VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.service_vpc_cidr]
  }

  ingress {
    description = "All traffic from the management VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.mgmt_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.resources_name_prefix}-service-sg"
    Terraform = "true"
  }
}
