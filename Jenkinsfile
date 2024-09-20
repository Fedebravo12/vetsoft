pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                // Descargar el código desde GitHub
                git branch: 'main', url: 'https://github.com/germansalinas1994/vetsoft'
            }
        }
        stage('Install Dependencies') {
            steps {
                // Instalar las dependencias listadas en requirements.txt
                sh 'python3 -m pip install -r requirements.txt'
            }
        }
        stage('Run Static Test') {
            steps {
                // Ejecutar pruebas de estilo de código, si estás usando Ruff
                sh 'ruff check'
            }
        }
        stage('Run Unit and Integration Tests') {
            steps {
                // Ejecutar las pruebas unitarias y de integración con cobertura
                sh 'coverage run --source="./app" --omit="./app/migrations/**" manage.py test app'
            }
        }
        stage('Check Coverage') {
            steps {
                // Verificar que el nivel de cobertura sea mayor al 90%
                sh 'coverage report --fail-under=90'
            }
        }
        stage('Run E2E Tests') {
            steps {
                // Ejecutar pruebas end-to-end
                sh 'python3 manage.py test functional_tests'
            }
        }
    }
    post {
        success {
            // Mensaje de éxito si todas las pruebas pasan
            echo 'All tests passed successfully!'
        }
        failure {
            // Mensaje de error si alguna prueba falla
            echo 'Some tests failed. Please check the logs.'
        }
    }
}
