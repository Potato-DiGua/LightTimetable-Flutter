package com.light.timetable.utils;

public class TextUtils {
    private TextUtils() {
    }

    public static boolean isEmpty(String text) {
        return text == null || text.isEmpty();
    }

    public static boolean isNotEmpty(String text) {
        return !isEmpty(text);
    }

    public static String orEmpty(String text, String defaultValue) {
        return isEmpty(text) ? defaultValue : text;
    }

}
