package com.light.timetable.controller;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.light.timetable.annotations.PassAuth;
import com.light.timetable.entity.User;
import com.light.timetable.model.ResponseWrap;
import com.light.timetable.model.UserModel;
import com.light.timetable.properties.JwtProperties;
import com.light.timetable.service.ImageService;
import com.light.timetable.service.UserService;
import com.light.timetable.share.SessionKey;
import com.light.timetable.utils.MD5Utils;
import com.light.timetable.utils.UserUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;


/**
 * 用户api
 */
@RestController
@RequestMapping("/user")
public class UserController {
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final UserService userService;
    private final JwtProperties jwtProperties;
    private final ImageService imageService;


    @Autowired
    public UserController(UserService userService, JwtProperties jwtProperties, ImageService imageService) {
        this.userService = userService;
        this.jwtProperties = jwtProperties;
        this.imageService = imageService;
    }

    /**
     * 注册
     *
     * @param account  账户号
     * @param userName 账户昵称
     * @param password 密码
     * @return
     */
    @PassAuth
    @PostMapping("/register")
    public ResponseWrap<Object> register(@RequestParam("account") String account,
                                         @RequestParam("name") String userName,
                                         @RequestParam("password") String password) {
        userName = userName.trim();
        account = account.trim();
        ResponseWrap<Object> responseWrap = new ResponseWrap<>();
        if (account.contains("@")) {
            if (!UserUtils.isEmail(account)) {
                responseWrap.setStatus(1).setMsg("邮箱格式错误").toJson();
            }
        } else {
            if (!UserUtils.isPhone(account)) {
                return responseWrap.setStatus(1).setMsg("手机号格式错误");
            }
        }
        User user = userService.getUser(account);
        if (user != null) {
            responseWrap.setStatus(1);
            responseWrap.setMsg("用户已存在!");
        } else {
            int flag = userService.registerUser(new User(account, userName, password));
            if (flag == 0) {
                responseWrap.setStatus(1).setMsg("注册失败, 请重试!");
            } else {
                responseWrap.setStatus(0).setMsg("注册成功!");
            }
        }
        return responseWrap;
    }

    /**
     * 登录
     *
     * @param account  账号
     * @param password 密码
     * @return
     */
    @PassAuth
    @PostMapping("/login")
    public ResponseWrap<UserModel> login(@RequestParam("account") String account, @RequestParam("password") String password, HttpServletResponse response) {
        User user = userService.getUser(account.trim());
        ResponseWrap<UserModel> responseWrap = new ResponseWrap<>();
        if (user == null) {
            responseWrap.setStatus(1);
            responseWrap.setMsg("用户不存在!");
        } else {
            if (user.getPassword().equals(MD5Utils.MD5(password))) {
                String token = JWT.create()
                        .withAudience(String.valueOf(user.getId()))
                        .withClaim("userName", user.getUserName())
                        .sign(Algorithm.HMAC256(jwtProperties.getKey()));

                responseWrap.setStatus(0).setMsg("登录成功").setData(new UserModel(user).setToken(token));

                Cookie cookie = new Cookie("token", token);
                cookie.setMaxAge(60 * 60 * 24 * 30);
                cookie.setPath("/");

                response.addCookie(cookie);
            } else {
                responseWrap.setStatus(1);
                responseWrap.setMsg("密码错误!");
            }
        }
        return responseWrap;
    }

    /**
     * 获取用户信息
     *
     * @return
     */
    @GetMapping("/info")
    public ResponseWrap<UserModel> getInfo(@RequestAttribute(SessionKey.USER) int userID) {
        User user = userService.getUserById(userID);
        return new ResponseWrap<UserModel>().setStatus(0).setData(new UserModel(user));
    }

    /**
     * 是否登录
     *
     * @return
     */
    @GetMapping("/isLogin")
    public ResponseWrap<Object> isLogin(HttpServletRequest request) {
        return new ResponseWrap<>().setStatus(request.getAttribute(SessionKey.USER) == null ? 1 : 0).setMsg("");
    }

    /**
     * @param file 头像
     * @return 头像的相对路径
     */
    @PostMapping("/upload-icon")
    public ResponseWrap<String> uploadUserIcon(@RequestParam("file") MultipartFile file,
                                               @RequestAttribute(SessionKey.USER) int userID) {
        if (file.getSize() > 1024 * 1024 * 2) {
            return ResponseWrap.error("图片大小不能大于2MB");
        }
        ResponseWrap<String> resp = new ResponseWrap<>();
        try {
            String icon = userService.uploadUserIcon(file.getInputStream(), file.getOriginalFilename(), userID);
            if (!icon.isEmpty()) {
                resp.setStatus(0).setData("/image/" + icon);
            } else {
                resp.setStatus(1).setMsg("服务器保存上传文件失败");
            }
        } catch (IOException e) {
            logger.error(e.getMessage(), e);
            resp.setStatus(1).setMsg("服务器保存上传文件失败");
        }
        return resp;
    }

}
