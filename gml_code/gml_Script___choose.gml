var iii;
switch argument_count
{
    case 1:
        ret = choose(0)
        break
    case 2:
        ret = choose(0, 1)
        break
    case 3:
        ret = choose(0, 1, 2)
        break
    case 4:
        ret = choose(0, 1, 2, 3)
        break
    case 5:
        ret = choose(0, 1, 2, 3, 4)
        break
    case 6:
        ret = choose(0, 1, 2, 3, 4, 5)
        break
    case 7:
        ret = choose(0, 1, 2, 3, 4, 5, 6)
        break
    case 8:
        ret = choose(0, 1, 2, 3, 4, 5, 6, 7)
        break
    case 9:
        ret = choose(0, 1, 2, 3, 4, 5, 6, 7, 8)
        break
    case 10:
        ret = choose(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
        break
    case 11:
        ret = choose(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
        break
    case 12:
        ret = choose(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)
        break
    case 13:
        ret = choose(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
        break
    case 14:
        ret = choose(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13)
        break
    case 15:
        ret = choose(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
        break
    case 16:
        ret = choose(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
        break
}

if (global.rngmode == "recording")
{
    if (global.rngplacebo == "off")
    {
        if (global.rngfilter == "off" || (global.rngfilter == "on" && argument_count != 1))
        {
            if (global.rngaggressive == "off" || (global.rngaggressive == "on" && object_get_name(object_index) != "obj_intromenu" && object_get_name(object_index) != "OBJ_WRITER" && object_get_name(object_index) != "OBJ_NOMSCWRITER" && object_get_name(object_index) != "OBJ_INSTAWRITER"))
            {
                if (global.rngbufferformat == "expanded")
                {
                    buffer_write(global.rngbuffer, buffer_string, string(global.rngcallcounter))
                    buffer_write(global.rngbuffer, buffer_string, (((("
" + object_get_name(object_index)) + "(") + string(id)) + "):
"))
                    global.rngchoosetext = "choose("
                    for (iii = 0; iii < argument_count; iii += 1)
                    {
                        global.rngchoosetext += string(argument[iii])
                        if (iii < (argument_count - 1))
                            global.rngchoosetext += ", "
                    }
                    global.rngchoosetext += ")
"
                    buffer_write(global.rngbuffer, buffer_string, global.rngchoosetext)
                    buffer_write(global.rngbuffer, buffer_string, (("Current: " + string(ret)) + "
"))
                    if (global.rngrecordingmode == "wildcard")
                        buffer_write(global.rngbuffer, buffer_string, "Target: *
")
                    else if (global.rngrecordingmode == "specified")
                        buffer_write(global.rngbuffer, buffer_string, (("Target: " + string(ret)) + "
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
                    buffer_write(global.rngbuffer, buffer_u8, (128 + argument_count))
                    for (iii = 0; iii < argument_count; iii += 1)
                        buffer_write(global.rngbuffer, buffer_string, string(argument[iii]))
                    buffer_write(global.rngbuffer, buffer_u8, ret)
                    if (global.rngrecordingmode == "specified")
                        buffer_write(global.rngbuffer, buffer_u8, ret)
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
        if (global.rngfilter == "off" || (global.rngfilter == "on" && argument_count != 1))
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
                            buffer_seek(global.rngbuffer, buffer_seek_relative, 4)
                            iii = (buffer_read(global.rngbuffer, buffer_u8) - 128)
                            repeat iii
                                buffer_read(global.rngbuffer, buffer_string)
                            buffer_seek(global.rngbuffer, buffer_seek_relative, 1)
                            if (global.rngcallcheck < 2147483648)
                                ret = buffer_read(global.rngbuffer, buffer_u8)
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
return argument[ret];
