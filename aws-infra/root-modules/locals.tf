######################################
# 공통 변수
######################################
locals {
  region_map = {
    "eu-west-1" = {
      name   = "ireland"
      code   = "ew1"
      prefix = "eu"
    }

    "us-west-2" = {
      name   = "oregon"
      code   = "uw2"
      prefix = "us"
    }
  }

  region_name   = local.region_map[var.region].name   # ireland, oregon
  region_code   = local.region_map[var.region].code   # ew1, uw2
  region_prefix = local.region_map[var.region].prefix # eu, us

  ipa_users = {
    dev = "fmmsysops.fmm-dev"
    stg = "fmmsysops.fmm-stg"
    prd = "fmmsysops.fmm-prod"
  }
  ipa_user = local.ipa_users[var.environment]

  naming_rule = "${var.project}-${var.environment}-${local.region_name}"

  context = {
    project = var.project
    environment = var.environment
    region      = var.region
    region_name = local.region_name
    naming_rule = local.naming_rule
  }

  # TAGS
  common_tags = {
    # Project      = var.project
    ENV          = var.environment
    ManagedBy    = "Terraform"
  }
}


######################################
# VPC Subnet Group Mapping
######################################
# Private Subnet
locals {
  private_subnet_ids = {
    for vpc_key, vpc in module.vpc :
    vpc_key => {
      for subnet_group in distinct([
        for subnet in values(vpc.private_subnet_id) :
        subnet.subnet_name
      ]) :

      subnet_group => [
        for subnet_key, subnet in vpc.private_subnet_id :
        subnet.id
        if subnet.subnet_name == subnet_group
      ]
    }
  }
}

######################################
# VPC Peering
######################################
locals {
  vpc_peerings = merge([
    for requester_alias, vpc in var.vpcs : {
      for accepter_alias, peering in vpc.vpc_peerings :
      "${requester_alias}-${accepter_alias}" => merge(
        peering,
        {
          requester_vpc_alias = requester_alias
          accepter_vpc_alias = accepter_alias
        }
      ) 
      if peering.enable
    }
  ]...)
}

######################################
# Route Table ㅡ csv file
######################################
locals {
  # 하나 이상의 VPC가 Additional Route 사용하면 CSV 로드
  additional_routes = anytrue([
    for vpc in values(var.vpcs) : # enable_additional_routes=false일 경우 안 읽고, true일 경우 csv파일을 decode > read 
    vpc.enable_additional_routes
  ]) ? csvdecode(file("${path.module}/route_tables/${var.environment}-${local.region_prefix}.csv")) : []
}

######################################
# S3 Bucket
######################################
locals {
  s3_bucket_files = fileset("${path.module}/s3/buckets", "*.yaml")

  s3_buckets = {
    for file_name in local.s3_bucket_files :
    trimsuffix(file_name, ".yaml") => yamldecode(
      file("${path.module}/s3/buckets/${file_name}")
    )
    if file_name != "__example.yaml"
  }
}

######################################
# EC2
######################################
locals { 
  # ec2 생성하기 위한 yaml파일 탐색
  ec2_files = [
    for file_name in fileset("${path.module}/ec2", "*.yaml")
    : file_name if file_name != "example.yaml"
  ]

  # yaml 파일명을 EC2 종류의 논리적 이름으로 변환
  ## ex) `example.yaml` 파일 이름을 local.ec2_definitions["example"] 로 변환
  ec2_definitions = {
    for file_name in local.ec2_files :

    trimsuffix(file_name, ".yaml") => yamldecode(
      file("${path.module}/ec2/${file_name}")
    )
  }
}

