# trash
Simple bash script to emulate a CLI recycle bin feature for files and directories

## Installation
Just paste the trash file into your /usr/bin/ folder and give 0655 permissions to only allow sudo execution

## Usage
    $sudo trash /path/to/file
moves the given file or directory to the trash folder (/tmp/trash/)
    
    $sudo trash -l
shows the content of the trash folder
    
    $sudo trash -r filename
restores the file to its previous folder with the original attributes
    
    $sudo trash -e
empties the trash bin

## Note
I created this script to have a little bit of a safety net when deleting files and directories... I am new to bash and the script can definitely use some improvements but it gets the job done for the most part. If you use it and like it... Well, great! Glad you found it useful. If you used it and killed your kitten... Well, crap, sorry but I'd really like not be held responsible! So know that if you use this script you MIGHT do some damage (although I'm pretty sure your feline friends are safe, it hasn't been tested on them). If you like this script and would like to add to it, please, be my guest! I owe much to the open source community and I always try to contribute as much as I can! Sharing is caring after all...
