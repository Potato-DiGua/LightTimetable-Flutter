package com.light.timetable.service.colleges;

import com.light.timetable.utils.TextUtils;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
public class CollegeFactory implements ApplicationContextAware {
    private static final Map<String, College> collegeMap = new HashMap<>();
    private static List<String> collegeNameList;

    public static List<String> getCollegeNameList() {
        if (null == collegeNameList) {
            collegeNameList = new ArrayList<>(collegeMap.keySet());
            Collections.sort(collegeNameList);
        }
        return collegeNameList;
    }

    public static College createCollege(String collegeName) {
        return TextUtils.isEmpty(collegeName) ? null : collegeMap.get(collegeName);
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        applicationContext.getBeansOfType(College.class).values().forEach(college -> {
            collegeMap.put(college.getCollegeName(), college);
        });
    }
}
