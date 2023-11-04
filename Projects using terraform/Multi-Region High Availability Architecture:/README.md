# Multi-Region High Availability Architecture with Terraform and AWS

This Terraform script creates a multi-region, highly available architecture on AWS to ensure your application remains operational even if one region goes down. It's a basic setup that can serve as a starting point for a more robust high availability infrastructure.

## Components and Explanation

1. **AWS Provider Blocks**:
   - Two AWS provider blocks are defined, one for the primary region (us-east-1) and another for the secondary region (us-west-2).

2. **VPC Creation**:
   - Two Virtual Private Clouds (VPCs) are created in both regions to isolate your network infrastructure.

3. **Public Subnets**:
   - Public subnets are created in each region. These subnets are designed to host your application servers. They have internet connectivity and allow your application to be accessible from the internet.

4. **Elastic Load Balancers (ELBs)**:
   - Elastic Load Balancers (ELBs) are created in both regions. ELBs distribute incoming traffic to your application instances. In a multi-region setup, you typically have ELBs in each region to load balance traffic.

5. **Route 53 Health Checks**:
   - Route 53 health checks are used to monitor the health of the primary ELB. These health checks continuously test the health of your application and the primary ELB. If the primary ELB fails the health check, Route 53 will automatically route traffic to the secondary ELB.

6. **Route 53 DNS Record**:
   - A Route 53 DNS record with a failover routing policy is set up. This record points to the primary ELB but automatically switches to the secondary ELB when the primary ELB fails its health check. This provides a seamless failover mechanism for your application.

Please note that this is a simplified example. In a real-world scenario, you'd need to configure other aspects of your infrastructure, such as your application servers, databases, and data replication between regions, to ensure data consistency and high availability. Additionally, your application code should be designed to handle failover gracefully.

## Getting Started

1. Ensure you have Terraform installed.
2. Configure your AWS credentials.
3. Clone this repository.
4. Run `terraform init` to initialize the project.
5. Run `terraform apply` to create the infrastructure.

## Further Enhancements

This example provides a foundational setup for multi-region high availability. Depending on your specific requirements, you can further enhance the architecture by adding redundancy, data replication, and automated failover mechanisms for databases and application servers.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
