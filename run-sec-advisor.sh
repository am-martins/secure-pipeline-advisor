#!/bin/bash
# @Author: Rodrigo Alves (rodrigoalves@ciandt.com)
# Version: 0.1

APPLICATION_NAME=
REPOSITORY_PATH=
current_date="$(date +'%Y%m%d_%H%M')"
HOST_REPORTS_FOLDER="job-reports"


function define_configs() {
    if [ -z "$APPLICATION_NAME" ];then
        echo "Type the application name:"
        read APPLICATION_NAME;
        printf "\n\n"
    fi

    if [ -z "$REPOSITORY_PATH" ];then
        echo "Type the repository path (type '.' for current folder path):"
        read REPOSITORY_PATH;
        printf "\n\n"
    fi
}

function _run_git_secrets_scanning() {
    define_configs
    docker-compose run security-tests gitleaks --path ${REPOSITORY_PATH} -v --report=/opt/job-reports/gitleaks-report_${current_date}.json
    printf "\n the analysis has been concluded..."
    printf "\n report generated at $(pwd)/$HOST_REPORTS_FOLDER/gitleaks-report_${current_date}.json\n\n"
    exit 0
}

function _run_certified_analysis() {
    if [ -z "$URL_MACHINE_APPLICATION" ];then
        echo "Type the DNS or IP of your application:"
        read URL_MACHINE_APPLICATION;
        printf "\n\n"
    fi

    docker-compose run security-tests sslyze --regular ${URL_MACHINE_APPLICATION} --json_out=/opt/job-reports/sslyze-analysis_${current_date}.json
    printf "\n the analysis has been concluded..."
    printf "\n report generated at $(pwd)/$HOST_REPORTS_FOLDER/sslyze-analysis_${current_date}.json\n\n"
    exit 0
}

function _run_dependency_and_libs_checking() {
    define_configs
    docker-compose run security-tests dependency-check --project "$APPLICATION_NAME" --scan ${REPOSITORY_PATH} --out /opt/job-reports/dependency-check-report_${current_date}.html
    printf "\n the analysis has been concluded..."
    printf "\n report generated at $(pwd)/$HOST_REPORTS_FOLDER/dependency-check-report_${current_date}.html\n\n"
    exit 0
}

function _run_sast_code_analysis() {
    define_configs
    docker-compose run security-tests findsecbugs -progress -html -output /opt/job-reports/findsecbug-analysis_${current_date}.htm ${REPOSITORY_PATH}/target/*.jar
    printf "\n the analysis has been concluded..."
    printf "\n report generated at $(pwd)/$HOST_REPORTS_FOLDER/findsecbug-analysis_${current_date}.htm\n\n"
    exit 0
}

function _run_mBDD {
    #  WIP - Reports target e cenário genérico
    # docker-compose run security-tests mvn clean tests
    exit 0
}

function _run () {

    export REPOSITORY_PATH

    while true; do
        echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~ Run Security Analysis & Testing 🦖 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo -e "1  - Git Secrets Scanning"
        echo -e "2  - SSL Certified Analysis"
        echo -e "3  - Project libs and dependency checking"
        echo -e "4  - SAST - Code Analysis"
        echo -e "5  - Functional Penetration Testing"
        echo -e "x  - Exit"
        echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo -e " 🦖 Choose the operation you want: "
        echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        read -a _QUESTION -p "~> "
        echo

        case "${_QUESTION}" in
            1) _run_git_secrets_scanning ;;
            2) _run_certified_analysis ;;
            3) _run_dependency_and_libs_checking ;;
            4) _run_sast_code_analysis ;;
            5) _run_mBDD ;;
            x)  echo "Bye"; exit 0;;
            *)  echo "Option not found!!"; clear ; _run;;
        esac

    done
}

# Run the main method
_run
