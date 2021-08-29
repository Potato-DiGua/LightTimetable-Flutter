package com.light.timetable.properties;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "image")
public class ImageProperties {
    private final Logger logger = LoggerFactory.getLogger(getClass());
    private String savePath;

    public String getSavePath() {
        return savePath;
    }

    public void setSavePath(String savePath) {
        this.savePath = savePath;
        logger.info("图片保存路径: " + savePath);
    }
}
