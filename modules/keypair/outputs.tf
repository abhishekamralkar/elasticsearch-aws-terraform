output "generic_key_pair_key_name" {
  description = "Your Key Pair Name."
  value       = element(concat(aws_key_pair.generic.*.key_name, list("")), 0)
}

output "generic_key_pair_fingerprint" {
  description = "The MD5 public key fingerprint as specified in section 4 of RFC 4716."
  value       = element(concat(aws_key_pair.generic.*.fingerprint, list("")), 0)
}
