#!/bin/bash
################################################################################
#
#	Step 1: Generate javascript to require and compile all templates.
#   This code gets executed only when JS_BUILD equals to false
#
#   Step 2: Compile the same tempaltes for faster loading times.
#   Pre-compiled templates get evaluated only when JS_BUILD equals to true
#
#   Dependencies:
#   https://github.com/npm/npm
#   https://github.com/gabrielgrant/node-ember-precompile
#
################################################################################


# Define globals
ROOT_DIR=""
OUT_PATH=""
FILE_COUNT=""
TEMPLATES_DIR="src/mist/io/static/js/app/templates"


################################################################################
#  Function: setupPaths
#  Description: Use some logic to determine the root dir of mist.io project.
#    Then get templates' directory and set the path of the output file
#  Parameters:
#    $1 -> Explicitly define the root directory of mist.io project (optional)
setupPaths(){

    if [ "$1" ]
    then
        ROOT_DIR="$1"
    else
        IS_CORE=`pwd | grep mist.core`
        if [ "$IS_CORE" ]
        then
            ROOT_DIR=`eval pwd | sed 's%mist.core.*%mist.core/src/mist.io%g'`
        else
            ROOT_DIR=`eval pwd | sed 's%mist.io.*%mist.io%g'`
        fi
    fi

    TEMPLATES_DIR="$ROOT_DIR/$TEMPLATES_DIR"
    OUT_PATH="$TEMPLATES_DIR/templates.js"
    FILE_COUNT=`eval ls -l $TEMPLATES_DIR | grep .html | wc -l | tr -d ' '`
}


################################################################################
#  Function: generateScript
#  Description: Implement step 1, as described in the header of this file
#  Parameters: None
generateScript(){

    echo "Step 1:"

    # Define templates file and require ember.js
    echo "define('app/templates/templates', ['ember'], function() {" > $OUT_PATH

    # Return a function to be called when the app needs to load the templates
    echo "  return function (callback) {" >> $OUT_PATH

    # Make sure the script doesn't run when JS_BUILD is true
    echo "    if (!JS_BUILD) {" >> $OUT_PATH

    # Require all html files
    echo "      require([" >> $OUT_PATH

    i=0
    for f in $TEMPLATES_DIR"/"*.html
    do
        i=$((i + 1))
        echo -ne "\r  Generating require parameters ($i/$FILE_COUNT)"
        echo "        'text!app/templates/""$(basename $f)""'," >> $OUT_PATH
    done

    # Generate template compilation statements
    echo ""
    echo "      ], function () {" >> $OUT_PATH

    i=0
    for f in $TEMPLATES_DIR"/"*.html
    do
        i=$((i + 1))
        echo -ne "\r  Generating compilation statements ($i/$FILE_COUNT)"
        filename=$(basename "$f")
        filename="${filename%.*}"
        var="Ember.TEMPLATES['$filename/html']"
        value="Ember.Handlebars.compile(arguments[$i]);"
        echo "        $var = $value" >> $OUT_PATH
    done

    # Terminate script
    echo "        callback();
      });
      return;
    }" >> $OUT_PATH

    echo ""
}


################################################################################
#  Function: generateScript
#  Description: Implements step 2, as described in the header of this file
#  Parameters: None
compileTemplates(){

    echo "Step 2:"

    # Compile templates
    i=0
    for f in $TEMPLATES_DIR"/"*.html
    do
        i=$((i + 1))
        echo -ne "\r  Compiling template: ($i/$FILE_COUNT)"
        ember-precompile "$f" >> $OUT_PATH
    done

    # Terminate file
    echo "callback();
}
});" >> $OUT_PATH

    echo ""
}


main(){
    setupPaths $@
    generateScript
    compileTemplates
}

main $@
