output "combined_agents" {
  value = try(module.thousandeyes[0].combined_agents, "")
}
