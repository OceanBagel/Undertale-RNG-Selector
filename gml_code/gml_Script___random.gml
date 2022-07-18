var i;
ret = random(argument0)
if (global.rngmode == "recording")
{
    if (global.rngplacebo == "off")
    {
        if (global.rngfilter == "off" || (global.rngfilter == "on" && argument0 != 0))
        {
            if (global.rngaggressive == "off" || (global.rngaggressive == "on" && object_get_name(object_index) != "obj_intromenu" && object_get_name(object_index) != "OBJ_WRITER" && object_get_name(object_index) != "OBJ_NOMSCWRITER" && object_get_name(object_index) != "OBJ_INSTAWRITER"))
            {
                if (global.rngbufferformat == "expanded")
                {
                    buffer_write(global.rngbuffer, buffer_string, string(global.rngcallcounter))
                    buffer_write(global.rngbuffer, buffer_string, (((("
" + object_get_name(object_index)) + "(") + string(id)) + "):
"))
                    buffer_write(global.rngbuffer, buffer_string, (("random(" + string(argument0)) + ")
"))
                    buffer_write(global.rngbuffer, buffer_string, (("Current: " + string_format(ret, 1, 8)) + "
"))
                    if (global.rngrecordingmode == "wildcard")
                        buffer_write(global.rngbuffer, buffer_string, "Target: *
")
                    else if (global.rngrecordingmode == "specified")
                        buffer_write(global.rngbuffer, buffer_string, (("Target: " + string_format(ret, 1, 8)) + "
"))
                    global.rngcallcounter += 1
                }
                else if (global.rngbufferformat == "compressed")
                {
                    if (global.rngrecordingmode == "wildcard")
                        buffer_write(global.rngbuffer, buffer_u32, (global.rngcallcounter + 2147483648))
                    else if (global.rngrecordingmode == "specified")
                        buffer_write(global.rngbuffer, buffer_u32, global.rngcallcounter)
                    buffer_write(global.rngbuffer, buffer_string, object_get_name(object_index))
                    buffer_write(global.rngbuffer, buffer_u32, id)
                    buffer_write(global.rngbuffer, buffer_u8, 0)
                    buffer_write(global.rngbuffer, buffer_f64, argument0)
                    buffer_write(global.rngbuffer, buffer_f64, ret)
                    if (global.rngrecordingmode == "specified")
                        buffer_write(global.rngbuffer, buffer_f64, ret)
                    global.rngcallcounter += 1
                }
            }
        }
    }
}
else if (global.rngmode == "playback")
{
    if (global.rngplacebo == "off")
    {
        if (global.rngfilter == "off" || (global.rngfilter == "on" && argument0 != 0))
        {
            if (global.rngaggressive == "off" || (global.rngaggressive == "on" && object_get_name(object_index) != "obj_intromenu" && object_get_name(object_index) != "OBJ_WRITER" && object_get_name(object_index) != "OBJ_NOMSCWRITER" && object_get_name(object_index) != "OBJ_INSTAWRITER"))
            {
                if (global.rngdesync == 0)
                {
                    if (global.rngbufferformat == "expanded")
                    {
                        global.rngcallcheck = real(buffer_read(global.rngbuffer, buffer_string))
                        if (global.rngcallcheck == global.rngcallcounter)
                        {
                            buffer_read(global.rngbuffer, buffer_string)
                            buffer_read(global.rngbuffer, buffer_string)
                            global.rngtext = buffer_read(global.rngbuffer, buffer_string)
                            global.rngtext = string_delete(string(global.rngtext), 1, 8)
                            global.rngcheck = buffer_read(global.rngbuffer, buffer_string)
                            if (string_char_at(global.rngtext, 1) != "*")
                                ret = real(global.rngtext)
                        }
                        else if (global.rngdesync == 0)
                        {
                            global.rngdesync = 1
                            global.rngdesyncframe = global.rngframe
                            ini_open("rngdata.ini")
                            ini_write_real("Data", "desyncframe", global.rngdesyncframe)
                            ini_write_real("Data", "desynccall", global.rngcallcounter)
                            ini_write_real("Data", "desyncexpectedcall", global.rngcallcheck)
                            ini_close()
                        }
                    }
                    else if (global.rngbufferformat == "compressed")
                    {
                        global.rngcallcheck = buffer_read(global.rngbuffer, buffer_u32)
                        global.rngcheck = buffer_read(global.rngbuffer, buffer_string)
                        if ((global.rngcallcheck & 2147483647) == global.rngcallcounter)
                        {
                            buffer_seek(global.rngbuffer, buffer_seek_relative, 21)
                            if (global.rngcallcheck < 2147483648)
                                ret = buffer_read(global.rngbuffer, buffer_f64)
                        }
                        else if (global.rngdesync == 0)
                        {
                            global.rngdesync = 1
                            global.rngdesyncframe = global.rngframe
                            ini_open("rngdata.ini")
                            ini_write_real("Data", "desyncframe", global.rngdesyncframe)
                            ini_write_real("Data", "desynccall", global.rngcallcounter)
                            ini_write_real("Data", "desyncexpectedcall", (global.rngcallcheck & 2147483647))
                            ini_close()
                        }
                    }
                }
                global.rngcallcounter += 1
            }
        }
    }
}
return ret;
