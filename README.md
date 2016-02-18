git-updater
===========

Peridically update a directory from a git repository.

This container is useful to maintain an up to date set of files in a
directory (or volume of another container), without teaching another
application how to understand GIT.


Usage
=====

     usage:  docker run deweysasser/git-updater [options]
        or
             docker run -d deweysasser/git-updater  [options] -loop
        or
             docker run -it deweysasser/git-updater  -shell [args...]
     
     options are:
     
     -help -- this text
     -shell -- invoke a bash shell with the remaining arguments
     -loop -- loop continously
     -source SOURCE -- set the source dir to SOURCE.  Currently foo'foo'
     -signed -- if set, copy files from the latest signed tag.  Currently 'false'.
     -target TARGET -- set the target dir to TARGET.  Currently '/volume'.
     -keys KEYS -- set the keys dir to KEYS.  Currently '/keys'.
     -sleep SLEEP -- number of seconds to sleep between polls.  Currently '300'.
          
     You may also specify each of SOURCE, TARGET and KEYS as environment
     variables as well as set the value of SIGNED to 'false' (to avoid
     signatures) or anything else (to check signatures)


This image will generate an SSH key on run and report it to the docker
console.  If you'd like to use an existing SSH key, arrange for it to
be in /root/.ssh/id_rsa

If you are checking GIT signatures, place GPG keys (suitable for gpg --import) in /keys or the 


Example
=======

     docker run -d --name xymon deweysasser/xymon

     docker run -d deweysasser/git-updater -volumes-from xymon -d SOURCE=git@somewhere:/my/xymon-conf.git -e TARGET=/etc/xymon -loop