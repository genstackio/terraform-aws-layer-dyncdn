variable "name" {
  type    = string
  default = "dyncdn"
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
    event_type = string
    code = string
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