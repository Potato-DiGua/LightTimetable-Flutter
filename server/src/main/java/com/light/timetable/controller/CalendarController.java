package com.light.timetable.controller;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.google.gson.reflect.TypeToken;
import com.light.timetable.annotations.PassAuth;
import com.light.timetable.entity.Course;
import com.light.timetable.model.ResponseWrap;
import com.light.timetable.model.ShareModel;
import com.light.timetable.service.CalendarService;
import com.light.timetable.share.SessionKey;
import com.light.timetable.utils.ListUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 获取课程表
 */
@RestController
@RequestMapping("/calendar")
public class CalendarController {
    private final Logger logger = LoggerFactory.getLogger(getClass());

    //服务端口号
    @Value("${server.port}")
    private String serverPort;

    private final CalendarService calendarService;

    @Autowired
    public CalendarController(CalendarService calendarService) {
        this.calendarService = calendarService;
    }

    /**
     * 获取课程表
     *
     * @param term 学期
     * @return 课程表
     */
    @GetMapping("/getCalendar")
    public ResponseWrap<String> getCalendar(@RequestAttribute(SessionKey.USER) int userID, String term) {
        ResponseWrap<String> responseWrap = new ResponseWrap<>();
        responseWrap
                .setStatus(0).setData(calendarService.getCalendar(userID, term));
        return responseWrap;
    }


    /**
     * 分享课程表
     *
     * @param calendar 课程表json列表
     * @return
     */
    @PostMapping("/shareCalendar")
    @ResponseBody
    public ResponseWrap<ShareModel> sharedCalendar(@RequestAttribute(SessionKey.USER) int userID,
                                                   @RequestParam("calendar") String calendar) {
        ResponseWrap<ShareModel> responseWrap = new ResponseWrap<>();
        try {
            List<Course> list = new Gson().fromJson(calendar, new TypeToken<List<Course>>() {
            }.getType());
            if (ListUtils.isEmpty(list)) {
                return responseWrap.setStatus(1).setMsg("课程表为空");
            }
        } catch (JsonSyntaxException e) {
            logger.error(e.getMessage(), e);
            return responseWrap.setStatus(1).setMsg("课程表格式错误");
        }

        String key = calendarService.shareCalendar(userID, calendar);
        if (key.isEmpty()) {
            responseWrap.setStatus(1).setMsg("发生错误, 请重试");
        } else {
//            String address = Utils.getIpAddress();
            String address = "39.106.212.166";
            responseWrap.setStatus(0).setMsg("分享成功!").setData(
                    new ShareModel(
                            key,
                            "http://" + address + ":10086" + "/calendar/getSharedCalendar?key=" + key,
                            "http://" + address + "/quick-access/" + key));
        }
        return responseWrap;
    }

    /**
     * 获取分享的课程表
     *
     * @param key 课程表的key
     * @return
     */
    @PassAuth
    @GetMapping("/getSharedCalendar")
    @ResponseBody
    public ResponseWrap<List<Course>> getSharedCalendar(String key) {

        ResponseWrap<List<Course>> responseWrap = new ResponseWrap<>();
        String calendar = calendarService.getSharedCalendar(key);
        if (calendar == null) {
            responseWrap.setStatus(1)
                    .setMsg("该课程表不存在");
        } else {
            responseWrap.setStatus(0)
                    .setMsg("获取课程成功")
                    .setData(new Gson().fromJson(calendar, new TypeToken<List<Course>>() {
                    }.getType()));
        }
        return responseWrap;
    }
}
