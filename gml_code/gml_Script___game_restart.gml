if (global.rngmode == "recording")
{
    if (global.rngbufferformat == "expanded")
    {
        global.rngsize = buffer_tell(global.rngbuffer)
        buffer_save_ext(global.rngbuffer, ("default\\" + ((global.rngfile + string(global.rngframe)) + ".txt")), 0, global.rngsize)
        if (global.rngsize > global.rngmaxsize)
        {
            global.rngmaxsize = global.rngsize
            ini_open("rngdata.ini")
            ini_write_real("Recording_Settings", "buffer_size", global.rngmaxsize)
            ini_close()
        }
        buffer_seek(global.rngbuffer, buffer_seek_start, 0)
    }
    else if (global.rngbufferformat == "compressed")
    {
        global.rngsize = buffer_tell(global.rngbuffer)
        buffer_save_ext(global.rngbuffer, ("default\\" + ((global.rngfile + string(global.rngframe)) + ".txt")), 0, global.rngsize)
        if (global.rngsize > global.rngmaxsize)
        {
            global.rngmaxsize = global.rngsize
            ini_open("rngdata.ini")
            ini_write_real("Recording_Settings", "buffer_size", global.rngmaxsize)
            ini_close()
        }
        buffer_seek(global.rngbuffer, buffer_seek_start, 0)
    }
}
else if (global.rngmode == "playback")
{
    if (global.rngbufferformat == "expanded")
    {
        buffer_seek(global.rngbuffer, buffer_seek_start, 0)
        buffer_load_ext(global.rngbuffer, (("default\\" + (global.rngfile + string((global.rngframe + 1)))) + ".txt"), 0)
    }
    else if (global.rngbufferformat == "compressed")
    {
        buffer_seek(global.rngbuffer, buffer_seek_start, 0)
        buffer_load_ext(global.rngbuffer, (("default\\" + (global.rngfile + string((global.rngframe + 1)))) + ".txt"), 0)
    }
}
global.rngframe += 1
ini_open("rngdata.ini")
ini_write_real("Data", "frame", global.rngframe)
ini_write_real("Data", "call", global.rngcallcounter)
ini_close()
if (global.rngdesync && global.rngmode == "playback" && global.rngdesyncframe != 0)
{
    draw_set_color(c_red)
    draw_text(10, 10, ("Desync at frame " + string(global.rngdesyncframe)))
}
game_restart()
