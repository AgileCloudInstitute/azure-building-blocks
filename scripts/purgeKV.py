import subprocess
import sys
import platform
import os

inputArgs=sys.argv

def removeKeyVault(cmd):
  print("----------------------------------------------------")
  logString = "About to run cli command: "+cmd
  print(logString)
  process = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, text=True)
  data = process.stdout
  err = process.stderr
  logString = "data string is: " + data
  print(logString)
  logString = "err is: " + str(err)
  print(logString)
  logString = "process.returncode is: " + str(process.returncode)
  print(logString)
  if process.returncode == 0:
    print("Registration command returned code 0, which implies success.  Now going to check to confirm that the registration has propagated before proceeding.  ")
#    checkForWorkspace(rgML)
  else:
    logString = "ERROR: The '"+cmd+"' command returned a non-zero return code.  Halting program so that you can identify the root cause of the problem. "
    print(logString)
    sys.exit(1)

#The following function will set all the values for the returned properties
def processInputArgs(inputArgs):
    print("y")
    print("str(inputArgs) is: ", inputArgs)
    if (inputArgs[1].startswith('kvName=')):
      kvName = (inputArgs[1])[7:]
      print("kvName is: ", kvName)
    else:
      logString = "ERROR: Illegal syntax.  Command must look like 'python removeML.py wsName=nameOfMLWorkspace rgName=nameOfResourceGroup'.  "
      print(logString)
      sys.exit(1)
    return kvName

#################get keys and config stuff
def getFirstLevelValue(yamlFileAndPath, keyName):
    #Only scan lines that have one or two colons.  
    # First colon separates key and value.  Second colon might be in a URL.
    returnVal = ""  
    with open(yamlFileAndPath) as file:
      for line in file:
        if line.count(':') == 1:
          lineParts = line.split(":")
          key = lineParts[0].strip()
          value = lineParts[1].strip()
          if keyName == key:
            returnVal = value
        elif line.count(':') == 2:
          lineParts = line.split(":")
          key = lineParts[0].strip()
          value = lineParts[1].strip() + ":" + lineParts[2].strip()
          if keyName == key:
            returnVal = value
    return returnVal

def formatPathForOS(input):
    if platform.system() == "Windows":
      #First, strip down to a single \ in each location.  
      input = input.replace('\\/','\\')
      input = input.replace('/','\\')
      input = input.replace('\\\\','\\')
      input = input.replace('\\\\\\','\\')
      input = input.replace('\\\\\\\\', '\\\\')
      #Now replace singles with doubles for terraform so you get C:\\path\\to\\a\\file with proper escape sequence.
      input = input.replace('\\','\\\\')   
    elif platform.system() == "Linux":  
      input = input.replace('\\','/')  
      input = input.replace('//','/')  
      input = input.replace('///','/')  
    if input.endswith('/n'):  
      input = input[:-2] + '\n'
    return input

  #@public
def formatKeyDir(keyDir):
    if platform.system() == "Windows":
      if keyDir[-1] != '\\':
        keyDir = keyDir + '\\'
    elif platform.system() == "Linux":
      if keyDir[-1] != '/':
        keyDir = keyDir + '/'
    keyDir = formatPathForOS(keyDir)
    return keyDir

def getAcmUserHome():
    if platform.system() == 'Windows':
      acmUserHome = os.path.expanduser("~")+'/acm/'
    elif platform.system() == 'Linux':
      acmUserHome = '/usr/acm/'
    if not os.path.exists(acmUserHome):
      os.makedirs(acmUserHome, exist_ok=True) 
    return acmUserHome

def getKeyDir():
    acmUserHome = getAcmUserHome()
    dirOfYamlKeys = acmUserHome + '\\keys\\starter\\'
    dirOfYamlKeys = formatPathForOS(dirOfYamlKeys)
    return dirOfYamlKeys

def getKeyFileAndPath(keyDir):
  yaml_keys_file_and_path = 'invalid'
  if platform.system() == "Windows":
    if keyDir[:-1] != "\\":
      keyDir = keyDir + "\\"
  if platform.system() == "Linux":
    if keyDir[:-1] != "/":
      keyDir = keyDir + "/"
  keyDir = formatPathForOS(keyDir)
  dirOfSourceKeys = keyDir
  yaml_keys_file_and_path = dirOfSourceKeys + 'keys.yaml'
  return yaml_keys_file_and_path

def getConfigFileAndPath(keyDir):
  yaml_keys_file_and_path = 'invalid'
  if platform.system() == "Windows":
    if keyDir[:-1] != "\\":
      keyDir = keyDir + "\\"
  if platform.system() == "Linux":
    if keyDir[:-1] != "/":
      keyDir = keyDir + "/"
  keyDir = formatPathForOS(keyDir)
  dirOfSourceKeys = keyDir
  yaml_keys_file_and_path = dirOfSourceKeys + 'config.yaml'
  return yaml_keys_file_and_path

def runCliCommand(cmd):
  print("----------------------------------------------------")
  logString = "About to run cli command: "+cmd
  print(logString)
  process = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, text=True)
  data = process.stdout
  err = process.stderr
  logString = "data string is: " + data
  print(logString)
  logString = "err is: " + str(err)
  print(logString)
  logString = "process.returncode is: " + str(process.returncode)
  print(logString)
  if process.returncode == 0:
    print("Command returned code 0, which implies success. ")
  else:
    logString = "ERROR: The '"+cmd+"' command returned a non-zero return code.  Halting program so that you can identify the root cause of the problem. "
    print(logString)
    sys.exit(1)


keyDir = getKeyDir()
yaml_global_config_file_and_path = getConfigFileAndPath(keyDir)
keyFileAndPath = getKeyFileAndPath(keyDir)
configFileAndPath = getConfigFileAndPath(keyDir)

clientId = getFirstLevelValue(keyFileAndPath, "clientId")
clientSecret = getFirstLevelValue(keyFileAndPath, "clientSecret")
tenantId = getFirstLevelValue(configFileAndPath, "tenantId")
subscriptionId = getFirstLevelValue(configFileAndPath, "subscriptionId")

loginCmd = "az login --service-principal -u " + clientId + " -p " + clientSecret + " --tenant " + tenantId
runCliCommand(loginCmd)

setSubscriptionCommand = 'az account set --subscription '+subscriptionId
runCliCommand(setSubscriptionCommand)


myKeyVault = processInputArgs(inputArgs)
myPurgeKVCmd = "az keyvault purge --name "+myKeyVault

removeKeyVault(myPurgeKVCmd)

runCliCommand("az logout")
