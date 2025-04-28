# KIU Challenge - AWS Infrastructure Deployment

Este proyecto contiene la configuración necesaria para desplegar una infraestructura en AWS utilizando Terraform. La infraestructura incluye recursos como una VPC, subnets públicas y privadas, gateways, tablas de rutas, y servicios como DynamoDB y S3 para el backend de Terraform. Además, se incluye un pipeline de GitHub Actions para automatizar el despliegue.

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
  ```

#### **Pasos**
1. **Inicializar y desplegar el backend**:
   - Navega al directorio del backend:
     ```bash
     cd terraform/backend
     ```
   - Inicializa Terraform:
     ```bash
     terraform init
     ```
   - Aplica la configuración del backend:
     ```bash
     terraform apply -auto-approve
     ```

2. **Inicializar y desplegar la infraestructura principal**:
   - Navega al directorio de la infraestructura principal:
     ```bash
     cd ../aws
     ```
   - Copia el archivo de estado del backend:
     ```bash
     cp ../backend/terraform.tfstate .
     ```
   - Inicializa Terraform:
     ```bash
     terraform init -force-copy
     ```
   - Aplica la configuración de la infraestructura:
     ```bash
     terraform apply -auto-approve
     ```

---

### **2. Despliegue Usando el Pipeline de GitHub Actions**

#### **Requisitos Previos**
- Configurar los secretos en el repositorio de GitHub:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AATT_AWS_REGION` (Región de AWS)

#### **Pasos**
1. Realiza un push de los cambios al repositorio remoto.
2. Ve a la pestaña **Actions** en GitHub.
3. Selecciona el workflow `00-Deploy AWS infrastructure`.
4. Haz clic en **Run workflow** para iniciar el despliegue.

#### **Qué Hace el Pipeline**
- **Paso 1**: Inicializa y aplica el backend de Terraform.
- **Paso 2**: Copia el estado del backend al directorio de la infraestructura principal.
- **Paso 3**: Inicializa y aplica la infraestructura principal.
- **Paso 4**: Extrae los endpoints de ElastiCache y actualiza los valores en los archivos de configuración de Helm.
- **Paso 5**: Guarda un comando SSH para conectarse al bastion host y lo sube como artefacto.

---

## **Notas**
- Asegúrate de que los nombres de los recursos (como el bucket S3) sean únicos para evitar conflictos.
- Si un recurso ya existe, puedes importarlo al estado de Terraform utilizando el comando `terraform import`.
- El pipeline automatiza el proceso, pero el despliegue manual puede ser útil para pruebas o depuración.



