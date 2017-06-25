resource "triton_firewall_rule" "etcd_docker" {
  rule = "FROM subnet 10.20.0.0/24 TO tag \"docker:label:com.docker.compose.service\" = \"etcd\" ALLOW tcp (PORT 2379 AND PORT 2380 AND PORT 4001)"
  enabled = true
}
