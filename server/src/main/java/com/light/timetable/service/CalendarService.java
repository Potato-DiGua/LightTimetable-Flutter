package com.light.timetable.service;


import org.jetbrains.annotations.NotNull;

import java.util.List;

public interface CalendarService {

    List<String> getTerms(int userId);

    String getCalendar(int userId, String term);

    int insertCalendar(int userId, String term, String calendar);

    int updateCalendar(int userId, List<String> term, List<String> calendar);

    @NotNull
    String shareCalendar(int userId, String calendar);

    String getSharedCalendar(String key);

}
