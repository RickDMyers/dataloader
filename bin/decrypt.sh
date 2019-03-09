
# Decrypts a password

password=$1
keyfile=$2

if [ -z "$keyfile" ]; then
    echo "Usage:       encrypt.sh password keyfile"
    echo
    echo "Description: Decrypts an encrypted password usingthe keyfile"
    return
fi

java -cp /dataloader/bin/dataloader.jar com.salesforce.dataloader.security.EncryptionUtil -e $password $keyfile


