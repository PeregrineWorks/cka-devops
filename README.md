# cka-devops

## Service Account Impersonation
Configured on basis of "least-privelage" principle. A central service account is created with permission to impersonate other service accounts. 

Each stack in the infrastructure has its own service account with the required permissions to perform its tasks. The central service account can impersonate these stack-specific service accounts to perform actions on their behalf.

## Infrastructure Stacks

### 1. Bootstrap
Handles state bucket and identities/sa creation. This stack is responsible for creating the initial infrastructure (state bucket).

### 2. Network
Handles VPC, subnet, firewall, cloud NAT, and private services. 

### 3. VMs
Google compute disk, instance, and 4 VMs - controlplane, worker1, worker2, and worker3

### 4. Database
CloudSQL instance, database and user, with ephemeral password.

### 5. DNS
A and CNAME records for the controlplane and worker nodes.

# Potential Expansions
1. `trivy` for vulnerability scanning.