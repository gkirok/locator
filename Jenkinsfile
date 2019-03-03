label = "${UUID.randomUUID().toString()}"
TAG_VERSION
DOCKER_TAG_VERSION
BUILD_FOLDER = "/go"
git_project = "locator"
git_project_user = "gkirok"
git_deploy_user_token = "iguazio-dev-git-user-token"
git_deploy_user_private_key = "iguazio-dev-git-user-private-key"

podTemplate(label: "${git_project}-${label}", inheritFrom: "jnlp-docker") {
    node("${git_project}-${label}") {
        withCredentials([
                string(credentialsId: git_deploy_user_token, variable: 'GIT_TOKEN')
        ]) {
            pipelinex = library(identifier: 'pipelinex@_test_gallz', retriever: modernSCM(
                    [$class       : 'GitSCMSource',
                     credentialsId: git_deploy_user_private_key,
                     remote       : "git@github.com:iguazio/pipelinex.git"])).com.iguazio.pipelinex
            multi_credentials = [pipelinex.DockerRepoDev.ARTIFACTORY_IGUAZIO, pipelinex.DockerRepoDev.DOCKER_HUB, pipelinex.DockerRepoDev.QUAY_IO]

            common.notify_slack {
                github.init_project(git_project, git_project_user, GIT_TOKEN) {
                    stage('prepare sources') {
                        container('jnlp') {
                            dir("${BUILD_FOLDER}/src/github.com/v3io/${git_project}") {
                                git(changelog: false, credentialsId: git_deploy_user_private_key, poll: false, url: "git@github.com:${git_project_user}/${git_project}.git")
                                common.shellc("git checkout ${TAG_VERSION}")
                            }
                        }
                    }

                    stage("build ${git_project} in dood") {
                        container('docker-cmd') {
                            dir("${BUILD_FOLDER}/src/github.com/v3io/${git_project}") {
                                common.shellc("LOCATOR_TAG=${DOCKER_TAG_VERSION} LOCATOR_REPOSITORY='' make build")
                            }
                        }
                    }

                    stage('push') {
                        container('docker-cmd') {
                            dockerx.images_push_multi_registries(["${git_project}:${DOCKER_TAG_VERSION}"], multi_credentials)
                        }
                    }
                }
            }
        }
    }
}
