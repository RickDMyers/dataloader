

password=$1
keyfile=$2

if [ -z "$keyfile" ]; then
    
    
    echo "Usage:    encrypt.sh password keyfile"
    echo
    echo "Description:  Encypts the password using the keyfile"
    return
fi

# Encrypt password
java -cp /dataloader/bin/dataloader.jar com.salesforce.dataloader.security.EncryptionUtil -e $password $keyfile
