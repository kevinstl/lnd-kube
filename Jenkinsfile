pipeline {

  agent {
    label "jenkins-go"
  }
  environment {
    ORG               = 'kevinstl'
    APP_NAME          = 'lnd-kube'
    CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    NEW_VERSION_LOCAL = 'true'
    DEPLOY_SIMNET     = 'false'
    DEPLOY_REGTEST    = 'false'
    DEPLOY_TESTNET    = 'false'
    DEPLOY_MAINNET    = 'true'
  }
  stages {

    stage('Determine Environment') {
      steps {
        script {
          kubeEnv = sh(returnStdout: true, script: 'echo "${KUBE_ENV}"')
        }
        echo "kubeEnv: ${kubeEnv}"
      }
    }

    stage('CI Build and push snapshot') {
      when {
        branch 'PR-*'
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container('go') {
//          sh "mvn versions:set -DnewVersion=$PREVIEW_VERSION"
          //sh "mvn install"
          //sh "./build.sh container prod verify"
//          sh "./build.sh container prod package"

          sh "make build"

          sh 'export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml'

          sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
        }

        dir ('./charts/preview') {
          container('go') {
            sh "make preview"
            sh "jx preview --app $APP_NAME --dir ../.."
          }
        }
      }
    }

    stage('Prepare Deployments') {
      steps {
        script {
          if (DEPLOY_SIMNET == 'true') {
            prepareBtcdDeployment()
          }
          if (DEPLOY_REGTEST == 'true') {
            prepareBitcoinddDeployment()
          }
          if (DEPLOY_TESTNET == 'true') {
            prepareBtcdDeployment()
          }
          if (DEPLOY_MAINNET == 'true') {
//            prepareBtcdDeployment()
            prepareBitcoinddDeployment()
          }
        }
      }
    }


    stage('Build Release Feature') {
      when {
        branch 'feature-*'
      }
      steps {
        script {
          release(null)
        }
      }
    }

    stage('Build Release Master') {
      when {
        branch 'master'
      }
      steps {
        script {
          release('master')
        }
      }
    }

    stage('Promote to Environments') {
      when {
        anyOf { branch 'master'; branch 'feature-*' }
      }
      steps {
        script {
          if (kubeEnv?.trim() != 'local') {
            promote()
          }
        }
      }
    }

    stage('Deploy Local Simnet') {
      when {
        anyOf { branch 'master'; branch 'feature-*' }
      }
      environment {
        DEPLOY_NAMESPACE = "lightning-kube-simnet"
      }
      steps {
        script {
          if (kubeEnv?.trim() == 'local') {
            if (DEPLOY_SIMNET == 'true') {
              deployLocal("simnet")
            }
          }
        }
      }
    }

    stage('Deploy Local Regtest') {
      when {
        anyOf { branch 'master'; branch 'feature-*' }
      }
      environment {
        DEPLOY_NAMESPACE = "lightning-kube-regtest"
      }
      steps {
        script {
          if (kubeEnv?.trim() == 'local') {
            if (DEPLOY_REGTEST == 'true') {
              deployLocal("regtest")
            }
          }
        }
      }
    }

    stage('Deploy Local Testnet') {
      when {
        anyOf { branch 'master'; branch 'feature-*' }
      }
      environment {
        DEPLOY_NAMESPACE = "lightning-kube-testnet"
      }
      steps {
        script {
          if (kubeEnv?.trim() == 'local') {
            if (DEPLOY_TESTNET == 'true') {
              deployLocal("testnet")
            }
          }
        }
      }
    }

    stage('Deploy Local Mainnet') {
      when {
        anyOf { branch 'master'; branch 'feature-*' }
      }
      environment {
        DEPLOY_NAMESPACE = "lightning-kube-mainnet"
      }
      steps {
        script {
          if (kubeEnv?.trim() == 'local') {
            if (DEPLOY_MAINNET == 'true') {
              deployLocal("mainnet")
            }
          }
        }
      }
    }


    stage('Push Local') {
      steps {
        script {
          if (kubeEnv?.trim() == 'local') {
            container('go') {
              sh "echo branch: ${env.BRANCH_NAME}"
              sh "./push.sh ${env.BRANCH_NAME}"
            }
          }
        }
      }
    }
  }

  post {
    always {
      cleanWs()
    }
    failure {
      input """Pipeline failed.
We will keep the build pod around to help you diagnose any failures.

Select Proceed or Abort to terminate the build pod"""
    }
  }
}

