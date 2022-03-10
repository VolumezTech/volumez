output "placement_group_ids" {
    value       = aws_placement_group.env_pg.*.id
}