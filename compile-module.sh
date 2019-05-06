#!/usr/bin/env bash

# Usage: bash compile-module.sh CLASSPATH MODULE_PATH [ROOT_PATH]
# Classpath is a list of files (separated by ':') which should exist after compilation
# MODULE_PATH is the path to compile from first, then will try ROOT_PATH (if exists and different)

CLASSPATH="$1"
MODULE_PATH="$2"
ROOT_PATH="$3"

#if bash "$DT_SCRIPTS/check-compiled.sh" "$CLASSPATH"; then
#    echo "[INFO] Project already compiled, exiting."
#    exit 0
#fi

# Try to compile just the module we need.
(
    # Compile all modules for the current version.
    cd "$ROOT_PATH"
    /home/awshi2/apache-maven/bin/mvn install -Dmavanagaiata.skip=true -Drat.skip=true -Ddependency-check.skip=true -Dcheckstyle.skip=true -Dmaven.javadoc.skip=true -Dmaven-source.skip=true -Dcobertura.skip -DskipTests -pl $(echo $MODULE_PATH | sed "s;$ROOT_PATH;;") -am

    # 2. Gather the dependencies of the old subject for that module.
    cd "$MODULE_PATH"
    /home/awshi2/apache-maven/bin/mvn install -fn -DskipTests -Dmavanagaiata.skip=true -Drat.skip=true -Ddependency-check.skip=true -Dcheckstyle.skip=true -Dmaven.javadoc.skip=true -Dmaven-source.skip=true -Dcobertura.skip dependency:copy-dependencies -Drat.skip=true -Dcobertura.skip

    bash "$DT_SCRIPTS/unsign-jars.sh" "$MODULE_PATH/target/dependency"
) | tee "$DT_SCRIPTS/compile-output/${SUBJ_NAME}-module.txt"

if grep -q "BUILD FAILURE" "$DT_SCRIPTS/compile-output/${SUBJ_NAME}-module.txt"; then
    >&2 echo "[INFO] One or more builds failed. See ${SUBJ_NAME}-module.txt for more information. Trying to compile from root."

    (
        cd "$ROOT_PATH"
        /home/awshi2/apache-maven/bin/mvn compile test-compile -Dmavanagaiata.skip=true -Drat.skip=true -Ddependency-check.skip=true -Dcheckstyle.skip=true -Dmaven.javadoc.skip=true -Dmaven-source.skip=true -Dcobertura.skip

        # 2. Gather the dependencies of the old subject.
        /home/awshi2/apache-maven/bin/mvn install -fn -DskipTests -Dmavanagaiata.skip=true -Drat.skip=true -Ddependency-check.skip=true -Dcheckstyle.skip=true -Dmaven.javadoc.skip=true -Dmaven-source.skip=true -Dcobertura.skip dependency:copy-dependencies -Drat.skip=true -Dcobertura.skip

        bash "$DT_SCRIPTS/unsign-jars.sh" "$MODULE_PATH/target/dependency"
    ) | tee "$DT_SCRIPTS/compile-output/${SUBJ_NAME}-root.txt"

    if grep -q "BUILD FAILURE" "$DT_SCRIPTS/compile-output/${SUBJ_NAME}-root.txt"; then
        >&2 echo "[INFO] Compiling from root failed. See ${SUBJ_NAME}-root.txt for more information."
        exit 1
    fi
fi
