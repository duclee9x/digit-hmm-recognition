declare -a tools=(hmmlearn)
declare -a validTools=()
declare -a dataPath="./data"
configuredClient=""
pythonPath=""
getConfiguredClient()
{
  if  command -v curl &>/dev/null; then
    configuredClient="curl"
  elif command -v wget &>/dev/null; then
    configuredClient="wget"
  elif command -v http &>/dev/null; then
    configuredClient="httpie"
  else
    echo "Error: This tool requires either curl, wget, httpie or fetch to be installed." >&2
    return 1
  fi
  if command -v python3 &>/dev/null; then
    pythonPath="python3"
  elif command -v python &>/dev/null; then
    pythonPath="python"
  else
    echo "Error: This system is lack of python interpreter"
    return 1
  fi

  pythonVersion=$($pythonPath --version | cut -d " " -f 2 | cut -c 1)
  if [[ $pythonVersion -eq 2 ]]; then
    echo "Python should be version 3"
    return 1
  fi
  echo "Python 3 and http downloader have been installed"
}


httpGet()
{
  case "$configuredClient" in
    curl)  curl -A curl -s "$@" ;;
    wget)  wget -qO- "$@" ;;
    httpie) http -b GET "$@" ;;
  esac
}
httpDownloadFile()
{
  case "$configuredClient" in
    curl)  curl "$@" --output "${dataPath}/raw_data.zip" ;;
    wget)  wget -O "${dataPath}/raw_data.zip" "$@" ;;
    httpie) http "$@" > "${dataPath}/raw_data.zip" ;;
  esac
  echo "File has been download on ${dataPath}/raw_data.zip"

}
checkInternet()
{
  httpGet github.com > /dev/null 2>&1 || { echo "Error: no active internet connection" >&2; return 1; } # query github with a get request
}




download(){
    if [[ $# -eq 1 ]]; then
        mkdir -p "${dataPath}"
        httpDownloadFile $1
    fi
}


if [[ $1 -eq "get" ]]; then
  clear
  checkInternet
  getConfiguredClient
  download https://github.com/duclee9x/digit-hmm-recognition/raw/master/record.zip
fi