locals {
  ec2_instances = merge(
    {},
    [
      for ec2_name, config in local.ec2_definitions : {
        for index in range(config.count) :
        "${local.naming_rule}-${ec2_name}-${index + 1}${config.network.zones[index % length(config.network.zones)]}" => {
          #### Instance
          ec2_name = ec2_name
          instance_type = config.instance_type

          monitoring = try(config.monitoring, false)

          #### Network
          network = config.network
          zone    = config.network.zones[index % length(config.network.zones)]

          associate_public_ip_address = try(
            config.associate_public_ip_address,
            false
          )

          # # EC2에 연결할 Security Group 목록
          security_groups = try(
            config.security_groups,
            []
          )

          #### Key Pair
          key_name = try(
            config.iam_instance_profile,
            null
          )

          #### IAM Instance Profile
          iam_instance_profile = (
            try(config.iam_instance_profile.suffix, null) != null
            ? "${local.naming_rule}-${config.iam_instance_profile.suffix}"
            : null
          )

          #### Elastic IP
          eip = try(
            config.eip,
            {
              enabled = false
            }
          )

          #### UserData
          user_data_file = try(
            config.user_data.file,
            null
          )

          #### Volume
          root_volume = config.root_volume
          ebs_volumes = try(
            config.ebs_volumes,
            {}
          )

          #### Tags
          tags = try(
            config.tags,
            {}
          )
        }
      }
    ]...
  )
}

check "ec2_configuration" {
  assert {
    condition = alltrue([
      for ec2_name, config in local.ec2_definitions :
      config.count > 0 && 
      config.count <= 10 &&
      length(config.network.zones) > 0
    ])

    error_message = "EC2 count must be greater than 0 and at least zone mush be defined."
  }
}


######################################
# Security Groups
######################################
# CSV파일 읽어서 SG 규칙 정의
locals {
  sg_common_file = "${path.module}/sg/common.csv"

  sg_environment_file = (
    "${path.module}/sg/${var.environment}-${local.region_prefix}.csv"
  )

  sg_common_rules = csvdecode(file(local.sg_common_file))
  
  sg_environment_rules = (
    fileexists(local.sg_environment_file) 
    ? csvdecode(file(local.sg_environment_file))
    : []
  )

  sg_rules_raw = concat(
    local.sg_common_rules,
    local.sg_environment_rules
  )
}

# CSV 파일에서 읽은 SG 규칙을 Terraform에서 사용할 수 있는 형태로 변환
locals {
  sg_rules = {
    for index, rule in local.sg_rules_raw :

    "${rule.vpc_name}-${rule.sg_name}-${rule.type}-${index + 1}" => {
      vpc_name     = rule.vpc_name
      sg_name      = rule.sg_name
      type         = rule.type
      protocol     = rule.protocol

      from_port    = (rule.protocol == "-1" ? null : tonumber(rule.from_port))
      to_port      = (rule.protocol == "-1" ? null : tonumber(rule.to_port))

      source_type  = rule.source_type
      source       = rule.source
      description  = rule.description
    }
  }

  sg_group_keys = toset([
    for rule in local.sg_rules_raw :
    "${rule.vpc_name}/${rule.sg_name}"
  ])

  security_groups = {
    for key in local.sg_group_keys :

    key => {
      vpc_name = split("/", key)[0]
      sg_name  = split("/", key)[1]
    }
  }
}

# 모든 프로토콜 "-1" 사용 금지 검증
check "sg_protocol_validation" {
  assert {
    condition = alltrue([
      for rule in local.sg_rules_raw :
      rule.protocol != "-1"
    ])

    error_message = "Security Group protocol '-1' is not allowed. Specify an explicit protocol such as tcp, udp, or icmp."
  }
}


######################################
# IAM
######################################
# IAM 파일 조회
locals {
  iam_files = [
    for file_name in fileset ("${path.module}/iam", "*.yaml")
    : file_name
    if file_name != "example.yaml"
  ]
}

# YAML Decode
locals {
  iam_definitions = {
    for file_name in local.iam_files :
    
    trimsuffix(file_name, ".yaml") => yamldecode(
      replace(
        replace(
          file("${path.module}/iam/${file_name}"),
          "{ACCOUNT_ID}",
          data.aws_caller_identity.current.account_id
        ),
        "{REGION}",
        var.region
      )
    )
  }
}

