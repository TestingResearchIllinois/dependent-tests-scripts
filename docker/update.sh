#!/bin/bash

# Script that updates Git repositories of tooling code to latest and rebuilds

cd /home/awshi2/testrunner/ && git pull && /home/awshi2/apache-maven/bin/mvn clean install -B
cd /home/awshi2/dependent-tests-scripts/ && git pull
cd /home/awshi2/dependent-tests-impact/ && git pull && /home/awshi2/apache-maven/bin/mvn clean install -B
