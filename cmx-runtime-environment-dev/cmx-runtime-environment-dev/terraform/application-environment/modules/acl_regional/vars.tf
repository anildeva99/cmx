variable "shared_resource_tags" {
  type = map
}

variable "waf_prefix" {
  default = "regional"
}

variable "blacklisted_ips" {
  default     = []
  type        = list
  description = "List of ips to be blocked by WAF"
}

variable "admin_remote_ipset" {
  default     = []
  type        = list
  description = "List of ip to be blocked as remote admin"
}

variable "environment" {
  type = string
}

variable "acl_constraint_body_size" {
  default     = 4096
  type        = number
  description = "Maximum number of bytes allowed in the body of the request. If you do not plan to allow large uploads, set it to the largest payload value that makes sense for your web application. Accepting unnecessarily large values can cause performance issues, if large payloads are used as an attack vector against your web application."
}

variable "acl_constraint_cookie_size" {
  default     = 4093
  type        = number
  description = "Maximum number of bytes allowed in the cookie header. The maximum size should be less than 4096, the size is determined by the amount of information your web application stores in cookies. If you only pass a session token via cookies, set the size to no larger than the serialized size of the session token and cookie metadata."
}

variable "acl_constraint_query_string_size" {
  default     = 1024
  type        = number
  description = "Maximum number of bytes allowed in the query string component of the HTTP request. Normally the  of query string parameters following the ? in a URL is much larger than the URI , but still bounded by the  of the parameters your web application uses and their values."
}

variable "acl_constraint_uri_size" {
  default     = 512
  type        = number
  description = "Maximum number of bytes allowed in the URI component of the HTTP request. Generally the maximum possible value is determined by the server operating system (maps to file system paths), the web server software, or other middleware components. Choose a value that accomodates the largest URI segment you use in practice in your web application."
}

variable "web_admin_url" {
  default     = "/admin"
  type        = string
  description = "The url that web admin request starts with"
}

variable "acl_constraint_match_auth_tokens" {
  type        = string
  description = "JSON Web Token signature portion which is  hijacked"
}

variable "acl_constraint_session_id" {
  default     = ""
  type        = string
  description = "Session id contained in cookie which is  hijacked"
}