def release(branch) {

  container('go') {
    // ensure we're not on a detached head
    //sh "git checkout master"

    if (branch?.trim()) {
      sh "git checkout $branch"
//      sh "git stash save"
//      sh "git pull -r"
//      sh "git stash apply"
    }

    sh "git config --global credential.helper store"
    sh "jx step git credentials"

    // so we can retrieve the version in later steps
    sh "echo \$(jx-release-version) > VERSION"
//    sh "echo \$(cat ../../VERSION) > VERSION"
//    sh "mvn versions:set -DnewVersion=\$(cat VERSION)"
  }

  dir ('./charts/lnd-kube') {
    if (kubeEnv?.trim() != 'local' || NEW_VERSION_LOCAL == 'true') {
      container('go') {
        sh "pwd"
        sh "ls -al"
        sh "make tag"
      }
    }
  }

  container('go') {
    //sh 'mvn clean deploy'
    //sh "./build.sh container prod verify -DskipTests"

    sh "ls -al"

    //sh "./build.sh container prod package -DskipTests"

//    sh "./build.sh container prod package"

    sh "make build"

    sh 'export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml'

//    sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"

    postBuild()
  }



}

def promote() {

  dir ('./charts/lnd-kube') {

    if (DEPLOY_SIMNET == 'true') {
      promoteNetwork("simnet")
    }

    if (DEPLOY_REGTEST == 'true') {
      promoteNetwork("regtest")
    }

    if (DEPLOY_TESTNET == 'true') {
      promoteNetwork("testnet")
    }

    if (DEPLOY_MAINNET == 'true') {
      promoteNetwork("mainnet")
    }
  }

}

def promoteNetwork(network) {


  container('go') {
    sh 'jx step changelog --version v\$(cat ../../VERSION)'
    // release the helm chart
    sh 'jx step helm release'
    // promote through all 'Auto' promotion Environments
    def promoteCommand = "jx promote --verbose -b --env lightning-kube-${network} --timeout 1h --version \$(cat ../../VERSION)"
//    sh "jx promote --verbose -b --env lightning-kube-${network} --timeout 1h --version \$(cat ../../VERSION)"
    sh "${promoteCommand}"
  }
}


def postBuild() {
  script {
    if (kubeEnv?.trim() != 'local') {
      sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
    }
  }
}

def deployLocal(network) {

  script {

    sh 'echo debug1'

    if (NEW_VERSION_LOCAL == 'true') {
      dir('./charts/lnd-kube') {
        container('go') {
          sh 'jx step helm release'
        }
      }
    }

    sh 'echo debug2'

    sh 'pwd'
    sh 'ls -al'
    sh "git clone https://github.com/kevinstl/environment-jx-lightning-kube-${network}.git"

    sh 'echo debug3'

    def envProjectDir = "./environment-jx-lightning-kube-${network}"
    dir(envProjectDir) {
      container('go') {
        sh 'cat ./env/requirements.yaml'
        sh 'git fetch'
        sh "git checkout local"
        sh "./scripts/replace-version.sh ./env/requirements.yaml \"lnd-kube\" \"  version: \$(cat ../VERSION)\""
        sh 'git add .'
        sh 'git commit -m \"release \$(cat ../VERSION)\"'
        sh 'git push -u origin local'
      }
    }

    def envProjectSubDir = "./environment-jx-lightning-kube-${network}/env"
    dir(envProjectSubDir) {
      container('go') {
        sh 'pwd'
        sh 'ls -al'
        sh 'cat ./requirements.yaml'
        sh 'jx step helm build'
        sh 'jx step helm apply --wait=false'
      }
    }
  }
}

def prepareBtcdDeployment() {
  sh 'cp ./charts/lnd-kube/dynamic-templates/deployment-alice.yaml ./charts/lnd-kube/templates'
  sh 'cp ./charts/lnd-kube/dynamic-templates/deployment-bob.yaml ./charts/lnd-kube/templates'
}

def prepareBitcoinddDeployment() {
  sh 'cp ./charts/lnd-kube/dynamic-templates/deployment-bitcoind-alice.yaml ./charts/lnd-kube/templates'
  sh 'cp ./charts/lnd-kube/dynamic-templates/deployment-bitcoind-bob.yaml ./charts/lnd-kube/templates'
}