# ------------------------------
# Helpers for Echo
# ------------------------------
C_000   := $(shell tput -Txterm setaf 0)
C_F00   := $(shell tput -Txterm setaf 1)
C_0F0   := $(shell tput -Txterm setaf 2)
C_FF0   := $(shell tput -Txterm setaf 3)
C_00F   := $(shell tput -Txterm setaf 4)
C_F0F   := $(shell tput -Txterm setaf 5)
C_0FF   := $(shell tput -Txterm setaf 6)
C_FFF   := $(shell tput -Txterm setaf 7)
C_NULL  := $(shell tput -Txterm sgr0)
REWRITE := \r\033[1A\033[0K

# ------------------------------
# Variables
# ------------------------------
DOCKER_CHECKUP = Docker version
DOCKER_COMPOSE_CHECKUP = docker-compose version
INPUT = null
PHP_DEFAULT_VERSION = 8.0
SED_CHECKUP = sed script
STUB_URL = https://github.com/danielneubert/docker-php-setup/blob/main/stubs



# ------------------------------
# Help command
# ------------------------------
help:
	@echo "${C_00F}Docker${C_NULL} ${C_F0F}PHP${C_NULL} Setup Helper ${C_000}v0.1${C_NULL}"
	@echo "${C_000}This makefile is created by Daniel Neubert.${C_NULL}"
	@echo "${C_000}For more visit: https://github.com/danielneubert/docker-php-setup${C_NULL}"
	@echo ""
	@echo "${C_FF0}Usage:${C_NULL}"
	@echo "  make [command]"
	@echo ""
	@echo "${C_FF0}Commands:${C_NULL}"
	@echo "  ${C_0F0}build       ${C_NULL}Builds the given docker image and composes the container"
	@echo "  ${C_0F0}check       ${C_NULL}Checks for the required commands"
	@echo "  ${C_0F0}compose     ${C_NULL}Composes a new docker container by the docker-compose.yaml"
	@echo "  ${C_0F0}create      ${C_NULL}Create a new image via the Dockerfile"
	@echo "  ${C_0F0}help, list  ${C_NULL}Lists all available commands"
	@echo "  ${C_0F0}proxy       ${C_NULL}Creates a Laravel valet proxy entry"

# ------------------------------
# Help command alias
# ------------------------------
list:
	@make help



# ------------------------------
# Check for the required commands
# ------------------------------
check:
	@if docker --version 2>/dev/null | grep -q "${DOCKER_CHECKUP}"; then\
		echo "${C_0F0}✔${C_NULL} command ${C_FF0}'docker'${C_NULL} is available"; else\
		echo "${C_F00}✘${C_NULL} command ${C_FF0}'docker'${C_NULL} is missing"; fi;
	@if docker-compose --version 2>/dev/null | grep -q "${DOCKER_COMPOSE_CHECKUP}"; then\
		echo "${C_0F0}✔${C_NULL} command ${C_FF0}'docker-compose'${C_NULL} is available"; else\
		echo "${C_F00}✘${C_NULL} command ${C_FF0}'docker-compose'${C_NULL} is missing"; fi;

	@if docker --version 2>/dev/null | grep -q "${DOCKER_CHECKUP}"; then true; else\
		echo "" && echo "${C_F00}Please provide the missing commands${C_NULL}" && exit 1; fi;
	@if docker-compose --version 2>/dev/null | grep -q "${DOCKER_COMPOSE_CHECKUP}"; then true; else\
		echo "" && echo "${C_F00}Please provide the missing commands${C_NULL}" && echo "" && exit 1; fi;



# ------------------------------
# Build Command (Check for arguments)
# ------------------------------
build:
	@make check

ifdef php
ifdef port
	@make build--run php=${php} port=${port}
endif
ifndef port
	@echo ""
	@read -p "${C_FF0}What port should the localhost run at?${C_NULL} " port;\
		make build--run php=${php} port=$$port
endif
endif

ifndef php
ifdef port
	@echo ""
	@read -p "${C_FF0}What version of PHP should be used? ${C_0F0}[${PHP_DEFAULT_VERSION}]${C_NULL} " php;\
		if [[ $$php == "" ]]; then\
			make build--run php=${PHP_DEFAULT_VERSION} port=${port}; else\
			make build--run php=$$php port=${port}; fi;
endif
ifndef port
	@echo ""
	@read -p "${C_FF0}What version of PHP should be used? ${C_0F0}[${PHP_DEFAULT_VERSION}]${C_NULL} " php;\
		read -p "${C_FF0}What port should the localhost run at?${C_NULL} " port;\
		if [[ $$php == "" ]]; then\
			make build--run php=${PHP_DEFAULT_VERSION} port=$$port; else\
			make build--run php=$$php port=$$port; fi;
endif
endif


# ------------------------------
# Build Complete Run
# ------------------------------
build--run:
ifndef php
	@make error-php-argument-missing
endif
ifndef port
	@make error-port-argument-missing
endif

	@echo ""
	@make build--populate php=${php} port=${port}
	@make create php=${php} port=${port} skip-check=true
	@make compose skip-check=true
	@make build--complete port=${port}



# ------------------------------
# Create the PHP docker image
# ------------------------------
build--populate:
ifndef php
	@make error-php-argument-missing
endif
ifndef port
	@make error-port-argument-missing
endif

	@echo "${C_00F}→${C_NULL} Downloading Dockerfile and docker-compose stubs ... ${C_0F0}(0/2)${C_NULL}"
	@curl ${SUB_URL}/Dockerfile --output .docker/Dockerfile.stub 2>/dev/null
	@echo "${REWRITE}${C_00F}→${C_NULL} Downloading Dockerfile and docker-compose stubs ... ${C_0F0}(1/2)${C_NULL}"
	@curl ${SUB_URL}/docker-compose.yaml --output .docker/docker-compose.stub 2>/dev/null
	@echo "${REWRITE}${C_0F0}✔${C_NULL} Downloading Dockerfile and docker-compose stubs ${C_0F0}(2/2)${C_NULL}"

	@echo "${C_00F}→${C_NULL} Writing PHP version and port to stubs ..."
	@sed 's/%PHP%/${php}/g' .docker/Dockerfile.stub > Dockerfile
	@sed 's/%PHP%/${php}/g' .docker/docker-compose.stub > .docker/docker-compose.yaml
	@sed 's/%PORT%/${port}/g' .docker/docker-compose.yaml > docker-compose.yaml
	@rm -rf .docker/Dockerfile.stub
	@rm -rf .docker/docker-compose.stub
	@rm -rf .docker/docker-compose.yaml
	@echo "${REWRITE}${C_0F0}✔${C_NULL} Writing PHP version and port to stubs ..."



# ------------------------------
# Build Complete Step
# ------------------------------
build--complete:
	@echo ""
	@read -p "${C_FF0}Would you like to create a proxy entry for Laravel Valet? ${C_0F0}[y/N]${C_NULL} " INPUT_VAR;\
		if [[ $$INPUT_VAR == "y" ]] || [[ $$INPUT_VAR == "Y" ]]; then\
			echo "${REWRITE}${C_0F0}Build process completed. ${C_NULL}" && echo "" && make proxy port=${port}; else\
			echo "${REWRITE}${C_0F0}Build process completed. Have fun!${C_NULL}"; fi;



# ------------------------------
# Compose the docker contaier
# ------------------------------
compose:
ifndef skip-check
	@make check
endif

	@echo "${C_00F}→${C_NULL} Composing the given docker container ..."
	@docker-compose up -d --build 2>/dev/null
	@echo "${REWRITE}${C_0F0}✔${C_NULL} Composing the given docker container ..."



# ------------------------------
# Create the PHP docker image
# ------------------------------
create:
ifndef php
	@make error-php-argument-missing
endif

ifndef skip-check
	@make check
endif

	@echo "${C_00F}→${C_NULL} Building the docker image from Dockerfile ${C_000}(php:${php}-full-apache)${C_NULL}"
	@docker build . -t php:${php}-full-apache 2>/dev/null
	@echo "${REWRITE}${C_0F0}✔${C_NULL} Building the docker image from Dockerfile ${C_000}(php:${php}-full-apache)${C_NULL}"



# ------------------------------
# Creates a Laravel valet proxy entry
# ------------------------------
proxy:
	@if valet list 2>/dev/null | grep -q "Laravel Valet"; then true; else\
		echo "${C_F00}✘${C_NULL} command ${C_FF0}'valet'${C_NULL} is missing"\
		&& echo "" && echo "${C_F00}Please install Laravel Valet for the proxy command.${C_NULL}"\
		&& echo "${C_000}Read more: https://laravel.com/docs/valet${C_NULL}"\
		&& echo "" && exit 1; fi;

ifdef port
	@read -p "${C_FF0}Desired domain:${C_NULL} " INPUT_DOMAIN;\
		valet proxy $$INPUT_DOMAIN http://localhost:${port}/
endif
ifndef port
	@read -p "${C_FF0}Port of your local server:${C_NULL} " INPUT_PORT;\
		read -p "${C_FF0}Desired domain:${C_NULL} " INPUT_DOMAIN;\
		valet proxy $$INPUT_DOMAIN http://localhost:$$INPUT_PORT/
endif



# ------------------------------
# Error: argument 'php' missing
# ------------------------------
error-php-argument-missing:
	@echo ""
	@echo "${C_F00}Please call the command with a PHP version. Example:${C_NULL}"
	@echo "  make [command] php=${PHP_DEFAULT_VERSION}"
	@echo ""
	@exit 1

# ------------------------------
# Error: argument 'port' missing
# ------------------------------
error-port-argument-missing:
	@echo ""
	@echo "${C_F00}Please call the command with a port. Example:${C_NULL}"
	@echo "  make [command] port=8080"
	@echo ""
	@exit 1