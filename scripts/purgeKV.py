import subprocess
import sys

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

myKeyVault = processInputArgs(inputArgs)
myPurgeKVCmd = "az keyvault purge --name "+myKeyVault

removeKeyVault(myPurgeKVCmd)
