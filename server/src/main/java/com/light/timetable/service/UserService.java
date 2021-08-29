package com.light.timetable.service;

import com.light.timetable.entity.User;
import org.jetbrains.annotations.NotNull;

import java.io.InputStream;

public interface UserService {

    User getUser(String account);

    User getUserById(int id);

    int registerUser(User user);

    /**
     * @param inputStream 文件输入流
     * @param name        上传文件名
     * @param userID      用户id
     * @return
     */
    @NotNull
    String uploadUserIcon(InputStream inputStream, String name, int userID);
}
