# Single-stage build of an oxidized container from phusion/baseimage-docker v0.11, derived from Ubuntu 18.04 (Bionic Beaver)
# FROM phusion/baseimage:0.11
FROM oxidized/oxidized:latest

ARG PS_VERSION=7.0.0
ARG PS_PACKAGE=powershell-lts_${PS_VERSION}-1.ubuntu.18.04_amd64.deb
ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${PS_PACKAGE}

# ARG PS_VERSION=7.0.0-rc.1
# ARG PS_PACKAGE=powershell-lts_${PS_VERSION}-1.ubuntu.18.04_amd64.deb
# ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${PS_PACKAGE}

# Define ENVs for Localization/Globalization
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    # set a fixed location for the Module analysis cache
    PSModuleAnalysisCachePath=/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache \
    POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-Ubuntu-18.04

# Install dependencies and clean up
RUN apt-get update \
    && apt-get install -y \
    # vim is required to edit files
        vim \
    # Git is required to pull files from repo
        git \    
    # curl is required to grab the Linux package
        curl \
    # less is required for help in powershell
        less \
    # requied to setup the locale
        locales \
    # required for SSL
        ca-certificates \
        gss-ntlmssp \
    # Download the Linux package and save it
    && echo ${PS_PACKAGE_URL} \
    && curl -sSL ${PS_PACKAGE_URL} -o /tmp/powershell.deb \
    && apt-get install -y /tmp/powershell.deb \
    && apt-get dist-upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen $LANG && update-locale \
    # remove powershell package
    && rm /tmp/powershell.deb \
    # intialize powershell module cache
    && pwsh \
        -NoLogo \
        -NoProfile \
        -Command " \
          \$ErrorActionPreference = 'Stop' ; \
          \$ProgressPreference = 'SilentlyContinue' ; \
          while(!(Test-Path -Path \$env:PSModuleAnalysisCachePath)) {  \
            Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; \
            Start-Sleep -Seconds 6 ; \
          }"

# Install dependencies and clean up
RUN apt-get update \
    && apt-get install -y \
    # Get packages needed for the install process
        ca-certificates curl apt-transport-https lsb-release gnupg
# Download and install the Microsoft signing key:
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

# Add the Azure CLI software repository
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list
# Update repository information and install the azure-cli package:

# RUN apt-get update
RUN apt-get update \
    && apt-get install azure-cli -y

RUN pwsh -command Install-Module AzureAD -Force

# # Use baseimage-docker's init system.
# CMD ["/sbin/my_init"]

# Use PowerShell as the default shell
# Use array to avoid Docker prepending /bin/sh -c
CMD [ "pwsh" ]



