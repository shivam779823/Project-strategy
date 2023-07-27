

/******************************************
	VPC 
 *****************************************/

module "usc1-trust-vpc-001" {
  source                  = "../../modules/vpc"
  project_id              = var.project_id
  network_name            = "usc1-trust-vpc-0001"
  auto_create_subnetworks = false
}

/******************************************
	subnet
 *****************************************/

module "usc1-trustsubnet-001" {
  source       = "../../modules/subnet"
  project_id   = var.project_id
  network_name = module.usc1-trust-vpc-001.vpc.self_link

  subnets = [{
    subnet_name           = "usc1-trustsubnet-001"
    subnet_region         = "us-central1"
    subnet_ip             = "10.10.0.0/24"
    subnet_flow_logs      = "false"
    subnet_private_access = "true"
    }
  ]
  depends_on = [
    module.usc1-trust-vpc-001
  ]
}
