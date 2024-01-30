
#### Create Testing and Production EC2 Instances on three different regions (AU, UK & US) on AWS 

###### Setting up a basic AWS environment for a web application which is accessible on port 80. In AWS Regions such as Australia (AU), United Kingdom (UK), and United States (US), we will create one ec2 instance for Testing environment & one ec2 instance for Production environment that will be running Windows Server.
S3 bucket will be created in the AWS United States (US) region in Test and Production environment which can be accessible by all the EC2 instances.


```bash
$ terraform init
$ terraform apply 
```


```
Files:

    ├── README.md
    ├── boot-strap.tf    --- Get Windows AMI, User Data for bootstrapping windows server & key pair creation
    ├── bucket.tf        --- Build S3 Bucket & Apply S3 Policy
    └── main.tf          --- Build VPC, Subnets, Security Groups & EC2 Instances
```

```
Architectural Diagram:

  +---------------------+          +-----------------+          +----------------+
  |                     |          |                 |          |                |
  | ap-southeast-2 (AU) |          |  eu-west-1 (UK) |          |  us-west-2 (US)|
  |                     |          |                 |          |                |
  +-----------|---------+          +--------|--------+          +-------|--------+
              |                             |                           |   
   +----------|-------+             +-------|---------+         +-------|---------+               
   |                  |             |                 |         |                 |              
   |                  |             |                 |         |                 |  
  Testing        Production       Testing       Production    Testing       Production 
  EC2 instance   EC2 Instance     EC2 Instance  EC2 Instance  EC2 Instance  EC2 Instance
                                                                 &               &
```                                                            S3 Bucket      S3 Bucket
  
 
