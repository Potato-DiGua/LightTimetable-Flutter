package com.light.timetable.model;

import com.light.timetable.entity.User;

public class UserModel {
    private int id;
    private String userName;
    private String account;
    private String token;
    private String iconUrl;

    public UserModel() {
    }

    public UserModel(User user) {
        this.account = user.getAccount();
        this.userName = user.getUserName();
        this.id = user.getId();
        this.iconUrl = "/image/" + user.getIcon();
    }

    public String getToken() {
        return token;
    }

    public UserModel setToken(String token) {
        this.token = token;
        return this;
    }


    public int getId() {
        return id;
    }

    public UserModel setId(int id) {
        this.id = id;
        return this;
    }

    public String getUserName() {
        return userName;
    }

    public UserModel setUserName(String userName) {
        this.userName = userName;
        return this;
    }

    public String getAccount() {
        return account;
    }

    public UserModel setAccount(String account) {
        this.account = account;
        return this;
    }

    public String getIconUrl() {
        return iconUrl;
    }

    public void setIconUrl(String iconUrl) {
        this.iconUrl = iconUrl;
    }
}
