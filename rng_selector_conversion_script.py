## Imports ##
import configparser
from os.path import exists, getsize
from os import remove
from shutil import rmtree
from struct import unpack, pack


## Variable definitions ##
version = "v1.0.3"
splitPath = "default/"
mergedPath = ""


## Function definitions ##
def makeSelection(validOptions, inputText = ""):
    ## Returns the integer entered provided it's included in the valid options. If a blank string is allowed, it will return 0.
    selection = 0
    selection = input(inputText)
    while selection not in validOptions:
        selection = input("Invalid input\n")
    if selection == '':
        selection = 0
    return int(selection)


def rngSettingsGenerator(rngMode = '"recording"', rngRecordingMode = '"wildcard"', rngFilter = '"on"',\
                         rngAggressiveFilter = '"on"', rngPlacebo = '"off"', rngBufferFormat = '"compressed"'):
    rngSettings = configparser.ConfigParser()
    rngSettings.read('rngsettings.ini')
    try:
        rngSettings.add_section('Settings')
    except configparser.DuplicateSectionError:
        pass
    
    if rngMode != None:
        rngSettings['Settings']['mode'] = rngMode
    if rngRecordingMode != None:
        rngSettings['Settings']['recordingmode'] = rngRecordingMode
    if rngFilter != None:
        rngSettings['Settings']['filter'] = rngFilter
    if rngAggressiveFilter != None:
        rngSettings['Settings']['aggressive_filter'] = rngAggressiveFilter
    if rngPlacebo != None:
        rngSettings['Settings']['placebo'] = rngPlacebo
    if rngBufferFormat != None:
        rngSettings['Settings']['buffer_format'] = rngBufferFormat
    
    with open('rngsettings.ini', 'w') as rngSettingsFile:
        rngSettings.write(rngSettingsFile)
        
    return 0


def removeDataSection(rngData): # rngData must already include the ini file
    rngData.remove_section('Data')
    
    with open('rngdata.ini', 'w') as rngDataFile:
        rngData.write(rngDataFile)
    
    return 0


def nullTerminatedString(data):
    i = 0
    while data[i] != 0:
        i += 1
    return data[0:i].decode('utf-8')


def nullTerminatedEncode(string):
    return string.encode() + b'\x00'
    

print("Welcome to the Undertale RNG Selector Conversion Script " + version +  " made by OceanBagel.")


selection = makeSelection(['1', '2', '3', '4', '5', '6', '7'], "Please select from the following options:\
\n1. Convert recorded files to editable format\
\n2. Convert editable file to playback format and prepare rngdata.ini and rngsettings.ini for playback\
\n3. Generate a default rngsettings.ini file\
\n4. Configure the rngsettings.ini file\
\n5. Configure script settings\
\n6. Delete recorded files and rngdata.ini and prepare rngsettings.ini for recording with default settings\
\n7. Exit without any changes\n")

if selection == 1:
    # First check rngdata.ini to see if it's in compressed or expanded mode
    rngData = configparser.ConfigParser()
    rngData.read('rngdata.ini')
    rngBufferFormat = rngData['Recording_Settings']['buffer_format']
    
    # Now handle expanded
    if rngBufferFormat == '"expanded"':
        with open(mergedPath + "rngfile.txt", "w") as mfid:
            i = 1
            while exists(splitPath + "rngfile" + str(i) + ".txt"):
                
                with open(splitPath + "rngfile" + str(i) + ".txt", "r") as sfid:
                    if getsize(splitPath + "rngfile" + str(i) + ".txt") > 1:
                        print("Frame {}".format(i))
                        mfid.write("\n# Frame " + str(i) + ": ############################################################\n")
                        mfid.write(sfid.read(-1).replace('\x00',''))
                    else:
                        print("Frame {} (empty)".format(i))
                i += 1
        
    
    # Now handle compressed
    else:
        with open(mergedPath + "rngfile.txt", "w") as mfid:
            i = 1
            while exists(splitPath + "rngfile" + str(i) + ".txt"):
                print("Frame {}".format(i))
                with open(splitPath + "rngfile" + str(i) + ".txt", "rb") as sfid:
                    if getsize(splitPath + "rngfile" + str(i) + ".txt") > 1:
                        mfid.write("\n# Frame " + str(i) + ": ############################################################\n")
                        splitFileContents = sfid.read()
                        
                        while len(splitFileContents) > 0:
                        
                            callNumber =  int.from_bytes(splitFileContents[0:4], "little") # A u32 int
                            splitFileContents = splitFileContents[4:] # Remove already read data
                            
                            objName = nullTerminatedString(splitFileContents) # A string
                            splitFileContents = splitFileContents[len(objName)+1:] # Remove the string and the null terminator
                            
                            objID = int.from_bytes(splitFileContents[0:4], "little") # A u32 int
                            splitFileContents = splitFileContents[4:] # Remove already read data
                            
                            callType = splitFileContents[0] # A u8 int
                            splitFileContents = splitFileContents[1:] # Remove already read data
                            
                            argumentList = []
                            
                            if callType == 0: # random() call
                                argument = unpack('<d', splitFileContents[0:8])[0] # A double precision float
                                splitFileContents = splitFileContents[8:]
                                                                
                                current = str(unpack('<d', splitFileContents[0:8])[0])
                                splitFileContents = splitFileContents[8:]
                                
                                if callNumber < 2147483648: # Represents specified target value
                                    target = str(unpack('<d', splitFileContents[0:8])[0]) # A double precision float
                                    splitFileContents = splitFileContents[8:]
                                else: # Represents wildcard, also subtract off 2147483648
                                    callNumber -= 2147483648
                                    target = "*"
                                    
                            else: # choose() call
                                numArgs = callType - 128
                                
                                for ii in range(numArgs):
                                    argument = nullTerminatedString(splitFileContents) # A string
                                    argumentList += [argument]
                                    splitFileContents = splitFileContents[len(argument)+1:]
                                    
                                current = str(splitFileContents[0]) # A u8 int represented as a string
                                splitFileContents = splitFileContents[1:]
                                
                                if callNumber < 2147483648: # Represents specified target value
                                    target = str(splitFileContents[0]) # A u8 int represented as a string
                                    splitFileContents = splitFileContents[1:]
                                else: # Represents wildcard, also subtract off 2147483648
                                    callNumber -= 2147483648
                                    target = "*"
                                
                            # Construct the call string
                            callString = str(callNumber) + '\n' + \
                                          objName + '(' + str(objID) + ')' + '\n' + \
                                          ("choose(" + ''.join((str(x) + ", ") for x in argumentList).strip(', ') + ")\n", \
                                           "random(" + str(argument) + ")\n")[callType == 0] + \
                                          "Current: " + current + '\n' + \
                                          "Target: " + target + '\n'
                                         
                            mfid.write(callString)
                    else:
                        print("Skipped")
                                
                        
                        
                i += 1

