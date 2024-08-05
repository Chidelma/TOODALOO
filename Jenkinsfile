pipeline {
    agent {
        // Use a Docker image with Python 3.11 installed with root access
        docker {
            image 'python:3.11.7'
            args '-u 0'
        }
    }
    stages {
        // Stage to install dependencies within virtualenv
        stage("Install Dependencies") {
            steps {
                sh 'mkdir -p ~/.virtualenvs'
                sh 'python -m venv ~/.virtualenvs/toodaloo'
                sh '. ~/.virtualenvs/toodaloo/bin/activate'
                sh 'python -m pip install --upgrade pip'
                sh 'pip install -r requirements.txt'
            }
        }
        stage('Tests') {
            // When expression is true, the stage is executed, otherwise the build is skipped
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            // Run pytest with coverage report, and fail the build if the coverage is below 80%
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
            // When any of the following commands fail, the build is skipped
            steps {
                sh 'black --check .'
                sh 'isort --check .'
                sh 'ruff check'
            }
        }
        // Stage to build the package
        stage('Build') {
            // build the package and store it in the build/dist directory
            steps {
                sh 'python -m build --wheel --outdir build/dist'
            }
        }
    }
}