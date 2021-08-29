package com.light.timetable.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Mapper
public interface CalendarMapper {

    List<String> getTerms(@Param("userid") int userId);

    String getCalendar(@Param("userid") int userId, @Param("term") String term);

    int updateCalendar(Map<String, Object> map);

    int insertCalendar(Map<String, Object> map);

    int deleteCalendar(@Param("userid") int userId);

    int shareCalendar(HashMap<Object, Object> map);

    String getSharedCalendar(@Param("key") String key);

    int deleteSharedCalendar(@Param("userid") int userId);
}
