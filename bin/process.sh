ProcessName=$1


if [ -z "$ProcessName" ]; then
    
    echo "Usage:    process.sh  ProcessName"
    echo
    echo "Description:  Executes dataloader process"
    return
fi


echo "<*** Running DL Process: " $ProcessName " ***>" >> /dev/stderr 


java -cp $(echo /dataloader/bin/*.jar | tr ' ' ':')  -Dsalesforce.config.dir=/dataloader/conf com.salesforce.dataloader.process.ProcessRunner process.name=$ProcessName 

