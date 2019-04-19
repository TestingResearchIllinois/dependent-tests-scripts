#!/bin/bash

# Script that updates Git repositories of tooling code to latest and rebuilds

cd /home/awshi2/testrunner/ && git pull && /home/awshi2/apache-maven/bin/mvn clean install -B
cd /home/awshi2/dependent-tests-scripts/ && git pull
cd /home/awshi2/dependent-tests-scripts/ && mvn install:install-file -Dfile=impact-tools/dtdetector-1.2.0.jar -DgroupId=edu.washington.cs.dt -DartifactId=dtdetector -Dversion=1.2.0 -Dpackaging=jar
cd /home/awshi2/dependent-tests-impact/ && git pull && /home/awshi2/apache-maven/bin/mvn clean install -DskipTests -B
cp dt-impact-tracer/target/dt-impact-tracer-1.0.5.3.jar /home/awshi2/dependent-tests-scripts/impact-tools/
