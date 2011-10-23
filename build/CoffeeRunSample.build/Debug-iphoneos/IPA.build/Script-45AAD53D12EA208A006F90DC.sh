#!/bin/sh
    if [ $BUILD_STYLE != "AdHoc_Distribution" ]; then

    exit

    fi

    # compress application.

    /bin/mkdir $CONFIGURATION_BUILD_DIR/Payload

    /bin/cp -R $CONFIGURATION_BUILD_DIR/CoffeeRunSample.app $CONFIGURATION_BUILD_DIR/Payload

    /bin/cp images/logo_itunes.png $CONFIGURATION_BUILD_DIR/iTunesArtwork

    cd $CONFIGURATION_BUILD_DIR

    # zip up the HelloWorld directory

    /usr/bin/zip -r CoffeeRunSample.ipa Payload iTunesArtwork
