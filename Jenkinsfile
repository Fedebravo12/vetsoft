pipeline {
    agent any
    environment {
        // ID de las credenciales de Azure configuradas en Jenkins
        AZURE_CREDENTIALS = credentials('cc4d1339-92cb-4dde-af11-694937876080')  // El ID que configuraste en Jenkins
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
        stage('Run Server') {
            steps {
                // Ejecutar el servidor de Django para asegurarse que levanta correctamente
                sh '. .venv/bin/activate && nohup python manage.py runserver &'
                // Esperar un tiempo para asegurarse que el servidor sube correctamente
                sh 'sleep 10'
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
        stage('Deploy to Azure') {
            steps {
                script {
                    // Autenticarse en Azure usando las credenciales configuradas en Jenkins
                    withCredentials([azureServicePrincipal(
                        credentialsId: 'cc4d1339-92cb-4dde-af11-694937876080',  // El ID de tus credenciales en Jenkins
                        subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                        clientIdVariable: 'AZURE_CLIENT_ID',
                        clientSecretVariable: 'AZURE_CLIENT_SECRET',
                        tenantIdVariable: 'AZURE_TENANT_ID'
                    )]) {
                        // Autenticarse en Azure CLI con el Principal de Servicio
                        sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID'

                        // Desplegar la aplicación en Azure App Service
                        sh 'az webapp up --name vetsoft-app --resource-group admsistemasinformacion2024 --sku B1 --runtime "PYTHON|3.12"'
                    }
                }
            }
        }
    }
    post {
        success {
            // Mensaje de éxito si todas las pruebas pasan
            echo 'Todos los test pasaron con éxito y la aplicación se desplegó en Azure!'
        }
        failure {
            // Mensaje de error si alguna prueba falla
            echo 'Hubo fallos en los tests o en el despliegue. Por favor revisar los logs.'
        }
    }
}
