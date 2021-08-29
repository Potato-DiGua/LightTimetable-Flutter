package com.light.timetable.service;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.io.FileNotFoundException;
import java.io.InputStream;

public interface ImageService {
    boolean saveImage(@NotNull InputStream inputStream, String name);

    boolean saveImage(@NotNull byte[] data, String name);

    @NotNull
    byte[] getImage(String name);

    @Nullable
    InputStream getImageInputStream(String name) throws FileNotFoundException;

    boolean deleteImage(@NotNull String name);
}
