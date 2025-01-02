# Kubernetes Cluster Access via AWS PrivateLink

This repository provides a step-by-step guide to set up two VPCs in AWS and configure them to securely access a private Kubernetes cluster (Amazon EKS) in one VPC from an EC2 instance in another VPC using AWS PrivateLink.

## Objective

You will set up the following infrastructure:
1. **VPC 1 (Provider VPC)**: Contains a private Kubernetes cluster (Amazon EKS) with private nodes.
2. **VPC 2 (Consumer VPC)**: Contains an EC2 instance that will access the Kubernetes cluster in VPC 1 using `kubectl`.

## Prerequisites

- AWS Account with necessary IAM permissions.
- AWS CLI installed and configured.
- kubectl installed on your EC2 instance.
- A basic understanding of Amazon EKS, VPCs, PrivateLink, and Kubernetes.

## Step-by-Step Workflow

### 1. Create Two VPCs

#### VPC 1 (Provider VPC)
1. Create a VPC with CIDR block `10.0.0.0/16`.
2. Add two private subnets:
   - `10.0.1.0/24`
   - `10.0.2.0/24`

#### VPC 2 (Consumer VPC)
1. Create a VPC with CIDR block `10.1.0.0/16`.
2. Add:
   - Public subnet: `10.1.1.0/24`
   - Private subnet: `10.1.2.0/24`

### 2. Set Up Kubernetes Cluster in VPC 1

1. Launch an Amazon EKS cluster in VPC 1.
2. Configure the EKS cluster to have:
   - Private API server.
   - Private worker nodes (create one private node for this demo).
   - Ensure no public accessibility for the API server and nodes.

### 3. Set Up EC2 Instance in VPC 2

1. Launch an EC2 instance in VPC 2 in the private subnet (`10.1.2.0/24`).
2. Allow SSH access for management purposes.

### 4. Create AWS PrivateLink

1. Set up a VPC Endpoint Service in VPC 1 to expose the EKS cluster’s private endpoint.
2. Create a VPC Endpoint in VPC 2 to connect to the VPC Endpoint Service from VPC 1.

### 5. Configure Security Groups

1. Modify security group rules to allow communication between VPC 2's EC2 instance and the EKS API server in VPC 1.
2. Open necessary ports:
   - Port `443` (HTTPS) for kubectl access.
   - Port `22` for SSH access to EC2.

### 6. Install kubectl on EC2 Instance

1. SSH into the EC2 instance.
2. Install `kubectl` on the EC2 instance.

### 7. Access Kubernetes Cluster from EC2

1. Use AWS CLI to retrieve the kubeconfig for the EKS cluster.
2. Use the PrivateLink connection to access the Kubernetes API server from the EC2 instance.
3. Run the following command on EC2 to display Kubernetes nodes:
   ```bash
   kubectl get nodes
### 8. Verify the Setup
1. Ensure the EC2 instance in VPC 2 can list the nodes from the Kubernetes cluster in VPC 1 using:
   ```bash
   kubectl get nodes

2. The output should display the Kubernetes nodes from VPC 1.
   ```bash
   Outcome
   After following the steps, your EC2 instance in VPC 2 will be able to access the private Kubernetes cluster in VPC 1 using AWS PrivateLink. When you run kubectl get nodes on the EC2 instance, you will see the Kubernetes nodes from the EKS  
   cluster in VPC 1.
   ```
   ```bash
   This `README.md` file provides clear instructions for setting up the VPCs, Kubernetes cluster, EC2 instance, and AWS PrivateLink, with troubleshooting tips and expected outcomes.

### Troubleshooting
1. Ensure that all security group rules are configured correctly to allow traffic on port 443 (HTTPS) for kubectl.
2. Verify the VPC Endpoint and Service are set up correctly in both VPCs.
3. Check the EC2 instance's kubeconfig file to ensure it points to the correct EKS cluster endpoint.

### Conclusion
This setup ensures a secure, private connection between two VPCs using AWS PrivateLink, allowing you to access the Kubernetes cluster from a private EC2 instance in a different VPC.

### License
This project is licensed under the MIT License - see the LICENSE file for details.
