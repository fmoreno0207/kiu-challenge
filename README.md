# KIU Challenge - AWS Infrastructure Deployment


# **ÍNDICE**

# **ÍNDICE**

- [Introducción](#introducción)
  - [Requisitos Previos](#requisitos-previos)
  - [Qué Haremos](#qué-haremos)
  - [Características Principales](#características-principales)
- [Configuración Local](#configuración-local)
- [Configuración en GitHub](#configuración-en-github)
  - [Obtener sus Llaves de AWS](#obtener-sus-llaves-de-aws)
  - [Crear Conexión de Servicio de AWS](#crear-conexión-de-servicio-de-aws)
  - [Permitir Push a GitHub](#permitir-push-a-github)
- [Pipeline de Implementación de Infraestructura de AWS](#pipeline-de-implementación-de-infraestructura-de-aws)
  - [Descripción Técnica](#descripción-técnica)
  - [Recursos Desplegados](#recursos-desplegados)
    - [Backend de Terraform](#backend-de-terraform)
    - [Infraestructura Principal](#infraestructura-principal)
- [Cómo Desplegar la Infraestructura](#cómo-desplegar-la-infraestructura)
  - [1. Despliegue Manual](#1-despliegue-manual)
    - [Requisitos Previos (Manual)](#requisitos-previos-manual)
    - [Pasos (Manual)](#pasos-manual)
  - [2. Despliegue Usando el Pipeline de GitHub Actions](#2-despliegue-usando-el-pipeline-de-github-actions)
    - [Requisitos Previos (Pipeline)](#requisitos-previos-pipeline)
    - [Pasos (Pipeline)](#pasos-pipeline)
    - [Qué Hace el Pipeline](#qué-hace-el-pipeline)
  - [Notas](#notas)




# **INTRODUCCIÓN**
Este proyecto se enfoca en el despliegue de infraestructura en AWS utilizando Terraform, con un diseño orientado a garantizar **alta disponibilidad** y **redundancia**. La infraestructura está distribuida en múltiples zonas de disponibilidad (AZs) para maximizar la resiliencia y minimizar los tiempos de inactividad.

<br/>

## Requisitos previos
- [Git instalado](https://www.python.org/downloads/)
- [Cuenta de GitHub activa](https://github.com/)
- [Cuenta de AWS activa](https://aws.amazon.com/)

<br/>

## Que haremos
 Esto incluye la creación de máquinas virtuales para los nodos de Kubernetes, un balanceador de carga para la accesibilidad pública. Automatizaremos la creación de estos recursos con Terraform, desplegaremos la aplicación en Kubernetes, configuraremos la base de datos para alta disponibilidad.

### **Características principales**:

- **Subnets públicas y privadas**: 
- **Escalamiento y balanceo de tráfico**: 
- **Conexión segura mediante Bastion Host**: 
- **Salida a Internet**: 
# **NOTA**
Haga el deploy manualmente ya que no se termino la pipeline

# **CONFIGURACIÓN LOCAL**

Para realizar este despliegue, necesitamos realizar una configuración inicial:

1. Haz un "fork" de este repositorio.
2. Clona el repositorio desde tu "fork":
   ```bash
   git clone [https://github.com/](https://github.com/)<tu-nombre-de-usuario>/kiu-challenge
3. Ir al directorio kiu-challenge
4. Sube tu repositorio personalizado a GitHub:
```bash
git add -A
git commit -m "customized repo"
git push
```
## Obtenga sus llaves de AWS

Estas serán necesarias para que Azure DevOps se conecte a su cuenta de AWS.

1. Abra la consola de IAM en [https://console.aws.amazon.com/iam/](https://console.aws.amazon.com/iam/).
2. En la barra de búsqueda, busque "IAM".
3. En el panel de IAM, seleccione "Usuarios" en el menú de la izquierda. *Si usted es el usuario raíz y no ha creado ningún usuario, encontrará la opción "Crear clave de acceso" en IAM > Mis credenciales de seguridad. Debe saber que ***crear claves de acceso para el usuario raíz es una mala práctica de seguridad***. Si elige continuar de todos modos, haga clic en "Crear clave de acceso" y omita el punto 6*.
4. Elija su nombre de usuario de IAM (no la casilla de verificación).
5. Abra la pestaña "Credenciales de seguridad" y luego elija "Crear clave de acceso".
6. Para ver la nueva clave de acceso, elija "Mostrar". Sus credenciales se parecerán a lo siguiente:
   - ID de clave de acceso: AKIEEEEEEEEEEEEEEEEE<br>
   - Clave de acceso secreta: wJalrXUtnFEMI/K7MDEEEEEEEEEEEEE
7. Copie y guarde estas claves en un lugar seguro.

<br/>

## Crear conexión de servicio de AWS

Esta conexión de servicio es necesaria para que nuestros pipelines de interactúen con AWS.

1. Regrese a GITHUB y abra su proyecto.
2. Vaya a "Configuración del proyecto" en el menú de la izquierda (esquina inferior izquierda).
3. En el menú de la izquierda, debajo de "Pipelines", seleccione "Conexiones de servicio".
4. Haga clic en "Crear conexión de servicio".
5. Seleccione AWS.
6. Pegue su ID de clave de acceso y su clave de acceso secreta.
7. En "Nombre de la conexión de servicio", escriba "aws".
8. Seleccione la opción "Otorgar permiso de acceso a todos los pipelines".
9. Guarde.

<br/>

## PIPELINE DE IMPLEMENTACIÓN DE INFRAESTRUCTURA DE AWS

### Descripción Técnica

Este pipeline despliega la infraestructura base en AWS.

**Tareas:**

1.  **Despliegue de Backend de Terraform:** Utiliza el plugin de Terraform para crear un bucket S3 y una tabla DynamoDB. Estos recursos se usarán para el almacenamiento remoto del estado de Terraform y el bloqueo de estado, facilitando el trabajo en equipo y previniendo conflictos de estado.
2.  **Movimiento del Estado de Terraform:** Mueve el archivo de estado al directorio `/terraform/aws/` para incluir los recursos de backend en la gestión de infraestructura.
3.  **Despliegue de Infraestructura Principal:** Despliega los recursos de networking y un clúster EKS. Adicionalmente, implementa un AWS Load Balancer Controller, que actuará como el Ingress Controller nativo de Kubernetes. Este controlador aprovisionará automáticamente Application Load Balancers de AWS por cada recurso Ingress definido en el clúster.

**Recursos Desplegados:**

* Bucket S3 (para estado de Terraform)
* Tabla DynamoDB (para bloqueo de estado de Terraform)
* Recursos de Networking (VPC, subredes, etc.)
* Clúster EKS
* AWS Load Balancer Controller

**Nota:** Los Application Load Balancers creados automáticamente por el AWS Load Balancer Controller no serán gestionados directamente por Terraform en este pipeline.

Para más detalles sobre los recursos desplegados, consulte los [archivos de Terraform](/terraform/aws).

### **Características principales**:
- **Subnets públicas y privadas**: 
  - Las subnets públicas alojan recursos como balanceadores de carga (Load Balancers) para gestionar el tráfico entrante.
  - Las subnets privadas alojan clústeres y bases de datos, asegurando que estos recursos críticos no sean accesibles directamente desde Internet.
- **Escalamiento y balanceo de tráfico**: 
  - Los balanceadores de carga distribuyen el tráfico entre las zonas de disponibilidad, garantizando un rendimiento óptimo.
  - La infraestructura está diseñada para soportar escalamiento automático.
- **Conexión segura mediante Bastion Host**: 
  - Un Bastion Host permite el acceso seguro a los recursos privados dentro de la VPC.
- **Salida a Internet**: 
  - Las subnets privadas utilizan NAT Gateways para acceder a Internet de manera segura.
  - Las subnets públicas tienen acceso directo a Internet mediante un Internet Gateway.

Además, el proyecto incluye un pipeline de GitHub Actions para automatizar el despliegue, lo que facilita la implementación y el mantenimiento de la infraestructura.

---

## **Recursos Desplegados**

### **Backend de Terraform**
- **DynamoDB Table**: Se utiliza para el bloqueo de estado de Terraform.
  - Nombre: `${var.project}-${var.environment_name}-tf-state-dynamo-db-table`
  - Modo de facturación: `PAY_PER_REQUEST`
  - Llave primaria: `LockID`
- **S3 Bucket**: Almacena el estado remoto de Terraform.
  - Nombre: `${var.project}-${var.environment_name}-tf-state-bucket`
  - ACL: `private`

### **Infraestructura Principal**
- **VPC**: Red principal con un rango CIDR de `10.0.0.0/16`.
- **Subnets**:
  - Subnets públicas y privadas en tres zonas de disponibilidad (AZ-a, AZ-b, AZ-c).
- **Internet Gateway**: Permite el acceso a Internet para las subnets públicas.
- **NAT Gateways**: Permiten que las subnets privadas accedan a Internet.
- **Tablas de Rutas**:
  - Tabla de rutas pública asociada a las subnets públicas.
  - Tablas de rutas privadas asociadas a las subnets privadas.
- **Elastic IPs**: Asociadas a los NAT Gateways.
- **ElastiCache**: Endpoints para bases de datos Redis en diferentes entornos (`dev`, `stage`, `prod`).
- **Bastion Host**: Permite el acceso seguro a los recursos privados dentro de la VPC.

---

## **Cómo Desplegar la Infraestructura**

### **1. Despliegue Manual**

#### **Requisitos Previos**
- Tener instalado:
  - [Terraform](https://www.terraform.io/downloads.html)
  - AWS CLI configurado con credenciales válidas.
- Clonar este repositorio:
  ```bash
  git clone https://github.com/tu-usuario/kiu-challenge.git
  cd kiu-challenge

Pasos
Inicializar y desplegar el backend:

Navega al directorio del backend:
```
cd terraform/backend
```
Inicializa Terraform:
```
terraform init
```
Genera un plan de la infra de deployar
```
terraform plan
```

Aplica la configuración del backend:

Inicializar y desplegar la infraestructura principal:
```
terraform apply -auto-approve
```

Navega al directorio de la infraestructura principal:
```
cd ../aws
```
Inicializa Terraform:
```
terraform init
```
```
terraform apply -auto-approve
```

Aplica la configuración de la infraestructura:

2. Despliegue Usando el Pipeline de GitHub Actions
Requisitos Previos
Configurar los secretos en el repositorio de GitHub:
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AATT_AWS_REGION (Región de AWS)

Pasos
Realiza un push de los cambios al repositorio remoto.
Ve a la pestaña Actions en GitHub.
Selecciona el workflow 00-Deploy AWS infrastructure.
Haz clic en Run workflow para iniciar el despliegue.

Qué Hace el Pipeline
Paso 1: Inicializa y aplica el backend de Terraform.
Paso 2: Copia el estado del backend al directorio de la infraestructura principal.
Paso 3: Inicializa y aplica la infraestructura principal.
Paso 4: Extrae los endpoints de ElastiCache
Paso 5: Guarda un comando SSH para conectarse al bastion host y lo sube como artefacto.

Notas
Asegúrate de que los nombres de los recursos (como el bucket S3) sean únicos para evitar conflictos.
Si un recurso ya existe, puedes importarlo al estado de Terraform utilizando el comando terraform import.
El pipeline automatiza el proceso, pero el despliegue manual puede ser útil para pruebas o depuración.