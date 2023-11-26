# ASSESSMENT_ANS

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAW4R3L46LJD57VLQN"
  secret_key = "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"
}


resource "aws_vpc" "asgvpc" {
  cidr_block       = "99.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "asgvpc"
  }
}

resource "aws_subnet" "asgpublicsubnet" {
  vpc_id     = aws_vpc.asgvpc.id
  cidr_block = "99.0.0.0/24"

  tags = {
    Name = "asgpublic_subnet"
  }
}

resource "aws_internet_gateway" "asgigw" {
  vpc_id = aws_vpc.asgvpc.id

  tags = {
    Name = "asgigw"
  }
}

resource "aws_route_table" "asgrta" {
  vpc_id = aws_vpc.asgvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.asgigw.id
  }
}

resource "aws_security_group" "asgsg" {
  name        = "asgsg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.asgvpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.asgvpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "asgsg"
  }
}



# Create AWS nginxkey

resource "aws_key_pair" "ASGkey" {
  key_name   = "ASGkey"
  public_key = file("ASGkey.pem.pub")
}

# Create AWS Instance
resource "aws_instance" "ASGnginx" {
  ami           = "ami-02a2af70a66af6dfb"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ASGkey.key_name  
  subnet_id     = aws_subnet.asgpublicsubnet.id 
  associate_public_ip_address = true
  tags = {
    Name = "ASGnginx_ins"
  }

  user_data = <<-EOF
    #! /bin/sh
    yum update -y
    yum install docker -y
    service docker start
    docker pull nginx:alpine
    docker run -it -d --name nginxcont -p 80:80 nginx:alpine
 EOF
}

output "public_ip" {
  value = aws_instance.ASGnginx.public_ip
}



===============================================================================
===============================================================================


    ***IN THE ABOVE CODE  I AM CREATING INSTANCE INSIDE VPC *** NGINX WEB SERVER ***

--->  so vpc,internet gateway, route table,security group, subnet ,instance all these are created by terraform code(Above code represents all resources)
    
----> i am installing nginx and run the nginx by using docker commands and also these nginx web server is running with public ip address on port 80  


----> After the successful execution by using terraform commands
  
   terraform init
   terraform validate
   terraform fmt
   terraform apply



----> we see the public ip address, By using this public ip address we run the nginx web server with port 80 

==============================================================================
==============================================================================


---
- name: apache server installation process
  hosts: GROUP1  
  tasks:
    - name: Install apache package
      yum:
        name: httpd
        state: present
    - name: start Apache package
      service:
        name: httpd
        state: started
    - name: add firewalls
       ansible.posix.firewalld:
        port: 8080/tcp
        permanent: true
        state: enabled
    - name: reload firewall config
      systemd:
        name: firewalld
        state: reloaded
    - name: copy indexfile to apache directory
      copy:
        src: /tmp/index.html
        dest: /var/www/html
    - name: Restart apache server
      service:
        name: httpd
        state: restarted


===============================================================
==============================================================



--> Prometheus is data collection tool and Grafana is data visualisation tool.
--> By default prometheus is running on port 9090
--> By default Grafana is running on port 3000

--> Key Metrics to Monitor:

    Web Application Metrics:
     * Request/response times
     * Error rates
     * Throughput (requests per second)
     * Concurrent connections
    System Metrics:
     * CPU and memory usage
     * Disk I/O and usage
     * Network throughput
    Container Metrics (if using containers):
     * Container resource utilization (CPU, memory)
     * Network statistics
    Logs:
     * Collect logs for application events, errors, and warnings.
    Security Metrics (optional):
     * Failed login attempts
     * Security events


-->Creating Dockerfile(by using some of the basic components)
     FROM: python:3.8-slim (here i am taking some of the base images of python)
     WORKDIR: /app
     COPY: . /app
     RUN: pip install --no-cache-dir -r requirements.txt(dependencies are in this txt file)
     EXPOSE: 5050
     CMD ["python", "app.py"]

---> # creating docker image by using command
        "docker build -t ."
---> # sending that docker image to our registry
---> we have to send that docker image to kubernetes for container orchestration purpose
---> creating cluster setup by setting up EKS in cloud platforms like AWS or by command wise also
---> one of the way to create cluster setup by using command
        "eksctl create cluster --name <clustername> --region <region> --node-type <ex:t2 micro>"
---> created cluster by using above command
---> creating pods by manifest file
 
deployment.yml
    
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-microservice
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-microservice
  template:
    metadata:
      labels:
        app: my-microservice
    spec:
      containers:
      - name: my-microservice
        image: (mention path of our image in our registry)
        imagePullPolicy: Always
        ports:
        - containerPort: 5050

---> providing some of the basic manifest file
---> then give command for applying deployment
          "kubectl apply -f deployment.yml"
---> we can deploy that deployment by using command
          "kubectl expose deployment <deployment name> --port=<port number> --type=LoadBalancer



We configure security by using different ways, some of them are as follows.

--->To Git: [Version Control System]
    * Firstly, Git is used for developing the code.
    * we can send to various integration tools by pushing that code to github repositories
    * Before performing the build process in jenkins pipeline, we can configure that code scanning analysis by using scanning tools like sonarqube
    * Sonarqube will check security of the code whether there are any bugs, bugsmells, vulnerabilities in that code.
    * likewise we are performing security to our version control system .

-->Securing CI/CD pipelines:
    * To enhance security, we implement artifact signing and verification. This ensures the integrity of our deployment artifacts by adding digital signatures, 
      and during deployment, we verify these signatures to prevent the execution of compromised or tampered code.
    * Additionally, we take extra care in managing secrets used in our CI/CD pipeline. Rather than hardcoding them into the code or configuration files, 
      we utilize secure vaults or secret management tools to protect sensitive information and limit access to authorized personnel."

-->Continuous Monitoring:  
    * Implement continuous monitoring to detect and respond to security incidents in real-time.
    * Utilize tools for log aggregation, anomaly detection, and intrusion detection to monitor system activities.

          
