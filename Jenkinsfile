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
    stage('Build docker image') {
      steps {
        sh 'build --tag docker.io/gigi206/test:latest --label org.label-schema.name="hello_world" --file Dockerfile .'
      }
    }
    stage('Push image') {
      steps {
        sh 'docker push docker.io/gigi206/test'
      }
    }
  }
}