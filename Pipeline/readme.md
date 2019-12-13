YML Template Files
azure-pipeline.yml uses all supporting YAML files to validate templates, download artifcats module if created and deploy ARM templates. This can be used to automate and scale multiple pipelines by using templates

universalpackages.yml
This template is used to download all the required universalpackages to the build artifact in the pipelines. The modules downloaded in this template will become available for all application pipelines.

deploy_template.yml
This template is used to deploy one specific ARM template/module.

validate_template.yml
This template is used to validate one specific ARM template/module.
