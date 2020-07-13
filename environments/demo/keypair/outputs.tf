output "demmo_key_pair_key_name" {
  description = "The key pair name."
  value       = module.demo_key_pair.generic_key_pair_key_name
}

output "demmo_key_pair_fingerprint" {
  description = "The MD5 public key fingerprint as specified in section 4 of RFC 4716."
  value       = module.demo_key_pair.generic_key_pair_fingerprint
}
