variable "name" {
  type    = string
  default = "dyncdn"
}
variable "allowed_methods" {
  type    = list(string)
  default = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
}
variable "cached_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}
variable "cache_policy" {
  type    = string
  default = null
}
variable "origin_request_policy" {
  type    = string
  default = null
}
variable "response_headers_policy" {
  type    = string
  default = null
}
variable "compress" {
  type    = bool
  default = true
}
variable "geolocations" {
  type    = list(string)
  default = []
}
variable "dns" {
  type = string
}
variable "dns_zone" {
  type = string
}
variable "functions" {
  type = list(object({
    name = string
    event_type = optional(string)
    code = optional(string)
    arn = optional(string)
    kv_stores = optional(list(string))
  }))
}
variable "price_class" {
  type    = string
  default = "PriceClass_100"
}
variable "edge_lambdas" {
  type = list(object({
    event_type = string
    lambda_arn = string
    include_body = bool
  }))
  default = []
}
variable "edge_lambdas_variables" {
  type    = map(string)
  default = {}
}
variable "forwarded_headers" {
  type    = list(string)
  default = []
}
variable "fake_origin" {
  type = string
  default = "unknown-origin.com"
}
variable "web_acl" {
  type    = string
  default = null
}
