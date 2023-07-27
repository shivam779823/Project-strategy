
##########################################################
#  COE - MIG 2 Tier App With CloudSql                       
##########################################################

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

/******************************************
	Firewall
 *****************************************/

module "gbg-app-fw-001" {
  source               = "./modules/firewall"
  firewall_description = "Creates firewall rule targeting tagged instances"
  firewall_name        = "coe-app-fw-001"
  network              = module.usc1-trust-vpc-001.vpc.self_link
  project_id           = var.project_id
  target_tags          = []
  rules_allow = [
    {
      protocol = "TCP"
      ports    = ["80", "8080"]
    }
  ]

  source_ranges = ["0.0.0.0/0"]
  #source_tags   = ["testing1", "testing2"]

  depends_on = [
    module.usc1-trust-vpc-001
  ]
}

/******************************************
	Router and NAT
 *****************************************/

module "router-nat" {
  source   = "./modules/router-nat"
  name     = "coe-router-01"
  region   = var.region
  network  = module.usc1-trust-vpc-001.vpc.self_link
  nat_name = "coe-router-nat-01"

}

/******************************************
 Loadbalancer
 *****************************************/


module "internal-app-lb" {
  source                = "./modules/2tier-linux-Internal-app-lb"
  lb_name               = "coe-lb"
  ip_protocol           = "TCP"
  port_range            = "80"
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"
  subnetwork            = module.usc1-trustsubnet-001.subnets["us-central1/usc1-trustsubnet-001"]["id"]
  network               = module.usc1-trust-vpc-001.vpc.name
  backend_group         = module.mig.instance_group
  depends_on            = [module.mig]

}

/******************************************
	MIG 
 *****************************************/

module "mig" {
  source        = "./modules/mig"
  project_id    = var.project_id
  region        = var.region
  zone          = "us-central1-a"
  sqladdress    = local.ip
  startup_sript = templatefile("./Bootstrap/Scripts/compute.sh", { user = "${var.db_user}", password = "${var.db_password}", database = "${var.db_name}", host = "${local.ip}" })
  network       = module.usc1-trust-vpc-001.vpc.name
  subnetwork    = "projects/${var.project_id}/regions/${var.region}/subnetworks/usc1-trustsubnet-001"
  scope         = ["https://www.googleapis.com/auth/cloud-platform"]
  #MIG
  service_account = var.service_account
  mig_name        = "coe-mig-001"
  min_replicas    = 1
  max_replicas    = 2
  named_ports = [{
    name = "http"
    port = "80"
  }]
  depends_on = [
    module.usc1-trustsubnet-001,
    module.usc1-trust-vpc-001,
    module.router-nat,
    module.cloudsql
  ]
}


/******************************************
	Cloud SQL- MYSQL
 *****************************************/

locals {
  ip = module.cloudsql.private_address
}

module "cloudsql" {
  source            = "./modules/CloudSQL"
  region            = var.region
  project_id        = var.project_id
  database_version  = "MYSQL_5_6"
  network           = module.usc1-trust-vpc-001.vpc.name
  dbname            = var.db_name
  sql_instance_name = "gbg-coe-sql"
  sqluser           = var.db_user
  password          = var.db_password
}
