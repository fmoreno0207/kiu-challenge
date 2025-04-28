# KIU Challenge - AWS Infrastructure Deployment

Este proyecto se enfoca en el despliegue de infraestructura en AWS utilizando Terraform, con un diseño orientado a garantizar **alta disponibilidad** y **redundancia**. La infraestructura está distribuida en múltiples zonas de disponibilidad (AZs) para maximizar la resiliencia y minimizar los tiempos de inactividad. 

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
Paso 4: Extrae los endpoints de ElastiCache y actualiza los valores en los archivos de configuración de Helm.
Paso 5: Guarda un comando SSH para conectarse al bastion host y lo sube como artefacto.

Notas
Asegúrate de que los nombres de los recursos (como el bucket S3) sean únicos para evitar conflictos.
Si un recurso ya existe, puedes importarlo al estado de Terraform utilizando el comando terraform import.
El pipeline automatiza el proceso, pero el despliegue manual puede ser útil para pruebas o depuración.