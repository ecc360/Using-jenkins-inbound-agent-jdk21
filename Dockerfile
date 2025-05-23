FROM bitnami/kubectl:1.33 as kubectl

FROM jenkins/inbound-agent:latest-jdk21

# Ejecutar comandos como root
USER root

# Actualizar los paquetes e instalar python3, pip y venv en una sola capa
RUN apt-get update -y && \
    apt-get install jq -y && \
    apt-get install -y python3 python3-pip python3-venv ca-certificates openssl && \
    rm -rf /var/lib/apt/lists/*

# Intalar PIP
RUN pip3 install kubernetes --break-system-packages
RUN pip3 install requests --break-system-package

# Instalar Helm desde los releases oficiales
RUN curl -fsSL https://get.helm.sh/helm-v3.14.0-linux-amd64.tar.gz | tar -xz -C /tmp && \
    mv /tmp/linux-amd64/helm /usr/local/bin/ && \
    rm -rf /tmp/linux-amd64

# Copiar kubectl desde la imagen kubectl
COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/

# Establecer el usuario jenkins y los argumentos de Java
USER jenkins
ENV JAVA_ARGS="-hudson.slaves.SlaveComputer.allowUnsupportedRemotingVersions=true -Dhudson.remoting.Launcher.sslHostVerification=false -Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true"
ENV CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# Asegurarse de que el entorno virtual esté activado en cada sesión
ENV PATH="/opt/venv/bin:$PATH"

# Definir el punto de entrada
ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
