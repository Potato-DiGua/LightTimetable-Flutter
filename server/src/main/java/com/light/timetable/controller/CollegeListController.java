package com.light.timetable.controller;

import com.light.timetable.annotations.PassAuth;
import com.light.timetable.model.ResponseWrap;
import com.light.timetable.service.colleges.CollegeFactory;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;


/**
 * 学校列表
 */
@CrossOrigin
@RestController
public class CollegeListController {
    /**
     * 获取学校列表
     *
     * @return
     */
    @PassAuth
    @GetMapping("/collegeList")
    public ResponseWrap<List<String>> getCollegeList() {
        return new ResponseWrap<List<String>>()
                .setStatus(0)
                .setMsg("")
                .setData(CollegeFactory.getCollegeNameList());
    }
}
