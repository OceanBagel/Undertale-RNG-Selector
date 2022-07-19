# Undertale-RNG-Selector
This is a tool for RNG manipulation in Undertale tool-assisted speedruns.
Undertale RNG Selector currently only supports Undertale v1.001 Linux.

The end goal of this tool is to be able to manipulate Undertale's RNG automatically, searching for the best possible RNG within the given parameters.
Given how complex this goal is, this tool will be released in stages.

- Stage 1: Basic RNG recording and playback functionality, allowing modification of RNG calls and playback of those modified RNG calls in a TAS.

- Stage 2: Add features to facilitate manual RNG searching, including start time-based searches.

- Stage 3: Add automation features for RNG searches.

- Stage 4+: TBD

Undertale RNG Selector is currently at Stage 1.

---

## What does it do?

The main functionality of Undertale RNG Selector is to record every RNG call in the TAS, allow modifications to these calls, and then play back the TAS with the RNG call modifications.
For example, you can program in perfect Ruins RNG and that's what you will get, regardless of what the actual RNG calls were.

Undertale RNG Selector works in two parts: a game mod and a Python script.
The game mod handles both recording RNG calls and replaying them back, depending on the settings.
The Python script has several functions for manipulating settings, as well as taking the files recorded by the game mod and merging them together into a more readable format.

---

## How is it installed?

First, apply the code changes to the 1.001 Linux game.unx, either by using [Floating IPS](https://www.smwcentral.net/?a=details&id=11474&p=section) to install the patch (included in the releases) or through importing the gml code using [UndertaleModTool](https://github.com/krzys-h/UndertaleModTool).

Note: if you're using the gml files, you must also check the `Visible` box under `obj_time` and change all of the following everywhere in the game's code:
- `random(`
- `choose(`
- `game_restart(`
- `game_end(`

to:
- `__random(`
- `__choose(`
- `__game_restart(`
- `__game_end(`

After applying the code changes, place the Python script in your Undertale save folder.

---

## How is it used?

Open a terminal in your save folder and run `python3 rng_selector_conversion_script.py` to run the script, installing dependencies as needed.
For initial recording, you'll want to select option 6.
This will generate an `rngsettings.ini` file which contains various recording and playback settings.
You can also use option 4 to walk through each of these settings.

Once you have all the files prepared, play your TAS through the mod with "Prevent write to disk" disabled.
You will see the file `rngdata.ini` and the folder `default` appear in your save folder.
It is recommended to not open `default` as it can contain a large number of files.

After you reach the end of your TAS (or as far as you want to record), stop the game and run the script again.
Then select option 1.
This generates the file `rngfile.txt` which contains all of the recorded calls in one file.
You can then edit the values listed as "Target" in this file.
Once you've saved all your changes, run the script and select option 2.
This splits up the file back into individual files in the `default` folder and prepares the ini files for playback.
Finally, you can run your TAS with the mod one more time and it will execute with your RNG modifications.

---

## What are its current limitations?

The main limitation is that the number of RNG calls must exactly match for playback to function.
Tool desyncs (not TAS desync) will occur if you change the number of RNG calls at all.
The tool detects desyncs through a simple count of the number of recorded RNG calls, and reverts to the game's RNG calls if it detects a desync.
This is significantly mitigated by the filtering settings, the basic one filtering out meaningless calls like choose with a single argument and the aggressive one filtering out mostly useless calls like text RNG.
But you will almost certainly experience problems with this version of the tool if you try to play back RNG files after making modifications to the TAS.

There is also no check put in place to ensure that modified RNG calls are within bounds.
It is up to the user to ensure that modified RNG calls are within the parameters requested by the game.
Otherwise, unexpected results or crashes may occur.

Undertale RNG Selector is also currently restricted to Undertale v1.001 Linux.
It's possible that other versions may work, possibly even with little to no modification of the gml code.
However, only v1.001 Linux has been tested so far so it is not guaranteed to work with other versions.
