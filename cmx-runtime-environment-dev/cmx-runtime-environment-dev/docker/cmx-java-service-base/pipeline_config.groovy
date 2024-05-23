pipeline_template = 'pipeline'

libraries {
  docker {
    //Project Name in CodeBuild
    dockerImageName = 'cmx-java-service-base'
    dockerFilePath = "docker/cmx-java-service-base"
    dockerImageTag = "latest"
  }
}
