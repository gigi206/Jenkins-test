pipeline {
  agent any
  stages {
    stage('echo') {
      steps {
        echo 'Hey, my first pimeline'
      }
    }
    stage('Get sources') {
      steps {
        git 'https://github.com/docker/dockercloud-hello-world.git'
      }
    }
  }
}