git-updater
===========

Peridically update a directory from a git repository.

This container is useful to maintain an up to date set of files in a
directory (or volume of another container), without teaching another
application how to understand GIT.


Usage
=====

    usage:  docker run deweysasser/git-updater [options] [commands]
       or 
            docker run -d deweysasser/git-updater  [options] -loop [commands]
       or 
            docker run -it deweysasser/git-updater  -shell [args...]
    
    options are:
    
    -help -- this text
    -shell -- invoke a bash shell with the remaining arguments
    -loop -- loop continously
    -source SOURCE -- set the source dir to SOURCE.  Currently empty
    -signed -- if set, copy files from the latest signed tag.  Currently 'false'.
    -target TARGET -- set the target dir to TARGET.  Currently ''.
    -keys KEYS -- set the keys dir to KEYS.  Currently ''.
    -sleep SLEEP -- number of seconds to sleep between polls.  Currently '60'.
    -standbox SANDBOX -- the location of the git sandbox used to poll
    -branch BRANCH -- branch of the git repository to clone and/or examine for signed tags
    -dir DIR -- directory within the repositor to copy to the TARGET
    
    You may also specify each of SOURCE, TARGET and KEYS as environment
    variables as well as set the value of SIGNED to 'false' (to avoid
    signatures) or anything else (to check signatures)
    
    You may optionally specificy a COMMAND to run after the update (and
    signature check, if any) is successful.



This image will generate an SSH key on run and report it to the docker
console.  If you'd like to use an existing SSH key, arrange for it to
be in /root/.ssh/id_rsa

If you are checking GIT signatures, place GPG keys (suitable for gpg --import) in /keys or the 


Example
=======

     docker run -d --name xymon deweysasser/xymon

     docker run -d deweysasser/git-updater -volumes-from xymon -d SOURCE=git@somewhere:/my/xymon-conf.git -e TARGET=/etc/xymon -loop