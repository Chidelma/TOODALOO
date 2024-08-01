pipeline {
    agent {
        docker {
            image 'python:3.11.7'
            args '-u 0'
        }
    }
    stages {
        stage("Install Dependencies") {
            steps {
                sh 'python -m pip install --upgrade pip'
                sh 'mkdir -p ~/.virtualenvs'
                sh 'python -m venv ~/.virtualenvs/toodaloo'
                sh 'source ~/.virtualenvs/toodaloo/bin/activate'
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