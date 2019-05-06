if ! [ -x "$(command -v azcopy)" ]; then
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod/ xenial main" > azure.list
    sudo cp -f ./azure.list /etc/apt/sources.list.d/
    sudo apt-key adv --keyserver packages.microsoft.com --recv-keys EB3E94ADBE1229CF
    sudo apt-get update
    sudo apt-get install -y apt-transport-https
    sudo apt-get update
    sudo apt-get install -y azcopy
fi

azcopy \
    --source https://dtdataset.file.core.windows.net/dtdata/$1 \
    --destination ./$1 \
    --source-key $2 \
    --preserve-last-modified-time \
    --quiet
