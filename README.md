

Building Testing & Production Environment on three different regions on AWS 

Setting up a basic AWS environment for a web application. IN AWS Regions such as Australia (AU), United Kingdom (UK), and United States, we will have create environment for Production and Testing. S3 bucket will also be created in the AWS US region which can be accessed by all the EC2 instances


$ terraform init
$ terraform apply  


.
├── README.md
├── boot-strap.tf    --- Get Windows AMI, User Data for bootstrapping windows server & key pair creation
├── bucket.tf        --- Build S3 Bucket & Apply S3 Policy
└── main.tf          --- Build VPC, Subnets, EC2 Instances & Security Groups 