elif selection == 2:
    
    # First set playback
    rngSettingsGenerator(rngMode = '"playback"', rngRecordingMode = None, rngFilter = None,\
                         rngAggressiveFilter = None, rngPlacebo = None, rngBufferFormat = None)
    
    # Next delete the data section in rngdata and pull the buffer format
    rngData = configparser.ConfigParser()
    rngData.read('rngdata.ini')
    rngBufferFormat = rngData['Recording_Settings']['buffer_format']
    
    removeDataSection(rngData) # Removes data meant to be used during recording or playback only
        
    # Now open the file
    with open(mergedPath + "rngfile.txt", 'r') as mfid:
        
        thisFrame = 0
        rngData = configparser.ConfigParser()
        rngData.read('rngdata.ini')
        rngBufferFormat = rngData['Recording_Settings']['buffer_format']
        
        
        for line in mfid: # Using this for loop allows it to automatically exit at eof
            if line[0] == '#': # Beginning of a frame
            
                thisFrame += 1
                # Get the frame number
                readFrame = int(line.strip('\n').strip('#').strip().strip(':')[6:])
                #print(readFrame)
                
                # Write empty files for skipped frames
                while thisFrame < readFrame:
                    print("Frame {} (empty)".format(thisFrame))
                    with open(splitPath + "rngfile" + str(thisFrame) + ".txt", "w") as sfid:
                        pass # Write an empty file for the frames that don't have any rng calls
                    thisFrame += 1
                   
                print("Frame {}".format(thisFrame))
                
                # Now thisFrame = readFrame. Parse the rng calls.
                if rngBufferFormat == '"expanded"':
                    writeThisString = ""
                    line = mfid.readline()
                    
                    while len(line) > 0 and line[0].isdigit(): # repeats if there's another rng call, relies on short circuiting at eof
                        writeThisString += line # Call number
                        writeThisString += '\x00'
                        writeThisString += mfid.readline() # obj name and id
                        writeThisString += '\x00'
                        writeThisString += mfid.readline() # function name and args
                        writeThisString += '\x00'
                        writeThisString += mfid.readline() # target
                        writeThisString += '\x00'
                        writeThisString += mfid.readline() # current
                        writeThisString += '\x00'
                        line = mfid.readline() # Read next line. newline if no more rng calls, otherwise next call number.
                        
                    with open(splitPath + "rngfile" + str(thisFrame) + ".txt", "w") as sfid:
                        sfid.write(writeThisString)
                    
                    
                else: # compressed
                    writeThisBuffer = b''                    
                    line = mfid.readline()
                    
                    
                    while len(line) > 0 and line[0].isdigit(): # repeats if there's another rng call, relies on short circuiting at eof
                        
                        callNumber = int(line)
                        
                        line = mfid.readline()
                        objName =  line.split('(')[0]
                        instID = int(line.split('(')[1].strip(")\n"))
                        
                        line = mfid.readline()
                        callType = line.split('(')[0]
                        arguments = line.split('(')[1].strip(")\n").split(", ") # a list of the arguments, only one element for random
                        
                        line = mfid.readline()
                        current = line.strip("Current: ").strip("\n")
                        
                        line = mfid.readline()
                        target = line.strip("Target: ").strip("\n")

                        # Add to the call number if wildcard
                        if target == '*':
                            callNumber += 2147483648
                        
                        # Construct the call name and num args byte
                        if callType == "random":
                            callArgsByte = 0
                        else:
                            callArgsByte = 128 + len(arguments)
                            
                        # Append to the buffer
                        writeThisBuffer += (callNumber).to_bytes(4, byteorder = "little")
                        writeThisBuffer += nullTerminatedEncode(objName)
                        writeThisBuffer += (instID).to_bytes(4, byteorder = "little")
                        writeThisBuffer += (callArgsByte).to_bytes(1, byteorder = "little")
                        
                        if callType == "random":
                            writeThisBuffer += pack("<d", float(arguments[0]))
                            writeThisBuffer += pack("<d", float(current))
                            if target != '*':
                                writeThisBuffer += pack("<d", float(target))
                            
                            
                        else:
                            for arg in arguments:
                                writeThisBuffer += nullTerminatedEncode(arg)
                            writeThisBuffer += (int(current)).to_bytes(1, byteorder = "little")
                            if target != '*':
                                writeThisBuffer += (int(target)).to_bytes(1, byteorder = "little")
                                
                        # Now this rng call's data has been appended to writeThisBuffer
                        line = mfid.readline()
                        
                    # Now all rng call data has been appended to writeThisBuffer and line contains the newline before the next frame
                    with open(splitPath + "rngfile" + str(thisFrame) + ".txt", "wb") as sfid:
                        sfid.write(writeThisBuffer)
                        
