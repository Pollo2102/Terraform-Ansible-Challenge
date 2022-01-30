
# Terraform/Ansible Challenge

The following instructions assume you have already setup the `AWS CLI` with an `AWS account` and installed both the `terraform CLI` and `ansible CLI` as well.
Use the following steps to reproduce the intended results of the challenge:

1. Open a console and make sure the working directory is the file where this README file is. Run the command `terraform init` and wait until it completes.

2. The main.tf file contains everything required to deploy the necessary infrastructure. It will even generate the required key pairs. Run the command `terraform apply` and type "yes" when prompted to. Wait until the deployment completes.

3. After the deployment of the infrastructure is completed, there should be a generated .tfstate file in the directory. Open it and search for the resources `ec2_instance` and `ec2_instance2`. Look for the respective `public_ip` field under each resource and copy them into the `./ansible/inventory` file under the `ansible_host=` variables for each respective ec2 instance (One for web and one for web2). If the `ansible_host=` variables contains an IP already (from the repository), replace it with your own IPs.

4. Afterwards, change the command line's working directory to the `./ansible` directory. Run the following command: `ansible-playbook -i inventory install-app.yaml`. After this command completes, the application's 2 instances should be deployed and available.
