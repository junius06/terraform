# route.tf 변수에 Peering 정보 저장 용도
# US - requester 기준
output "target_vpc_peer_exist_us" {
  value = [for value in [for value in aws_vpc_peering_connection.us_region_code : value.tags] : value.Name]
}

output "target_vpc_peer_info_us" {
  value = aws_vpc_peering_connection.us_region_code
}

# EU - requester 기준
output "target_vpc_peer_exist_eu" {
  value = [for value in [for value in aws_vpc_peering_connection.eu_region_code : value.tags] : value.Name]
}

output "target_vpc_peer_info_eu" {
  value = aws_vpc_peering_connection.eu_region_code
}