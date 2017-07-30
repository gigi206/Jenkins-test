currentBuild.displayName = 'FAILED'

node('gigix-jenkins-jenkins-slave') {
    stage('Installation des dépendances') {
        sh 'apt-get update -y'
        //sh 'apt-get upgrade -y'
        sh 'apt-get install -y libncurses5-dev libgnome2-dev libgnomeui-dev libgtk2.0-dev libatk1.0-dev libbonoboui2-dev libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev python3-dev ruby-dev lua5.1 lua5.1-dev libperl-dev git'
        }

    stage ('Téléchargement des sources Github') {
        if (params.BRANCH_NAME) {
            VERSION = params.BRANCH_NAME
        }
        else {
            VERSION = sh(returnStdout: true, script: 'git ls-remote --tags https://github.com/vim/vim.git | tail -1 | awk -F\'/\' \'{ print $NF }\'').trim()
        }

        echo "Build Version : ${VERSION}"

        checkout([$class: 'GitSCM',
            branches: [[name: 'master']],
            doGenerateSubmoduleConfigurations: false,
            extensions: [[$class: 'LocalBranch']],
            submoduleCfg: [],
            userRemoteConfigs: [[
//                credentialsId: 'gigi206',
                url: 'https://github.com/vim/vim.git']]])
    }

    stage('Configure Build') {
        sh "./configure --prefix=`pwd`/${VERSION} --with-features=huge --enable-multibyte --enable-rubyinterp=yes --enable-pythoninterp=yes --with-python-config-dir=/usr/lib/python2.7/config --enable-python3interp=yes --with-python3-config-dir=/usr/lib/python3.5/config --enable-perlinterp=yes --enable-luainterp=yes --enable-gui=gtk2 --enable-cscope"
    }

    stage('Install') {
        sh 'make install'
        sh 'src/vim --version'
    }
        
    stage('Binaires') {
        sh "cd ${VERSION} && tar czf ${VERSION}.tar.gz * && mv ${VERSION}.tar.gz .."
        archiveArtifacts artifacts: "${VERSION}.tar.gz", excludes: ''
    }
}

stage('Approval') {
    timeout(time:5, unit:'DAYS') {
    /*
    emailext (
        subject: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
        body: """<p>SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
        <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""",
        recipientProviders: [[$class: 'DevelopersRecipientProvider']]
    )
    */
        def feedback = input message:'Approve deployment ?', submitter: 'admin', 'ok': "Let's go !"
    }
}

stage('Archivage sur le FTP') {
    node('gigix-jenkins-jenkins-slave') {
        echo "Envoie de ${VERSION}.tar.gz sur le FTP"
    }
}

//currentBuild.displayName = "V" + (currentBuild.number + offset)
currentBuild.displayName = VERSION
