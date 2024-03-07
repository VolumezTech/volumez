output "bastion_public_dns" {
  value       = join(",", aws_instance.bastion.*.public_dns)
  description = "List of dev public dns addr"
}
