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

# 5.  Instrument the source and test files.
echo "[DEBUG] Instrumenting auto tests."
# java -cp $DT_TOOLS:$DT_LIBS:$DT_CLASS:$DT_RANDOOP:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain --soot-cp -inputDir $DT_RANDOOP
java -cp $DT_TOOLS:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain --soot-cp $DT_LIBS:$DT_CLASS:$DT_RANDOOP:$JAVA_HOME/jre/lib/*: -inputDir $DT_RANDOOP
# java -cp $DT_TOOLS:$DT_LIBS:$DT_CLASS:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir $DT_CLASS
java -cp $DT_TOOLS:$DT_LIBS:$DT_CLASS:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir $DT_CLASS --soot-cp $DT_LIBS:$DT_CLASS:$JAVA_HOME/jre/lib/*:

# 6. Run the instrumented tests.
echo "[DEBUG] Running instrumented auto tests."
# Make sure to change directories to the src directory.
# Sometimes tests require that the pwd is a particular directory, and this is usually it.
cd $DT_SUBJ_SRC
echo "[DEBUG] java -cp $DT_TOOLS: edu.washington.cs.dt.impact.Main.RunnerMain -classpath $DT_LIBS:$DT_TOOLS:$DT_SUBJ/sootOutput/: -inputTests $DT_SUBJ/$SUBJ_NAME-auto-order"
java -cp $DT_TOOLS: edu.washington.cs.dt.impact.Main.RunnerMain -classpath $DT_LIBS:$DT_TOOLS:$DT_SUBJ/sootOutput/: -inputTests $DT_SUBJ/$SUBJ_NAME-auto-order
mv sootTestOutput/ $DT_SUBJ/sootTestOutput-auto
cd $DT_SUBJ
rm -rf sootOutput/

# 7. Move auto tests to new subject
# Move auto tests to the new subject/remove the compiled files from the old version
cd $DT_SUBJ
cp -R randoop/ $NEW_DT_SUBJ/
cd $NEW_DT_RANDOOP
rm -rf *.class
cd ..

mkdir -p out
# Only look for the ones with the numbers (the others just reference the files with numbers after them, which messes with everything)
# ErrorTest.java and RegressionTest.java will get compiled later (in "execute the correct javac line..." below)
echo "[DEBUG] Removing incompatible auto tests."
java -cp $DT_TOOLS: edu.washington.cs.dt.impact.tools.FailedTestRemover $NEW_DT_LIBS:$NEW_DT_CLASS:$DT_TOOLS: $(ls | grep -E "[0-9]+\.java$")

# Move the java files from the out dir to the randoop dir
cd out
mv *.java ..
cd ..
rm -rf out/

#execute the correct javac line depending on situation to compile auto tests with NEW_DT_CLASS
tcount=`ls -1 ErrorTest*.java 2>/dev/null | wc -l`
echo "[DEBUG] Compiling auto tests with new subject."
if [ $tcount != 0 ];
then
   javac -cp $NEW_DT_LIBS:$NEW_DT_CLASS:$DT_TOOLS: ErrorTest*.java RegressionTest*.java
else
   javac -cp $NEW_DT_LIBS:$NEW_DT_CLASS:$DT_TOOLS: RegressionTest*.java
fi
mv *.class bin/

# Find the automatically generated tests in the subject.
cd $NEW_DT_SUBJ
echo "[DEBUG] Finding auto tests in new subject."
bash "$DT_SCRIPTS/find-test-list.sh" new auto

