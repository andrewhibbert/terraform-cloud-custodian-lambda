variable "policy_name" {
  description = "Name of the policy, made unique per test run so concurrent runs do not collide"
  type        = string
}

variable "mode_type" {
  description = "Cloud Custodian mode to deploy the policy in"
  type        = string

  validation {
    condition     = contains(["periodic", "cloudtrail"], var.mode_type)
    error_message = "mode_type must be either periodic or cloudtrail."
  }
}
