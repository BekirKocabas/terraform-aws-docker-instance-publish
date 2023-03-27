output "instance_public_ip" {
    value = aws_instance.tf_my_ec2.private_ip  
}

output "sec_gr_id" {
    value = aws_security_group.tf-sec-gr.id  
}

output "instance_id" {
    value = aws_instance.tf_my_ec2.*.id  
}