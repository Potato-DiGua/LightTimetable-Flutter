package com.light.timetable.service.colleges.impl;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;
import com.google.gson.reflect.TypeToken;
import com.light.timetable.entity.Course;
import com.light.timetable.service.colleges.College;
import com.light.timetable.utils.OkHttpUtils;
import com.light.timetable.utils.TextUtils;
import okhttp3.FormBody;
import okhttp3.Request;
import okhttp3.Response;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.stream.Collectors;


@Component
//@Scope(value = WebApplicationContext.SCOPE_SESSION, proxyMode = ScopedProxyMode.INTERFACES)
public class CSUCollege implements College {
    private final Logger logger = LoggerFactory.getLogger(getClass());
    public static final String NAME = "中南大学";

    private static final String BASE_URL = "http://csujwc.its.csu.edu.cn";
    // 加密
    private static final String SESS_URL = BASE_URL + "/Logon.do?method=logon&flag=sess";
    // 登陆
    private static final String LOGIN_URL = BASE_URL + "/Logon.do?method=logon";
    // 验证码
    private static final String RANDOM_CODE_URL = BASE_URL + "/verifycode.servlet";
    // 首页
    private static final String INDEX_URL = BASE_URL + "/jsxsd/framework/xsMain.jsp";
    // 打印课程表
    private static final String TIMETABLE_EXCEL_URL = BASE_URL + "/jsxsd/xskb/printXsgrkb.do?xnxq01id=%s&zc=";
    // 课程表json
    private static final String TIMETABLE_JSON_URL = BASE_URL + "/jsxsd/kbxx/getKbxx.do";
    // 我的课表
    private static final String TERMS_URL = BASE_URL + "/jsxsd/xskb/xskb_list.do?Ves632DSdyV=NEW_XSD_WDKB";

    private static final List<Course> EMPTY_COURSE_LIST = new ArrayList<>(0);

    @Override
    public String getCollegeName() {
        return NAME;
    }

