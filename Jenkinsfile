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
    stage('Build/push docker hub') {
      steps {
        build 'docker'
      }
    }
    stage('xxx') {
      steps {
        dockerNode(image: 'debian') {
          sh 'cat /etc/*version*'
        }
        
      }
    }
  }
}