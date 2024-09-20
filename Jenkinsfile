pipeline {
    agent any
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

    }
    post {
        success {
            // Mensaje de éxito si todas las pruebas pasan
            echo 'Todos los test pasaron con éxito!'
        }
        failure {
            // Mensaje de error si alguna prueba falla
            echo 'Hay falla en los test.'
        }
    }
}
