pipeline {

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/germansalinas1994/vetsoft'
            }
        }
        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements-dev.txt'
            }
        }
        stage('Install Playwright') {
            steps {
                sh 'python -m playwright install --with-deps firefox'
            }
        }
        stage('Run Static Test') {
            steps {
                sh 'ruff check'
            }
        }
        stage('Run Unit and Integration Tests') {
            steps {
                sh 'coverage run --source="./app" --omit="./app/migrations/**" manage.py test app'
            }
        }
        stage('Check Coverage') {
            steps {
                sh 'coverage report --fail-under=90'
            }
        }
        stage('Run E2E Tests') {
            steps {
                sh 'python manage.py test functional_tests'
            }
        }
    }
    post {
        success {
            echo 'All tests passed successfully!'
        }
        failure {
            echo 'Some tests failed. Please check the logs.'
        }
    }
}
