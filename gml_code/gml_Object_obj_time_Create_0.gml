up = 0
down = 0
left = 0
right = 0
quit = 0
try_up = 0
try_down = 0
try_left = 0
try_right = 0
canquit = 1
h_skip = 0
j_xpos = 0
j_ypos = 0
j_dir = 0
j_fr = 0
j_fl = 0
j_fu = 0
j_fd = 0
j_fr_p = 0
j_fl_p = 0
j_fu_p = 0
j_fd_p = 0
for (i = 0; i < 12; i += 1)
{
    j_prev[i] = 0
    j_on[i] = 0
}
global.button0 = 2
global.button1 = 1
global.button2 = 4
global.analog_sense = 0.15
global.analog_sense_sense = 0.01
global.joy_dir = 0
ini_open("config.ini")
b0_i = ini_read_real("joypad1", "b0", -1)
b1_i = ini_read_real("joypad1", "b1", -1)
b2_i = ini_read_real("joypad1", "b2", -1)
as_i = ini_read_real("joypad1", "as", -1)
jd_i = ini_read_real("joypad1", "jd", -1)
if (b0_i >= 0)
    global.button0 = b0_i
if (b1_i >= 0)
    global.button1 = b1_i
if (b2_i >= 0)
    global.button2 = b2_i
if (as_i >= 0)
    global.analog_sense = as_i
if (jd_i >= 0)
    global.joy_dir = jd_i
ini_close()
debug_r = 0
debug_f = 0
j1 = 0
j2 = 0
ja = 0
j_ch = 0
jt = 0
spec_rtimer = 0
global.rngfile = "rngfile"
ini_open("rngsettings.ini")
global.rngmode = ini_read_string("Settings", "mode", "recording")
global.rngrecordingmode = ini_read_string("Settings", "recordingmode", "wildcard")
global.rngfilter = ini_read_string("Settings", "filter", "on")
global.rngaggressive = ini_read_string("Settings", "aggressive_filter", "on")
global.rngplacebo = ini_read_string("Settings", "placebo", "off")
global.rngbufferformat = ini_read_string("Settings", "buffer_format", "compressed")
ini_close()
ini_open("rngdata.ini")
global.rngframe = ini_read_real("Data", "frame", 1)
global.rngcallcounter = ini_read_real("Data", "call", 1)
global.rngmaxsize = ini_read_real("Recording_Settings", "buffer_size", 1)
global.rngsize = global.rngmaxsize
if (global.rngframe == 1)
{
    ini_write_real("Data", "desyncframe", 0)
    ini_write_real("Data", "desynccall", 0)
    global.rngdesync = 0
    global.rngdesyncframe = 0
}
else
{
    global.rngdesyncframe = ini_read_real("Data", "desyncframe", 0)
    global.rngdesync = 1
}
global.rngline = 0
if (global.rngmode == "recording")
{
    if (global.rngbufferformat == "expanded")
        global.rngbuffer = buffer_create(global.rngmaxsize, buffer_grow, 1)
    else if (global.rngbufferformat == "compressed")
        global.rngbuffer = buffer_create(global.rngmaxsize, buffer_grow, 1)
    ini_write_real("Recording_Settings", "version", 1)
    ini_write_string("Recording_Settings", "buffer_format", global.rngbufferformat)
}
ini_close()
global.rngtext = ""
global.rngcheck = ""
if (global.rngmode == "playback")
{
    if (global.rngbufferformat == "expanded")
    {
        global.rngbuffer = buffer_create(global.rngmaxsize, buffer_grow, 1)
        buffer_load_ext(global.rngbuffer, (("default\\" + (global.rngfile + string(global.rngframe))) + ".txt"), 0)
    }
    else if (global.rngbufferformat == "compressed")
    {
        global.rngbuffer = buffer_create(global.rngmaxsize, buffer_grow, 1)
        buffer_load_ext(global.rngbuffer, (("default\\" + (global.rngfile + string(global.rngframe))) + ".txt"), 0)
    }
}
global.rngfailures = 0
global.rnglastfailure = 0
global.rngfirstfailure = 0
