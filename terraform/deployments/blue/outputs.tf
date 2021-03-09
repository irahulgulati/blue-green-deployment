output "final_endpoint" {
  value       = module.public_lb_1.lb.dns_name
  description = "Final endpoint to access the app servers"
}