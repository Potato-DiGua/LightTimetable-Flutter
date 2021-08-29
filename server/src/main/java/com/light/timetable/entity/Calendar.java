package com.light.timetable.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Calendar {
    private int uuid;

    private int userId;

    private String term;

    private String calendar;

}
