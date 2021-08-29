package com.light.timetable.utils;

import org.jetbrains.annotations.NotNull;

import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class MD5Utils {

    public static String MD5(@NotNull String s){

        byte[] secretBytes = null;

        try {
            secretBytes = MessageDigest.getInstance("md5")
                    .digest(s.getBytes(StandardCharsets.UTF_8));
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        assert secretBytes != null;
        StringBuilder code = new StringBuilder(new BigInteger(1, secretBytes).toString(16));
        for (int i = 0; i < 32 - code.length(); i++) {
            code.insert(0, "0");
        }
        return code.toString();
    }

}
