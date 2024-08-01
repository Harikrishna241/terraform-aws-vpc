###creating VPC for the expense project #######
resource "aws_vpc" "expense" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = var.enable_dns_hostnames


    tags = merge(
        var.common_tags,
        var.vpc_tags,
        {
            Name = local.resource_name
            #Name = "${var.project_name}-${var.environment}"
        }
    )
            
} 
###creating interet gate way and attaching it to VPC 
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.expense.id

    tags = merge(
        var.common_tags,
        var.igw_tags,
        {
           Name = local.resource_name
           #Name = "${var.project_name}-${var.environment}"
        }
    )
}



#####Creaation of Db subnet ######
resource "aws_subnet" "public" {
    count = length(var.public_cidr_blocks)
    vpc_id     = aws_vpc.expense.id
    cidr_block = var.public_cidr_blocks[count.index]
    map_public_ip_on_launch = true
    availability_zone = local.zone_names[count.index]

        tags = merge(
            var.common_tags,
            {
                Name = local.zone_names[count.index]
            }
        )
}

# #####Creaation of Backend subnet ######
resource "aws_subnet" "Backend" {
    count = length(var.private_backend_cidr_blocks)
    vpc_id     = aws_vpc.expense.id
    cidr_block = var.private_backend_cidr_blocks[count.index]
    availability_zone = local.zone_names[count.index]

        tags = merge(
            var.common_tags,
            {
                Name ="backend- ${local.zone_names[count.index]}"
            }
        )
}

# #####Creaation of frontend subnet ######
resource "aws_subnet" "db" {
    count = length(var.private_db_cidr_blocks)
    vpc_id     = aws_vpc.expense.id
    cidr_block = var.private_db_cidr_blocks[count.index]
    availability_zone = local.zone_names[count.index]

        tags = merge(
            var.common_tags,
            {
                Name ="db- ${local.zone_names[count.index]}"
            }
        )
}

resource "aws_eip" "expense" {
  
  domain   = "vpc"
}

resource "aws_nat_gateway" "expense" {
  allocation_id = aws_eip.expense.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

#####Creaation of route tables public ,Bckend and DB 

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.expense.id

  tags = {
    Name = "public"
  }
}




resource "aws_route_table" "backend" {
  vpc_id = aws_vpc.expense.id

  tags = {
    Name = "bckend"
  }
}


resource "aws_route_table" "db" {
  vpc_id = aws_vpc.expense.id

  tags = {
    Name = "db"
  }
}


resource "aws_route" "public" {
    route_table_id            = aws_route_table.public.id
    destination_cidr_block    = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  
}
resource "aws_route" "private" {
    route_table_id            = aws_route_table.backend.id
    destination_cidr_block    = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.expense.id
  
}

resource "aws_route" "db" {
    route_table_id            = aws_route_table.db.id
    destination_cidr_block    = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.expense.id
  
}
resource "aws_route_table_association" "public" {
    count = length(var.public_cidr_blocks)
    subnet_id      = element(aws_subnet.public[*].id,count.index)
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "backend" {
    count = length(var.private_backend_cidr_blocks)
    subnet_id = element(aws_subnet.Backend[*].id,count.index)
    route_table_id = aws_route_table.backend.id
}

resource "aws_route_table_association" "db" {
    count = length(var.private_db_cidr_blocks)
    subnet_id = element(aws_subnet.db[*].id,count.index)
    route_table_id = aws_route_table.db.id
}