elif selection == 3:
    rngSettingsGenerator()

elif selection == 4:
    
    # Mode
    selection = makeSelection(['1','2', ''], "Select from the following options:\
\n1. Recording mode (default)\
\n2. Playback mode\n")
    if selection == 1:
        rngMode = '"recording"'
    elif selection == 2:
        rngMode = '"playback"'
    else:
        rngMode = '"recording"'
    print("You selected " + rngMode + ".")
    
    
    # Recording mode
    selection = makeSelection(['1','2', ''], "1. Wildcard mode (default)\
\n2. Specified mode\n")
    if selection == 1:
        rngRecordingMode = '"wildcard"'
    elif selection == 2:
        rngRecordingMode = '"specified"'
    else:
        rngRecordingMode = '"wildcard"'
    print("You selected " + rngRecordingMode + ".")
    
    
    # Filter
    selection = makeSelection(['1','2', ''], "1. Basic filter on (default)\
\n2. Basic filter off\n")
    if selection == 1:
        rngFilter = '"on"'
    elif selection == 2:
        rngFilter = '"off"'
    else:
        rngFilter = '"on"'
    print("You selected " + rngFilter + ".")
    
    
    # Aggressive filter
    selection = makeSelection(['1','2', ''], "1. Aggressive filter on (default)\
\n2. Aggressive filter off\n")
    if selection == 1:
        rngAggressiveFilter = '"on"'
    elif selection == 2:
        rngAggressiveFilter = '"off"'
    else:
        rngAggressiveFilter = '"on"'
    print("You selected " + rngAggressiveFilter + ".")
    
    
    # Placebo mode
    selection = makeSelection(['1','2', ''], "1. Placebo mode off (default)\
\n2. Placebo mode on\n")
    if selection == 1:
        rngPlacebo = '"off"'
    elif selection == 2:
        rngPlacebo = '"on"'
    else:
        rngPlacebo = '"off"'
    print("You selected " + rngPlacebo + ".")
    
    
    # Buffer format
    selection = makeSelection(['1','2', ''], "1. Compressed buffer format (default)\
\n2. Expanded buffer format\n")
    if selection == 1:
        rngBufferFormat = '"compressed"'
    elif selection == 2:
        rngBufferFormat = '"expanded"'
    else:
        rngBufferFormat = '"compressed"'
    print("You selected " + rngBufferFormat + ".")
    
        
    rngSettingsGenerator(rngMode, rngRecordingMode, rngFilter, rngAggressiveFilter, rngPlacebo, rngBufferFormat)
    
elif selection == 5:
    print("There are currently no script settings, but this will be where you can access them in the future.")

elif selection == 6:
    print("Deleting rngdata.ini")
    try:
        remove("rngdata.ini")
    except FileNotFoundError:
        pass
    print("Deleting recorded rng files")
    try:
        rmtree("default")
    except FileNotFoundError:
        pass
    print("Setting rngsettings.ini for recording")
    rngSettingsGenerator()
    
elif selection == 7:
    pass # Just exit

input("\nPress enter to exit.")