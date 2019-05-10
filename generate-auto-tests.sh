source ~/.bashrc

set -e

# 1. In the old-subj, get the list of public classes in your subject. Make sure that the jar file used as input to the command contains only your source files and contains no test files.
cd $DT_SUBJ

if [[ ! -e "$SUBJ_NAME-classes" ]]; then
    echo "[DEBUG] Getting list of public classes."
    jar -cf ./$SUBJ_NAME.jar -C classes/ .
    java -cp $DT_LIBS:$DT_TOOLS: edu.washington.cs.dt.util.PublicClassFinder $SUBJ_NAME.jar > $SUBJ_NAME-classes
fi

# 2. In the old-subj, generate the randoop tests. For some of our subjects we noticed that randoop either exited unexpectedly or threw some exceptions and was unable to generate tests.  In those cases, we simply removed the class that is causing the problem from old-subj-classes. See our Experiments caveats page for more details on what we omitted.
echo "[DEBUG] Generating auto tests."
jar -cf ./$SUBJ_NAME.jar -C classes/ .
java -ea -cp $DT_LIBS:$DT_CLASS:$DT_TOOLS_DIR/randoop.jar: randoop.main.Main gentests --classlist=$SUBJ_NAME-classes --outputlimit=5000 --ignore-flaky-tests=true
# 3. Compile the  randoop tests that were generated
mkdir -p randoop/
mv *.java randoop/
cd randoop/

#see if ErrorTest exists, then execute the appropriate compile line
echo "[DEBUG] Compiling auto tests."
count=`ls -1 ErrorTest*.java 2>/dev/null | wc -l`
if [ $count != 0 ];
then
   javac -cp $DT_LIBS:$DT_CLASS:$DT_TOOLS: ErrorTest*.java RegressionTest*.java
else
   javac -cp $DT_LIBS:$DT_CLASS:$DT_TOOLS: RegressionTest*.java
fi

mkdir -p bin
mv *.class ./bin

#get sootTestOutput-auto
cd $DT_SUBJ
# 4. Find the automatically-generated tests in the subject.
echo "[DEBUG] Finding auto tests in the old subject."
bash "$DT_SCRIPTS/find-test-list.sh" old auto
