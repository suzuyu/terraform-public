# VPN 向け Cloud Router の構築
## private/restricted google のアドレス帯を広報する
resource "google_compute_router" "ha_vpn_router1" {
  name    = "ha-vpn-router1"
  network = google_compute_network.host_sharedvpc.name
  project = google_project.host_project.name
  region  = var.gcp_common.region

  bgp {
    asn               = var.vpn.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    dynamic "advertised_ip_ranges" {
      for_each = {
        privategoogle    = "199.36.153.8/30"
        restrictedgoogle = "199.36.153.4/30"
      }
      content {
        range = advertised_ip_ranges.value
      }
    }
  }
}

# HA VPN Gateway の作成
resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  region  = google_compute_router.ha_vpn_router1.region
  name    = "ha-vpn-1"
  network = google_compute_network.host_sharedvpc.name
  project = google_project.host_project.name
}

# 外部 VPN ゲートウェイの登録
resource "google_compute_external_vpn_gateway" "external_gateway" {
  name            = "external-gateway"
  project         = google_project.host_project.name
  redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
  description     = "An externally managed VPN gateway"
  interface {
    id         = 0
    ip_address = var.vpn.peer_global_ip_address
  }
}

# VPN Tunnel の作成
resource "google_compute_vpn_tunnel" "vpn_tunnel1" {
  name                            = "ha-vpn-tunnel1"
  project                         = google_project.host_project.name
  region                          = google_compute_router.ha_vpn_router1.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 0
  shared_secret                   = var.vpn.shared_secret
  router                          = google_compute_router.ha_vpn_router1.id
  vpn_gateway_interface           = 0
}

resource "google_compute_vpn_tunnel" "vpn_tunnel2" {
  name                            = "ha-vpn-tunnel2"
  project                         = google_project.host_project.name
  region                          = google_compute_router.ha_vpn_router1.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 0
  shared_secret                   = var.vpn.shared_secret
  router                          = google_compute_router.ha_vpn_router1.id
  vpn_gateway_interface           = 1
}

# Cloud Router Interface , BGP 作成1
resource "google_compute_router_interface" "vpn_router1_interface1" {
  name       = "router1-interface1"
  router     = google_compute_router.ha_vpn_router1.name
  project    = google_project.host_project.name
  region     = google_compute_router.ha_vpn_router1.region
  ip_range   = "169.254.0.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.vpn_tunnel1.name
}

resource "google_compute_router_peer" "vpn_router1_peer1" {
  name                      = "router1-peer1"
  router                    = google_compute_router.ha_vpn_router1.name
  project                   = google_project.host_project.name
  region                    = google_compute_router.ha_vpn_router1.region
  peer_ip_address           = "169.254.0.2"
  peer_asn                  = var.vpn.peer_asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.vpn_router1_interface1.name
}

# Cloud Router Interface , BGP 作成2
resource "google_compute_router_interface" "vpn_router1_interface2" {
  name       = "router1-interface2"
  router     = google_compute_router.ha_vpn_router1.name
  project    = google_project.host_project.name
  region     = google_compute_router.ha_vpn_router1.region
  ip_range   = "169.254.1.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.vpn_tunnel2.name
}

resource "google_compute_router_peer" "vpn_router1_peer2" {
  name                      = "router1-peer2"
  router                    = google_compute_router.ha_vpn_router1.name
  project                   = google_project.host_project.name
  region                    = google_compute_router.ha_vpn_router1.region
  peer_ip_address           = "169.254.1.2"
  peer_asn                  = var.vpn.peer_asn
  advertised_route_priority = 200
  interface                 = google_compute_router_interface.vpn_router1_interface2.name
}

output "EdgeRouter_VPN_Config" {
  value = join("\n", [
    "set vpn ipsec auto-firewall-nat-exclude enable",
    "set vpn ipsec esp-group gcp-esp compression disable",
    "set vpn ipsec esp-group gcp-esp lifetime 10800",
    "set vpn ipsec esp-group gcp-esp mode tunnel",
    "set vpn ipsec esp-group gcp-esp pfs enable",
    "set vpn ipsec esp-group gcp-esp proposal 1 encryption aes256",
    "set vpn ipsec esp-group gcp-esp proposal 1 hash sha1",
    "set vpn ipsec ike-group gcp-ike dead-peer-detection action restart",
    "set vpn ipsec ike-group gcp-ike dead-peer-detection interval 30",
    "set vpn ipsec ike-group gcp-ike dead-peer-detection timeout 120",
    "set vpn ipsec ike-group gcp-ike ikev2-reauth no",
    "set vpn ipsec ike-group gcp-ike key-exchange ikev2",
    "set vpn ipsec ike-group gcp-ike lifetime 36000",
    "set vpn ipsec ike-group gcp-ike proposal 1 dh-group 14",
    "set vpn ipsec ike-group gcp-ike proposal 1 encryption aes256",
    "set vpn ipsec ike-group gcp-ike proposal 1 hash sha1",
    "set interfaces vti vti0 address ${google_compute_router_peer.vpn_router1_peer1.peer_ip_address}/30",
    "set interfaces vti vti0 mtu '1332'",
    "set firewall options mss-clamp interface-type vti",
    "set firewall options mss-clamp mss 1292",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[0].ip_address} authentication id ${google_compute_external_vpn_gateway.external_gateway.interface[0].ip_address}",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[0].ip_address} authentication mode pre-shared-secret",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[0].ip_address} authentication pre-shared-secret ${google_compute_vpn_tunnel.vpn_tunnel1.shared_secret}",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[0].ip_address} connection-type initiate",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[0].ip_address} local-address ${var.vpn.peer_private_ip_address}",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[0].ip_address} ike-group gcp-ike",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[0].ip_address} ikev2-reauth inherit",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[0].ip_address} vti bind 'vti0'",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[0].ip_address} vti esp-group 'gcp-esp'",
    "set interfaces vti vti1 address ${google_compute_router_peer.vpn_router1_peer2.peer_ip_address}/30",
    "set interfaces vti vti1 mtu '1332'",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[1].ip_address} authentication id ${google_compute_external_vpn_gateway.external_gateway.interface[0].ip_address}",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[1].ip_address} authentication mode pre-shared-secret",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[1].ip_address} authentication pre-shared-secret ${google_compute_vpn_tunnel.vpn_tunnel2.shared_secret}",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[1].ip_address} connection-type initiate",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[1].ip_address} local-address ${var.vpn.peer_private_ip_address}",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[1].ip_address} ike-group gcp-ike",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[1].ip_address} ikev2-reauth inherit",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[1].ip_address} vti bind 'vti1'",
    "set vpn ipsec site-to-site peer ${google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[1].ip_address} vti esp-group 'gcp-esp'",
  ])
}


