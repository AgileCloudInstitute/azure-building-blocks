import subprocess
import json
import sys
import time
import platform
import os

def registerService(cmd, subscriptionId):
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
    checkForProvider(subscriptionId)
  else:
    logString = "ERROR: The '"+cmd+"' command returned a non-zero return code.  Halting program so that you can identify the root cause of the problem. "
    print(logString)
    sys.exit(1)

def checkForProvider(subscriptionId, counter=0):
  print("----------------------------------------------------")
  tot = 20
  cmd = "az provider list"
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
  foundMatch = False
  if process.returncode == 0:
    print("List providers command returned code 0, which implies success.  ")
    mydata = json.loads(data)
    for myitem in mydata:
      idparts = myitem["id"].split("/")
      mySubscription = idparts[2]
      serviceName = idparts[4]
      if (mySubscription == subscriptionId) and (serviceName == "Microsoft.Purview"):
        foundMatch = True
        print("Match!")
        print("mySubscription is: ", mySubscription)
        print("serviceName is: ", serviceName)
        print("myitem['id'] is: ", myitem["id"])
  else:
    logString = "ERROR: The '"+cmd+"' command returned a non-zero return code.  Halting program so that you can identify the root cause of the problem. "
    print(logString)
    sys.exit(1)
  if not foundMatch:
    if counter < tot:
      counter +=1
      print("Microsoft.Purview registeration with subscription is not yet visible.  Sleeping 30 seconds before rechecking.  Attempt number ", counter, " of ", tot, ". ")
      time.sleep(30)
      checkForProvider(subscriptionId, counter)
    else:
      print("ERROR: Microsoft. Purview registration with subscription still not visible after repeating attempt ", tot, " times and sleeping 30 seconds between each check attempt.  Halting program so that you can examine the root cause of the problem. ")
      sys.exit(1)
  else:
    print("Found match.")
    return

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

#subscriptionId = getSubscriptionId()
regCmd = "az provider register --namespace Microsoft.Purview --subscription "+subscriptionId
print("regCmd is: ", regCmd)

registerService(regCmd, subscriptionId)

#runCliCommand("az logout")
