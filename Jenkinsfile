pipeline {
  agent any
  stages {
    stage('echo') {
      steps {
        echo 'Hey, my first pimeline'
      }
    }
        stage('Build image') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */

        app = docker.build(".")
    }

  }
}
