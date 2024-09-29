locals {
    responsible_team = "Team Name Here"
}

generate "vnet_subnets.csv" {
    path = "vnet_subnets.csv"
    if_exists = "overwrite"
    disable_signature = true    # A signature line at the top will break the CSV-nature of a CSV file.
    # The this file will be created for every resource TF in the resource group, however, I don't love
    # the idea of putting it lower and burying it
    contents = <<EOF
name,cidr
ase-subnet,10.0.15.0/24
EOF
}