package com.light.timetable.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class User {

    private int id;

    private String userName;

    private String password;

    private String account;

    // 头像文件名
    private String icon;

    public User(String userName, String password) {
        this.userName = userName;
        this.password = password;
    }

    public User(int id, String userName, String password) {
        this.id = id;
        this.userName = userName;
        this.password = password;
    }

    public User(String account, String userName, String password){
        this.account = account;
        this.userName = userName;
        this.password = password;
    }

}