output "EdgeRouter_BGP_Config" {
  value = join("\n", [
    "set vpn ipsec auto-firewall-nat-exclude enable",
    "set policy prefix-list gcp-export rule 100 action permit",
    "set policy prefix-list gcp-export rule 100 prefix [GCPへ広報したいアドレス/サブネット]",
    "set policy prefix-list gcp-export rule 100 le 32",
    "set policy route-map TO-GCP-OUT-1 rule 1 action permit",
    "set policy route-map TO-GCP-OUT-1 rule 1 match ip address prefix-list gcp-export",
    "set policy route-map TO-GCP-OUT-1 rule 1 set metric 100",
    "set policy route-map TO-GCP-OUT-2 rule 1 action permit",
    "set policy route-map TO-GCP-OUT-2 rule 1 match ip address prefix-list gcp-export",
    "set policy route-map TO-GCP-OUT-2 rule 1 set metric 200",
    "set protocols bgp ${google_compute_router_peer.vpn_router1_peer1.peer_asn} network [GCPへ広報したいアドレス/サブネット]",
    "set protocols bgp ${google_compute_router_peer.vpn_router1_peer1.peer_asn} parameters graceful-restart stalepath-time 300",
    "set protocols bgp ${google_compute_router_peer.vpn_router1_peer1.peer_asn} parameters router-id [ルータのLoopbackアドレスなどID]",
    "set protocols bgp ${google_compute_router_peer.vpn_router1_peer1.peer_asn} neighbor ${split("/", google_compute_router_interface.vpn_router1_interface1.ip_range)[0]} capability graceful-restart",
    "set protocols bgp ${google_compute_router_peer.vpn_router1_peer1.peer_asn} neighbor ${split("/", google_compute_router_interface.vpn_router1_interface1.ip_range)[0]} remote-as ${google_compute_router.ha_vpn_router1.bgp[0].asn}",
    "set protocols bgp ${google_compute_router_peer.vpn_router1_peer1.peer_asn} neighbor ${split("/", google_compute_router_interface.vpn_router1_interface1.ip_range)[0]} route-map export TO-GCP-OUT-1",
    "set protocols bgp ${google_compute_router_peer.vpn_router1_peer1.peer_asn} neighbor ${split("/", google_compute_router_interface.vpn_router1_interface1.ip_range)[0]} timers holdtime 60",
    "set protocols bgp ${google_compute_router_peer.vpn_router1_peer1.peer_asn} neighbor ${split("/", google_compute_router_interface.vpn_router1_interface1.ip_range)[0]} timers keepalive 20",
    "set protocols bgp ${google_compute_router_peer.vpn_router1_peer2.peer_asn} neighbor ${split("/", google_compute_router_interface.vpn_router1_interface2.ip_range)[0]} capability graceful-restart",
    "set protocols bgp ${google_compute_router_peer.vpn_router1_peer2.peer_asn} neighbor ${split("/", google_compute_router_interface.vpn_router1_interface2.ip_range)[0]} remote-as ${google_compute_router.ha_vpn_router1.bgp[0].asn}",
    "set protocols bgp ${google_compute_router_peer.vpn_router1_peer2.peer_asn} neighbor ${split("/", google_compute_router_interface.vpn_router1_interface2.ip_range)[0]} route-map export TO-GCP-OUT-2",
    "set protocols bgp ${google_compute_router_peer.vpn_router1_peer2.peer_asn} neighbor ${split("/", google_compute_router_interface.vpn_router1_interface2.ip_range)[0]} timers holdtime 60",
    "set protocols bgp ${google_compute_router_peer.vpn_router1_peer2.peer_asn} neighbor ${split("/", google_compute_router_interface.vpn_router1_interface2.ip_range)[0]} timers keepalive 20",
  ])
}
