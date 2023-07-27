
/******************************************
	VPC 
 *****************************************/

module "usc1-trust-vpc-001" {
  source                  = "./modules/vpc"
  project_id              = var.project_id
  network_name            =  var.network_name
  auto_create_subnetworks = false
}

/******************************************
	subnet
 *****************************************/

module "usc1-trustsubnet-001" {
  source       = "./modules/subnet"
  project_id   = var.project_id
  network_name = module.usc1-trust-vpc-001.vpc.self_link

  subnets = [{

    subnet_name           = "${var.subnet_name1}"
    subnet_region         = "${var.region}"
    subnet_ip             = "${var.subnet_ip}"
    subnet_flow_logs      = "${var.subnet_flow_logs}"
    subnet_private_access = "${var.subnet_private_access}"
    
    
    }
  ]
  depends_on = [
    module.usc1-trust-vpc-001
  ]
}
