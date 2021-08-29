package com.light.timetable.utils;

import org.jetbrains.annotations.Nullable;

import java.io.File;

public class FileUtils {
    private FileUtils() {
    }

    public static boolean createFileParentDir(String filePath) {
        return createDir(new File(filePath).getParent());
    }

    public static boolean createDir(String dirPath) {
        File file = new File(dirPath);
        return file.exists() || file.mkdirs();
    }

    public static String concatDirAndFile(String dirPath, String name) {
        return dirPath + File.separator + name;
    }

    public static String getExtension(@Nullable String name) {
        if (TextUtils.isEmpty(name)) {
            return "";
        }
        int index = name.lastIndexOf('.');
        if (index == -1) {
            return "";
        } else {
            return name.substring(index + 1);
        }
    }
}
