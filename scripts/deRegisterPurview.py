import subprocess
import sys
import json

def deRegisterService(cmd):
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
    print("Unregister command returned code 0, which implies success.  ")
    print(data)
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

subscriptionId = getSubscriptionId()
deRegCmd = "az provider unregister --namespace Microsoft.Purview --subscription "+subscriptionId+" --wait"
deRegisterService(deRegCmd)
