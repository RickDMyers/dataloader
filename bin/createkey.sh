
keyfile=$1

if [ -z "$keyfile" ]; then
    
    echo "Usage:    createkey.sh  keyfile"
    echo
    echo "Description:  Generates a random key and stores it in keyfile."
    echo "              The keyfile can be used by enrypt and decrypt to safely"
    echo "              store passwords in your config files"
    return
fi


 # Create Key File
java -cp /dataloader/bin/dataloader.jar com.salesforce.dataloader.security.EncryptionUtil -k $keyfile