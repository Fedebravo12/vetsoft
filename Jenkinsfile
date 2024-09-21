pipeline {
    agent any
    environment {
        AZURE_CREDENTIALS = credentials('cc4d1339-92cb-4dde-af11-694937876080')  // Las credenciales de Azure que configuraste en Jenkins
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')  // Credenciales de Docker Hub
        DOCKER_IMAGE = 'germansalinas1994/vetsoft-app'  // Nombre de la imagen en Docker Hub
        DOCKER_TAG = 'latest'  // Etiqueta que siempre será latest
    }
    stages {
        stage('Checkout') {
            steps {
                // Descargar el código desde GitHub
                git branch: 'main', url: 'https://github.com/germansalinas1994/vetsoft'
            }
        }
        stage('Set up Python Virtual Environment') {
            steps {
                // Crear un entorno virtual en el directorio .venv
                sh 'python3 -m venv .venv'
                // Activar el entorno virtual e instalar las dependencias
                sh '. .venv/bin/activate && pip install -r requirements.txt'
            }
        }
        stage('Build and Check') {
            steps {
                // Verificar si la aplicación Django tiene errores usando el comando check
                sh '. .venv/bin/activate && python manage.py check'
            }
        }
        stage('Run Static Test') {
            steps {
                // Ejecutar el análisis estático de código usando el entorno virtual
                sh '. .venv/bin/activate && ruff check'
            }
        }
        stage('Run Unit and Integration Tests') {
            steps {
                // Ejecutar las pruebas unitarias y de integración con cobertura
                sh '. .venv/bin/activate && coverage run --source="./app" --omit="./app/migrations/**" manage.py test app'
            }
        }
        stage('Check Coverage') {
            steps {
                // Verificar que el nivel de cobertura no sea menor al 90%
                sh '. .venv/bin/activate && coverage report --fail-under=90'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    // Autenticarse en Docker Hub
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                    }
                    // // Construir la imagen Docker
                    // sh 'docker build -t $DOCKER_IMAGE:$DOCKER_TAG .'
                    // // Subir la imagen a Docker Hub
                    // sh 'docker push $DOCKER_IMAGE:$DOCKER_TAG'
                }
            }
        }
        stage('Deploy to Azure') {
            steps {
                script {
                    // Desplegar la imagen Docker en Azure App Service
                    withCredentials([azureServicePrincipal(
                        credentialsId: 'cc4d1339-92cb-4dde-af11-694937876080',
                        subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                        clientIdVariable: 'AZURE_CLIENT_ID',
                        clientSecretVariable: 'AZURE_CLIENT_SECRET',
                        tenantIdVariable: 'AZURE_TENANT_ID'
                    )]) {
                        sh '''
                        az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
                        az webapp config container set --name vetsoft-app --resource-group admsistemasinformacion2024 --docker-custom-image-name germansalinas1994/vetsoft-app:latest
                        az webapp restart --name vetsoft-app --resource-group admsistemasinformacion2024
                        '''
                    }
                }
            }
        }
    }
    post {
        success {
            echo 'Todos los tests pasaron con éxito, la imagen Docker se subió a Docker Hub y la aplicación se desplegó en Azure!'
        }
        failure {
            echo 'Hubo fallos en los tests, el build o el despliegue. Por favor revisar los logs.'
        }
    }
}
