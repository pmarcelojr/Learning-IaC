variable "image" {
  default     = "ami-033b95fb8079dc481"
  type        = string
  description = "valor da imagem"
}

variable "instance_type" {
  default = "t2.micro"
  type    = string
}

variable "password" {
  type = string
}
