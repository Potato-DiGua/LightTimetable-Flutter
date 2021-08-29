package com.light.timetable.controller;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.light.timetable.entity.Course;
import com.light.timetable.model.ResponseWrap;
import com.light.timetable.model.college.RandomImg;
import com.light.timetable.service.CalendarService;
import com.light.timetable.service.colleges.College;
import com.light.timetable.service.colleges.CollegeFactory;
import com.light.timetable.share.SessionKey;
import com.light.timetable.utils.RedisUtil;
import com.light.timetable.utils.TextUtils;
import org.jetbrains.annotations.NotNull;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

/**
 * 教务系统接口
 */
@RestController
@CrossOrigin
@RequestMapping("/college")
public class CollegeController {


    private final Logger logger = LoggerFactory.getLogger(getClass());
    private final CalendarService calendarService;
    private final RedisUtil redisUtil;

    @Autowired
    public CollegeController(CalendarService calendarService, RedisUtil redisUtil) {
        this.calendarService = calendarService;
        this.redisUtil = redisUtil;
    }

    /**
     * 获取验证码长度
     *
     * @param collegeName
     * @return
     */
    @GetMapping("/random-code-length")
    public ResponseWrap<Integer> getRandomCodeLength(@RequestParam("collegeName") String collegeName) {
        ResponseWrap<Integer> resp = new ResponseWrap<>();
        College college = CollegeFactory.createCollege(collegeName);
        if (college == null) {
            return resp.setStatus(1)
                    .setMsg("暂不支持" + collegeName);
        } else {
            return resp.setStatus(0)
                    .setData(college.getRandomCodeMaxLength());
        }

    }

    /**
     * 获取验证码
     *
     * @return
     */
    @GetMapping("/random-img-base64")
    public ResponseWrap<RandomImg> getRandomImgBase64(@RequestParam("collegeName") String collegeName, @RequestAttribute(SessionKey.USER) int userID) {
        College college = CollegeFactory.createCollege(collegeName);
        if (college == null) {
            return ResponseWrap.error("暂不支持" + collegeName);
        }

        String cookie = getCookie(userID, college);
        ResponseWrap<RandomImg> responseWrap = new ResponseWrap<>();
        String base64 = Base64.getMimeEncoder()
                .encodeToString(college.getRandomCodeImg(cookie));
        responseWrap.setData(new RandomImg(base64));
        responseWrap.setStatus(0);
        if (TextUtils.isEmpty(base64)) {
            logger.error("没有获取到验证码");
            responseWrap.setStatus(1);
            responseWrap.setMsg("没有获取到验证码");
        } else {
            responseWrap.setStatus(0);
        }

        return responseWrap;
    }

    /**
     * 获取验证码
     *
     * @param collegeName 学校名
     * @return
     */
    @GetMapping(value = "/random-img", produces = {MediaType.IMAGE_JPEG_VALUE, MediaType.IMAGE_PNG_VALUE})
    public byte[] getRandomImg(@RequestParam("collegeName") String collegeName, @RequestAttribute(SessionKey.USER) int userID) {
        College college = CollegeFactory.createCollege(collegeName);
        if (college == null) {
            return new byte[0];
        }
        return college.getRandomCodeImg(getCookie(userID, college));
    }

    private String getCookie(int userID, College college) {
        String cookie = getCookieFromRedis(userID);
        if (TextUtils.isEmpty(cookie)) {
            cookie = college.getCookie();
            redisUtil.set("user:" + userID, cookie, 60 * 30);//30分钟过期
        }
        return cookie;
    }

    /**
     * 登录教务系统
     *
     * @param collegeName 学校名
     * @param account     学号
     * @param pwd         密码
     * @param randomCode  验证码
     * @return
     */
    @PostMapping("/login")
    public ResponseWrap<Boolean> login(@RequestAttribute(SessionKey.USER) int userID,
                                       @RequestParam("collegeName") String collegeName,
                                       @RequestParam("account") String account,
                                       @RequestParam("password") String pwd,
                                       @RequestParam("randomCode") String randomCode) {
        College college = CollegeFactory.createCollege(collegeName);
        if (college == null) {
            return ResponseWrap.error("暂不支持" + collegeName);
        }
        String cookie = getCookieFromRedis(userID);

        ResponseWrap<Boolean> responseWrap = new ResponseWrap<>();

        if (college.isLogin(cookie)) {
            responseWrap.setData(true);
        } else {
            responseWrap.setData(college.login(account, pwd, randomCode, cookie));
        }

        if (responseWrap.getData()) {
            responseWrap.setStatus(0);

            List<String> terms = college.getTermOptions(cookie);
            List<String> courses = new ArrayList<>(terms.size());

            Gson gson = new Gson();
            for (String term : terms) {
                List<Course> list = college.getCourses(term, cookie);
                list.sort(Course::compareTo);
                courses.add(gson.toJson(list));
            }

            // 保存课表
            int size = calendarService.updateCalendar(userID, terms, courses);
            if (size <= 0) {
                responseWrap.setData(false).setMsg("导入课程表出错");
            }

        } else {
            logger.error("登陆失败,cookie=" + cookie);
            responseWrap.setStatus(1);
            responseWrap.setMsg("登陆失败");
        }
        return responseWrap;
    }

    /**
     * 获取学期选项
     *
     * @return
     */
    @GetMapping("/term-options")
    public ResponseWrap<List<String>> getTermOptions(@RequestAttribute(SessionKey.USER) int userID) {
        ResponseWrap<List<String>> resp = new ResponseWrap<>();
        List<String> termOptions = calendarService.getTerms(userID);
        if (termOptions.size() <= 0) {
            resp.setStatus(1)
                    .setMsg("请先登录！");
        } else {
            resp.setStatus(0)
                    .setData(termOptions);
        }
        return resp;
    }

    /**
     * 获取课程表
     *
     * @param term 学期
     * @return
     */
    @GetMapping("/timetable")
    public ResponseWrap<List<Course>> getCourses(@RequestParam("term") String term,
                                                 @RequestAttribute(SessionKey.USER) int userID
    ) {
        ResponseWrap<List<Course>> resp = new ResponseWrap<>();
        return resp.setStatus(0)
                .setData(new Gson().fromJson(calendarService.getCalendar(userID, term), new TypeToken<List<Course>>() {
                }.getType()));
    }

    /**
     * 判断是否登录
     *
     * @param collegeName 学校名字
     * @return
     */
    @GetMapping("/is-login")
    public ResponseWrap<Boolean> isLogin(@RequestParam("collegeName") String collegeName, @RequestAttribute(SessionKey.USER) int userID) {
        College college = CollegeFactory.createCollege(collegeName);
        if (college == null) {
            return ResponseWrap.error("暂不支持" + collegeName);
        }
        return new ResponseWrap<Boolean>().setData(college.isLogin(getCookieFromRedis(userID)))
                .setStatus(0);
    }

    @NotNull
    public String getCookieFromRedis(int userID) {
        Object obj = redisUtil.get("user:" + userID);
        if (obj instanceof String) {
            return (String) obj;
        }
        return "";
    }
}
