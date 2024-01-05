import subprocess
import json
import sys
import time

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

addMLExtension()

myWorkSpaceML, myRgML = processInputArgs(inputArgs)

subscriptionId = getSubscriptionId()
print("myWorkSpaceML is: ", myWorkSpaceML)
print("myRgML is: ", myRgML)
myRemoveWorkspaceCmd = "az ml workspace delete --name "+myWorkSpaceML+" --no-wait -g "+myRgML+" --permanently-delete --all-resources -y" 
print("myRemoveWorkspaceCmd is: ", myRemoveWorkspaceCmd)

removeWorkspace(myRemoveWorkspaceCmd, myRgML, subscriptionId, myWorkSpaceML)
