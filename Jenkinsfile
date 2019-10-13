label = "${UUID.randomUUID().toString()}"
git_project = "locator"
git_project_user = "gkirok"
git_deploy_user_token = "iguazio-prod-git-user-token"
git_deploy_user_private_key = "iguazio-prod-git-user-private-key"

podTemplate(label: "${git_project}-${label}", inheritFrom: "jnlp-docker-golang") {
    node("${git_project}-${label}") {
        pipelinex = library(identifier: 'pipelinex@pr', retriever: modernSCM(
                [$class       : 'GitSCMSource',
                 credentialsId: git_deploy_user_private_key,
                 remote       : "git@github.com:iguazio/pipelinex.git"])).com.iguazio.pipelinex
        common.notify_slack {
            withCredentials([
                    string(credentialsId: git_deploy_user_token, variable: 'GIT_TOKEN')
            ]) {
                github.release(git_project, git_project_user, GIT_TOKEN) {
                    stage('prepare sources') {
                        container('jnlp') {
                            dir("${github.BUILD_FOLDER}/src/github.com/v3io/${git_project}") {
                                git(changelog: false, credentialsId: git_deploy_user_private_key, poll: false, url: "git@github.com:${git_project_user}/${git_project}.git")
                                common.shellc("git checkout ${github.TAG_VERSION}")
                            }
                        }
                    }

                    stage("build ${git_project} in dood") {
                        container('docker-cmd') {
                            dir("${github.BUILD_FOLDER}/src/github.com/v3io/${git_project}") {
                                common.shellc("LOCATOR_TAG=${github.DOCKER_TAG_VERSION} LOCATOR_REPOSITORY='' make build")
                            }
                        }
                    }

                    stage('push') {
                        container('docker-cmd') {
                            dockerx.images_push_multi_registries(["${git_project}:${github.DOCKER_TAG_VERSION}"], [pipelinex.DockerRepoDev.ARTIFACTORY_IGUAZIO, pipelinex.DockerRepoDev.DOCKER_HUB, pipelinex.DockerRepoDev.QUAY_IO])
                        }
                    }
                }

                github.pr(git_project, git_project_user, GIT_TOKEN) {
                    stage('prepare sources') {
                        container('jnlp') {
                            dir("${github.BUILD_FOLDER}/src/github.com/v3io/${git_project}") {
                                git(changelog: false, credentialsId: git_deploy_user_private_key, poll: false, url: "git@github.com:${git_project_user}/${git_project}.git")
                                common.shellc("git checkout ${github.PR_COMMIT}")
                            }
                        }
                    }

                    stage("build ${git_project} in dood") {
                        container('golang') {
                            dir("${github.BUILD_FOLDER}/src/github.com/v3io/${git_project}") {
                                common.shellc("LOCATOR_TAG=pr${env.CHANGE_ID} LOCATOR_REPOSITORY='' make lint")
                            }
                        }
                    }
                }
            }
        }
    }
}
