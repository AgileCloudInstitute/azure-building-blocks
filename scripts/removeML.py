import subprocess
import json
import sys
import time
import platform
import os

inputArgs=sys.argv

def addMLExtension():
  print("----------------------------------------------------")
  cmd = "az extension add --name ml"
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
    print("Add ml extension command returned code 0, which implies success.  We will now continue with the rest of the program flow because we assume that the ml extension has been properly added on your computer by this command.  ")
  else:
    logString = "ERROR: The '"+cmd+"' command returned a non-zero return code.  Halting program so that you can identify the root cause of the problem. "
    print(logString)
    sys.exit(1)


def removeWorkspace(cmd, rgML, subscriptionId, myWorkSpaceML):
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
    checkForWorkspace(rgML, subscriptionId, myWorkSpaceML)
  else:
    logString = "ERROR: The '"+cmd+"' command returned a non-zero return code.  Halting program so that you can identify the root cause of the problem. "
    print(logString)
    sys.exit(1)

def checkForWorkspace(rgMLWorkspace, subscriptionId, myWorkSpaceML, counter=0):
  print("----------------------------------------------------")
  tot = 20
  cmd = "az ml workspace list --resource-group "+rgMLWorkspace
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
    print("List providers command returned code 0, which implies success.  ")
    foundMatch = False
    mydata = json.loads(data)
    for myitem in mydata:
      print("myitem['id'] is: ", myitem["id"])
      idparts = myitem["id"].split("/")
      print("len(idparts) is: ", str(len(idparts)))
      mySubscription = idparts[2]
      resourceGroupName = idparts[4]
      resourceType = idparts[6]
      mlWorkspaceID = idparts[8]
      if (mySubscription == subscriptionId) and (resourceType == "Microsoft.MachineLearningServices") and (resourceGroupName == rgMLWorkspace) and (myWorkSpaceML == mlWorkspaceID):
        foundMatch = True
        print("Match!")
        print("mySubscription is: ", mySubscription)
        print("resourceGroupName is: ", resourceGroupName)
        print("resourceType is: ", resourceType)
        print("mlWorkspaceID is: ", mlWorkspaceID)
    if foundMatch:
      if counter < tot:
        counter +=1
        print("Microsoft.MachineLearningServices workspace ",myWorkSpaceML," is still visible because the delete command has not yet completed running.  Sleeping 30 seconds before rechecking.  Attempt number ", counter, " of ", tot, ". ")
        time.sleep(30)
        checkForWorkspace(rgMLWorkspace, subscriptionId, myWorkSpaceML, counter)
      else:
        print("ERROR: Microsoft. Purview registration with subscription still not visible after repeating attempt ", tot, " times and sleeping 30 seconds between each check attempt.  Halting program so that you can examine the root cause of the problem. ")
        sys.exit(1)
    else:
      print("Microsoft.MachineLearningServices workspace ",myWorkSpaceML," is no longer visible.  Program will now move on assuming that it has been deleted. ")
      return
  else:
    logString = "ERROR: The '"+cmd+"' command returned a non-zero return code.  Halting program so that you can identify the root cause of the problem. "
    print(logString)
    sys.exit(1)

def getSubscriptionId():
  print("----------------------------------------------------")
  cmd = "az account show"
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
    print("List providers command returned code 0, which implies success.  ")
    mydata = json.loads(data)
    mySubscriptionId = mydata["id"]
    print("len(mySubscriptionId) is: ", str(len(mySubscriptionId)))
    print("mySubscriptionId.count('-') ", str(mySubscriptionId.count('-')))
    if len(mySubscriptionId) != 36:
      print("Error:  subscription ID ", mySubscriptionId, " is not 36 characters in length.  Halting program so you can examine the root cause of the problem.")
      sys.exit(1)
    if mySubscriptionId.count('-') != 4:
      print("Error: Subscription ID ", mySubscriptionId, " does not contain exactly four dashes - .  Halting program so that you can examine the root cause of the problem. ")
      sys.exit(1)
    return mySubscriptionId
  else:
    logString = "ERROR: The '"+cmd+"' command returned a non-zero return code.  Halting program so that you can identify the root cause of the problem. "
    print(logString)
    sys.exit(1)

#The following function will set all the values for the returned properties
def processInputArgs(inputArgs):
    print("y")
    print("str(inputArgs) is: ", inputArgs)
    if (inputArgs[1].startswith('wsName=')) and (inputArgs[2].startswith('rgName=')):
      wsName = (inputArgs[1])[7:]
      print("wsName is: ", wsName)
      rgName = (inputArgs[2])[7:]
      print("rgName is: ", rgName)
    else:
      logString = "ERROR: Illegal syntax.  Command must look like 'python removeML.py wsName=nameOfMLWorkspace rgName=nameOfResourceGroup'.  "
      print(logString)
      sys.exit(1)
    return wsName, rgName

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


addMLExtension()

myWorkSpaceML, myRgML = processInputArgs(inputArgs)

#subscriptionId = getSubscriptionId()
print("myWorkSpaceML is: ", myWorkSpaceML)
print("myRgML is: ", myRgML)
myRemoveWorkspaceCmd = "az ml workspace delete --name "+myWorkSpaceML+" --no-wait -g "+myRgML+" --permanently-delete --all-resources -y" 
print("myRemoveWorkspaceCmd is: ", myRemoveWorkspaceCmd)

removeWorkspace(myRemoveWorkspaceCmd, myRgML, subscriptionId, myWorkSpaceML)

runCliCommand("az logout")
