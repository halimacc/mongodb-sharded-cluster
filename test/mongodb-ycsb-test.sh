install_java()
{
    sudo apt-get update

    # install java
    sudo apt-get install -y default-jre
    sudo apt-get install -y default-jdk

    # install maven
    sudo apt-get install -y maven
}

install_ycsb()
{
    curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.8.0/ycsb-0.8.0.tar.gz
    tar xfvz ycsb-0.8.0.tar.gz
    rm ycsb-0.8.0.tar.gz
    mv ycsb-0.8.0 ycsb
}

configure_workload()
{
}

install_java
install_ycsb

