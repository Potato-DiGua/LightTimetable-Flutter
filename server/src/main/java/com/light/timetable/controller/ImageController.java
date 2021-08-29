package com.light.timetable.controller;

import com.light.timetable.annotations.PassAuth;
import com.light.timetable.service.ImageService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;

@RestController
@RequestMapping("/image")
public class ImageController {
    private final Logger logger = LoggerFactory.getLogger(getClass());
    private final ImageService imageService;

    @Autowired
    public ImageController(ImageService imageService) {
        this.imageService = imageService;
    }


    @PassAuth
    @GetMapping(value = "/{name}", produces = {MediaType.IMAGE_JPEG_VALUE, MediaType.IMAGE_PNG_VALUE})
    public void getImage(@PathVariable("name") String name, HttpServletResponse response) {
        try {
            InputStream inputStream = imageService.getImageInputStream(name);
            if (inputStream == null) {
                response.sendError(404);
                return;
            }
            response.setContentLengthLong(inputStream.available());
            response.setContentType(MediaType.IMAGE_JPEG_VALUE + "; " + MediaType.IMAGE_PNG_VALUE);
            FileCopyUtils.copy(inputStream, response.getOutputStream());
        } catch (IOException e) {
            logger.error(e.getMessage(), e);
        }
    }
}