    @Override
    public boolean login(String account, String pw, String RandomCode, String cookie) {
        String encoded = encode(account, pw, cookie);
        //String data = "view=0&useDogCode=&encoded=" + encoded + "&RANDOMCODE=" + RandomCode;

        FormBody form = new FormBody.Builder()
                .add("view", "0")
                .add("useDogCode", "")
                .add("encoded", encoded)
                .add("RANDOMCODE", RandomCode)
                .build();

        Request request = new Request.Builder()
                .url(LOGIN_URL)
                .addHeader("Cookie", cookie)
                .post(form)
                .build();
        try {
            String result = OkHttpUtils.downloadText(request);
            if (!TextUtils.isEmpty(result)) {
                Document doc = Jsoup.parse(result);
                return doc.title().equals("学生个人中心");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean isLogin(String cookie) {
        String result = OkHttpUtils.downloadText(createRequestWithCookie(INDEX_URL, cookie));
        if (!TextUtils.isEmpty(result)) {
            Document doc = Jsoup.parse(result);
            return doc.title().equals("学生个人中心");
        }
        return false;
    }

    private String encode(String account, String pw, String cookie) {
        String result = OkHttpUtils.downloadText(createRequestWithCookie(SESS_URL, cookie));

        if (TextUtils.isEmpty(result))
            return "";
        String[] strings = result.split("#");
        String scode = strings[0];
        String sxh = strings[1];
        String code = account + "%%%" + pw;
        StringBuilder encoded = new StringBuilder();
        for (int i = 0; i < code.length(); i++) {
            if (i < 50) {
                encoded.append(code.charAt(i));
                int value = Integer.parseInt(String.valueOf(sxh.charAt(i)));
                encoded.append(scode, 0, value);
                scode = scode.substring(value);
            } else {
                encoded.append(code.substring(i));
                i = code.length();
            }
        }
        return encoded.toString();
    }

    @Override
    public List<Course> getCourses(String term, String cookie) {
        FormBody form = new FormBody.Builder()
                .add("xnxq01id", term)
                .add("zc", "")
                .build();
        Request request = new Request.Builder()
                .url(TIMETABLE_JSON_URL)
                .addHeader("Cookie", cookie)
                .post(form)
                .build();
        String json = OkHttpUtils.downloadText(request);
        if (TextUtils.isEmpty(json)) {
            return EMPTY_COURSE_LIST;
        }
        List<TimetableItem> list = new Gson().fromJson(json, new TypeToken<List<TimetableItem>>() {
        }.getType());

        if (list == null) {
            return EMPTY_COURSE_LIST;
        }

        List<Course> courseList = new ArrayList<>(list.size());
        for (TimetableItem item : list) {
            if (item.lesson > 6) {
                continue;
            }
            for (String content : item.title.split("\n\n")) {
                //课程名称：大学英语（一）\n上课教师：黄莹讲师（高校）\n周次：5-19(周)\n星期：星期一\n节次：0102节\n上课地点：外语网络楼449\n
                String[] lines = content.split("\n");
                if (lines.length != 6) {
                    continue;
                }
                Course course = new Course();
                course.setName(getValue(lines[0]));
                course.setTeacher(getValue(lines[1]));
                course.setClassRoom(getValue(lines[5]));
                course.setClassStart((item.lesson - 1) * 2 + 1);
                String str = getValue(lines[4]);// 0102节
                str = str.substring(0, str.length() - 1);//0102
                try {
                    int min = Integer.parseInt(str.substring(0, 2));
                    int max = Integer.parseInt(str.substring(str.length() - 2));
                    course.setClassLength(max - min + 1);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                    course.setClassLength(2);
                }

                int week = item.DayOfWeek - 1;
                if (week == 0) {
                    week = 7;
                }
                course.setDayOfWeek(week);

                course.setWeekOfTerm(getWeekOfTermFromString(getValue(lines[2])));
                courseList.add(course);
            }
        }
        return courseList;
    }

    private String getValue(String line) {
        return line.substring(line.indexOf('：') + 1).trim();
    }

    private int getWeekOfTermFromString(String text) {
        //Log.d("excel",text);
        String[] s1 = text.trim().split("\\(");
        String[] s11 = s1[0].split(",");

        int weekOfTerm = 0;
        for (String s : s11) {
            if (s == null || s.isEmpty())
                continue;
            if (s.contains("-")) {
                int space = 2;
                if (text.contains("(周)")) {
                    space = 1;
                }
                String[] s2 = s.split("-");
                if (s2.length != 2) {
                    return 0;
                }
                int min = Integer.parseInt(s2[0]);
                int max = Integer.parseInt(s2[1]);
                if (text.contains("单") && min % 2 == 0) {
                    min++;
                } else if (text.contains("双") && min % 2 == 1) {
                    min++;
                }

                for (int n = min; n <= max; n += space) {
                    weekOfTerm += 1 << (25 - n);
                }
            } else {
                weekOfTerm += 1 << (25 - Integer.parseInt(s));
            }
        }
        return weekOfTerm;
    }

    /*        "jc": 1,
         "title": "课程名称：大学英语（一）\n上课教师：黄莹讲师（高校）\n周次：5-19(周)\n星期：星期一\n节次：0102节\n上课地点：外语网络楼449\n",
         "xq": 2,
         "kcmc": "大学英语（..."

         */
    private static class TimetableItem {
        /**
         * 第几节课
         * 值[1,7]
         * 7表示备注
         */
        @SerializedName("jc")
        private int lesson;
        /**
         * 星期几
         * 数值1-7
         * 1表示周日，依次类推
         */
        @SerializedName("xq")
        private int DayOfWeek;
        private String title;
        private String kcmc;
    }

    @Override
    public byte[] getRandomCodeImg(String cookie) {
        return OkHttpUtils.downloadRaw(createRequestWithCookie(RANDOM_CODE_URL, cookie));
    }

    @Override
    public List<String> getTermOptions(String cookie) {
        List<String> termOptions = new LinkedList<>();
        try {
            String result = OkHttpUtils.downloadText(createRequestWithCookie(TERMS_URL, cookie));
            if (!TextUtils.isEmpty(result)) {
                Document doc = Jsoup.parse(result);
                Element e = doc.select("#xnxq01id").first();
                Elements es = e.children();
                for (Element element : es) {
                    termOptions.add(element.text().trim());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return termOptions;
    }

    @Override
    public boolean getFollowRedirects() {
        return true;
    }

    @Override
    public int getRandomCodeMaxLength() {
        return 4;
    }

    @Override
    public String getCookie() {
        try (Response response = OkHttpUtils.getOkHttpClient()
                .newCall(OkHttpUtils.createRequest(BASE_URL))
                .execute()) {
            List<String> list = response.headers("Set-Cookie").stream().map(cookie -> {
                if (TextUtils.isEmpty(cookie)) {
                    return "";
                }
                int index = cookie.indexOf(';');
                return index != -1 ? cookie.substring(0, index) : cookie;
            }).collect(Collectors.toList());
            response.close();

            return String.join("; ", list);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "";
    }
}
