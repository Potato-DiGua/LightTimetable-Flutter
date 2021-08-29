package com.light.timetable.utils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.UUID;

public class Utils {
    public static final Logger logger = LoggerFactory.getLogger(Utils.class);

    public static String getIpAddress() {
        InetAddress localHost = null;
        try {
            localHost = Inet4Address.getLocalHost();
        } catch (UnknownHostException e) {
            logger.error(e.getMessage(), e);
        }
        if (localHost == null) {
            return "";
        } else {
            return TextUtils.orEmpty(localHost.getHostAddress(), "");
        }
    }

    public static String getUUID() {
        return UUID.randomUUID().toString().replace("-", "");
    }
}
