terraform {
  required_providers {
    thousandeyes = {
      source = "william20111/thousandeyes"
      # source = "cgascoig/cgascoig/thousandeyes"   # this is a custom build of the william20111/thousandeyes provider with a bug fixed (see https://github.com/william20111/terraform-provider-thousandeyes/issues/59)
      # version = "0.6.0"
    }
  }
}

# ### ThousandEyes Agents ###
# locals {
#   combined_agents = distinct(flatten([for test in var.http_tests : test.agents ]))
# }
#
# data "thousandeyes_agent" "agents" {
#   for_each = toset(local.combined_agents)
#   agent_name  = each.key
# }

data "thousandeyes_agent" "agents" {
  for_each = toset(var.agent_list)
  agent_name  = each.key
}

resource "thousandeyes_http_server" "http_tests" {
  for_each = var.http_tests

  test_name = "HTTP - ${each.value.name}"
  interval = 60
  url = each.value.url

  content_regex = ".*"


  # # NOTE: Bug with API/Provider?  Need to save test in GUI to match settings
  # # Initial Setup
  # network_measurements = 0
  # mtu_measurements = 0
  # bandwidth_measurements = 0
  # bgp_measurements = 0
  # use_public_bgp = 0
  # # num_path_traces = 0

  # Updated Settings
  network_measurements = 1
  mtu_measurements = 1
  bandwidth_measurements = 0
  bgp_measurements = 1
  use_public_bgp = 1
  # num_path_traces = 0

  dynamic "agents" {
    for_each = toset(var.agent_list)
    content {
      agent_id = data.thousandeyes_agent.agents[agents.key].agent_id
    }
  }

}
