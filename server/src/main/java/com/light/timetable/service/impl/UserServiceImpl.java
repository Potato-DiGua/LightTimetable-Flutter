package com.light.timetable.service.impl;

import com.light.timetable.entity.User;
import com.light.timetable.mapper.UserMapper;
import com.light.timetable.service.ImageService;
import com.light.timetable.service.UserService;
import com.light.timetable.utils.FileUtils;
import com.light.timetable.utils.MD5Utils;
import com.light.timetable.utils.TextUtils;
import com.light.timetable.utils.Utils;
import org.jetbrains.annotations.NotNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.InputStream;


@Service
public class UserServiceImpl implements UserService {
    private final UserMapper userMapper;
    private final ImageService imageService;

    @Autowired
    public UserServiceImpl(UserMapper userMapper, ImageService imageService) {
        this.userMapper = userMapper;
        this.imageService = imageService;
    }

    @Override
    public User getUser(String account) {
        return userMapper.getUser(account);
    }

    @Override
    public User getUserById(int id) {
        return userMapper.getUserById(id);
    }

    @Override
    public int registerUser(User user) {
        user.setPassword(MD5Utils.MD5(user.getPassword()));
        return userMapper.registerUser(user);
    }

    @NotNull
    @Override
    public String uploadUserIcon(InputStream inputStream, String name, int userID) {
        String newName = Utils.getUUID() + "." + FileUtils.getExtension(name);

        if (imageService.saveImage(inputStream, newName)) {
            String oldIcon = userMapper.getIconById(userID);
            if (TextUtils.isNotEmpty(oldIcon)) {
                imageService.deleteImage(oldIcon);
            }
            userMapper.updateIconById(userID, newName);
            return newName;
        } else {
            return "";
        }

    }
}
