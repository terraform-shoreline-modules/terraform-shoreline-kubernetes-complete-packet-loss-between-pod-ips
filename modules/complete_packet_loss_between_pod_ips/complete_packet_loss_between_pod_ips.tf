resource "shoreline_notebook" "complete_packet_loss_between_pod_ips" {
  name       = "complete_packet_loss_between_pod_ips"
  data       = file("${path.module}/data/complete_packet_loss_between_pod_ips.json")
  depends_on = [shoreline_action.invoke_modify_policy_traffic,shoreline_action.invoke_restart_network_plugin]
}

resource "shoreline_file" "modify_policy_traffic" {
  name             = "modify_policy_traffic"
  input_file       = "${path.module}/data/modify_policy_traffic.sh"
  md5              = filemd5("${path.module}/data/modify_policy_traffic.sh")
  description      = "Modify the network policies if they are blocking the traffic"
  destination_path = "/tmp/modify_policy_traffic.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "restart_network_plugin" {
  name             = "restart_network_plugin"
  input_file       = "${path.module}/data/restart_network_plugin.sh"
  md5              = filemd5("${path.module}/data/restart_network_plugin.sh")
  description      = "Restart the kubernetes network plugins"
  destination_path = "/tmp/restart_network_plugin.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_modify_policy_traffic" {
  name        = "invoke_modify_policy_traffic"
  description = "Modify the network policies if they are blocking the traffic"
  command     = "`chmod +x /tmp/modify_policy_traffic.sh && /tmp/modify_policy_traffic.sh`"
  params      = ["NAMESPACE","POLICY_NAME"]
  file_deps   = ["modify_policy_traffic"]
  enabled     = true
  depends_on  = [shoreline_file.modify_policy_traffic]
}

resource "shoreline_action" "invoke_restart_network_plugin" {
  name        = "invoke_restart_network_plugin"
  description = "Restart the kubernetes network plugins"
  command     = "`chmod +x /tmp/restart_network_plugin.sh && /tmp/restart_network_plugin.sh`"
  params      = ["NETWORK_PLUGIN"]
  file_deps   = ["restart_network_plugin"]
  enabled     = true
  depends_on  = [shoreline_file.restart_network_plugin]
}

