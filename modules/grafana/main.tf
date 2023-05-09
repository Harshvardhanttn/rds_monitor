resource "aws_instance" "grafana" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = "t2.medium"
  vpc_security_group_ids = ["${aws_security_group.graf_sg.id}"]
  
  tags = {
    Name = "grafana"
  }
     user_data = file("./modules/grafana/script.sh")
    #user_data = <<-EOF
                  #!/bin/bash
     #             /home/ttn/Desktop/Monitor/modules/script.sh
      #            EOF
}