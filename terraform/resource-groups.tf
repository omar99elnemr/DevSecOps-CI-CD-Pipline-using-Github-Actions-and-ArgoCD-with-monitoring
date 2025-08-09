# AWS Resource Group for all DevSecOps infrastructure
resource "aws_resourcegroups_group" "quizapp_rg" {
  name        = "quizapp_rg"
  description = "All resources for DevSecOps CI/CD Pipeline with EKS, ArgoCD, Prometheus, and Grafana"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key    = "Project"
          Values = [var.project_name]
        }
      ]
    })
  }

  tags = var.common_tags
}

# Output Resource Group information
output "resource_groups" {
  description = "AWS Resource Group for managing all infrastructure"
  value = {
    name        = aws_resourcegroups_group.quizapp_rg.name
    arn         = aws_resourcegroups_group.quizapp_rg.arn
    console_url = "https://console.aws.amazon.com/resource-groups/group/${aws_resourcegroups_group.quizapp_rg.name}"
  }
}

# Output instructions for resource management
output "resource_management_instructions" {
  description = "Instructions for managing and destroying resources"
  value = {
    view_resources    = "Go to AWS Console > Resource Groups > Saved Groups > quizapp_rg"
    terraform_destroy = "Run 'terraform destroy' in the terraform directory to delete all resources"
    aws_cli_list     = "aws resource-groups list-group-resources --group-name quizapp_rg"
    cost_explorer    = "Use AWS Cost Explorer with tag filters: Project=${var.project_name}"
  }
}
