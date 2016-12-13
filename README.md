# trash
Simple bash script to emulate a CLI recycle bin feature for files and directories

## Installation
### On Arch Linux
1. Install [yaourt](https://archlinux.fr/yaourt-en)
2. run `yaourt -S trash`
3. follow the instructions
4. It's that easy.

### Other distros
In order to use trash the recommended steps are the following

1. Make sure to install [shc](https://github.com/neurobin/shc) (this is most likely available from your distro package manager)
2. run `git clone https://github.com/tonymorello/trash.git`
3. cd to the repo directory
4. run make
5. copy trash binary to your bin folder (/usr/bin/ generally)
6. ???
7. Profit.

## Usage
    $trash [file1] [file2]...
Moves the given file/s or directory to the trash folder (/tmp/trash/)
    
    $trash -l
Shows the content of the trash folder
    
    $trash -r file1 [-r file2 -r file3 ...]
Restores file/s or folder/s to their previous locations with their original attributes

    $trash -R
Restores ALL file/s or folder/s to their previous locations with their original attributes
    
    $trash -e
Empties the trash bin

    $trash -p file1 [-p file2 -p file3 ...] 
Purge (delete permanently!) file/s or folder/s from the trash can.

    $trash -v
Verbose. Add some additional information about the performed operation.

    $trash -V
Show current version.

    $trash -h
Show usage.

## Note
I created this script to have a little bit of a safety net when deleting files and directories... I am new to bash and the script can definitely use some improvements but it gets the job done for the most part. If you use it and like it... Well, great! Glad you found it useful. If you used it and it killed your kitten... Well, crap, sorry but I'd really like not be held responsible! So know that if you use this script you MIGHT do some damage (although I'm pretty sure your feline friends are safe, it hasn't been tested on them). If you like this script and would like to improve it, please, be my guest! I owe much to the open source community and I always try to contribute as much as I can! Sharing is caring after all...
