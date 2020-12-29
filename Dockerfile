# Cypress Docker image.
#
# Uses full 'windows' base image due to Cypress requiring DirectX DLLs.
#
# Example build arguments with explicit versions:
#   docker build --build-arg WIN_VERSION=1809 --build-arg GIT_VERSION=2.25.1 --build-arg NODEJS_VERSION=12.16.1 --build-arg CYPRESS_VERSION=4.2.0 -t cypress .
#
# The versions of nodejs and cypress can be 'latest'.
#
# Example running the image and mapping test code from a local directory:
#   docker run --rm -v c:\dev\my-test-project:c:\cypress --env CYPRESS_BASE_URL=http://app:7071 cypress
# Where 'app' is another container running via 'docker run --name app'

ARG WIN_VERSION=1809
ARG WIN_IMAGE=mcr.microsoft.com/windows:$WIN_VERSION

FROM $WIN_IMAGE AS install

ARG GIT_VERSION=2.25.1
ARG NODEJS_VERSION=12.16.1
ARG CYPRESS_VERSION=4.2.0

ARG GIT_URL=https://github.com/git-for-windows/git/releases/download/v${GIT_VERSION}.windows.1/MinGit-${GIT_VERSION}-busybox-64-bit.zip
ARG NODEJS_URL=https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-win-x64.zip

USER ContainerAdministrator
ARG SETX=/M
RUN setx %SETX% PATH "%PATH%;c:\nodejs;c:\git\cmd;c:\git\mingw64\bin;c:\git\usr\bin"
USER ContainerUser

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install Git
RUN mkdir c:\download | Out-Null; \
    curl.exe --fail --location "$env:GIT_URL" -o /download/git.zip; \
    Expand-Archive /download/git.zip -DestinationPath c:\git; \
    rm /download/git.zip

# Install NodeJS
RUN curl.exe --fail "$env:NODEJS_URL" -o /download/nodejs.zip; \
    Expand-Archive 'c:\download\nodejs.zip' -DestinationPath 'c:\'; \
    mv /node-v$env:NODEJS_VERSION-win-x64 /nodejs; \
    rm /download/nodejs.zip

# Install Cypress
ENV CI=1
RUN npm install cypress@$CYPRESS_VERSION --save-dev --global

# Run Cypress to ensure working and to do first run optimisation
ENV CYPRESS_CRASH_REPORTS=0
WORKDIR /cypress
RUN Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
RUN cypress verify

# Show versions of local tools
RUN echo "\"node version:    $(node -v)\"" ; \
  echo "\"npm version:     $(npm -v | Out-String)\""; \
  echo "\"cypress version: $(cypress -v | Out-String)\""; \
  echo "\"git version:     $(git version | Out-String)\""; \
  echo "\"windows version: $(cmd /s /c ver | Out-String)\""; \
  echo "\"user:            $env:USERNAME\""

CMD ["cypress.cmd", "run"]