# IAM Role 정규화
locals {
  iam_roles = {
    # role_name = YAML 파일명
    # config    = YAML 내용
    for role_name, config in local.iam_definitions :

    role_name => {
      role_name = role_name

      # Assume Role
      services = try(
        config.services,
        []
      )

      # Instance Profile
      instance_profile_enabled = try(
        config.instance_profile.enabled,
        false
      )

      # AWS Managed Policies
      aws_managed_policies = try(
        config.aws_managed_policies,
        []
      )
      
      # Customer Managed Policies
      custom_policies = {
        for policy_name, policy in try(config.custom_policies, {}) :

        policy_name => {
          description = try(policy.description, null)

          statements = [
            for statement in policy.statements : {
              sid       = try(statement.sid, null)
              effect    = statement.effect
              actions   = statement.actions
              resources = statement.resources

              # conditions = [
              #   for condition in try(statement.conditions, []) : {
              #     test     = condition.test
              #     variable = condition.variable
              #     values   = condition.values
              #   }
              # ]
            }
          ]
        }
      }

      tags = try(
        config.tags,
        {}
      )
    }
  }
}


######################################
# EKS Cluster
######################################
# eks yaml files
locals {
  eks_cluster_files = [
    for file_name in fileset("${path.module}/eks/cluster", "*.yaml") :
    file_name
    if file_name != "example.yaml"
  ]

  eks_node_group_files = [
    for file_name in fileset("${path.module}/eks/node_groups", "*.yaml") :
    file_name
    if file_name != "example.yaml"
  ]
}

# EKS YAML Definitions
locals {
  eks_cluster_definitions = {
    for file_name in local.eks_cluster_files :
    trimsuffix(file_name, ".yaml") => yamldecode(
      file("${path.module}/eks/cluster/${file_name}")
    )
  }

  eks_node_group_definitions = {
    for file_name in local.eks_node_group_files :
    trimsuffix(file_name, ".yaml") => yamldecode(
      file("${path.module}/eks/node_groups/${file_name}")
    )
  }
}

# EKS Cluster / Node Group Mapping
locals {
  eks_definitions = {
    for cluster_key, cluster in local.eks_cluster_definitions :
    cluster_key => merge(
      cluster,
      {
        node_groups = {
          for node_group_key in try(cluster.node_groups, []) :
          node_group_key => local.eks_node_group_definitions[node_group_key]
        }
      }
    )
  }
}

# EKS Cluster Configuration
locals {
  eks_clusters = {
    for cluster_key, cluster in local.eks_definitions :
    cluster_key => {
      # Cluster
      role_arn = module.iam.role_arns[cluster.iam_role]
      version  = cluster.version

      subnet_ids = flatten([
        for subnet_group in cluster.subnet_groups :
        local.private_subnet_ids[cluster.vpc][subnet_group]
      ])

      security_group_ids = [
        for sg_key in try(cluster.security_groups, []) :
        module.sg.security_group_ids[sg_key]
      ]

      endpoint_private_access = try(
        cluster.endpoint_private_access,
        true
      )

      endpoint_public_access = try(
        cluster.endpoint_public_access,
        false
      )

      public_access_cidrs = try(
        cluster.public_access_cidrs,
        []
      )

      enabled_cluster_log_types = try(
        cluster.enabled_cluster_log_types,
        [
          "api",
          "audit",
          "authenticator",
          "controllerManager",
          "scheduler"
        ]
      )

      authentication_mode = try(
        cluster.authentication_mode,
        "API_AND_CONFIG_MAP"
      )

      bootstrap_cluster_creator_admin_permissions = try(
        cluster.bootstrap_cluster_creator_admin_permissions,
        false
      )

      deletion_protection = try(
        cluster.deletion_protection,
        true
      )

      tags = try(cluster.tags, {})

      # Managed Node Groups
      node_groups = {
        for node_group_key, node_group in cluster.node_groups :
        node_group_key => {

          node_role_arn = module.iam.role_arns[node_group.iam_role]

          subnet_ids = flatten([
            for subnet_group in node_group.subnet_groups :
            local.private_subnet_ids[cluster.vpc][subnet_group]
          ])

          instance_types = try(
            node_group.instance_types,
            ["m7g.large"]
          )

          ami_type = try(
            node_group.ami_type,
            "AL2023_ARM_64_STANDARD"
          )

          capacity_type = try(
            node_group.capacity_type,
            "ON_DEMAND"
          )

          disk_size = try(
            node_group.disk_size,
            50
          )

          scaling = node_group.scaling

          max_unavailable = try(
            node_group.max_unavailable,
            1
          )

          labels = try(
            node_group.labels,
            {}
          )

          taints = coalesce(
            try(node_group.taints, null),
            []
          )

          tags = try(node_group.tags, {})
        }
      }
    }
  }
}