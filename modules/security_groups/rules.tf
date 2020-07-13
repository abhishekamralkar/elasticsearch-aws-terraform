variable "rules" {
  description = "Map of known security group rules (define as 'name' = ['from port', 'to port', 'protocol', 'description'])"
  type        = map(list(any))

  # Protocols (tcp, udp, icmp, all - are allowed keywords) or numbers (from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml):
  # All = -1, IPV4-ICMP = 1, TCP = 6, UDP = 16, IPV6-ICMP = 58
  default = {
    # Elasticsearch
    elastic-rest-tcp = [9200, 9200, "tcp", "Elasticsearch REST interface"]
    elastic-java-tcp = [9300, 9300, "tcp", "Elasticsearch Java interface"]
    # SSH
    ssh-tcp = [22, 22, "tcp", "SSH"]
    # Open all ports & protocols
    all-all = [-1, -1, "-1", "All protocols"]
    # This is a fallback rule to pass to lookup() as default. It does not open anything, because it should never be used.
    _ = ["", "", ""]
  }
}
