package com.light.timetable.service.impl;

import com.light.timetable.properties.ImageProperties;
import com.light.timetable.service.ImageService;
import com.light.timetable.utils.FileUtils;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.*;

@Service
public class ImageServiceImpl implements ImageService {
    private final byte[] empty = new byte[0];
    private final Logger logger = LoggerFactory.getLogger(getClass());
    private final ImageProperties imageProperties;

    @Autowired
    public ImageServiceImpl(ImageProperties imageProperties) {
        this.imageProperties = imageProperties;
    }

    @Override
    public boolean saveImage(@NotNull InputStream inputStream, String name) {
        if (!FileUtils.createDir(imageProperties.getSavePath())) {
            try {
                inputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
            return false;
        }
        try (BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(
                getPath(name)))) {
            byte[] buffer = new byte[1024];
            int size;
            while ((size = inputStream.read(buffer, 0, buffer.length)) != -1) {
                bos.write(buffer, 0, size);
            }
            bos.flush();
            return true;
        } catch (IOException e) {
            logger.error(e.getMessage(), e);
        } finally {
            try {
                inputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return false;
    }

    @Override
    public boolean saveImage(@NotNull byte[] data, String name) {
        if (data.length == 0) {
            return true;
        }
        try (BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(
                getPath(name)))) {
            bos.write(data);
            bos.flush();
            return true;
        } catch (IOException e) {
            logger.error(e.getMessage(), e);
        }
        return false;
    }

    @NotNull
    @Override
    public byte[] getImage(String name) {
        try (InputStream inputStream = getImageInputStream(name)) {
            if (inputStream == null) {
                return empty;
            }
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            int size;
            while ((size = inputStream.read(buffer, 0, buffer.length)) != -1) {
                byteArrayOutputStream.write(buffer, 0, size);
            }
            return byteArrayOutputStream.toByteArray();
        } catch (IOException e) {
            logger.error(e.getMessage(), e);
        }
        return empty;
    }

    @Override
    @Nullable
    public InputStream getImageInputStream(String name) {
        final String path = getPath(name);
        try {
            if (!new File(path).exists()) {
                return null;
            } else {
                return new FileInputStream(path);
            }
        } catch (FileNotFoundException e) {
            return null;
        }
    }

    @NotNull
    private String getPath(String name) {
        return FileUtils.concatDirAndFile(imageProperties.getSavePath(), name);
    }

    @Override
    public boolean deleteImage(@NotNull String name) {
        try {
            File file = new File(getPath(name));
            if (!file.exists()) {
                return true;
            }
            return file.delete();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
