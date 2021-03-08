resource "aws_vpc_peering_connection" "peering_connection" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.other_vpc_id
  vpc_id        = var.own_vpc_id
  peer_region   = var.peer_region
  auto_accept   = var.auto_accept


  accepter {
      allow_remote_vpc_dns_resolution = var.allow_accepter_dns
  }

  requester {
      allow_remote_vpc_dns_resolution = var.allow_requester_dns
  }

  tags = {
      Name = var.name
  }
}