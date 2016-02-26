#!/bin/bash

# This variant of the lein script is meant for downstream packagers.
# It has all the cross-platform stuff stripped out as well as the
# logic for running from a source checkout and self-install/upgrading.

export LEIN_VERSION="2.6.1"

if [ "$(whoami)" = "root" ] && [ "$LEIN_ROOT" = "" ]; then
    echo "WARNING: You're currently running as root; probably by accident."
    echo "Press control-C to abort or Enter to continue as root."
    echo "Set LEIN_ROOT to disable this warning."
    read _
fi

# cd to the project root, if applicable
NOT_FOUND=1
ORIGINAL_PWD="$PWD"
while [ ! -r "$PWD/project.clj" ] && [ "$PWD" != "/" ] && [ $NOT_FOUND -ne 0 ]; do
    cd ..
    if [ "$(dirname "$PWD")" = "/" ]; then
        NOT_FOUND=0
        cd "$ORIGINAL_PWD"
    fi
done

# Support $JAVA_OPTS for backwards-compatibility.
JVM_OPTS=${JVM_OPTS:-"$JAVA_OPTS"}
JAVA_CMD=${JAVA_CMD:-"java"}

# User init
export LEIN_HOME="${LEIN_HOME:-"$HOME/.lein"}"

for f in "/etc/leinrc" "$LEIN_HOME/leinrc" ".leinrc"; do
    if [ -e "$f" ]; then
        source "$f"
    fi
done

export LEIN_JVM_OPTS="${LEIN_JVM_OPTS-"-XX:+TieredCompilation -XX:TieredStopAtLevel=1"}"

grep -E -q '^\s*:eval-in\s+:classloader\s*$' project.clj 2> /dev/null &&
LEIN_JVM_OPTS="${LEIN_JVM_OPTS:-'-Xms64m -Xmx512m'}"

# If you're not using an uberjar you'll need to list each dependency
# and add them individually to the classpath/bootclasspath as well.

LEIN_JAR=/var/vcap/packages/leiningen-$LEIN_VERSION/leiningen-$LEIN_VERSION-standalone.jar

# Do not use installed leiningen jar during self-compilation
if ! { [ "$1" = "compile" ] &&
        grep -qsE 'defproject leiningen[[:space:]]+"[[:digit:].]+"' \
            project.clj ;}; then
    CLASSPATH="$CLASSPATH":"$LEIN_JAR"
    BOOTCLASSPATH="-Xbootclasspath/a:$LEIN_JAR"
fi

# apply context specific CLASSPATH entries
if [ -f .lein-classpath ]; then
    CLASSPATH="$(cat .lein-classpath):$CLASSPATH"
fi

if [ -n "$DEBUG" ]; then
    echo "Leiningen's classpath: $CLASSPATH"
fi

# Which Java?

export JAVA_CMD="${JAVA_CMD:-"java"}"
export LEIN_JAVA_CMD="${LEIN_JAVA_CMD:-$JAVA_CMD}"

if [[ "$(basename "$LEIN_JAVA_CMD")" == *drip* ]]; then
    export DRIP_INIT="$(printf -- '-e\n(require (quote leiningen.repl))')"
fi

# Support $JAVA_OPTS for backwards-compatibility.
export JVM_OPTS="${JVM_OPTS:-"$JAVA_OPTS"}"

function command_not_found {
    >&2 echo "Leiningen coundn't find $1 in your \$PATH ($PATH), which is required."
    exit 1
}

if ([ "$LEIN_FAST_TRAMPOLINE" != "" ] || [ -r .lein-fast-trampoline ]) &&
    [ -r project.clj ]; then
    INPUTS="$* $(cat project.clj) $(test -f "$LEIN_HOME/profiles.clj" && cat "$LEIN_HOME/profiles.clj")"

    if command -v shasum >/dev/null 2>&1; then
        SUM="shasum"
    elif command -v sha1sum >/dev/null 2>&1; then
        SUM="sha1sum"
    else
        command_not_found "sha1sum or shasum"
    fi

    INPUT_CHECKSUM=$(echo "$INPUTS" | $SUM | cut -f 1 -d " ")
    # Just don't change :target-path in project.clj, mkay?
    TRAMPOLINE_FILE="target/trampolines/$INPUT_CHECKSUM"
else
    TRAMPOLINE_FILE="/var/vcap/data/tmp/lein-trampoline-$$"
    trap "rm -f $TRAMPOLINE_FILE" EXIT
fi

if [ "$1" = "upgrade" ]; then
    echo "This version of Leiningen was installed with a package manager, but"
    echo "the upgrade task is intended for manual installs. Please use your"
    echo "package manager's built-in upgrade facilities instead."
    exit 1
fi

if [ "$INPUT_CHECKSUM" != "" ] && [ -r "$TRAMPOLINE_FILE" ]; then
    if [ -n "$DEBUG" ]; then
        echo "Fast trampoline with $TRAMPOLINE_FILE."
    fi
    exec sh -c "exec $(cat $TRAMPOLINE_FILE)"
else
    export TRAMPOLINE_FILE
    "$LEIN_JAVA_CMD" \
        "${BOOTCLASSPATH[@]}" \
        -Dfile.encoding=UTF-8 \
        -Dmaven.wagon.http.ssl.easy=false \
        -Dmaven.wagon.rto=10000 \
        $LEIN_JVM_OPTS \
        -Dleiningen.original.pwd="$ORIGINAL_PWD" \
        -Dleiningen.script="$0" \
        -classpath "$CLASSPATH" \
        clojure.main -m leiningen.core.main "$@"

    EXIT_CODE=$?

    if [ -r "$TRAMPOLINE_FILE" ] && [ "$LEIN_TRAMPOLINE_WARMUP" = "" ]; then
        TRAMPOLINE="$(cat $TRAMPOLINE_FILE)"
        if [ "$INPUT_CHECKSUM" = "" ]; then
            rm $TRAMPOLINE_FILE
        fi
        exec sh -c "exec $TRAMPOLINE"
    else
        exit $EXIT_CODE
    fi
fi
