#!/bin/bash

# VM
function unit_tests_on_vm()
{
    local VAGRANT_CMD=$(which vagrant)

    if [[ "$VAGRANT_CMD" == "" ]]; then
        echo "No se encontro Vagrant"
        exit 1
    fi

    export TESTS=true

    echo -e "\n\033[1;32m########## UnitTest en VM ##########\033[0m"

    $VAGRANT_CMD up

    # Test
    $VAGRANT_CMD ssh -c "cd /vagrant/cookbooks/database && chef exec rspec --format=documentation"
    $VAGRANT_CMD ssh -c "cd /vagrant/cookbooks/wordpress && chef exec rspec --format=documentation"
    $VAGRANT_CMD ssh -c "cd /vagrant/cookbooks/proxy && chef exec rspec --format=documentation"

    # Destroy VM
    $VAGRANT_CMD destroy -f test

    unset TESTS

    echo -e "\n\033[1;32m########## Fin UnitTest en VM ##########\033[0m\n\n"

}

# Docker Valid
function run_tests_on_a_conatiner()
{
    local DOCKER_CMD=$(which docker)
    local DOCKER_IMAGE="cppmx/chefdk:latest"
    local TEST_CMD="chef exec rspec --format=documentation"

    if [[ "$DOCKER_CMD" == "" ]]; then
        echo "No se encontro docker"
        exit 1
    fi

    $DOCKER_CMD run --rm -v $1:/cookbooks $DOCKER_IMAGE $TEST_CMD
}

# Docker
function unit_tests_on_a_conatiner()
{
    local DATABASE="$(pwd)/cookbooks/database"
    local WORDPRESS="$(pwd)/cookbooks/wordpress"
    local PROXY="$(pwd)/cookbooks/proxy"

    echo -e "\n\033[1;32m########## UnitTest en Docker ##########\033[0m"

    echo "Probando las recetas de Database"
    run_tests_on_a_conatiner $DATABASE

    echo "Probando las recetas de Wordpress"
    run_tests_on_a_conatiner $WORDPRESS

    echo "Probando las recetas de Proxy"
    run_tests_on_a_conatiner $PROXY

    echo -e "\n\033[1;32m########## Fin UnitTest en Docker ##########\033[0m\n\n"

}

function itg_tests()
{
    local KITCHEN_CMD=$(which kitchen)

    cd $1
    $KITCHEN_CMD test
}

function all_itg_tests()
{
    local COOKBOOKS=$(pwd)/cookbooks

    itg_tests $COOKBOOKS/database
    itg_tests $COOKBOOKS/wordpress
    itg_tests $COOKBOOKS/proxy
}

function manual()
{
    # Agrega dos espacios en blanco arriba
    echo -e "\n\033[1;32mElija una opción:\033[0m"
    echo -e "\033[1;32m1. UnitTest en Máquina Virtual (VM)\033[0m"
    echo -e "\033[1;32m2. UnitTest en Docker\033[0m"
    echo -e "\033[1;32m3. UnitTest de integración e infraestructura\033[0m"
    echo -e "\033[1;32m4. Exit\033[0m"
    read -p "Opción: " OPTION

    # Llamada según opción elegida
    case $OPTION in
        1) unit_tests_on_vm ;;
        2) unit_tests_on_a_conatiner ;;
        3) all_itg_tests ;;
        4) echo -e "\033[1;31mBye bye... \n\033[0m" && exit 0 ;;
        *) echo -e "\033[1;31mLa opción es inválida. Saliendo... \n\033[0m" ;;
    esac
}

if [[ "$1" == "" ]]; then
    manual
elif [[ "$1" == "vm" ]]; then
    unit_tests_on_vm
elif [[ "$1" == "docker" ]]; then
    unit_tests_on_a_conatiner
elif [[ "$1" == "database" ]]; then
    itg_tests $(pwd)/cookbooks/database
elif [[ "$1" == "wordpress" ]]; then
    itg_tests $(pwd)/cookbooks/wordpress
elif [[ "$1" == "proxy" ]]; then
    itg_tests $(pwd)/cookbooks/proxy
else
    echo "Opción inválida"
    exit 1
fi
