# Elastic IP
locals {
  eip_instances = {
    for instance_name, instance in var.instances :
    instance_name => instance
    if instance.eip.enabled
  }
}

# Additional EBS Volumes
locals {
  ebs_volumes = merge(
    {},
    [
      for instance_name, instance in var.instances : {
        for volume_name, volume in instance.ebs_volumes :

        "${instance_name}-${volume_name}" => merge(
          volume,
          {
            instance_name = instance_name
            volume_name   = volume_name
          }
        )
      }
    ]...
  )
}