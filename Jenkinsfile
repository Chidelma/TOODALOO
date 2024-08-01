pipeline {
    agent any
    stages {
        stage("Install Dependencies") {
            steps {
                sh 'sudo apt install libpq-dev python3-dev -y'
                sh 'pip install -r requirements.txt'
            }
        }
        stage('Tests') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh 'pytest --cov-fail-under=80'
            }
        }
        stage('Code Analysis') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh 'black --check .'
                sh 'isort --check .'
                sh 'ruff check'
            }
        }
        stage('Build') {
            steps {
                sh 'python -m build --wheel --outdir build/dist'
            }
        }
    }
}