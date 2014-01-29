Run tasks thru Drush commands.

Examples:
  bash trigger -t releases -r 0001           Runs the release 0001 task.

Options:
  -t [task]
     The task to be run. e.g. "releases".

  -r [release]
     The release to be run. Depends on -t [task] to be set to "releases"

     options

     [release] an specific release number.

     [all] runs all release scripts after the last logged release script ran.
           Will run all during the first installation.

     [status] provides information, such the last logged release script ran.

  -h [help]
     Provides a list of supported options.


