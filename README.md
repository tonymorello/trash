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
