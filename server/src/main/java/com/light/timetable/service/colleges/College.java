package com.light.timetable.service.colleges;

import com.light.timetable.entity.Course;
import okhttp3.Request;

import java.util.List;

public interface College {
    /**
     * 获取学校名字
     *
     * @return
     */
    String getCollegeName();

    /**
     * 登录
     *
     * @param account
     * @param pw
     * @param RandomCode 可为NULL，根据实际情况填写
     * @return 返回是否登录成功
     */
    boolean login(String account, String pw, String RandomCode, String cookie);

    /**
     * 获取课程
     *
     * @param term 课程学期
     * @return
     */
    List<Course> getCourses(String term, String cookie);

    /**
     * 获取验证码的base64
     *
     * @return
     */
    byte[] getRandomCodeImg(String cookie);

    /**
     * 获取课程学期选项
     *
     * @return
     */
    List<String> getTermOptions(String cookie);

    /**
     * 判断是否已经登陆
     *
     * @return
     */
    boolean isLogin(String cookie);

    /**
     * 配置okhttp是否自动重定向
     *
     * @return
     */
    boolean getFollowRedirects();

    /**
     * @return 验证码长度
     */
    int getRandomCodeMaxLength();

    /**
     * @return 返回cookie
     */
    String getCookie();

    default Request createRequestWithCookie(String url, String cookie) {
        return new Request
                .Builder()
                .url(url)
                .addHeader("Cookie", cookie)
                .build();
    }
}
