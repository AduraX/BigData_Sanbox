#!/usr/bin/env bash
if test "`echo -e`" = "-e" ; then ECHO=echo ; else ECHO="echo -e" ; fi

CreateHost() { # para: lbAZ NumMasters NumSlaves isBastion

#[** Parameters & Mappings creation
ParaMapBlock="""
Parameters:
  Region:
    Type: String
    Default: ap-southeast-1
    AllowedValues:
      - us-east-1
      - ap-southeast-1
      - ap-southeast-2
    Description: Enter the AWS region to deploy stack. Default is eu-west-1
  VPCCidr:
    AllowedPattern: '((\d{1,3})\.){3}\d{1,3}/\d{1,2}'
    Type: String
    Default: 10.0.0.0/16
    Description: Enter the CIDR for your VPC
  PublicSubnetACidr:
    AllowedPattern: '((\d{1,3})\.){3}\d{1,3}/\d{1,2}'
    Type: String
    Default: 10.0.1.0/24
    Description: Enter the CIDR for your Public Subnet A
  PrivateSubnetACidr:
    AllowedPattern: '((\d{1,3})\.){3}\d{1,3}/\d{1,2}'
    Type: String
    Default: 10.0.3.0/24
    Description: Enter the CIDR for your Private Subnet A
  KeyPair:
    Type: String
    Default: SingaporeKeyEc2
    Description: Enter the name of pre-generated KeyPair
  InstType:
    Type: String
    Default: t3a.medium
    Description: Enter the name of Instance Type
  VolSize:
    Type: String
    Default: "4"
    Description: Enter the Volume size
Mappings:
  RegionMap:
    # Ubuntu Server 18.04 LTS (HVM) amd64 hvm:ebs-ssd
    us-east-1:
      HVM64: ami-07d0cf3af28718ef8
    ap-southeast-1:
      HVM64: ami-03b6f27628a4569c8
    ap-southeast-2:
      HVM64: ami-0edcec072887c2caa """
lbStack="$ParaMapBlock"
#**] Parameters & Mappings creation

#[** First Resource block creation
FirstResBlock="""
Resources:
  Ec2S3Role:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Principal:
              Service: ec2.amazonaws.com
            Action: sts:AssumeRole
      Path: /
  Ec2S3InstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      Path: /
      Roles:
        - !Ref Ec2S3Role
  Ec2S3RolePolicies:
    Type: AWS::IAM::Policy
    Properties:
      PolicyName: S3InstancePolicy
      PolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Action: 's3:*'
            Resource: '*'
      Roles:
        - !Ref Ec2S3Role
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VPCCidr
      EnableDnsHostnames: 'true'
      Tags:
        - Key: Name
          Value: VPC
  IG:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        -  Key: Name
           Value: IG
  AttachIGtoVPC:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      InternetGatewayId: !Ref IG
      VpcId: !Ref VPC
  PublicRT:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: Public-RT
  PublicRouteToInternet:
    Type: AWS::EC2::Route
    Properties:
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref IG
      RouteTableId: !Ref PublicRT
    DependsOn: AttachIGtoVPC
  # Create EIP which will be used by the NAT Gateway
  NATEIP:
    Type: AWS::EC2::EIP
    Properties:
      Domain: !Ref VPC
  EC2SG:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security Group for EC2 to allow SSH from Bastion and expose HTTP 80
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
          Description: SSH
        - IpProtocol: tcp
          FromPort: 8899
          ToPort: 8899
          CidrIp: 0.0.0.0/0
          Description: Jupyter
        - IpProtocol: tcp
          FromPort: 2181
          ToPort: 2181
          CidrIp: 0.0.0.0/0
          Description: ZooKeeper
        - IpProtocol: tcp
          FromPort: 3888
          ToPort: 3888
          CidrIp: 0.0.0.0/0
          Description: ZooKeeper
        - IpProtocol: tcp
          FromPort: 2888
          ToPort: 2888
          CidrIp: 0.0.0.0/0
          Description: ZooKeeper
        - IpProtocol: tcp
          FromPort: 0
          ToPort: 65535
          CidrIp: !Ref VPCCidr
      Tags:
        - Key: Name
          Value: EC2-SG
      VpcId: !Ref VPC  """
lbStack="$lbStack $FirstResBlock"
#**] First Resource block creation

#[** PP Resource block creation
if [ $4 == "Y" ]; then
PpResBlock="""
  PrivateRT:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: Private-RT
  PrivateRouteToInternet:
    Type: AWS::EC2::Route
    Properties:
      DestinationCidrBlock: 0.0.0.0/0
      NatGatewayId: !Ref NATGWa
      RouteTableId: !Ref PrivateRT
  BastionSG:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security Group for Bastion Host to allow SSH
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 0
          ToPort: 65535
          CidrIp: !Ref VPCCidr
      Tags:
        - Key: Name
          Value: Bastion-SG
      VpcId: !Ref VPC """
lbStack="$lbStack $PpResBlock"
fi
#**] PP Resource block creation

# ~~~~  Availability Zone(AZ) Components ~~~~~~~~~~~~~
lbHostBlock="\n\n  # ~~~~~ Cluster Nodes"
lbOutputBlock="\n\nOutputs:"

# for loop ***************
#[** Pub-Pri Subnet Resource block creation
PubSubnetBlock="""
  # ~~~~  Availability Zone(AZ) A Components ~~~~~~~~~~~~~
  PublicSubnet$1:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Sub \${Region}${1,}
      CidrBlock: !Ref PublicSubnetACidr
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: PublicSubnet$1
  AssociatePublicSubnet${1}PublicRT:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PublicRT
      SubnetId: !Ref PublicSubnet$1 """
lbStack="$lbStack $PubSubnetBlock "

if [ $4 == "Y" ]; then
PriSubnetBlock="""
  PrivateSubnet$1:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Sub \${Region}${1,}
      CidrBlock: !Ref PrivateSubnetACidr
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: PrivateSubnet$1
  AssociatePrivateSubnet${1}PrivateRT:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PrivateRT
      SubnetId: !Ref PrivateSubnet$1 """
lbStack="$lbStack $PriSubnetBlock "
fi
#**]  Pub-Pri Subnet Resource block creation

#[** Bastion host creation
lbPriPub="Public"
if [ $4 == "Y" ]; then
outHost="Bastion$1"
lbSubnetType="PublicSubnet$1"
HostBlock="""
  $outHost:
    Type: AWS::EC2::Instance
    Properties:
      AvailabilityZone: !Sub \${Region}${1,}
      ImageId: !FindInMap [RegionMap, !Ref 'AWS::Region', HVM64]
      InstanceType: t3a.nano
      KeyName: !Ref KeyPair
      NetworkInterfaces:
        - AssociatePublicIpAddress: "true"
          DeviceIndex: "0"
          SubnetId: !Ref $lbSubnetType
          GroupSet:
            - !Ref AmbariSG
            - !Ref EC2SG
      Tags:
        - Key: Name
          Value: $outHost """
lbHostBlock="$lbHostBlock $HostBlock"

OutputBlock="""
  ${outHost}Ip:
    Value: !Sub \${$outHost.PrivateIp}
    Description: 'Private IP of host to connect via SSH from Bastion Host.'
  ${outHost}Dns:
    Value: !Sub \${$outHost.PublicDnsName}
    Description: 'Private IP of host to connect via SSH from Bastion Host.' """
lbOutputBlock="$lbOutputBlock $OutputBlock"
lbPriPub="Private"
fi
#**] Bastion host creation

#[** Master hosts creation
for ((i=1; i<=$2; i++)); do
  Psn=$(echo `printf "%2.0d\n" $i |sed "s/ /0/"`)
  outHost="Master$Psn$1"
  lbSubnetType="${lbPriPub}Subnet$1"
HostBlock="""
  $outHost:
    Type: AWS::EC2::Instance
    Properties:
      IamInstanceProfile: !Ref Ec2S3InstanceProfile
      AvailabilityZone: !Sub \${Region}${1,}
      BlockDeviceMappings:
        - DeviceName: "/dev/xvda"
          Ebs:
            VolumeType: "gp2"
            DeleteOnTermination: "true"
            VolumeSize: !Ref VolSize
      ImageId: !FindInMap [RegionMap, !Ref 'AWS::Region', HVM64]
      InstanceType: !Ref InstType
      KeyName: !Ref KeyPair
      NetworkInterfaces:
        - AssociatePublicIpAddress: "true"
          DeviceIndex: "0"
          SubnetId: !Ref $lbSubnetType
          GroupSet:
            - !Ref EC2SG
      Tags:
        - Key: Name
          Value: $outHost """
lbHostBlock="$lbHostBlock $HostBlock"

OutputBlock="""
  ${outHost}Ip:
    Value: !Sub \${$outHost.PrivateIp}
    Description: 'Private IP of host to connect via SSH from Bastion Host.'
  ${outHost}Dns:
    Value: !Sub \${$outHost.${lbPriPub}DnsName}
    Description: 'Private IP of host to connect via SSH from Bastion Host.' """
lbOutputBlock="$lbOutputBlock $OutputBlock"
done
#**] Master hosts creation

#[** Slave hosts creation
for ((i=1; i<=$3; i++)); do
  Psn=`echo "$i + 10" | bc`
  outHost="Slave$Psn$1"
  lbSubnetType="${lbPriPub}Subnet$1"
HostBlock="""
  $outHost:
    Type: AWS::EC2::Instance
    Properties:
      IamInstanceProfile: !Ref Ec2S3InstanceProfile
      AvailabilityZone: !Sub \${Region}${1,}
      BlockDeviceMappings:
        - DeviceName: "/dev/xvda"
          Ebs:
            VolumeType: "gp2"
            DeleteOnTermination: "true"
            VolumeSize: !Ref VolSize
      ImageId: !FindInMap [RegionMap, !Ref 'AWS::Region', HVM64]
      InstanceType: !Ref InstType
      KeyName: !Ref KeyPair
      NetworkInterfaces:
        - AssociatePublicIpAddress: "true"
          DeviceIndex: "0"
          SubnetId: !Ref $lbSubnetType
          GroupSet:
            - !Ref EC2SG
      Tags:
        - Key: Name
          Value: $outHost """
lbHostBlock="$lbHostBlock $HostBlock"

OutputBlock="""
  ${outHost}Ip:
    Value: !Sub \${$outHost.PrivateIp}
    Description: 'Private IP of host to connect via SSH from Bastion Host.'
  ${outHost}Dns:
    Value: !Sub \${$outHost.${lbPriPub}DnsName}
    Description: 'Private IP of host to connect via SSH from Bastion Host.' """
lbOutputBlock="$lbOutputBlock $OutputBlock"
done
#**] Slave hosts creation

$ECHO "$lbStack $lbHostBlock $lbOutputBlock" > template.yaml
}
