#!/bin/bash
#===============================================================================
#
#        FILE: trigger
# DESCRIPTION: this bash file must be executed from the root of a Drupal
#              installation.
#===============================================================================

#-------------------------------------------------------------------------------
#  includes
#-------------------------------------------------------------------------------
source sites/all/scripts/tasks/includes/paths
source sites/all/scripts/tasks/includes/variables



#-------------------------------------------------------------------------------
#  run tasks
#-------------------------------------------------------------------------------
while getopts ":t:h" OPTION; do
  case $OPTION in
    t)
      #--------------
      #  RELEASE TASK
      #--------------

      if [ "$OPTARG" == "releases" ]; then

        TASK=$OPTARG

        while getopts ":r:" TR
        do
          case $TR in
            r)
              RELEASE=$OPTARG

              if [ "$RELEASE" == "all" ]; then
                echo -e "\033[36mNOTICE:\033[0m releases less than the current release will be skipped." >&2
                for f in $TASKS_PATH/releases/*.rse;
                  do
                    RELEASE_NORM=`echo ${f//[^0-9]/}`
                    ./$f -r $RELEASE_NORM
                done
                exit

              elif [ "$RELEASE" == "status" ]; then
                $DRUSH vget $VGET_RELEASE
                exit

              elif [ "$RELEASE" == "update" ]; then
                VGET=`$DRUSH vget $VGET_RELEASE`
                CURRENT_RELEASE=`echo ${VGET//[^0-9]/}`
                CURRENT_RELEASE=`printf %04d ${CURRENT_RELEASE%}`

                echo -e "\033[36mNOTICE:\033[0m updating your installation to the most current release." >&2

                declare -a RSE_FILES
                RSE_FILES=($TASKS_PATH/releases/*.rse)
                pos=$(( ${#RSE_FILES[*]} - 1 ))
                last=${RSE_FILES[$pos]}

                for f in "${RSE_FILES[@]}"; do
                  if [[ $f == $last ]]; then
                    RELEASE_UPDATE_COMPLETE="TRUE"
                  fi
                  RELEASE_NORM=`echo ${f//[^0-9]/}`
                  if [ $RELEASE_NORM -ge $CURRENT_RELEASE ]; then
                    ./$f -r $RELEASE_NORM -l $RELEASE_UPDATE_COMPLETE
                  fi
                done

                exit
              fi
              ;;
            :)
              echo -e "\033[31mWARNING:\033[0m option -$OPTARG requires an argument." >&2
              exit 1
              ;;
            ?)
              echo -e "\033[31mERROR:\033[0m Invalid option: -$OPTARG" >&2
              more $TASKS_PATH/releases/includes/help
              exit
              ;;
          esac
        done

        if [ -z $RELEASE ]; then
          echo -e "\033[31mERROR:\033[0m The \033[1mreleases\033[0m tasks requires a release number to be run." >&2
          exit
        fi

        if [ ! -f $TASKS_PATH/$TASK/$RELEASE.rse ]; then
          echo -e "\033[31mERROR:\033[0m The release $RELEASE.rse was not found." >&2
          exit
        fi

        ./$TASKS_PATH/$TASK/$RELEASE.rse -r $RELEASE

      #------------------
      #  INTALLATION TASK
      #------------------

      elif [ "$OPTARG" == "install" ]; then

        id -u

        if [[ $(/usr/bin/id -u) -ne 0 ]]; then
          echo "Not running as root"
          exit
        fi

        while getopts ":u:p:n:" DB_CONFIG; do
          case $DB_CONFIG in
            u) DB_USER=$OPTARG ;;
            p) DB_PASS=$OPTARG ;;
            n) DB_NAME=$OPTARG ;;
            \?)
              echo "Invalid option: -$OPTARG" >&2
              ;;
            :)
              echo "Option -$OPTARG requires an argument." >&2
              exit 1
              ;;
            h)
              echo -e `cat $TASKS_PATH/install/includes/help` >&2
              exit
              ;;
          esac
        done

        if [[ -z $DB_USER ]] || [[ -z $DB_NAME ]]; then
          more $TASKS_PATH/install/includes/help
          exit
        fi

        cp sites/default/default.settings.php sites/default/settings.php

        $DRUSH si minimal --db-url=mysql://$DB_USER:$DB_PASS@localhost/$DB_NAME
        $DRUSH upwd admin --password="admin"

        cat sites/all/scripts/settings.php/local.settings.php >> sites/default/settings.php
exit
        # run all the releases
        ./$TASKS_PATH/trigger -t releases -r update

        mkdir $FILES_PATH/cache
        echo "cache dir created in $FILES_PATH"
        mkdir $FILES_PATH/cache/third_party_mod
        echo "third_party_mod dir created in $FILES_PATH"

      fi
      ;;
    :)
      echo -e "\033[31mWARNING:\033[0m option -$OPTARG requires an argument." >&2
      exit 1
      ;;
    h)
      more $TASKS_PATH/includes/help
      exit
      ;;
    ?)
      echo -e "\033[31mERROR:\033[0m Invalid option: -$OPTARG" >&2
      more $TASKS_PATH/includes/help
      exit
      ;;
  esac
done

exit

