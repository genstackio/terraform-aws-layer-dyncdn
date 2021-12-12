locals {
  functions = {for k, v in var.functions: lookup(v, "name", k) => v}
  edge_lambdas = {for i,l in var.edge_lambdas: "lambda-${i}" => l}
}