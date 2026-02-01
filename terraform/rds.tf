resource "aws_db_subnet_group" "this" {
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

resource "aws_db_instance" "strapi" {
    engine = "postgres"
    engine_version = "15"
    instance_class = "db.t3.micro"

    allocated_storage = 20
    db_name = var.db_name
    username = var.db_user
    password = var.db_password

    publicly_accessible = false
    skip_final_snapshot = true

    vpc_security_group_ids = [aws_security_group.db_sg.id]
    db_subnet_group_name = aws_db_subnet_group.this.name
}