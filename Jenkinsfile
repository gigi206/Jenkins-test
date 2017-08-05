properties([
  parameters([
    string(
      defaultValue: '',
      description: 'Force la version de build à une branche, révision ou tag. Ex : v8.0.0800',
      name: 'BRANCH_NAME'
    )
  ])
])

VERSION = "FAILED"
currentBuild.displayName = VERSION

//https://github.com/jenkinsci/kubernetes-plugin
podTemplate(name: 'jenkins-slave-docker', label: 'jenkins-slave-docker', containers: [
  containerTemplate(name: 'docker', image: 'docker:dind', ttyEnabled: true, alwaysPullImage: false, privileged: true,
    command: 'dockerd --host=unix:///var/run/docker.sock --host=tcp://127.0.0.1:2375'),
  containerTemplate(name: 'debian', image: 'debian:jessie', ttyEnabled: true, alwaysPullImage: false, privileged: false,
    command: 'bash')
],
volumes: [emptyDirVolume(memory: false, mountPath: '/var/lib/docker')]) {
  node ('jenkins-slave-docker') {
    container('debian') {
      stage('Installation des dépendances') {
        sh 'apt-get update -y'
        //sh 'apt-get upgrade -y'
        sh 'apt-get install -y libncurses5-dev libgnome2-dev libgnomeui-dev libgtk2.0-dev libatk1.0-dev libbonoboui2-dev libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev python3-dev ruby-dev lua5.1 lua5.1-dev libperl-dev git'
      }

      VIM_REPOSITORY='https://github.com/vim/vim.git'

      stage ('Téléchargement des sources Github') {
        if (params.BRANCH_NAME != '') {
          VERSION = params.BRANCH_NAME
        }
        else {
          VERSION = sh(returnStdout: true, script: "git ls-remote --tags ${VIM_REPOSITORY} | tail -1 | awk -F'/' '{ print \$NF }'").trim()
        }

        echo "Build Version : ${VERSION}"

        checkout([$class: 'GitSCM',
          branches: [[name: "${VERSION}"]],
          doGenerateSubmoduleConfigurations: false,
          extensions: [[$class: 'LocalBranch']],
          submoduleCfg: [],
          userRemoteConfigs: [[
            //credentialsId: 'gigi206',
            url: "${VIM_REPOSITORY}"
          ]]
        ])
      }

      stage('Configure Build') {
        sh "./configure --prefix=\"${workspace}/${VERSION}\" --with-features=huge --enable-multibyte --enable-rubyinterp=yes --enable-pythoninterp=yes --with-python-config-dir=/usr/lib/python2.7/config --enable-python3interp=yes --with-python3-config-dir=/usr/lib/python3.5/config --enable-perlinterp=yes --enable-luainterp=yes --enable-gui=gtk2 --enable-cscope"
      }

      stage('Install') {
        sh 'make install'
        sh 'src/vim --version'
      }

      def uploadSpec = """{
        "files": [
          {
            "pattern": "*.tar.gz",
            "target": "vim/${VERSION}.tgz"
          }
       ]
      }"""

      stage('Upload Artifact') {
        sh "cd \"${workspace}/${VERSION}\" && tar czf ${VERSION}.tar.gz * && mv ${VERSION}.tar.gz .."
        //archiveArtifacts artifacts: "${VERSION}.tar.gz", excludes: ''

        //def server = Artifactory.newServer url: 'http://nginx/artifactory', username: 'admin', password: 'xxxxxxxxxxxxxxxx'
        def server = Artifactory.newServer url: 'http://nginx/artifactory', credentialsId: 'artifactory'
        def buildInfo = Artifactory.newBuildInfo()
        buildInfo.env.capture = true
        //buildInfo.env.filter.addInclude("*a*")
        //buildInfo.env.filter.addExclude("DONT_COLLECT*")
        buildInfo.retention maxBuilds: 10, doNotDiscardBuilds: ["3"], deleteBuildArtifacts: true

        /*
        def scanConfig = [
          'buildName'      : VIM,
          'buildNumber'    : ${currentBuild.number}
        ]

        def distributionConfig = [
          // Mandatory parameters
          'buildName'             : 'VIM',
          'buildNumber'           : ${currentBuild.number},
          'targetRepo'            : 'vim',
          // Optional parameters
          'publish'               : true, // Default: true. If true, artifacts are published when deployed to Bintray.
          'overrideExistingFiles' : true, // Default: false. If true, Artifactory overwrites builds already existing in the target path in Bintray.
          //'gpgPassphrase'         : 'passphrase', // If specified, Artifactory will GPG sign the build deployed to Bintray and apply the specified passphrase.
          'async'                 : false, // Default: false. If true, the build will be distributed asynchronously. Errors and warnings may be viewed in the Artifactory log.
          "sourceRepos"           : ["yum-local"], // An array of local repositories from which build artifacts should be collected.
          'dryRun'                : false, // Default: false. If true, distribution is only simulated. No files are actually moved.
        ]
        */

        server.upload(uploadSpec)
        server.publishBuildInfo buildInfo
        //server.distribute distributionConfig
      }
    }
  }

  stage('Approval') {
    //timeout(time:5, unit:'DAYS') {
      /*
      emailext (
        subject: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
        body: """<p>SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
        <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""",
        recipientProviders: [[$class: 'DevelopersRecipientProvider']]
      )
      */
      def feedback = input message:'Build container ?', submitter: 'admin', 'ok': "Let's go !"
    //}
  }

  node ('jenkins-slave-docker') {
    registry_url = "https://index.docker.io/v1/" // Docker Hub
    docker_creds_id = "dockerhub" // name of the Jenkins Credentials ID
    build_tag = "${VERSION}" // default tag to push for to the registry

    // Set up the container to build
    maintainer_name = 'gigi206'
    container_name = 'vim-test'

    stage('Download Dockerfile') {
      git url: 'https://github.com/gigi206/Jenkins-test.git'
    }

    def downloadSpec = """{
     "files": [
      {
          "pattern": "vim/${VERSION}.tgz"
        }
     ]
    }"""
    //"pattern": "vim/${VERSION}.tgz",
    //"target": "${workspace}"

    container('docker') {
      stage('Download vim artifact') {
        //def server = Artifactory.newServer url: 'http://nginx/artifactory', username: 'admin', password: 'xxxxxxxxxxxxxxxx'
        def server = Artifactory.newServer url: 'http://nginx/artifactory', credentialsId: 'artifactory'
        server.download(downloadSpec)
        sh "mv ${VERSION}.tgz vim.tgz"
      }

      stage('Building Container') {
        docker.withRegistry("${registry_url}", "${docker_creds_id}") {
          stage('Building container') {
            sh "docker build -t ${maintainer_name}/${container_name}:${build_tag} ."
            //container = docker.build("${maintainer_name}/${container_name}:${build_tag}", '.') //Plugin buggé :'(
          }

          stage("Push image to Dockerhub ${maintainer_name}/${container_name}:${build_tag}") {
            sh "docker push ${maintainer_name}/${container_name}:${build_tag}"
            //container.push() //docker.build buggé
          }
        }
      }
    }
  }
}

currentBuild.displayName = VERSION
