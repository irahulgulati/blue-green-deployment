.PHONY: pkvalidate pkbuild tfplan tfapply tfdestroy tfinit

build: | clearscr pkvalidate pkbuild tfplan tfapply

clearscr:
	@clear

pkvalidate:
	@echo "validating packer file..."
	@cd packer \
	&& packer validate nginx_web_server.json \
	&& packer validate app_server.json

pkbuild:
	@echo "building AMI..."
	@cd packer \
	&& packer build nginx_web_server.json \
	&& packer build app_server.json

tfplan-blue:
	@echo "planning infrastructure..."
	@cd terraform/$(deployment_path) \
	&& terraform plan

tfapply:
	@echo "applying infrastructure..."
	@cd terraform/$(deployment_path) \
	&& terraform apply -auto-approve

tfdestroy:
	@echo "destroying infrastructure..."
	@cd terraform/$(deployment_path) \
	&& terraform destroy -auto-approve

tfinit:
	@echo "initalizing terraform..."
	@cd terraform/$(deployment_path) \
	&& terraform init
