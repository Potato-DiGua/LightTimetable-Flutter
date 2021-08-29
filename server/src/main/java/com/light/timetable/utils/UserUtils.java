package com.light.timetable.utils;

import java.util.regex.Pattern;

public class UserUtils {

    public static boolean isPhone(String phone){
        return Pattern
                .compile("^[1][3,4,5,7,8][0-9]{9}$")
                .matcher(phone).matches();
    }

    public static boolean isEmail(String email){
        return Pattern
                .compile("^\\\\s*\\\\w+(?:\\\\.{0,1}[\\\\w-]+)*@[a-zA-Z0-9]+(?:[-.][a-zA-Z0-9]+)*\\\\.[a-zA-Z]+\\\\s*$")
                .matcher(email).matches();
    }

}
