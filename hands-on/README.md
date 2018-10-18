# JCasC hands on

## Introduction

Setting up Jenkins is a complex process, as both Jenkins and its plugins require some tuning and configuration, with dozens of parameters to set within the web UI manage section.

Many of the experienced Jenkins users rely on groovy init scripts to customize jenkins and enforce desired state. Those scripts directly invoke Jenkins API and as such can do everything (at your own risk). But they also require you to know Jenkins and its plugins' internals, and to be confident in writing groovy scripts on top of Jenkins API.

[Configuration-as-Code plugin](https://github.com/jenkinsci/configuration-as-code-plugin) has been designed as an opinionated way to configure Jenkins based on human-readable declarative configuration files. Writing such a file should be feasible without being a Jenkins expert, just translating into code a configuration process one is used to executing in the web UI.

And the goal of this hands on session is to show you to start with JCasC and how to not give up :smile:

## What we'll use

* docker (& docker-compose)
* git
  * https://github.com/ewelinawilkosz/praqma-jenkins-casc
  * https://github.com/Praqma/jenkins4casc
  
### jenkins4casc 

jenkins4casc is a simple docker image based on official jenkins image, with setup wizard disabled (via JAVA_OPTS) and JCasC plugin installed (via install-plugins.sh)

### praqma-jenkins-casc

praqma-jenkins-casc is a demo setup with docker-compose and simple support for file based credentials. It uses jenkins4casc and add plugins on top of that.

## How to

1. clone https://github.com/ewelinawilkosz/praqma-jenkins-casc (or fork it, if you want to play with it and keep your changes)

2. Let's have a look at [docker compose.yml](https://github.com/ewelinawilkosz/praqma-jenkins-casc/blob/master/docker-compose.yml)


JcasC supports url as a yaml location, but to make it easier for hands-on session we'll rely on location on disk. In order to make the yaml accessible inside your docker container map the location of your repo to */var/jenkins_conf* folder at you container

```
volumes:
  - jenkins_home:/var/jenkins_home
  - /Users/ewelinawilkosz/praqma/bd_repos/jenkinsci/praqma-jenkins-casc:/var/jenkins_conf
```

Obviously the secrets should be kept in more safe location, but again for this demo purpose I put the in *secrets* folder inside the repository. Please make sure to update the path in *docker-compose.yml*

```
secrets:
  github:
    file: /Users/ewelinawilkosz/praqma/bd_repos/jenkinsci/praqma-jenkins-casc/secrets/github
  adminpw:
    file: /Users/ewelinawilkosz/praqma/bd_repos/jenkinsci/praqma-jenkins-casc/secrets/adminpw
```


3. We good? Let's run this thing!

```
docker-compose up --build
```

4. This configuration (jenkins.yaml in the repo) is pretty basic, and not secure at all. Small steps though, we'll create a user (under `jenkins` root element)

```
securityRealm:
  local:
    allowsSignup: false
    users:
     - id: demoAdmin
       password: ${adminpw}
```

Update your yaml and reload configuration - *Manage Jenkins* -> *Configuration as Code* -> *Reload existing configuration*

How do I know that? What is the right root element, what are the keywords? 

When you add users (Jenkins' own database) you go to `http://127.0.0.1:8080/securityRealm/`. So let's look for `securityRealm` in the documentation. 
Or have a look at `demo` folder in JCasC repository.

5. We have a user, how to manage who&what? (still under `jenkins`)

```
authorizationStrategy:
  globalMatrix:
    grantedPermissions:
      - "Overall/Read:anonymous"
      - "Overall/Administer:authenticated"
```

And yes, we're taking the same journey through documentation, links, demos... 

6. What about those errors at __Manage Jenkins__ subpage?

```
jenkins:
  (...)
  
  crumbIssuer:
    standard:
      excludeClientIPFromCrumb: false      

  remotingSecurity:
    enabled: true
    
security:
  remotingCLI:
    enabled: false
```

Notice we introduce another root element: `security`

7. Credentials 

```
credentials:
  system:
    domainCredentials:
      - credentials:
          - usernamePassword:
              scope: GLOBAL
              id: github
              username: "abcdef"
              password: ${github}
```

8. Anything missing? Oh yes, JOBS!

```
jobs:
  - url: https://raw.githubusercontent.com/Praqma/memory-map-plugin/master/jenkins-pipeline/pipeline.groovy
  - script: >
      multibranchPipelineJob('configuration-as-code') {
          branchSources {
              git {
                  id = 'configuration-as-code'
                  remote('https://github.com/jenkinsci/configuration-as-code-plugin.git')
              }
          }
      }
```

9. What about all the plugins we're using?

Many of them ends up under `unclassified` root element, together with other things - documentation is your friend

```
unclassified:    
  location:
    adminAddress: admin@abcd.com
    url: http://127.0.0.1:8080/
              
  globalLibraries:
    libraries:
      - name: "demo-lib"
        retriever:
          modernSCM:
            scm:
              git:
                remote: "https://github.com/Praqma/praqma-jenkins-casc-shared-lib-demo"

  warnings:
    parsers:
      - name: "Example parser"
        linkName: "Example parser link"
        trendName: "Example parser trend name"
        regexp: "^\\s*(.*):(\\d+):(.*):\\s*(.*)$"
        script: |
          import hudson.plugins.warnings.parser.Warning
          String fileName = matcher.group(1)
          String lineNumber = matcher.group(2)
          String category = matcher.group(3)
          String message = matcher.group(4)
          return new Warning(fileName, Integer.parseInt(lineNumber), "Dynamic Parser", category, message);
        example: "somefile.txt:2:SeriousWarnings:SomethingWentWrong"
```

c


## Where to look for help

* github issues: https://github.com/jenkinsci/configuration-as-code-plugin/issues
* gitter room: https://gitter.im/jenkinsci/configuration-as-code-plugin
