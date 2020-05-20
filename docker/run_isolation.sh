#!/usr/bin/env bash

echo "*******************ISOLATION************************"
echo "Starting run_isolation.sh"

# This script is run inside the Docker image, for single experiment (one project)
# Should only be invoked by the run_experiment.sh script

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]] || [[ $4 == "" ]] || [[ $5 == "" ]]; then
    echo "arg1 - GitHub SLUG"
    echo "arg2 - Module"
    echo "arg3 - New commit"
    echo "arg4 - Old commit"
    echo "arg5 - Timeout in seconds"
    echo "arg6 - Test type (Optional)"
    echo "arg7 - Technique (Optional)"
    exit
fi

slug=$1
module=$2
newcommit=$3
oldcommit=$4
timeout=$5


# Run the plugin, get module test times
echo "Running the isolation for tests"
cd /home/awshi2/${slug}/
git rev-parse HEAD
date

export PATH=/home/awshi2/apache-maven/bin:${PATH}
cd /home/awshi2/

echo "================ Setting up old commit"
modifiedslug=${slug//\//.}
cd /home/awshi2/
if [[ ${module} == '.' ]]; then
    name=${modifiedslug}
else
    name=${modifiedslug}-$(basename ${module})
fi
wget http://mir.cs.illinois.edu/awshi2/dt-impact/${name}.zip
unzip ${name}.zip
owner=$(echo ${slug} | cut -d'/' -f1)
projname=$(echo ${slug} | cut -d'/' -f2)
mv ${name}/${projname}-old-* /home/awshi2/${owner}/
cd /home/awshi2/${owner}/${projname}-old-$oldcommit

cd $module
echo "================ extract_test_names_from_maven_output.sh"
wget http://mir.cs.illinois.edu/winglam/dt-impact-isolation/${name}-tests-isolation.txt

pip install BeautifulSoup4
pip install lxml

MVNOPTIONS="-Ddependency-check.skip=true -Dgpg.skip=true -DfailIfNoTests=false -Dskip.installnodenpm -Dskip.npm -Dskip.yarn -Dlicense.skip -Dcheckstyle.skip -Drat.skip -Denforcer.skip -Danimal.sniffer.skip -Dmaven.javadoc.skip -Dfindbugs.skip -Dwarbucks.skip -Dmodernizer.skip -Dimpsort.skip -Dmdep.analyze.skip -Dpgpverify.skip -Dxml.skip"

wget http://mir.cs.illinois.edu/winglam/personal/parse_surefire_report-a281abbecbac34c5de4d68e87d921ddd8f49c8c6.py -O parse_surefire_report.py

total=$(wc -l ${name}-tests-isolation.txt)
i=1
echo "" > test-results.csv
for t in $(cat ${name}-tests-isolation.txt); do
    echo "Running test: $t"
    echo "Iteration: $i / $total"
    find -name "TEST-*.xml" -delete

    formatTest="$(echo $t | rev | cut -d. -f2 | rev)#$(echo $t | rev | cut -d. -f1 | rev )"
    echo "Test name is given. Running isolation on the specific test: $formatTest"
    testarg="-Dtest=$formatTest"

    /home/awshi2/apache-maven/bin/mvn test ${testarg} ${MVNOPTIONS} |& tee mvn-test-$i.log
    for f in $(find -name "TEST*.xml"); do python /home/awshi2/dt-fixing-tools/scripts/python-scripts/parse_surefire_report.py $f $i; done >> test-results.csv

    mkdir -p /home/awshi2/isolation/$i
    mv mvn-test-$i.log /home/awshi2/isolation/$i
    for f in $(find -name "TEST*.xml"); do mv $f /home/awshi2/isolation/$i; done
    i=$((i + 1))
done

echo "================ Saving outputs"
RESULTSDIR=/home/awshi2/output/
mkdir -p ${RESULTSDIR}

mv /home/awshi2/isolation ${RESULTSDIR}

echo "*******************PRADET************************"
echo "Finished run_isolation.sh"
date
