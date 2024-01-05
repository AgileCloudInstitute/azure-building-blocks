import subprocess
import json
import sys
import time

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

subscriptionId = getSubscriptionId()
regCmd = "az provider register --namespace Microsoft.Purview --subscription "+subscriptionId
print("regCmd is: ", regCmd)

registerService(regCmd, subscriptionId)
